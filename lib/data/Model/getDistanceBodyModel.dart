// To parse this JSON data, do
//
//     final getDistanceBodyModel = getDistanceBodyModelFromJson(jsonString);

import 'dart:convert';

GetDistanceBodyModel getDistanceBodyModelFromJson(String str) => GetDistanceBodyModel.fromJson(json.decode(str));

String getDistanceBodyModelToJson(GetDistanceBodyModel data) => json.encode(data.toJson());

class GetDistanceBodyModel {
    String name;
    String mobNo;
    String origName;
    String destName;
    String picUpType;
    double origLat;
    double origLon;
    double destLat;
    double destLon;

    GetDistanceBodyModel({
        required this.name,
        required this.mobNo,
        required this.origName,
        required this.destName,
        required this.picUpType,
        required this.origLat,
        required this.origLon,
        required this.destLat,
        required this.destLon,
    });

    factory GetDistanceBodyModel.fromJson(Map<String, dynamic> json) => GetDistanceBodyModel(
        name: json["name"],
        mobNo: json["mobNo"],
        origName: json["origName"],
        destName: json["destName"],
        picUpType: json["picUpType"],
        origLat: json["origLat"]?.toDouble(),
        origLon: json["origLon"]?.toDouble(),
        destLat: json["destLat"]?.toDouble(),
        destLon: json["destLon"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "mobNo": mobNo,
        "origName": origName,
        "destName": destName,
        "picUpType": picUpType,
        "origLat": origLat,
        "origLon": origLon,
        "destLat": destLat,
        "destLon": destLon,
    };
}
