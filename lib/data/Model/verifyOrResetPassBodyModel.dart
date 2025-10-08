// To parse this JSON data, do
//
//     final verifyOrResetPassBodyModel = verifyOrResetPassBodyModelFromJson(jsonString);

import 'dart:convert';

VerifyOrResetPassBodyModel verifyOrResetPassBodyModelFromJson(String str) => VerifyOrResetPassBodyModel.fromJson(json.decode(str));

String verifyOrResetPassBodyModelToJson(VerifyOrResetPassBodyModel data) => json.encode(data.toJson());

class VerifyOrResetPassBodyModel {
    String token;
    String otp;
    String newPassword;
    String confirmPassword;

    VerifyOrResetPassBodyModel({
        required this.token,
        required this.otp,
        required this.newPassword,
        required this.confirmPassword,
    });

    factory VerifyOrResetPassBodyModel.fromJson(Map<String, dynamic> json) => VerifyOrResetPassBodyModel(
        token: json["token"],
        otp: json["otp"],
        newPassword: json["newPassword"],
        confirmPassword: json["confirmPassword"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "otp": otp,
        "newPassword": newPassword,
        "confirmPassword": confirmPassword,
    };
}
