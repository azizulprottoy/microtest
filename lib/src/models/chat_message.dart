class Message {
  final String id;
  final int? senderId;
  final String senderType;
  final String type;
  final String? text;

  final String? name;
  final String? mimeType;
  final String? uri;
  final String? path;
  final int? size;
  final int? width;

  final DateTime createdAt;

  Message({
    required this.id,
    this.senderId,
    required this.senderType,
    required this.type,
    this.text,
    this.name,
    this.mimeType,
    this.uri,
    this.path,
    this.size,
    this.width,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> map) {
    final file = map['file'] as Map<String, dynamic>?;

    return Message(
      id: map['_id'] as String,
      senderId: map['senderId'] as int?,
      senderType: map['senderType'] as String,
      type: map['type'] as String,
      text: map['text']?.toString(),
      name: file?['path']?.toString().split('/').last,
      mimeType: file?['mimetype'],
      uri: file?['url'],
      path: file?['path'],
      size: file?['size'] ,
      width: null,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderType': senderType,
      'senderId': senderId,
      'type': type,
      'text': text,
      'name': name,
      'mimeType': mimeType,
      'uri': uri,
      'path': path,
      'size': size,
      'width': width,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ChatHistory {
  final List<Message> messages;

  ChatHistory({required this.messages});

  factory ChatHistory.fromJson(Map<String, dynamic> map) {

    return ChatHistory(
      messages: (map['data'] as List)
          .map((x) => Message.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
  }



  Map<String, dynamic> toJson() {
    return {
      'data': messages.map((x) => x.toJson()).toList(),
    };
  }
}





