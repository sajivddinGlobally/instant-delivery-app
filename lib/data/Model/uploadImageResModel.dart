// To parse this JSON data, do
//
//     final uploadImageReModel = uploadImageReModelFromJson(jsonString);

import 'dart:convert';

UploadImageReModel uploadImageReModelFromJson(String str) => UploadImageReModel.fromJson(json.decode(str));

String uploadImageReModelToJson(UploadImageReModel data) => json.encode(data.toJson());

class UploadImageReModel {
    String message;
    int code;
    bool error;
    Data data;

    UploadImageReModel({
        required this.message,
        required this.code,
        required this.error,
        required this.data,
    });

    factory UploadImageReModel.fromJson(Map<String, dynamic> json) => UploadImageReModel(
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
    String imageName;
    String imageUrl;

    Data({
        required this.imageName,
        required this.imageUrl,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        imageName: json["imageName"],
        imageUrl: json["imageUrl"],
    );

    Map<String, dynamic> toJson() => {
        "imageName": imageName,
        "imageUrl": imageUrl,
    };
}
