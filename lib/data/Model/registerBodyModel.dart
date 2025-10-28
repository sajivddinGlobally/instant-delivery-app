// To parse this JSON data, do
//
//     final registerBodyModel = registerBodyModelFromJson(jsonString);

import 'dart:convert';

RegisterBodyModel registerBodyModelFromJson(String str) =>
    RegisterBodyModel.fromJson(json.decode(str));

String registerBodyModelToJson(RegisterBodyModel data) =>
    json.encode(data.toJson());

class RegisterBodyModel {
  String firstName;
  String lastName;
  String email;
  String phone;
  String password;
  String deviceId;

  RegisterBodyModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.deviceId,
  });

  factory RegisterBodyModel.fromJson(Map<String, dynamic> json) =>
      RegisterBodyModel(
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
        deviceId: json["deviceId"],
      );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phone": phone,
    "password": password,
    "deviceId": deviceId,
  };
}
