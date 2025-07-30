import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:chat_module/chat_module.dart';
import '../../app_enums.dart';
import '../file_view/arguments/file_view_argument.dart';
import '../file_view/views/file_view_page.dart';
import '../utils/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../utils/services.dart';
class ChatController extends GetxController {

  final ChatRepository repo = Get.find();
  int _currentPage = 1;
  final int _limit = 20;
  bool _isFetching = false;
  bool _hasMore = true;

  final ScrollController scrollController = ScrollController();
  Rx<ChatArgs> args = ChatArgs().obs;
  final RxBool isCallPage = false.obs;
  RxList<Message> messages = <Message>[].obs;
  Timer? _typingTimer;
  Rx<ChatDoctor> doctor = ChatDoctor(id: 0, name: '').obs;
  Rxn<RealtimeChat> rtc = Rxn();
  RxBool showAttachmentTooltip = false.obs;
  RxBool isDoctorOnline = false.obs;
  RxBool isDoctorTyping = false.obs;
  RxInt count = 0.obs;
  RxBool isChatAvailable = false.obs;

  @override
  void onReady() async {
    super.onReady();
    scrollController.addListener(_onScroll);

    final currentArgs = Get.arguments as ChatArgs?;
    if (currentArgs == null || currentArgs.chatId == null || currentArgs.roomId == null) {
      Get.back();
      return;
    }

    args.value = currentArgs;
    rtc.value = RealtimeChat(args.value);

    await rtc.value!.init(
      onNewMessage: (message) async {
        addMessage(message);
        await _autoDownloadIfDoctor(message);
      },
      onDoctorPresenceChange: (presence) => isDoctorOnline.value = presence,
      onDoctorTyping: (isTyping) => isDoctorTyping.value = isTyping,
    );

    await _loadDoctor();
    await _loadMessages();
  }

  @override
  void onClose() {
    rtc.value?.close();
    super.onClose();
  }

  Future<void> _loadDoctor() async {
    try {
      final chatDoctor = await BookingInfo.provider.getDoctorDetails(args.value.doctorId!);
      doctor.value = chatDoctor!;
    } catch (e) {
      // _logger.e("Error loading doctor info", error: e);
    }
  }
  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100 &&
        !_isFetching && _hasMore) {
      _loadMessages(isInitial: false);
    }
  }


  Future<void> _loadMessages({bool isInitial = true}) async {
    if (_isFetching) return;
    _isFetching = true;

    if (isInitial) {
      _currentPage = 1;
      _hasMore = true;
      messages.clear();
    }

    final result = await repo.getAll(args.value, page: _currentPage, limit: _limit);

    result.fold(
          (l) => debugPrint("Error loading messages: ${l.message}"),
          (r) {
        final fetched = r.messages;

        for (final msg in fetched) {
          if (!messages.any((m) => m.id == msg.id)) {
            messages.add(msg);
          }
        }

        if (fetched.length < _limit) {
          _hasMore = false;
        } else {
          _currentPage++;
        }

        count.value = messages.length;
      },
    );

    _isFetching = false;
  }






  bool _isCurrentlyTyping = false;

  void handleTyping(String value) {
    if (value.trim().isEmpty) {
      stopTyping();
      return;
    }

    if (!_isCurrentlyTyping) {
      rtc.value?.sendTyping(true);
      _isCurrentlyTyping = true;
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 1), () {
      stopTyping();
    });
  }

  void stopTyping() {
    if (_isCurrentlyTyping) {
      rtc.value?.sendTyping(false);
      _isCurrentlyTyping = false;
    }
  }

  void addMessage(Message message) {
    messages.insert(0, message);
    count.value++;
  }

  void handleAttachmentPressed() {
    showAttachmentTooltip.value = !showAttachmentTooltip.value;
  }

  void closeAttachmentTooltip() {
    showAttachmentTooltip.value = false;
  }

  Future<void> handleFileSelection() async {
    final picked = await FileService.pickFile();
    if (picked == null) return;

    rtc.value?.sendFile(
      id: UniqueKey().toString(),
      path: picked.path,
      type: 'file',
      size: picked.size,
      mimeType: picked.mimeType,
      chatId: args.value.chatId!,
    );
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    Get.back();

    final image = await FileService.pickImage(source);
    if (image == null) return;

    rtc.value?.sendFile(
      id: UniqueKey().toString(),
      path: image.path,
      type: 'image',
      size: image.size,
      chatId: args.value.chatId!,
    );
  }

  void handleImageSelection() {
    showImagePickerDialog(_handleImageSelection);
  }

  void handleMessageTap(BuildContext context, Message message) async {
    final uri = message.uri ?? '';
    final name = message.name ?? 'File';
    final mimeType = message.mimeType ?? '';

    if (mimeType.startsWith('image/')) {
      await showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: InteractiveViewer(
            child: Image.network(uri, fit: BoxFit.contain),
          ),
        ),
      );
    } else if (mimeType.startsWith('video/')) {
      await showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: _VideoPlayerWidget(videoUrl: uri),
        ),
      );
    } else if (mimeType == 'application/pdf') {
      Get.to(() => FileViewPage(), arguments: FileViewArgument(
        fileUrl: uri,
        fileType: AppFileType.pdf,
      ));
    } else {
      if (!uri.startsWith('http')) {
        await OpenFilex.open(uri);
      } else {
        try {
          _updateFileDownloadingStatus(message, true);
          await FileService.download(uri, name);
        } finally {
          _updateFileDownloadingStatus(message, false);
        }
      }
    }
  }

  void _updateFileDownloadingStatus(Message message, bool isLoading) {
    final index = messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      final updated = Message(
        id: message.id,
        senderId: message.senderId,
        senderType: message.senderType,
        type: message.type,
        text: message.text,
        name: message.name,
        mimeType: message.mimeType,
        uri: message.uri,
        path: message.path,
        size: message.size,
        width: message.width,
        createdAt: message.createdAt,
      );

      messages[index] = updated;
      messages.refresh();
    }
  }

  void handleSendPressed(String text) {
    final msg = Message(
      id: UniqueKey().toString(),
      senderType: 'patient',
      type: 'text',
      text: text,
      createdAt: DateTime.now(),
    );

    final chatId = rtc.value?.args.chatId;
    final roomId = rtc.value?.args.roomId;

    if (chatId != null && roomId != null) {
      rtc.value?.sendText(chatId, text);
    }
  }

  Future<void> _autoDownloadIfDoctor(Message message) async {
    if (message.senderType != 'doctor') return;

    final uri = message.uri;
    final name = message.name ?? 'file';

    if (uri != null && uri.startsWith('http')) {
      try {
        _updateFileDownloadingStatus(message, true);
        final localPath = await FileService.download(uri, name);
        if (localPath != null) {
          final updated = Message(
            id: message.id,
            senderId: message.senderId,
            senderType: message.senderType,
            type: message.type,
            text: message.text,
            name: message.name,
            mimeType: message.mimeType,
            uri: localPath,
            path: localPath,
            size: message.size,
            createdAt: message.createdAt,
          );
          _replaceMessage(message, updated);
        }
      } catch (e) {
        debugPrint("Auto-download failed for $name: $e");
      } finally {
        _updateFileDownloadingStatus(message, false);
      }
    }
  }

  void _replaceMessage(Message oldMessage, Message newMessage) {
    final index = messages.indexWhere((m) => m.id == oldMessage.id);
    if (index != -1) {
      messages[index] = newMessage;
      messages.refresh();
    }
  }
}


class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      });

    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (!_isInitialized) {
      return const Center(
        child: SizedBox(
          height: 60,
          width: 60,
          child: Image(
            image: AssetImage('assets/loader.gif'),
            fit: BoxFit.contain,
          ),
        ),
      );
    }



    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          Positioned.fill(
            child: _ControlsOverlay(controller: _controller),
          ),
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            padding: const EdgeInsets.all(8.0),
          ),
        ],
      ),
    );

  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  const _ControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: Container(
        color: Colors.transparent,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                key: ValueKey(controller.value.isPlaying),
                duration: const Duration(milliseconds: 300),
                child: controller.value.isPlaying
                    ? const SizedBox.shrink()
                    : const Icon(Icons.play_arrow, size: 64.0, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

