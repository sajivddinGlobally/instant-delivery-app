// To parse this JSON data, do
//
//     final registerBodyModel = registerBodyModelFromJson(jsonString);

import 'dart:convert';

RegisterBodyModel registerBodyModelFromJson(String str) => RegisterBodyModel.fromJson(json.decode(str));

String registerBodyModelToJson(RegisterBodyModel data) => json.encode(data.toJson());

class RegisterBodyModel {
    String firstName;
    String lastName;
    String email;
    String phone;
    String password;

    RegisterBodyModel({
        required this.firstName,
        required this.lastName,
        required this.email,
        required this.phone,
        required this.password,
    });

    factory RegisterBodyModel.fromJson(Map<String, dynamic> json) => RegisterBodyModel(
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
    );

    Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "password": password,
    };
}
