// To parse this JSON data, do
//
//     final chatUser = chatUserFromJson(jsonString);

import 'dart:convert';

ChatUser chatUserFromJson(String str) => ChatUser.fromJson(json.decode(str));

String chatUserToJson(ChatUser data) => json.encode(data.toJson());

class ChatUser {
  String? image;
  String? about;
  String? name;
  String? createdAt;
  String? lastActive;
  bool? isOnline;
  String? id;
  String? email;
  String? pushToken;

  ChatUser({
    this.image,
    this.about,
    required this.name,
    this.createdAt,
    this.lastActive,
    this.isOnline,
    this.id,
    this.email,
    this.pushToken,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        image: json["image"] ?? '',
        about: json["about"] ?? '',
        name: json["name"] ?? '',
        createdAt: json["created_at"] ?? '',
        lastActive: json["last_active"] ?? '',
        isOnline: json["is_online"],
        id: json["id"] ?? '',
        email: json["email"] ?? '',
        pushToken: json["push_token"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "image": image,
        "about": about,
        "name": name,
        "created_at": createdAt,
        "last_active": lastActive,
        "is_online": isOnline,
        "id": id,
        "email": email,
        "push_token": pushToken,
      };

  toList() {}
}
