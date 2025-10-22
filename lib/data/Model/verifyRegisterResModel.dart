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
 Data? data;

  VerifyRegisterResModel({
    required this.message,
    required this.code,
    required this.error,
   this.data,
  });

  factory VerifyRegisterResModel.fromJson(Map<String, dynamic> json) =>
      VerifyRegisterResModel(
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
  String firstName;
  String lastName;
  String email;
  String phone;
  String id;

  Data({
    required this.token,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.id,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    token: json["token"] ?? "",
    firstName: json["firstName"] ?? "",
    lastName: json["lastName"] ?? "",
    email: json["email"] ?? "",
    phone: json["phone"] ?? "",
    id: json["id"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phone": phone,
    "id": id,
  };
}
