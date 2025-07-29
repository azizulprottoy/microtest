import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:chat_module/chat_module.dart';
import 'package:flutter/material.dart';

class RealtimeChat {
  static const String senderType = 'patient';
  late String? accessToken;
  late String? userId;
  late String userName;

  final ChatArgs args;

  final Logger _logger = Get.find();
  final ChatRepository repo = Get.find();

  Future<void> _fetchSessionData() async {
    final provider = Session.provider;

    accessToken = await provider.getAccessToken();

    userId = await provider.getUserId();
    final currentUser = await provider.getCurrentUser();

    userName = currentUser?.name ?? 'Unknown User';

    _logger.i("Session fetched: userId=$userId, userName=$userName, ");
  }
  final String chatUrl = 'https://dev-chat-v2.shukhee.com';

  late final io.Socket socket;

  RealtimeChat(this.args,) {
    socket = io.io(
      chatUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
  }

  Future<void> init({
    required void Function(Message) onNewMessage,
    required void Function(bool) onDoctorPresenceChange,
    required void Function(bool) onDoctorTyping,
  }) async {

    await _fetchSessionData(); // Important to fetch first

    socket.auth = {
      'token': accessToken,
    };
    socket.connect();

    socket.onConnect((_) {
      _logger.i("Socket connected");
      socket.emit('room:join', {
        'roomId': _getRoomId(),
      });

      Timer? _onlineHeartbeatTimer;
      _onlineHeartbeatTimer = Timer.periodic(
          const Duration(seconds: 2),
              (_) {
                socket.on('user:online', (data) {
                  if (data['userType'] == 'doctor' && data['userId'] == args.doctorId) {
                    _logger.i("user:online: $data");
                    onDoctorPresenceChange(true);
                  }
                });
              }
        );

    });

    socket.onDisconnect((_) {
      _logger.i("Socket disconnected");
    });

    socket.on('chat:message', (data) {
      _logger.i("chat:message: $data");
      onNewMessage(Message.fromJson(data));
    });

    socket.on('user:joined', (data) {
      _logger.i("user:joined: $data");
      if (data['userType'] == 'doctor' && data['userId'] == args.doctorId) {
        onDoctorPresenceChange(true);
        makeDoctorOnline();
      }
    });

    socket.on('user:left', (data) {
      _logger.i("user:left: $data");
      if (data['userType'] == 'doctor' && data['userId'] == args.doctorId) {
        onDoctorPresenceChange(false);
      }
    });

    socket.on('user:online', (data) {
      if (data['userType'] == 'doctor' && data['userId'] == args.doctorId) {
        _logger.i("user:online: $data");
        onDoctorPresenceChange(true);
        makeDoctorOnline();

      }
    });

    socket.on('user:offline', (data) {
      if (data['userType'] == 'doctor' && data['userId'] == args.doctorId) {
        _logger.i("user:offline: $data");
        onDoctorPresenceChange(false);
      }
    });

    socket.on('chat:typing', (data) {
      if (data['userType'] == 'doctor' &&
          data['userId'] == args.doctorId &&
          data['isTyping'] is bool) {
        _logger.i("chat:typing: $data");
        onDoctorTyping(data['isTyping']);
      }
    });
  }

  Future<void> sendText(String chatId, String text) async {
    if (text.trim().isEmpty) {
      _logger.w('Skipped sending empty message');
      return;
    }

    final msgData = {
      'chatId': _getChatId(),
      'roomId': _getRoomId(),
      'text': text,
    };

    final token = accessToken;

    // _logger.i('Preparing to send message: ${token} chatId=${_getChatId()}, roomId=${_getRoomId()}, text=$text');

    if (socket.connected) {
      socket.emit('chat:message', msgData);
      _logger.i('msg sent. ');

    } else {
      _logger.e('Cannot send message. Socket not connected.');
    }
  }


  Future<void> sendFile({
    required String chatId,
    required String path,
    required String type,
    required num size,
    String? mimeType,
    required String id,
  }) async {
    if (!socket.connected) {
      _logger.w('Socket not connected yet. Retrying after delay...');
      await Future.delayed(const Duration(milliseconds: 300));
      if (!socket.connected) {
        _logger.e('Still not connected. Aborting file send.');
        return;
      }
    }

    final mime = mimeType ?? lookupMimeType(path);

    if (mime == null) {
      _logger.e('Failed to determine MIME type for file: $path');
      return;
    }

    final data = FileUploadDto(
      file: File(path),
      type: type,
      mimeType: mime,
      size: size,
    );

    final res = (await repo.upload(data)).fold((l) {
      _logger.e("Upload failed: ${l.message}");
      return null;
    }, (r) => r);

    if (res == null || res.url.isEmpty || res.name.isEmpty) {
      _logger.e("Invalid upload response: $res");
      return;
    }

    final payload = {
      'chatId': _getChatId(),
      'roomId': _getRoomId(),
      'text': '',
      'file': {
        'url': res.url,
        'mimeType': res.mimeType,
        'fileName': res.name,
        'path': res.path ?? '',
        'size': res.size,
      }
    };

    _logger.i('Emitting chat:file: $payload');
    socket.emit('chat:file', payload);
  }
  void sendTyping(bool isTyping) {
    _logger.i('typing log');

    socket.emit('chat:typing', {
      'chatId': args.chatId,
      'roomId': args.roomId,
      'isTyping': isTyping,

    });
  }

  void makeDoctorOnline(){
    socket.emit('user:online',{
    'roomId': args.roomId,
    'userId': args.patientId,
    'userType': 'patient',
    });}
  void sendSeenStatus() {
    socket.emit('chat:seen', {
      'roomId': _getRoomId(),
    });
  }

  void leaveRoom() {
    socket.emit('room:leave', {
      'roomId': _getRoomId(),
    });
  }

  void close() {
    leaveRoom();
    socket.disconnect();
  }
  String _getChatId() {
    return args.chatId!;
  }

  String _getRoomId() {
    return args.roomId!;
  }

}
