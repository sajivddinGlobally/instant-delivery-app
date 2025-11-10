// To parse this JSON data, do
//
//     final ticketReplyResModel = ticketReplyResModelFromJson(jsonString);

import 'dart:convert';

TicketReplyResModel ticketReplyResModelFromJson(String str) => TicketReplyResModel.fromJson(json.decode(str));

String ticketReplyResModelToJson(TicketReplyResModel data) => json.encode(data.toJson());

class TicketReplyResModel {
    String message;
    int code;
    bool error;
    Data data;

    TicketReplyResModel({
        required this.message,
        required this.code,
        required this.error,
        required this.data,
    });

    factory TicketReplyResModel.fromJson(Map<String, dynamic> json) => TicketReplyResModel(
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
    String ticketId;
    String message;
    String repliedBy;
    String repliedByModel;
    String role;
    bool isDisable;
    bool isDeleted;
    String id;
    int date;
    int month;
    int year;
    int createdAt;
    int updatedAt;

    Data({
        required this.ticketId,
        required this.message,
        required this.repliedBy,
        required this.repliedByModel,
        required this.role,
        required this.isDisable,
        required this.isDeleted,
        required this.id,
        required this.date,
        required this.month,
        required this.year,
        required this.createdAt,
        required this.updatedAt,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        ticketId: json["ticketId"],
        message: json["message"],
        repliedBy: json["repliedBy"],
        repliedByModel: json["repliedByModel"],
        role: json["role"],
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        id: json["_id"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
    );

    Map<String, dynamic> toJson() => {
        "ticketId": ticketId,
        "message": message,
        "repliedBy": repliedBy,
        "repliedByModel": repliedByModel,
        "role": role,
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
