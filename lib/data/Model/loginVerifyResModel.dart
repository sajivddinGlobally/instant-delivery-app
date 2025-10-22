// To parse this JSON data, do
//
//     final loginverifyResModel = loginverifyResModelFromJson(jsonString);

import 'dart:convert';

LoginverifyResModel loginverifyResModelFromJson(String str) => LoginverifyResModel.fromJson(json.decode(str));

String loginverifyResModelToJson(LoginverifyResModel data) => json.encode(data.toJson());

class LoginverifyResModel {
    String message;
    int code;
    bool error;
    Data? data;

    LoginverifyResModel({
        required this.message,
        required this.code,
        required this.error,
         this.data,
    });

    factory LoginverifyResModel.fromJson(Map<String, dynamic> json) => LoginverifyResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data:json["data"] != null ? Data.fromJson(json["data"]) : null,
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
        token: json["token"]?? "",
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
