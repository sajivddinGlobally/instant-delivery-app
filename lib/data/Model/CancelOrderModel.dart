// To parse this JSON data, do
//
//     final CancelOrderModel = CancelOrderModelFromJson(jsonString);

import 'dart:convert';

CancelOrderModel CancelOrderModelFromJson(String str) => CancelOrderModel.fromJson(json.decode(str));

String CancelOrderModelToJson(CancelOrderModel data) => json.encode(data.toJson());

class CancelOrderModel {
  String txId;
  String cancellationReason;

  CancelOrderModel({
    required this.txId,
    required this.cancellationReason,

  });

  factory CancelOrderModel.fromJson(Map<String, dynamic> json) =>
      CancelOrderModel(
        txId: json["txId"],
        cancellationReason: json["cancellationReason"],

  );

  Map<String, dynamic> toJson() => {
    "txId": txId,
    "cancellationReason": cancellationReason,

  };
}
