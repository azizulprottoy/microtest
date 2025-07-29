
import 'chat_doctor.dart';

class Conversation {
  final ChatDoctor doctor;
  final String lastMessage;
  final bool isSeen;
  final DateTime lastConversionDate;

  Conversation({
    required this.doctor,
    required this.lastMessage,
    required this.isSeen,
    required this.lastConversionDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'doctor': doctor.toJson(),
      'lastMessage': lastMessage,
      'isSeen': isSeen,
      'lastConversionDate': lastConversionDate.millisecondsSinceEpoch,
    };
  }

  factory Conversation.fromJson(Map<String, dynamic> map) {
    return Conversation(
      doctor: ChatDoctor.fromJson(map['doctor']),
      lastMessage: map['lastMessage'],
      isSeen: map['isSeen'],
      lastConversionDate: DateTime.fromMillisecondsSinceEpoch(map['lastConversionDate']),
    );
  }
}

