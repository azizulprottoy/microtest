
class ChatDoctor {
  final int id;
  final String name;
  final String? profilePic;

  ChatDoctor({
    required this.id,
    required this.name,
    this.profilePic,
  });

  factory ChatDoctor.fromJson(Map<String, dynamic> json) {
    return ChatDoctor(
      id: json['id'] as int,
      name: json['name'] as String,
      profilePic: json['profilePic'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profilePic': profilePic,
    };
  }

  @override
  String toString() => 'ChatDoctor(id: $id, name: $name, profilePic: $profilePic)';
}
