// To parse this JSON data, do
//
//     final registerResModel = registerResModelFromJson(jsonString);

import 'dart:convert';

RegisterResModel registerResModelFromJson(String str) => RegisterResModel.fromJson(json.decode(str));

String registerResModelToJson(RegisterResModel data) => json.encode(data.toJson());

class RegisterResModel {
    String message;
    int code;
    bool error;
    Data data;

    RegisterResModel({
        required this.message,
        required this.code,
        required this.error,
        required this.data,
    });

    factory RegisterResModel.fromJson(Map<String, dynamic> json) => RegisterResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": data.toJson(),
    };
}

class Data {
    String token;

    Data({
        required this.token,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
    };
}
