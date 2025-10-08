// To parse this JSON data, do
//
//     final forgotSentOtpBodyModel = forgotSentOtpBodyModelFromJson(jsonString);

import 'dart:convert';

ForgotSentOtpBodyModel forgotSentOtpBodyModelFromJson(String str) => ForgotSentOtpBodyModel.fromJson(json.decode(str));

String forgotSentOtpBodyModelToJson(ForgotSentOtpBodyModel data) => json.encode(data.toJson());

class ForgotSentOtpBodyModel {
    String loginType;

    ForgotSentOtpBodyModel({
        required this.loginType,
    });

    factory ForgotSentOtpBodyModel.fromJson(Map<String, dynamic> json) => ForgotSentOtpBodyModel(
        loginType: json["loginType"],
    );

    Map<String, dynamic> toJson() => {
        "loginType": loginType,
    };
}
