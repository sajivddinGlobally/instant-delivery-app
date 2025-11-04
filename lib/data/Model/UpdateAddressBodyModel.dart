// To parse this JSON data, do
//
//     final UpdateAddressBodyModel = UpdateAddressBodyModelFromJson(jsonString);

import 'dart:convert';

UpdateAddressBodyModel UpdateAddressBodyModelFromJson(String str) => UpdateAddressBodyModel.fromJson(json.decode(str));

String UpdateAddressBodyModelToJson(UpdateAddressBodyModel data) => json.encode(data.toJson());

class UpdateAddressBodyModel {
  String id;
  String name;
  String lat;
  String lon;
  String type;

  UpdateAddressBodyModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
    required this.type,

  });

  factory UpdateAddressBodyModel.fromJson(Map<String, dynamic> json) =>
      UpdateAddressBodyModel(
        id: json["id"],
        name: json["name"],
        lat: json["lat"],
        lon: json["lon"],
        type: json["type"],

      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "lat": lat,
    "lon": lon,
    "type": type,

  };
}
