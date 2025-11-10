// To parse this JSON data, do
//
//     final NearByDriverModel = NearByDriverModelFromJson(jsonString);

import 'dart:convert';

NearByDriverModel NearByDriverModelFromJson(String str) => NearByDriverModel.fromJson(json.decode(str));

String NearByDriverModelToJson(NearByDriverModel data) => json.encode(data.toJson());

class NearByDriverModel {
  double lat;
  double long;
  String vehicleId;

  NearByDriverModel({

    required this.lat,
   required this.long,
    required this.vehicleId
  });

  factory NearByDriverModel.fromJson(Map<String, dynamic> json) =>
      NearByDriverModel(

        lat: json["lat"],
        long: json["long"],
        vehicleId: json["vehicleId"],

      );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "long": long,
    "vehicleId": vehicleId,


  };
}


