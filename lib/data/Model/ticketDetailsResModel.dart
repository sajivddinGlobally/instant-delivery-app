// // To parse this JSON data, do
// //
// //     final getTicketDetailsResModel = getTicketDetailsResModelFromJson(jsonString);

// import 'dart:convert';

// GetTicketDetailsResModel getTicketDetailsResModelFromJson(String str) => GetTicketDetailsResModel.fromJson(json.decode(str));

// String getTicketDetailsResModelToJson(GetTicketDetailsResModel data) => json.encode(data.toJson());

// class GetTicketDetailsResModel {
//     String message;
//     int code;
//     bool error;
//     Data data;

//     GetTicketDetailsResModel({
//         required this.message,
//         required this.code,
//         required this.error,
//         required this.data,
//     });

//     factory GetTicketDetailsResModel.fromJson(Map<String, dynamic> json) => GetTicketDetailsResModel(
//         message: json["message"],
//         code: json["code"],
//         error: json["error"],
//         data: Data.fromJson(json["data"]),
//     );

//     Map<String, dynamic> toJson() => {
//         "message": message,
//         "code": code,
//         "error": error,
//         "data": data.toJson(),
//     };
// }

// class Data {
//     Ticket ticket;
//     List<Reply> replies;

//     Data({
//         required this.ticket,
//         required this.replies,
//     });

//     factory Data.fromJson(Map<String, dynamic> json) => Data(
//         ticket: Ticket.fromJson(json["ticket"]),
//         replies: List<Reply>.from(json["replies"].map((x) => Reply.fromJson(x))),
//     );

//     Map<String, dynamic> toJson() => {
//         "ticket": ticket.toJson(),
//         "replies": List<dynamic>.from(replies.map((x) => x.toJson())),
//     };
// }

// class Reply {
//     String id;
//     String ticketId;
//     String message;
//     RepliedBy repliedBy;
//     String repliedByModel;
//     String role;
//     bool isDisable;
//     bool isDeleted;
//     int date;
//     int month;
//     int year;
//     int createdAt;
//     int updatedAt;

//     Reply({
//         required this.id,
//         required this.ticketId,
//         required this.message,
//         required this.repliedBy,
//         required this.repliedByModel,
//         required this.role,
//         required this.isDisable,
//         required this.isDeleted,
//         required this.date,
//         required this.month,
//         required this.year,
//         required this.createdAt,
//         required this.updatedAt,
//     });

//     factory Reply.fromJson(Map<String, dynamic> json) => Reply(
//         id: json["_id"],
//         ticketId: json["ticketId"],
//         message: json["message"],
//         repliedBy: RepliedBy.fromJson(json["repliedBy"]),
//         repliedByModel: json["repliedByModel"],
//         role: json["role"],
//         isDisable: json["isDisable"],
//         isDeleted: json["isDeleted"],
//         date: json["date"],
//         month: json["month"],
//         year: json["year"],
//         createdAt: json["createdAt"],
//         updatedAt: json["updatedAt"],
//     );

//     Map<String, dynamic> toJson() => {
//         "_id": id,
//         "ticketId": ticketId,
//         "message": message,
//         "repliedBy": repliedBy.toJson(),
//         "repliedByModel": repliedByModel,
//         "role": role,
//         "isDisable": isDisable,
//         "isDeleted": isDeleted,
//         "date": date,
//         "month": month,
//         "year": year,
//         "createdAt": createdAt,
//         "updatedAt": updatedAt,
//     };
// }

// class RepliedBy {
//     String id;
//     String userType;
//     String firstName;
//     String lastName;
//     String email;

//     RepliedBy({
//         required this.id,
//         required this.userType,
//         required this.firstName,
//         required this.lastName,
//         required this.email,
//     });

//     factory RepliedBy.fromJson(Map<String, dynamic> json) => RepliedBy(
//         id: json["_id"],
//         userType: json["userType"],
//         firstName: json["firstName"],
//         lastName: json["lastName"],
//         email: json["email"],
//     );

//     Map<String, dynamic> toJson() => {
//         "_id": id,
//         "userType": userType,
//         "firstName": firstName,
//         "lastName": lastName,
//         "email": email,
//     };
// }

// class Ticket {
//     String id;
//     String userId;
//     String subject;
//     String description;
//     String status;
//     bool isDisable;
//     bool isDeleted;
//     int date;
//     int month;
//     int year;
//     int createdAt;
//     int updatedAt;

//     Ticket({
//         required this.id,
//         required this.userId,
//         required this.subject,
//         required this.description,
//         required this.status,
//         required this.isDisable,
//         required this.isDeleted,
//         required this.date,
//         required this.month,
//         required this.year,
//         required this.createdAt,
//         required this.updatedAt,
//     });

//     factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
//         id: json["_id"],
//         userId: json["userId"],
//         subject: json["subject"],
//         description: json["description"],
//         status: json["status"],
//         isDisable: json["isDisable"],
//         isDeleted: json["isDeleted"],
//         date: json["date"],
//         month: json["month"],
//         year: json["year"],
//         createdAt: json["createdAt"],
//         updatedAt: json["updatedAt"],
//     );

//     Map<String, dynamic> toJson() => {
//         "_id": id,
//         "userId": userId,
//         "subject": subject,
//         "description": description,
//         "status": status,
//         "isDisable": isDisable,
//         "isDeleted": isDeleted,
//         "date": date,
//         "month": month,
//         "year": year,
//         "createdAt": createdAt,
//         "updatedAt": updatedAt,
//     };
// }

// To parse this JSON data, do
//
//     final getTicketDetailsResModel = getTicketDetailsResModelFromJson(jsonString);

import 'dart:convert';

GetTicketDetailsResModel getTicketDetailsResModelFromJson(String str) =>
    GetTicketDetailsResModel.fromJson(json.decode(str));

String getTicketDetailsResModelToJson(GetTicketDetailsResModel data) =>
    json.encode(data.toJson());

class GetTicketDetailsResModel {
  String message;
  int code;
  bool error;
  Data data;

  GetTicketDetailsResModel({
    required this.message,
    required this.code,
    required this.error,
    required this.data,
  });

  factory GetTicketDetailsResModel.fromJson(Map<String, dynamic> json) =>
      GetTicketDetailsResModel(
        message: json["message"] ?? "",
        code: json["code"] ?? 0,
        error: json["error"] ?? true,
        data: json["data"] != null
            ? Data.fromJson(json["data"])
            : Data.empty(), // ✅ Safe fallback
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data.toJson(),
  };
}

class Data {
  Ticket? ticket;
  List<Reply> replies;

  Data({this.ticket, required this.replies});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    ticket: json["ticket"] != null
        ? Ticket.fromJson(json["ticket"])
        : null, // ✅ Safe parsing
    replies: json["replies"] == null
        ? []
        : List<Reply>.from(json["replies"].map((x) => Reply.fromJson(x))),
  );

  factory Data.empty() => Data(ticket: null, replies: []); // ✅ Empty fallback

  Map<String, dynamic> toJson() => {
    "ticket": ticket?.toJson(),
    "replies": List<dynamic>.from(replies.map((x) => x.toJson())),
  };
}

class Reply {
  String id;
  String ticketId;
  String message;
  RepliedBy repliedBy;
  String repliedByModel;
  String role;
  bool isDisable;
  bool isDeleted;
  int date;
  int month;
  int year;
  int createdAt;
  int updatedAt;

  Reply({
    required this.id,
    required this.ticketId,
    required this.message,
    required this.repliedBy,
    required this.repliedByModel,
    required this.role,
    required this.isDisable,
    required this.isDeleted,
    required this.date,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
    id: json["_id"] ?? "",
    ticketId: json["ticketId"] ?? "",
    message: json["message"] ?? "",
    repliedBy: json["repliedBy"] != null
        ? RepliedBy.fromJson(json["repliedBy"])
        : RepliedBy.empty(), // ✅ Safe fallback
    repliedByModel: json["repliedByModel"] ?? "",
    role: json["role"] ?? "",
    isDisable: json["isDisable"] ?? false,
    isDeleted: json["isDeleted"] ?? false,
    date: json["date"] ?? 0,
    month: json["month"] ?? 0,
    year: json["year"] ?? 0,
    createdAt: json["createdAt"] ?? 0,
    updatedAt: json["updatedAt"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "ticketId": ticketId,
    "message": message,
    "repliedBy": repliedBy.toJson(),
    "repliedByModel": repliedByModel,
    "role": role,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class RepliedBy {
  String id;
  String userType;
  String firstName;
  String lastName;
  String email;

  RepliedBy({
    required this.id,
    required this.userType,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory RepliedBy.fromJson(Map<String, dynamic> json) => RepliedBy(
    id: json["_id"] ?? "",
    userType: json["userType"] ?? "",
    firstName: json["firstName"] ?? "",
    lastName: json["lastName"] ?? "",
    email: json["email"] ?? "",
  );

  factory RepliedBy.empty() =>
      RepliedBy(id: "", userType: "", firstName: "", lastName: "", email: "");

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userType": userType,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
  };
}

class Ticket {
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

  Ticket({
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

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
    id: json["_id"] ?? "",
    userId: json["userId"] ?? "",
    subject: json["subject"] ?? "",
    description: json["description"] ?? "",
    status: json["status"] ?? "",
    isDisable: json["isDisable"] ?? false,
    isDeleted: json["isDeleted"] ?? false,
    date: json["date"] ?? 0,
    month: json["month"] ?? 0,
    year: json["year"] ?? 0,
    createdAt: json["createdAt"] ?? 0,
    updatedAt: json["updatedAt"] ?? 0,
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
