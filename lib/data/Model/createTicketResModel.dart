import 'dart:convert';

CreateTicketResModel createTicketResModelFromJson(String str) =>
    CreateTicketResModel.fromJson(json.decode(str));

String createTicketResModelToJson(CreateTicketResModel data) =>
    json.encode(data.toJson());

class CreateTicketResModel {
  String message;
  int code;
  bool error;
  Data data;

  CreateTicketResModel({
    required this.message,
    required this.code,
    required this.error,
    required this.data,
  });

  factory CreateTicketResModel.fromJson(Map<String, dynamic> json) =>
      CreateTicketResModel(
        message: json["message"] ?? "",
        code: json["code"] ?? 0,
        error: json["error"] ?? true,
        data: json["data"] != null
            ? Data.fromJson(json["data"])
            : Data.empty(), // ✅ safely handles null
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data.toJson(),
  };
}

class Data {
  String? userId;
  String? subject;
  String? description;
  String? status;
  bool isDisable;
  bool isDeleted;
  String? id;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  Data({
    this.userId,
    this.subject,
    this.description,
    this.status,
    this.isDisable = false,
    this.isDeleted = false,
    this.id,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["userId"],
    subject: json["subject"],
    description: json["description"],
    status: json["status"],
    isDisable: json["isDisable"] ?? false,
    isDeleted: json["isDeleted"] ?? false,
    id: json["_id"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  factory Data.empty() => Data();

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "subject": subject,
    "description": description,
    "status": status,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "_id": id,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}
