// To parse this JSON data, do
//
//     final updateUserProfileBodyModel = updateUserProfileBodyModelFromJson(jsonString);

import 'dart:convert';

UpdateUserProfileBodyModel updateUserProfileBodyModelFromJson(String str) => UpdateUserProfileBodyModel.fromJson(json.decode(str));

String updateUserProfileBodyModelToJson(UpdateUserProfileBodyModel data) => json.encode(data.toJson());

class UpdateUserProfileBodyModel {
    String firstName;
    String lastName;
    String image;

    UpdateUserProfileBodyModel({
        required this.firstName,
        required this.lastName,
        required this.image,
    });

    factory UpdateUserProfileBodyModel.fromJson(Map<String, dynamic> json) => UpdateUserProfileBodyModel(
        firstName: json["firstName"],
        lastName: json["lastName"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "image": image,
    };
}
