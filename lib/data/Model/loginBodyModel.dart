// To parse this JSON data, do
//
//     final loginBodyModel = loginBodyModelFromJson(jsonString);

import 'dart:convert';

LoginBodyModel loginBodyModelFromJson(String str) => LoginBodyModel.fromJson(json.decode(str));

String loginBodyModelToJson(LoginBodyModel data) => json.encode(data.toJson());

class LoginBodyModel {
    String loginType;
    String password;

    LoginBodyModel({
        required this.loginType,
        required this.password,
    });

    factory LoginBodyModel.fromJson(Map<String, dynamic> json) => LoginBodyModel(
        loginType: json["loginType"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "loginType": loginType,
        "password": password,
    };
}
