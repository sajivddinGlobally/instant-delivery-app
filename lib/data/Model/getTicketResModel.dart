// To parse this JSON data, do
//
//     final getTicketListResModel = getTicketListResModelFromJson(jsonString);

import 'dart:convert';

GetTicketListResModel getTicketListResModelFromJson(String str) => GetTicketListResModel.fromJson(json.decode(str));

String getTicketListResModelToJson(GetTicketListResModel data) => json.encode(data.toJson());

class GetTicketListResModel {
    String message;
    int code;
    bool error;
    Data data;

    GetTicketListResModel({
        required this.message,
        required this.code,
        required this.error,
        required this.data,
    });

    factory GetTicketListResModel.fromJson(Map<String, dynamic> json) => GetTicketListResModel(
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
    int total;
    List<ListElement> list;

    Data({
        required this.total,
        required this.list,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        total: json["total"],
        list: List<ListElement>.from(json["list"].map((x) => ListElement.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "total": total,
        "list": List<dynamic>.from(list.map((x) => x.toJson())),
    };
}

class ListElement {
    String id;
    String userId;
    String subject;
    String description;
    String status;
    bool isDisable;
    bool isDeleted;
    int date;
    int month;
    int year;
    int createdAt;
    int updatedAt;

    ListElement({
        required this.id,
        required this.userId,
        required this.subject,
        required this.description,
        required this.status,
        required this.isDisable,
        required this.isDeleted,
        required this.date,
        required this.month,
        required this.year,
        required this.createdAt,
        required this.updatedAt,
    });

    factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
        id: json["_id"],
        userId: json["userId"],
        subject: json["subject"],
        description: json["description"],
        status: json["status"],
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
        "userId": userId,
        "subject": subject,
        "description": description,
        "status": status,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
    };
}
