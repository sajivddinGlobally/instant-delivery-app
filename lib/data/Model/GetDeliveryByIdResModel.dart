/*
// To parse this JSON data, do
//
//     final getDeliveryByIdResModel = getDeliveryByIdResModelFromJson(jsonString);

import 'dart:convert';

GetDeliveryByIdResModel getDeliveryByIdResModelFromJson(String str) => GetDeliveryByIdResModel.fromJson(json.decode(str));

String getDeliveryByIdResModelToJson(GetDeliveryByIdResModel data) => json.encode(data.toJson());

class GetDeliveryByIdResModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  GetDeliveryByIdResModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory GetDeliveryByIdResModel.fromJson(Map<String, dynamic> json) => GetDeliveryByIdResModel(
    message: json["message"],
    code: json["code"],
    error: json["error"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data?.toJson(),
  };
}

class Data {
  Dropoff? pickup;
  Dropoff? dropoff;
  PackageDetails? packageDetails;
  String? id;
  String? customer;
  DeliveryBoy? deliveryBoy;
  VehicleTypeId? vehicleTypeId;
  String? status;
  String? paymentMethod;
  String? txId;
  int? createdAt;
  int? userPayAmount;
  String? otp;

  Data({
    this.pickup,
    this.dropoff,
    this.packageDetails,
    this.id,
    this.customer,
    this.deliveryBoy,
    this.vehicleTypeId,
    this.status,
    this.paymentMethod,
    this.txId,
    this.createdAt,
    this.userPayAmount,
    this.otp,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pickup: json["pickup"] == null ? null : Dropoff.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null ? null : Dropoff.fromJson(json["dropoff"]),
    packageDetails: json["packageDetails"] == null ? null : PackageDetails.fromJson(json["packageDetails"]),
    id: json["_id"],
    customer: json["customer"],
    deliveryBoy: json["deliveryBoy"] == null ? null : DeliveryBoy.fromJson(json["deliveryBoy"]),
    vehicleTypeId: json["vehicleTypeId"] == null ? null : VehicleTypeId.fromJson(json["vehicleTypeId"]),
    status: json["status"],
    paymentMethod: json["paymentMethod"],
    txId: json["txId"],
    createdAt: json["createdAt"],
    userPayAmount: json["userPayAmount"],
    otp: json["otp"],
  );

  Map<String, dynamic> toJson() => {
    "pickup": pickup?.toJson(),
    "dropoff": dropoff?.toJson(),
    "packageDetails": packageDetails?.toJson(),
    "_id": id,
    "customer": customer,
    "deliveryBoy": deliveryBoy?.toJson(),
    "vehicleTypeId": vehicleTypeId?.toJson(),
    "status": status,
    "paymentMethod": paymentMethod,
    "txId": txId,
    "createdAt": createdAt,
    "userPayAmount": userPayAmount,
    "otp": otp,
  };
}

class DeliveryBoy {
  CurrentLocation? currentLocation;
  String? id;
  String? userType;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? password;
  String? cityId;
  String? driverStatus;
  String? status;
  String? deviceId;
  int? completedOrderCount;
  int? averageRating;
  String? referralCode;
  String? refByCode;
  dynamic image;
  String? socketId;
  bool? isDisable;
  bool? isDeleted;
  List<VehicleDetail>? vehicleDetails;
  List<dynamic>? rating;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  DateTime? lastLocationUpdate;

  DeliveryBoy({
    this.currentLocation,
    this.id,
    this.userType,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.password,
    this.cityId,
    this.driverStatus,
    this.status,
    this.deviceId,
    this.completedOrderCount,
    this.averageRating,
    this.referralCode,
    this.refByCode,
    this.image,
    this.socketId,
    this.isDisable,
    this.isDeleted,
    this.vehicleDetails,
    this.rating,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.lastLocationUpdate,
  });

  factory DeliveryBoy.fromJson(Map<String, dynamic> json) => DeliveryBoy(
    currentLocation: json["currentLocation"] == null ? null : CurrentLocation.fromJson(json["currentLocation"]),
    id: json["_id"],
    userType: json["userType"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    phone: json["phone"],
    password: json["password"],
    cityId: json["cityId"],
    driverStatus: json["driverStatus"],
    status: json["status"],
    deviceId: json["deviceId"],
    completedOrderCount: json["completedOrderCount"],
    averageRating: json["averageRating"],
    referralCode: json["referralCode"],
    refByCode: json["refByCode"],
    image: json["image"],
    socketId: json["socketId"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    vehicleDetails: json["vehicleDetails"] == null ? [] : List<VehicleDetail>.from(json["vehicleDetails"]!.map((x) => VehicleDetail.fromJson(x))),
    rating: json["rating"] == null ? [] : List<dynamic>.from(json["rating"]!.map((x) => x)),
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    lastLocationUpdate: json["lastLocationUpdate"] == null ? null : DateTime.parse(json["lastLocationUpdate"]),
  );

  Map<String, dynamic> toJson() => {
    "currentLocation": currentLocation?.toJson(),
    "_id": id,
    "userType": userType,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phone": phone,
    "password": password,
    "cityId": cityId,
    "driverStatus": driverStatus,
    "status": status,
    "deviceId": deviceId,
    "completedOrderCount": completedOrderCount,
    "averageRating": averageRating,
    "referralCode": referralCode,
    "refByCode": refByCode,
    "image": image,
    "socketId": socketId,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "vehicleDetails": vehicleDetails == null ? [] : List<dynamic>.from(vehicleDetails!.map((x) => x.toJson())),
    "rating": rating == null ? [] : List<dynamic>.from(rating!.map((x) => x)),
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "lastLocationUpdate": lastLocationUpdate?.toIso8601String(),
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
  String? vehicle;
  String? numberPlate;
  String? model;
  int? capacityWeight;
  int? capacityVolume;
  bool? isActive;
  String? status;
  String? id;

  VehicleDetail({
    this.vehicle,
    this.numberPlate,
    this.model,
    this.capacityWeight,
    this.capacityVolume,
    this.isActive,
    this.status,
    this.id,
  });

  factory VehicleDetail.fromJson(Map<String, dynamic> json) => VehicleDetail(
    vehicle: json["vehicle"],
    numberPlate: json["numberPlate"],
    model: json["model"],
    capacityWeight: json["capacityWeight"],
    capacityVolume: json["capacityVolume"],
    isActive: json["isActive"],
    status: json["status"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "vehicle": vehicle,
    "numberPlate": numberPlate,
    "model": model,
    "capacityWeight": capacityWeight,
    "capacityVolume": capacityVolume,
    "isActive": isActive,
    "status": status,
    "_id": id,
  };
}

class Dropoff {
  String? name;
  double? lat;
  double? long;

  Dropoff({
    this.name,
    this.lat,
    this.long,
  });

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
    name: json["name"],
    lat: json["lat"]?.toDouble(),
    long: json["long"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "lat": lat,
    "long": long,
  };
}

class PackageDetails {
  bool? fragile;

  PackageDetails({
    this.fragile,
  });

  factory PackageDetails.fromJson(Map<String, dynamic> json) => PackageDetails(
    fragile: json["fragile"],
  );

  Map<String, dynamic> toJson() => {
    "fragile": fragile,
  };
}

class VehicleTypeId {
  String? id;
  String? name;
  int? capacity;
  int? baseFare;
  int? perKmRate;
  int? perMinuteRate;
  int? maxDeliveryDistance;
  String? image;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  VehicleTypeId({
    this.id,
    this.name,
    this.capacity,
    this.baseFare,
    this.perKmRate,
    this.perMinuteRate,
    this.maxDeliveryDistance,
    this.image,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleTypeId.fromJson(Map<String, dynamic> json) => VehicleTypeId(
    id: json["_id"],
    name: json["name"],
    capacity: json["capacity"],
    baseFare: json["baseFare"],
    perKmRate: json["perKmRate"],
    perMinuteRate: json["perMinuteRate"],
    maxDeliveryDistance: json["maxDeliveryDistance"],
    image: json["image"],
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
    "name": name,
    "capacity": capacity,
    "baseFare": baseFare,
    "perKmRate": perKmRate,
    "perMinuteRate": perMinuteRate,
    "maxDeliveryDistance": maxDeliveryDistance,
    "image": image,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}
*/


// To parse this JSON data, do
//
//     final getDeliveryByIdResModel = getDeliveryByIdResModelFromJson(jsonString);

import 'dart:convert';

GetDeliveryByIdResModel getDeliveryByIdResModelFromJson(String str) => GetDeliveryByIdResModel.fromJson(json.decode(str));

String getDeliveryByIdResModelToJson(GetDeliveryByIdResModel data) => json.encode(data.toJson());

class GetDeliveryByIdResModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  GetDeliveryByIdResModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory GetDeliveryByIdResModel.fromJson(Map<String, dynamic> json) => GetDeliveryByIdResModel(
    message: json["message"],
    code: json["code"],
    error: json["error"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data?.toJson(),
  };
}

class Data {
  Dropoff? pickup;
  Dropoff? dropoff;
  PackageDetails? packageDetails;
  String? id;
  String? customer;
  DeliveryBoy? deliveryBoy;
  VehicleTypeId? vehicleTypeId;
  int? userPayAmount;
  String? status;
  String? paymentMethod;
  String? otp;
  String? txId;
  int? createdAt;

  Data({
    this.pickup,
    this.dropoff,
    this.packageDetails,
    this.id,
    this.customer,
    this.deliveryBoy,
    this.vehicleTypeId,
    this.userPayAmount,
    this.status,
    this.paymentMethod,
    this.otp,
    this.txId,
    this.createdAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pickup: json["pickup"] == null ? null : Dropoff.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null ? null : Dropoff.fromJson(json["dropoff"]),
    packageDetails: json["packageDetails"] == null ? null : PackageDetails.fromJson(json["packageDetails"]),
    id: json["_id"],
    customer: json["customer"],
    deliveryBoy: json["deliveryBoy"] == null ? null : DeliveryBoy.fromJson(json["deliveryBoy"]),
    vehicleTypeId: json["vehicleTypeId"] == null ? null : VehicleTypeId.fromJson(json["vehicleTypeId"]),
    userPayAmount: json["userPayAmount"],
    status: json["status"],
    paymentMethod: json["paymentMethod"],
    otp: json["otp"],
    txId: json["txId"],
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "pickup": pickup?.toJson(),
    "dropoff": dropoff?.toJson(),
    "packageDetails": packageDetails?.toJson(),
    "_id": id,
    "customer": customer,
    "deliveryBoy": deliveryBoy?.toJson(),
    "vehicleTypeId": vehicleTypeId?.toJson(),
    "userPayAmount": userPayAmount,
    "status": status,
    "paymentMethod": paymentMethod,
    "otp": otp,
    "txId": txId,
    "createdAt": createdAt,
  };
}

class DeliveryBoy {
  CurrentLocation? currentLocation;
  String? id;
  String? userType;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? password;
  String? cityId;
  String? driverStatus;
  String? status;
  String? deviceId;
  int? completedOrderCount;
  int? averageRating;
  String? referralCode;
  String? refByCode;
  dynamic socketId;
  bool? isDisable;
  bool? isDeleted;
  List<VehicleDetail>? vehicleDetails;
  List<dynamic>? rating;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  DateTime? lastLocationUpdate;
  String? image;

  DeliveryBoy({
    this.currentLocation,
    this.id,
    this.userType,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.password,
    this.cityId,
    this.driverStatus,
    this.status,
    this.deviceId,
    this.completedOrderCount,
    this.averageRating,
    this.referralCode,
    this.refByCode,
    this.socketId,
    this.isDisable,
    this.isDeleted,
    this.vehicleDetails,
    this.rating,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.lastLocationUpdate,
    this.image,
  });

  factory DeliveryBoy.fromJson(Map<String, dynamic> json) => DeliveryBoy(
    currentLocation: json["currentLocation"] == null ? null : CurrentLocation.fromJson(json["currentLocation"]),
    id: json["_id"],
    userType: json["userType"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
    phone: json["phone"],
    password: json["password"],
    cityId: json["cityId"],
    driverStatus: json["driverStatus"],
    status: json["status"],
    deviceId: json["deviceId"],
    completedOrderCount: json["completedOrderCount"],
    averageRating: json["averageRating"],
    referralCode: json["referralCode"],
    refByCode: json["refByCode"],
    socketId: json["socketId"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    vehicleDetails: json["vehicleDetails"] == null ? [] : List<VehicleDetail>.from(json["vehicleDetails"]!.map((x) => VehicleDetail.fromJson(x))),
    rating: json["rating"] == null ? [] : List<dynamic>.from(json["rating"]!.map((x) => x)),
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    lastLocationUpdate: json["lastLocationUpdate"] == null ? null : DateTime.parse(json["lastLocationUpdate"]),
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "currentLocation": currentLocation?.toJson(),
    "_id": id,
    "userType": userType,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phone": phone,
    "password": password,
    "cityId": cityId,
    "driverStatus": driverStatus,
    "status": status,
    "deviceId": deviceId,
    "completedOrderCount": completedOrderCount,
    "averageRating": averageRating,
    "referralCode": referralCode,
    "refByCode": refByCode,
    "socketId": socketId,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "vehicleDetails": vehicleDetails == null ? [] : List<dynamic>.from(vehicleDetails!.map((x) => x.toJson())),
    "rating": rating == null ? [] : List<dynamic>.from(rating!.map((x) => x)),
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "lastLocationUpdate": lastLocationUpdate?.toIso8601String(),
    "image": image,
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
  String? vehicle;
  String? numberPlate;
  String? model;
  int? capacityWeight;
  int? capacityVolume;
  bool? isActive;
  String? status;
  String? id;

  VehicleDetail({
    this.vehicle,
    this.numberPlate,
    this.model,
    this.capacityWeight,
    this.capacityVolume,
    this.isActive,
    this.status,
    this.id,
  });

  factory VehicleDetail.fromJson(Map<String, dynamic> json) => VehicleDetail(
    vehicle: json["vehicle"],
    numberPlate: json["numberPlate"],
    model: json["model"],
    capacityWeight: json["capacityWeight"],
    capacityVolume: json["capacityVolume"],
    isActive: json["isActive"],
    status: json["status"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "vehicle": vehicle,
    "numberPlate": numberPlate,
    "model": model,
    "capacityWeight": capacityWeight,
    "capacityVolume": capacityVolume,
    "isActive": isActive,
    "status": status,
    "_id": id,
  };
}

class Dropoff {
  String? name;
  double? lat;
  double? long;

  Dropoff({
    this.name,
    this.lat,
    this.long,
  });

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
    name: json["name"],
    lat: json["lat"]?.toDouble(),
    long: json["long"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "lat": lat,
    "long": long,
  };
}

class PackageDetails {
  bool? fragile;

  PackageDetails({
    this.fragile,
  });

  factory PackageDetails.fromJson(Map<String, dynamic> json) => PackageDetails(
    fragile: json["fragile"],
  );

  Map<String, dynamic> toJson() => {
    "fragile": fragile,
  };
}

class VehicleTypeId {
  Dimensions? dimensions;
  String? id;
  String? name;
  int? capacity;
  int? baseFare;
  int? perKmRate;
  double? perMinuteRate;
  int? maxDeliveryDistance;
  String? image;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  VehicleTypeId({
    this.dimensions,
    this.id,
    this.name,
    this.capacity,
    this.baseFare,
    this.perKmRate,
    this.perMinuteRate,
    this.maxDeliveryDistance,
    this.image,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleTypeId.fromJson(Map<String, dynamic> json) => VehicleTypeId(
    dimensions: json["dimensions"] == null ? null : Dimensions.fromJson(json["dimensions"]),
    id: json["_id"],
    name: json["name"],
    capacity: json["capacity"],
    baseFare: json["baseFare"],
    perKmRate: json["perKmRate"],
    perMinuteRate: json["perMinuteRate"]?.toDouble(),
    maxDeliveryDistance: json["maxDeliveryDistance"],
    image: json["image"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "dimensions": dimensions?.toJson(),
    "_id": id,
    "name": name,
    "capacity": capacity,
    "baseFare": baseFare,
    "perKmRate": perKmRate,
    "perMinuteRate": perMinuteRate,
    "maxDeliveryDistance": maxDeliveryDistance,
    "image": image,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Dimensions {
  int? length;
  int? width;
  int? height;

  Dimensions({
    this.length,
    this.width,
    this.height,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
    length: json["length"],
    width: json["width"],
    height: json["height"],
  );

  Map<String, dynamic> toJson() => {
    "length": length,
    "width": width,
    "height": height,
  };
}
