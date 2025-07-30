class ChatUser {
  final int? id;
  final String? name;
  final String? avatarUrl;

  ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
  });
}

class ChatSpecialty {
  final int id;
  final String name;

  ChatSpecialty({required this.id, required this.name});

  factory ChatSpecialty.fromJson(Map<String, dynamic> json) {
    return ChatSpecialty(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

