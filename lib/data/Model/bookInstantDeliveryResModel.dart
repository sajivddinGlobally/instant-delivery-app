// To parse this JSON data, do
//
//     final bookInstantDeliveryResModel = bookInstantDeliveryResModelFromJson(jsonString);

import 'dart:convert';

BookInstantDeliveryResModel bookInstantDeliveryResModelFromJson(String str) => BookInstantDeliveryResModel.fromJson(json.decode(str));

String bookInstantDeliveryResModelToJson(BookInstantDeliveryResModel data) => json.encode(data.toJson());

class BookInstantDeliveryResModel {
    String message;
    int code;
    bool error;
    dynamic data;

    BookInstantDeliveryResModel({
        required this.message,
        required this.code,
        required this.error,
        required this.data,
    });

    factory BookInstantDeliveryResModel.fromJson(Map<String, dynamic> json) => BookInstantDeliveryResModel(
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
