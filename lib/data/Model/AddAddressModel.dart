// To parse this JSON data, do
//
//     final AddAddressModel = AddAddressModelFromJson(jsonString);

import 'dart:convert';

AddAddressModel AddAddressModelFromJson(String str) => AddAddressModel.fromJson(json.decode(str));

String AddAddressModelToJson(AddAddressModel data) => json.encode(data.toJson());

class AddAddressModel {
  String name;
  String lat;
  String lon;
  String type;

  AddAddressModel({
    required this.name,
    required this.lat,
    required this.lon,
    required this.type,

  });

  factory AddAddressModel.fromJson(Map<String, dynamic> json) =>
      AddAddressModel(
        name: json["name"],
        lat: json["lat"],
        lon: json["lon"],
        type: json["type"],

      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "lat": lat,
    "lon": lon,
    "type": type,

  };
}


