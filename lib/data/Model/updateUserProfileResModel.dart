// To parse this JSON data, do
//
//     final updateUserProfileResModel = updateUserProfileResModelFromJson(jsonString);

import 'dart:convert';

UpdateUserProfileResModel updateUserProfileResModelFromJson(String str) => UpdateUserProfileResModel.fromJson(json.decode(str));

String updateUserProfileResModelToJson(UpdateUserProfileResModel data) => json.encode(data.toJson());

class UpdateUserProfileResModel {
    String message;
    int code;
    bool error;
    dynamic data;

    UpdateUserProfileResModel({
        required this.message,
        required this.code,
        required this.error,
        required this.data,
    });

    factory UpdateUserProfileResModel.fromJson(Map<String, dynamic> json) => UpdateUserProfileResModel(
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
