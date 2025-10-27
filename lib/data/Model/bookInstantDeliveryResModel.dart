// To parse this JSON data, do
//
//     final bookInstantDeliveryResModel = bookInstantDeliveryResModelFromJson(jsonString);

import 'dart:convert';

BookInstantDeliveryResModel bookInstantDeliveryResModelFromJson(String str) =>
    BookInstantDeliveryResModel.fromJson(json.decode(str));

String bookInstantDeliveryResModelToJson(BookInstantDeliveryResModel data) =>
    json.encode(data.toJson());

class BookInstantDeliveryResModel {
  String message;
  int code;
  bool error;
  Data data;

  BookInstantDeliveryResModel({
    required this.message,
    required this.code,
    required this.error,
    required this.data,
  });

  factory BookInstantDeliveryResModel.fromJson(Map<String, dynamic> json) =>
      BookInstantDeliveryResModel(
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
  String customer;
  dynamic deliveryBoy;
  dynamic pendingDriver;
  String vehicleTypeId;
  List<dynamic> rejectedDeliveryBoy;
  bool isCopanCode;
  int copanAmount;
  int coinAmount;
  int taxAmount;
  int userPayAmount;
  double distance;
  String mobNo;
  String picUpType;
  String name;
  Dropoff pickup;
  Dropoff dropoff;
  PackageDetails packageDetails;
  String status;
  dynamic cancellationReason;
  String paymentMethod;
  dynamic image;
  dynamic otp;
  bool isDisable;
  bool isDeleted;
  String id;
  String txId;
  int date;
  int month;
  int year;
  int createdAt;
  int updatedAt;

  Data({
    required this.customer,
    required this.deliveryBoy,
    required this.pendingDriver,
    required this.vehicleTypeId,
    required this.rejectedDeliveryBoy,
    required this.isCopanCode,
    required this.copanAmount,
    required this.coinAmount,
    required this.taxAmount,
    required this.userPayAmount,
    required this.distance,
    required this.mobNo,
    required this.picUpType,
    required this.name,
    required this.pickup,
    required this.dropoff,
    required this.packageDetails,
    required this.status,
    required this.cancellationReason,
    required this.paymentMethod,
    required this.image,
    required this.otp,
    required this.isDisable,
    required this.isDeleted,
    required this.id,
    required this.txId,
    required this.date,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    customer: json["customer"],
    deliveryBoy: json["deliveryBoy"],
    pendingDriver: json["pendingDriver"],
    vehicleTypeId: json["vehicleTypeId"],
    rejectedDeliveryBoy: List<dynamic>.from(
      json["rejectedDeliveryBoy"].map((x) => x),
    ),
    isCopanCode: json["isCopanCode"],
    copanAmount: json["copanAmount"],
    coinAmount: json["coinAmount"],
    taxAmount: json["taxAmount"],
    userPayAmount: json["userPayAmount"],
    distance: json["distance"]?.toDouble(),
    mobNo: json["mobNo"],
    picUpType: json["picUpType"],
    name: json["name"],
    pickup: Dropoff.fromJson(json["pickup"]),
    dropoff: Dropoff.fromJson(json["dropoff"]),
    packageDetails: PackageDetails.fromJson(json["packageDetails"]),
    status: json["status"],
    cancellationReason: json["cancellationReason"],
    paymentMethod: json["paymentMethod"],
    image: json["image"],
    otp: json["otp"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    id: json["_id"],
    txId: json["txId"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "customer": customer,
    "deliveryBoy": deliveryBoy,
    "pendingDriver": pendingDriver,
    "vehicleTypeId": vehicleTypeId,
    "rejectedDeliveryBoy": List<dynamic>.from(
      rejectedDeliveryBoy.map((x) => x),
    ),
    "isCopanCode": isCopanCode,
    "copanAmount": copanAmount,
    "coinAmount": coinAmount,
    "taxAmount": taxAmount,
    "userPayAmount": userPayAmount,
    "distance": distance,
    "mobNo": mobNo,
    "picUpType": picUpType,
    "name": name,
    "pickup": pickup.toJson(),
    "dropoff": dropoff.toJson(),
    "packageDetails": packageDetails.toJson(),
    "status": status,
    "cancellationReason": cancellationReason,
    "paymentMethod": paymentMethod,
    "image": image,
    "otp": otp,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "_id": id,
    "txId": txId,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Dropoff {
  String name;
  double lat;
  double long;

  Dropoff({required this.name, required this.lat, required this.long});

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
    name: json["name"],
    lat: json["lat"]?.toDouble(),
    long: json["long"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {"name": name, "lat": lat, "long": long};
}

class PackageDetails {
  bool fragile;

  PackageDetails({required this.fragile});

  factory PackageDetails.fromJson(Map<String, dynamic> json) =>
      PackageDetails(fragile: json["fragile"]);

  Map<String, dynamic> toJson() => {"fragile": fragile};
}
