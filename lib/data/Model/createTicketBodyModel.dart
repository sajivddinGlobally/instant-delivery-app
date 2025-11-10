// To parse this JSON data, do
//
//     final createTicketBodyModel = createTicketBodyModelFromJson(jsonString);

import 'dart:convert';

CreateTicketBodyModel createTicketBodyModelFromJson(String str) => CreateTicketBodyModel.fromJson(json.decode(str));

String createTicketBodyModelToJson(CreateTicketBodyModel data) => json.encode(data.toJson());

class CreateTicketBodyModel {
    String subject;
    String description;

    CreateTicketBodyModel({
        required this.subject,
        required this.description,
    });

    factory CreateTicketBodyModel.fromJson(Map<String, dynamic> json) => CreateTicketBodyModel(
        subject: json["subject"],
        description: json["description"],
    );

    Map<String, dynamic> toJson() => {
        "subject": subject,
        "description": description,
    };
}
