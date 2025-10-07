// To parse this JSON data, do
//
//     final loginverifyBodyModel = loginverifyBodyModelFromJson(jsonString);

import 'dart:convert';

LoginverifyBodyModel loginverifyBodyModelFromJson(String str) => LoginverifyBodyModel.fromJson(json.decode(str));

String loginverifyBodyModelToJson(LoginverifyBodyModel data) => json.encode(data.toJson());

class LoginverifyBodyModel {
    String token;
    String otp;

    LoginverifyBodyModel({
        required this.token,
        required this.otp,
    });

    factory LoginverifyBodyModel.fromJson(Map<String, dynamic> json) => LoginverifyBodyModel(
        token: json["token"],
        otp: json["otp"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "otp": otp,
    };
}
