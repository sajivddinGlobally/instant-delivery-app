// To parse this JSON data, do
//
//     final getDeliveryHistoryBodyModel = getDeliveryHistoryBodyModelFromJson(jsonString);

import 'dart:convert';

GetDeliveryHistoryBodyModel getDeliveryHistoryBodyModelFromJson(String str) => GetDeliveryHistoryBodyModel.fromJson(json.decode(str));

String getDeliveryHistoryBodyModelToJson(GetDeliveryHistoryBodyModel data) => json.encode(data.toJson());

class GetDeliveryHistoryBodyModel {
    int page;
    int limit;
    String key;

    GetDeliveryHistoryBodyModel({
        required this.page,
        required this.limit,
        required this.key,
    });

    factory GetDeliveryHistoryBodyModel.fromJson(Map<String, dynamic> json) => GetDeliveryHistoryBodyModel(
        page: json["page"],
        limit: json["limit"],
        key: json["key"],
    );

    Map<String, dynamic> toJson() => {
        "page": page,
        "limit": limit,
        "key": key,
    };
}
