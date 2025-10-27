// To parse this JSON data, do:
//
//     final getDeliveryHistoryResModel = getDeliveryHistoryResModelFromJson(jsonString);

import 'dart:convert';

GetDeliveryHistoryResModel getDeliveryHistoryResModelFromJson(String str) =>
    GetDeliveryHistoryResModel.fromJson(json.decode(str));

String getDeliveryHistoryResModelToJson(GetDeliveryHistoryResModel data) =>
    json.encode(data.toJson());

class GetDeliveryHistoryResModel {
  String message;
  int code;
  bool error;
  Data data;

  GetDeliveryHistoryResModel({
    required this.message,
    required this.code,
    required this.error,
    required this.data,
  });

  factory GetDeliveryHistoryResModel.fromJson(Map<String, dynamic> json) =>
      GetDeliveryHistoryResModel(
        message: json["message"] ?? '',
        code: json["code"] ?? 0,
        error: json["error"] ?? false,
        data: json["data"] != null
            ? Data.fromJson(json["data"])
            : Data(totalCount: 0, deliveries: []),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data.toJson(),
  };
}

class Data {
  int totalCount;
  List<Delivery> deliveries;

  Data({required this.totalCount, required this.deliveries});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    totalCount: json["totalCount"] ?? 0,
    deliveries: json["deliveries"] == null
        ? []
        : List<Delivery>.from(
            json["deliveries"].map((x) => Delivery.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "totalCount": totalCount,
    "deliveries": List<dynamic>.from(deliveries.map((x) => x.toJson())),
  };
}

class Delivery {
  Dropoff pickup;
  Dropoff dropoff;
  PackageDetails packageDetails;
  String id;
  String? customer;
  String? deliveryBoy;
  dynamic pendingDriver;
  String? vehicleTypeId;
  List<dynamic> rejectedDeliveryBoy;
  bool isCopanCode;
  int copanAmount;
  int coinAmount;
  int taxAmount;
  int userPayAmount;
  double distance;
  String mobNo;
  String? picUpType;
  String? name; // ✅ Changed from enum to String
  String? status; // ✅ Changed from enum to String
  dynamic cancellationReason;
  String? paymentMethod; // ✅ Changed from enum to String
  dynamic image;
  bool isDisable;
  bool isDeleted;
  String txId;
  int date;
  int month;
  int year;
  int createdAt;
  int updatedAt;

  Delivery({
    required this.pickup,
    required this.dropoff,
    required this.packageDetails,
    required this.id,
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
    required this.status,
    required this.cancellationReason,
    required this.paymentMethod,
    required this.image,
    required this.isDisable,
    required this.isDeleted,
    required this.txId,
    required this.date,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
    pickup: Dropoff.fromJson(json["pickup"] ?? {}),
    dropoff: Dropoff.fromJson(json["dropoff"] ?? {}),
    packageDetails: PackageDetails.fromJson(json["packageDetails"] ?? {}),
    id: json["_id"] ?? '',
    customer: json["customer"]?.toString(),
    deliveryBoy: json["deliveryBoy"],
    pendingDriver: json["pendingDriver"],
    vehicleTypeId: json["vehicleTypeId"]?.toString(),
    rejectedDeliveryBoy: json["rejectedDeliveryBoy"] == null
        ? []
        : List<dynamic>.from(json["rejectedDeliveryBoy"].map((x) => x)),
    isCopanCode: json["isCopanCode"] ?? false,
    copanAmount: json["copanAmount"] ?? 0,
    coinAmount: json["coinAmount"] ?? 0,
    taxAmount: json["taxAmount"] ?? 0,
    userPayAmount: json["userPayAmount"] ?? 0,
    distance: (json["distance"] ?? 0).toDouble(),
    mobNo: json["mobNo"] ?? '',
    picUpType: json["picUpType"]?.toString(),
    name: json["name"]?.toString(),
    status: json["status"]?.toString(),
    cancellationReason: json["cancellationReason"],
    paymentMethod: json["paymentMethod"]?.toString(),
    image: json["image"],
    isDisable: json["isDisable"] ?? false,
    isDeleted: json["isDeleted"] ?? false,
    txId: json["txId"] ?? '',
    date: json["date"] ?? 0,
    month: json["month"] ?? 0,
    year: json["year"] ?? 0,
    createdAt: json["createdAt"] ?? 0,
    updatedAt: json["updatedAt"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "pickup": pickup.toJson(),
    "dropoff": dropoff.toJson(),
    "packageDetails": packageDetails.toJson(),
    "_id": id,
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
    "status": status,
    "cancellationReason": cancellationReason,
    "paymentMethod": paymentMethod,
    "image": image,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "txId": txId,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Dropoff {
  String? name;
  double lat;
  double long;

  Dropoff({this.name, required this.lat, required this.long});

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
    name: json["name"]?.toString(),
    lat: (json["lat"] ?? 0).toDouble(),
    long: (json["long"] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {"name": name, "lat": lat, "long": long};
}

class PackageDetails {
  bool fragile;

  PackageDetails({required this.fragile});

  factory PackageDetails.fromJson(Map<String, dynamic> json) =>
      PackageDetails(fragile: json["fragile"] ?? false);

  Map<String, dynamic> toJson() => {"fragile": fragile};
}
