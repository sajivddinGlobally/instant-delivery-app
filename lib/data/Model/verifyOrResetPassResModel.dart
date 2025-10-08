// To parse this JSON data, do
//
//     final verifyOrResetPassResModel = verifyOrResetPassResModelFromJson(jsonString);

import 'dart:convert';

VerifyOrResetPassResModel verifyOrResetPassResModelFromJson(String str) => VerifyOrResetPassResModel.fromJson(json.decode(str));

String verifyOrResetPassResModelToJson(VerifyOrResetPassResModel data) => json.encode(data.toJson());

class VerifyOrResetPassResModel {
    String message;
    int code;
    bool error;
    dynamic data;

    VerifyOrResetPassResModel({
        required this.message,
        required this.code,
        required this.error,
        required this.data,
    });

    factory VerifyOrResetPassResModel.fromJson(Map<String, dynamic> json) => VerifyOrResetPassResModel(
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
