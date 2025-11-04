// To parse this JSON data, do
//
//     final getAddressRsponseModel = getAddressRsponseModelFromJson(jsonString);

import 'dart:convert';

GetAddressRsponseModel getAddressRsponseModelFromJson(String str) => GetAddressRsponseModel.fromJson(json.decode(str));

String getAddressRsponseModelToJson(GetAddressRsponseModel data) => json.encode(data.toJson());

class GetAddressRsponseModel {
  String? message;
  int? code;
  bool? error;
  List<Datum>? data;

  GetAddressRsponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory GetAddressRsponseModel.fromJson(Map<String, dynamic> json) => GetAddressRsponseModel(
    message: json["message"],
    code: json["code"],
    error: json["error"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? userId;
  String? name;
  double? lat;
  double? lon;
  String? type;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  int? v;

  Datum({
    this.id,
    this.userId,
    this.name,
    this.lat,
    this.lon,
    this.type,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    userId: json["userId"],
    name: json["name"],
    lat: json["lat"]?.toDouble(),
    lon: json["lon"]?.toDouble(),
    type: json["type"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "name": name,
    "lat": lat,
    "lon": lon,
    "type": type,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}
