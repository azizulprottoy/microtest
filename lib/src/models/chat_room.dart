
import 'chat_doctor.dart';

class Conversation {
  final ChatDoctor doctor;
  final String lastMessage;
  final bool isSeen;
  final DateTime lastConversionDate;
  final String roomId;
  final String chatId;
  final String conversationId;

  Conversation({
    required this.doctor,
    required this.lastMessage,
    required this.isSeen,
    required this.lastConversionDate,
    required this.roomId,
    required this.chatId,
    required this.conversationId,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'doctor': doctor,
      'lastMessage': lastMessage,
      'isSeen': isSeen,
      'lastConversionDate': lastConversionDate.millisecondsSinceEpoch,
      'roomId': roomId,
      'chatId': chatId,
      'conversationId': conversationId,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> map) {
    return Conversation(
      doctor: map['doctor'] ,
      lastMessage: map['lastMessage'] as String,
      isSeen: map['isSeen'] as bool,
      lastConversionDate:
      DateTime.fromMillisecondsSinceEpoch(map['lastConversionDate'] as int),
      roomId: map['roomId'] ?? '',
      chatId: map['chatId'] ?? '',
      conversationId: map['conversationId'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Conversation(doctor: $doctor, lastMessage: $lastMessage, isSeen: $isSeen, lastConversionDate: $lastConversionDate, roomId: $roomId, chatId: $chatId, conversationId: $conversationId)';
  }

  @override
  bool operator ==(covariant Conversation other) {
    return other.doctor == doctor &&
        other.lastMessage == lastMessage &&
        other.isSeen == isSeen &&
        other.lastConversionDate == lastConversionDate &&
        other.roomId == roomId &&
        other.chatId == chatId &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    return doctor.hashCode ^
    lastMessage.hashCode ^
    isSeen.hashCode ^
    lastConversionDate.hashCode ^
    roomId.hashCode ^
    chatId.hashCode ^
    conversationId.hashCode;
  }


}

