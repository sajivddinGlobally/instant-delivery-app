// To parse this JSON data, do
//
//     final getNearByDriverResponse = getNearByDriverResponseFromJson(jsonString);

import 'dart:convert';

GetNearByDriverResponse getNearByDriverResponseFromJson(String str) => GetNearByDriverResponse.fromJson(json.decode(str));

String getNearByDriverResponseToJson(GetNearByDriverResponse data) => json.encode(data.toJson());

class GetNearByDriverResponse {
  String? message;
  int? code;
  bool? error;
  List<Datum>? data;

  GetNearByDriverResponse({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory GetNearByDriverResponse.fromJson(Map<String, dynamic> json) => GetNearByDriverResponse(
    message: json["message"],
    code: json["code"],
    error: json["error"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? driverStatus;
  CurrentLocation? currentLocation;
  List<VehicleDetail>? vehicleDetails;
  double? distance;

  Datum({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.driverStatus,
    this.currentLocation,
    this.vehicleDetails,
    this.distance,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["_id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    phone: json["phone"],
    driverStatus: json["driverStatus"],
    currentLocation: json["currentLocation"] == null ? null : CurrentLocation.fromJson(json["currentLocation"]),
    vehicleDetails: json["vehicleDetails"] == null ? [] : List<VehicleDetail>.from(json["vehicleDetails"]!.map((x) => VehicleDetail.fromJson(x))),
    distance: json["distance"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phone": phone,
    "driverStatus": driverStatus,
    "currentLocation": currentLocation?.toJson(),
    "vehicleDetails": vehicleDetails == null ? [] : List<dynamic>.from(vehicleDetails!.map((x) => x.toJson())),
    "distance": distance,
  };
}

class CurrentLocation {
  String? type;
  List<double>? coordinates;

  CurrentLocation({
    this.type,
    this.coordinates,
  });

  factory CurrentLocation.fromJson(Map<String, dynamic> json) => CurrentLocation(
    type: json["type"],
    coordinates: json["coordinates"] == null ? [] : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => x)),
  };
}

class VehicleDetail {
  String? numberPlate;
  String? model;
  String? vehicleName;

  VehicleDetail({
    this.numberPlate,
    this.model,
    this.vehicleName,
  });

  factory VehicleDetail.fromJson(Map<String, dynamic> json) => VehicleDetail(
    numberPlate: json["numberPlate"],
    model: json["model"],
    vehicleName: json["vehicleName"],
  );

  Map<String, dynamic> toJson() => {
    "numberPlate": numberPlate,
    "model": model,
    "vehicleName": vehicleName,
  };
}
