// To parse this JSON data, do
//
//     final ticketReplyBodyModel = ticketReplyBodyModelFromJson(jsonString);

import 'dart:convert';

TicketReplyBodyModel ticketReplyBodyModelFromJson(String str) => TicketReplyBodyModel.fromJson(json.decode(str));

String ticketReplyBodyModelToJson(TicketReplyBodyModel data) => json.encode(data.toJson());

class TicketReplyBodyModel {
    String message;
    String ticketId;

    TicketReplyBodyModel({
        required this.message,
        required this.ticketId,
    });

    factory TicketReplyBodyModel.fromJson(Map<String, dynamic> json) => TicketReplyBodyModel(
        message: json["message"],
        ticketId: json["ticketId"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "ticketId": ticketId,
    };
}
