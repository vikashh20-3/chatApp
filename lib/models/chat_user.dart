// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

ProductModel productModelFromJson(String str) =>
    ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
  String? image;
  String? about;
  String? name;
  String? createdAt;
  String? lastActive;
  bool? isOnline;
  String? id;
  String? email;
  String? pushToken;

  ProductModel({
    this.image,
    this.about,
    this.name,
    this.createdAt,
    this.lastActive,
    this.isOnline,
    this.id,
    this.email,
    this.pushToken,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        image: json["image"],
        about: json["about"],
        name: json["name"],
        createdAt: json["created_at"],
        lastActive: json["last_active"],
        isOnline: json["is_online"],
        id: json["id"],
        email: json["email"],
        pushToken: json["push_token"],
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
}
