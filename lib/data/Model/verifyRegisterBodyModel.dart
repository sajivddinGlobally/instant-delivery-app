// To parse this JSON data, do
//
//     final verifyRegisterBodyModel = verifyRegisterBodyModelFromJson(jsonString);

import 'dart:convert';

VerifyRegisterBodyModel verifyRegisterBodyModelFromJson(String str) => VerifyRegisterBodyModel.fromJson(json.decode(str));

String verifyRegisterBodyModelToJson(VerifyRegisterBodyModel data) => json.encode(data.toJson());

class VerifyRegisterBodyModel {
    String token;
    String otp;

    VerifyRegisterBodyModel({
        required this.token,
        required this.otp,
    });

    factory VerifyRegisterBodyModel.fromJson(Map<String, dynamic> json) => VerifyRegisterBodyModel(
        token: json["token"],
        otp: json["otp"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "otp": otp,
    };
}
