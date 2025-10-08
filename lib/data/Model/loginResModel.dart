// To parse this JSON data, do
//
//     final loginResModel = loginResModelFromJson(jsonString);

import 'dart:convert';

LoginResModel loginResModelFromJson(String str) =>
    LoginResModel.fromJson(json.decode(str));

String loginResModelToJson(LoginResModel data) => json.encode(data.toJson());

class LoginResModel {
  String message;
  int code;
  bool error;
  Data? data;

  LoginResModel({
    required this.message,
    required this.code,
    required this.error,
    this.data,
  });

  factory LoginResModel.fromJson(Map<String, dynamic> json) => LoginResModel(
    message: json["message"],
    code: json["code"],
    error: json["error"],
    data: json["data"] != null ? Data.fromJson(json["data"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data?.toJson(),
  };
}

class Data {
  String token;

  Data({required this.token});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(token: json["token"]);

  Map<String, dynamic> toJson() => {"token": token};
}
