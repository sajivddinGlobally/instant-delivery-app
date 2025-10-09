// To parse this JSON data, do
//
//     final getDistanceResModel = getDistanceResModelFromJson(jsonString);

import 'dart:convert';

GetDistanceResModel getDistanceResModelFromJson(String str) => GetDistanceResModel.fromJson(json.decode(str));

String getDistanceResModelToJson(GetDistanceResModel data) => json.encode(data.toJson());

class GetDistanceResModel {
    String message;
    int code;
    bool error;
    List<Datum> data;

    GetDistanceResModel({
        required this.message,
        required this.code,
        required this.error,
        required this.data,
    });

    factory GetDistanceResModel.fromJson(Map<String, dynamic> json) => GetDistanceResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    String vehicleTypeId;
    String vehicleType;
    String image;
    bool isDisable;
    String price;
    int capacity;
    double distance;
    String name;
    String mobNo;
    String origName;
    double origLat;
    double origLon;
    String destName;
    double destLat;
    double destLon;
    String picUpType;
    String gst;

    Datum({
        required this.vehicleTypeId,
        required this.vehicleType,
        required this.image,
        required this.isDisable,
        required this.price,
        required this.capacity,
        required this.distance,
        required this.name,
        required this.mobNo,
        required this.origName,
        required this.origLat,
        required this.origLon,
        required this.destName,
        required this.destLat,
        required this.destLon,
        required this.picUpType,
        required this.gst,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        vehicleTypeId: json["vehicleTypeId"],
        vehicleType: json["vehicleType"],
        image: json["image"],
        isDisable: json["isDisable"],
        price: json["price"],
        capacity: json["capacity"],
        distance: json["distance"]?.toDouble(),
        name: json["name"],
        mobNo: json["mobNo"],
        origName: json["origName"],
        origLat: json["origLat"]?.toDouble(),
        origLon: json["origLon"]?.toDouble(),
        destName: json["destName"],
        destLat: json["destLat"]?.toDouble(),
        destLon: json["destLon"]?.toDouble(),
        picUpType: json["picUpType"],
        gst: json["gst"],
    );

    Map<String, dynamic> toJson() => {
        "vehicleTypeId": vehicleTypeId,
        "vehicleType": vehicleType,
        "image": image,
        "isDisable": isDisable,
        "price": price,
        "capacity": capacity,
        "distance": distance,
        "name": name,
        "mobNo": mobNo,
        "origName": origName,
        "origLat": origLat,
        "origLon": origLon,
        "destName": destName,
        "destLat": destLat,
        "destLon": destLon,
        "picUpType": picUpType,
        "gst": gst,
    };
}
