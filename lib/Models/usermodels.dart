// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String UserModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? name;
  String? email;


  UserModel({
    required this.name,
    required this.email,

  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    name: json["name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
  };
}
