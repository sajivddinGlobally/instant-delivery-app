// To parse this JSON data, do
//
//     final driverCancelDeliveryResModel = driverCancelDeliveryResModelFromJson(jsonString);

import 'dart:convert';

DriverCancelDeliveryResModel driverCancelDeliveryResModelFromJson(String str) => DriverCancelDeliveryResModel.fromJson(json.decode(str));

String driverCancelDeliveryResModelToJson(DriverCancelDeliveryResModel data) => json.encode(data.toJson());

class DriverCancelDeliveryResModel {
  String message;
  int code;
  bool error;
  dynamic data;

  DriverCancelDeliveryResModel({
    required this.message,
    required this.code,
    required this.error,
    required this.data,
  });

  factory DriverCancelDeliveryResModel.fromJson(Map<String, dynamic> json) => DriverCancelDeliveryResModel(
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