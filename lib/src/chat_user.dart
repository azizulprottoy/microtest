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
