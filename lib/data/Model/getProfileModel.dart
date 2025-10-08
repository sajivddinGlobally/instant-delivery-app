// To parse this JSON data, do
//
//     final getProfileModel = getProfileModelFromJson(jsonString);

import 'dart:convert';

GetProfileModel getProfileModelFromJson(String str) =>
    GetProfileModel.fromJson(json.decode(str));

String getProfileModelToJson(GetProfileModel data) =>
    json.encode(data.toJson());

class GetProfileModel {
  String message;
  int code;
  bool error;
  Data? data;

  GetProfileModel({
    required this.message,
    required this.code,
    required this.error,
     this.data,
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) =>
      GetProfileModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
       data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data?.toJson(),
  };
}

class Data {
  String id;
  String userType;
  String firstName;
  String lastName;
  String email;
  String phone;
  String password;
  String driverStatus;
  int averageRating;
  dynamic image;
  bool isDisable;
  bool isDeleted;
  int date;
  int month;
  int year;
  int createdAt;
  int updatedAt;
  int v;
  dynamic deviceId;
  Wallet wallet;

  Data({
    required this.id,
    required this.userType,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    required this.driverStatus,
    required this.averageRating,
    required this.image,
    required this.isDisable,
    required this.isDeleted,
    required this.date,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.deviceId,
    required this.wallet,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    userType: json["userType"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    phone: json["phone"],
    password: json["password"],
    driverStatus: json["driverStatus"],
    averageRating: json["averageRating"],
    image: json["image"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
    deviceId: json["deviceId"],
    wallet: Wallet.fromJson(json["wallet"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userType": userType,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phone": phone,
    "password": password,
    "driverStatus": driverStatus,
    "averageRating": averageRating,
    "image": image,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
    "deviceId": deviceId,
    "wallet": wallet.toJson(),
  };
}

class Wallet {
  String id;
  String user;
  int balance;
  bool isDisable;
  bool isDeleted;
  int date;
  int month;
  int year;
  int createdAt;
  int updatedAt;

  Wallet({
    required this.id,
    required this.user,
    required this.balance,
    required this.isDisable,
    required this.isDeleted,
    required this.date,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
    id: json["_id"],
    user: json["user"],
    balance: json["balance"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user,
    "balance": balance,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}
