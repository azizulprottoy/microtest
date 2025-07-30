import '../../chat_module.dart';

class ChatDoctor {
  final int id;
  final String name;
  final String? profilePic;
  final ChatSpecialty? specialty;

  ChatDoctor({
    required this.id,
    required this.name,
    this.profilePic,
    this.specialty,
  });

  factory ChatDoctor.fromJson(Map<String, dynamic> json) {
    return ChatDoctor(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePic: json['profilePic'],
      specialty: json['specialty'] != null
          ? ChatSpecialty.fromJson(json['specialty'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profilePic': profilePic,
      'specialty': specialty?.toJson(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatDoctor &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              profilePic == other.profilePic &&
              specialty == other.specialty;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ profilePic.hashCode ^ specialty.hashCode;

  @override
  String toString() => 'ChatDoctor(id: $id, name: $name)';
}
