// To parse this JSON data, do
//
//     final verifyRegisterResModel = verifyRegisterResModelFromJson(jsonString);

import 'dart:convert';

VerifyRegisterResModel verifyRegisterResModelFromJson(String str) =>
    VerifyRegisterResModel.fromJson(json.decode(str));

String verifyRegisterResModelToJson(VerifyRegisterResModel data) =>
    json.encode(data.toJson());

class VerifyRegisterResModel {
  String message;
  int code;
  bool error;
  String data;

  VerifyRegisterResModel({
    required this.message,
    required this.code,
    required this.error,
    required this.data,
  });

  factory VerifyRegisterResModel.fromJson(Map<String, dynamic> json) =>
      VerifyRegisterResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"].toString(),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data,
  };
}
