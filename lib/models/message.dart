// To parse this JSON data, do
//
//     final message = messageFromJson(jsonString);

import 'dart:convert';

Message messageFromJson(String str) => Message.fromJson(json.decode(str));

String messageToJson(Message data) => json.encode(data.toJson());

class Message {
  String? toId;
  String? msg;
  String? read;
  Type? type;
  String? sent;
  String? fromId;

  Message({
    this.toId,
    this.msg,
    this.read,
    this.type,
    this.sent,
    this.fromId,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        toId: json["toId"].toString(),
        msg: json["msg"].toString(),
        read: json["read"].toString(),
        type:
            json["type"].toString() == Type.image.name ? Type.image : Type.text,
        sent: json["sent"].toString(),
        fromId: json["fromId"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "toId": toId,
        "msg": msg,
        "read": read,
        "type": type?.name,
        "sent": sent,
        "fromId": fromId,
      };
}

enum Type { text, image }
