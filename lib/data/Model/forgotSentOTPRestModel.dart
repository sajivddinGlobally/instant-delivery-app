// To parse this JSON data, do
//
//     final forgotSentOtpResModel = forgotSentOtpResModelFromJson(jsonString);

import 'dart:convert';

ForgotSentOtpResModel forgotSentOtpResModelFromJson(String str) => ForgotSentOtpResModel.fromJson(json.decode(str));

String forgotSentOtpResModelToJson(ForgotSentOtpResModel data) => json.encode(data.toJson());

class ForgotSentOtpResModel {
    String message;
    int code;
    bool error;
    Data data;

    ForgotSentOtpResModel({
        required this.message,
        required this.code,
        required this.error,
        required this.data,
    });

    factory ForgotSentOtpResModel.fromJson(Map<String, dynamic> json) => ForgotSentOtpResModel(
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
