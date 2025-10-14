// To parse this JSON data, do
//
//     final bookInstantDeliveryBodyModel = bookInstantDeliveryBodyModelFromJson(jsonString);

import 'dart:convert';

BookInstantDeliveryBodyModel bookInstantDeliveryBodyModelFromJson(String str) => BookInstantDeliveryBodyModel.fromJson(json.decode(str));

String bookInstantDeliveryBodyModelToJson(BookInstantDeliveryBodyModel data) => json.encode(data.toJson());

class BookInstantDeliveryBodyModel {
    String vehicleTypeId;
    int price;
    bool isCopanCode;
    String copanId;
    int copanAmount;
    int coinAmount;
    double taxAmount;
    int userPayAmount;
    double distance;
    String mobNo;
    String name;
    String origName;
    double origLat;
    double origLon;
    String destName;
    double destLat;
    double destLon;
    String picUpType;

    BookInstantDeliveryBodyModel({
        required this.vehicleTypeId,
        required this.price,
        required this.isCopanCode,
        required this.copanId,
        required this.copanAmount,
        required this.coinAmount,
        required this.taxAmount,
        required this.userPayAmount,
        required this.distance,
        required this.mobNo,
        required this.name,
        required this.origName,
        required this.origLat,
        required this.origLon,
        required this.destName,
        required this.destLat,
        required this.destLon,
        required this.picUpType,
    });

    factory BookInstantDeliveryBodyModel.fromJson(Map<String, dynamic> json) => BookInstantDeliveryBodyModel(
        vehicleTypeId: json["vehicleTypeId"],
        price: json["price"],
        isCopanCode: json["isCopanCode"],
        copanId: json["copanId"],
        copanAmount: json["copanAmount"],
        coinAmount: json["coinAmount"],
        taxAmount: json["taxAmount"]?.toDouble(),
        userPayAmount: json["userPayAmount"],
        distance: json["distance"]?.toDouble(),
        mobNo: json["mobNo"],
        name: json["name"],
        origName: json["origName"],
        origLat: json["origLat"]?.toDouble(),
        origLon: json["origLon"]?.toDouble(),
        destName: json["destName"],
        destLat: json["destLat"]?.toDouble(),
        destLon: json["destLon"]?.toDouble(),
        picUpType: json["picUpType"],
    );

    Map<String, dynamic> toJson() => {
        "vehicleTypeId": vehicleTypeId,
        "price": price,
        "isCopanCode": isCopanCode,
        "copanId": copanId,
        "copanAmount": copanAmount,
        "coinAmount": coinAmount,
        "taxAmount": taxAmount,
        "userPayAmount": userPayAmount,
        "distance": distance,
        "mobNo": mobNo,
        "name": name,
        "origName": origName,
        "origLat": origLat,
        "origLon": origLon,
        "destName": destName,
        "destLat": destLat,
        "destLon": destLon,
        "picUpType": picUpType,
    };
}
