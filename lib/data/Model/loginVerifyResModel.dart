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
    dynamic data;

    LoginverifyResModel({
        required this.message,
        required this.code,
        required this.error,
        required this.data,
    });

    factory LoginverifyResModel.fromJson(Map<String, dynamic> json) => LoginverifyResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": data,
    };
}
