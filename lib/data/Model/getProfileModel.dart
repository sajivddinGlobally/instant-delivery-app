// // To parse this JSON data, do
// //
// //     final getProfileModel = getProfileModelFromJson(jsonString);

// import 'dart:convert';

// GetProfileModel getProfileModelFromJson(String str) =>
//     GetProfileModel.fromJson(json.decode(str));

// String getProfileModelToJson(GetProfileModel data) =>
//     json.encode(data.toJson());

// class GetProfileModel {
//   String message;
//   int code;
//   bool error;
//   Data? data;

//   GetProfileModel({
//     required this.message,
//     required this.code,
//     required this.error,
//     required this.data,
//   });

//   factory GetProfileModel.fromJson(Map<String, dynamic> json) =>
//       GetProfileModel(
//         message: json["message"],
//         code: json["code"],
//         error: json["error"],
//         data: json["data"] == null ? null : Data.fromJson(json["data"]),
//       );

//   Map<String, dynamic> toJson() => {
//     "message": message,
//     "code": code,
//     "error": error,
//     "data": data?.toJson(),
//   };
// }

// class Data {
//   Empty empty;
//   bool isNew;
//   Doc doc;
//   Wallet wallet;

//   Data({
//     required this.empty,
//     required this.isNew,
//     required this.doc,
//     required this.wallet,
//   });

//   factory Data.fromJson(Map<String, dynamic> json) => Data(
//     empty: Empty.fromJson(json["\u0024__"]),
//     isNew: json["\u0024isNew"],
//     doc: Doc.fromJson(json["_doc"]),
//     wallet: Wallet.fromJson(json["wallet"]),
//   );

//   Map<String, dynamic> toJson() => {
//     "\u0024__": empty.toJson(),
//     "\u0024isNew": isNew,
//     "_doc": doc.toJson(),
//     "wallet": wallet.toJson(),
//   };
// }

// class Doc {
//   CurrentLocation currentLocation;
//   Documents documents;
//   String status;
//   int completedOrderCount;
//   String id;
//   String userType;
//   String firstName;
//   String lastName;
//   String email;
//   String phone;
//   String password;
//   String driverStatus;
//   int averageRating;
//   dynamic image;
//   bool isDisable;
//   bool isDeleted;
//   int date;
//   int month;
//   int year;
//   int createdAt;
//   int updatedAt;
//   int v;
//   dynamic deviceId;
//   String socketId;
//   DateTime lastLocationUpdate;
//   List<dynamic> vehicleDetails;
//   List<dynamic> rating;

//   Doc({
//     required this.currentLocation,
//     required this.documents,
//     required this.status,
//     required this.completedOrderCount,
//     required this.id,
//     required this.userType,
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.phone,
//     required this.password,
//     required this.driverStatus,
//     required this.averageRating,
//     required this.image,
//     required this.isDisable,
//     required this.isDeleted,
//     required this.date,
//     required this.month,
//     required this.year,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.v,
//     required this.deviceId,
//     required this.socketId,
//     required this.lastLocationUpdate,
//     required this.vehicleDetails,
//     required this.rating,
//   });

//   factory Doc.fromJson(Map<String, dynamic> json) => Doc(
//     currentLocation: CurrentLocation.fromJson(json["currentLocation"]),
//     documents: Documents.fromJson(json["documents"]),
//     status: json["status"],
//     completedOrderCount: json["completedOrderCount"],
//     id: json["_id"],
//     userType: json["userType"],
//     firstName: json["firstName"],
//     lastName: json["lastName"],
//     email: json["email"],
//     phone: json["phone"],
//     password: json["password"],
//     driverStatus: json["driverStatus"],
//     averageRating: json["averageRating"],
//     image: json["image"],
//     isDisable: json["isDisable"],
//     isDeleted: json["isDeleted"],
//     date: json["date"],
//     month: json["month"],
//     year: json["year"],
//     createdAt: json["createdAt"],
//     updatedAt: json["updatedAt"],
//     v: json["__v"],
//     deviceId: json["deviceId"],
//     socketId: json["socketId"],
//     lastLocationUpdate: DateTime.parse(json["lastLocationUpdate"]),
//     vehicleDetails: List<dynamic>.from(json["vehicleDetails"].map((x) => x)),
//     rating: List<dynamic>.from(json["rating"].map((x) => x)),
//   );

//   Map<String, dynamic> toJson() => {
//     "currentLocation": currentLocation.toJson(),
//     "documents": documents.toJson(),
//     "status": status,
//     "completedOrderCount": completedOrderCount,
//     "_id": id,
//     "userType": userType,
//     "firstName": firstName,
//     "lastName": lastName,
//     "email": email,
//     "phone": phone,
//     "password": password,
//     "driverStatus": driverStatus,
//     "averageRating": averageRating,
//     "image": image,
//     "isDisable": isDisable,
//     "isDeleted": isDeleted,
//     "date": date,
//     "month": month,
//     "year": year,
//     "createdAt": createdAt,
//     "updatedAt": updatedAt,
//     "__v": v,
//     "deviceId": deviceId,
//     "socketId": socketId,
//     "lastLocationUpdate": lastLocationUpdate.toIso8601String(),
//     "vehicleDetails": List<dynamic>.from(vehicleDetails.map((x) => x)),
//     "rating": List<dynamic>.from(rating.map((x) => x)),
//   };
// }

// class CurrentLocation {
//   String type;
//   List<double> coordinates;

//   CurrentLocation({required this.type, required this.coordinates});

//   factory CurrentLocation.fromJson(Map<String, dynamic> json) =>
//       CurrentLocation(
//         type: json["type"],
//         coordinates: List<double>.from(
//           json["coordinates"].map((x) => x?.toDouble()),
//         ),
//       );

//   Map<String, dynamic> toJson() => {
//     "type": type,
//     "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
//   };
// }

// class Documents {
//   Documents();

//   factory Documents.fromJson(Map<String, dynamic> json) => Documents();

//   Map<String, dynamic> toJson() => {};
// }

// class Empty {
//   ActivePaths activePaths;
//   bool skipId;

//   Empty({required this.activePaths, required this.skipId});

//   factory Empty.fromJson(Map<String, dynamic> json) => Empty(
//     activePaths: ActivePaths.fromJson(json["activePaths"]),
//     skipId: json["skipId"],
//   );

//   Map<String, dynamic> toJson() => {
//     "activePaths": activePaths.toJson(),
//     "skipId": skipId,
//   };
// }

// class ActivePaths {
//   Paths paths;
//   States states;

//   ActivePaths({required this.paths, required this.states});

//   factory ActivePaths.fromJson(Map<String, dynamic> json) => ActivePaths(
//     paths: Paths.fromJson(json["paths"]),
//     states: States.fromJson(json["states"]),
//   );

//   Map<String, dynamic> toJson() => {
//     "paths": paths.toJson(),
//     "states": states.toJson(),
//   };
// }

// class Paths {
//   String currentLocationCoordinates;
//   String userType;
//   String driverStatus;
//   String status;
//   String currentLocationType;
//   String completedOrderCount;
//   String averageRating;
//   String image;
//   String socketId;
//   String isDisable;
//   String isDeleted;
//   String id;
//   String firstName;
//   String lastName;
//   String email;
//   String phone;
//   String password;
//   String date;
//   String month;
//   String year;
//   String createdAt;
//   String updatedAt;
//   String v;
//   String deviceId;
//   String lastLocationUpdate;
//   String vehicleDetails;
//   String rating;

//   Paths({
//     required this.currentLocationCoordinates,
//     required this.userType,
//     required this.driverStatus,
//     required this.status,
//     required this.currentLocationType,
//     required this.completedOrderCount,
//     required this.averageRating,
//     required this.image,
//     required this.socketId,
//     required this.isDisable,
//     required this.isDeleted,
//     required this.id,
//     required this.firstName,
//     required this.lastName,
//     required this.email,
//     required this.phone,
//     required this.password,
//     required this.date,
//     required this.month,
//     required this.year,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.v,
//     required this.deviceId,
//     required this.lastLocationUpdate,
//     required this.vehicleDetails,
//     required this.rating,
//   });

//   factory Paths.fromJson(Map<String, dynamic> json) => Paths(
//     currentLocationCoordinates: json["currentLocation.coordinates"],
//     userType: json["userType"],
//     driverStatus: json["driverStatus"],
//     status: json["status"],
//     currentLocationType: json["currentLocation.type"],
//     completedOrderCount: json["completedOrderCount"],
//     averageRating: json["averageRating"],
//     image: json["image"],
//     socketId: json["socketId"],
//     isDisable: json["isDisable"],
//     isDeleted: json["isDeleted"],
//     id: json["_id"],
//     firstName: json["firstName"],
//     lastName: json["lastName"],
//     email: json["email"],
//     phone: json["phone"],
//     password: json["password"],
//     date: json["date"],
//     month: json["month"],
//     year: json["year"],
//     createdAt: json["createdAt"],
//     updatedAt: json["updatedAt"],
//     v: json["__v"],
//     deviceId: json["deviceId"],
//     lastLocationUpdate: json["lastLocationUpdate"],
//     vehicleDetails: json["vehicleDetails"],
//     rating: json["rating"],
//   );

//   Map<String, dynamic> toJson() => {
//     "currentLocation.coordinates": currentLocationCoordinates,
//     "userType": userType,
//     "driverStatus": driverStatus,
//     "status": status,
//     "currentLocation.type": currentLocationType,
//     "completedOrderCount": completedOrderCount,
//     "averageRating": averageRating,
//     "image": image,
//     "socketId": socketId,
//     "isDisable": isDisable,
//     "isDeleted": isDeleted,
//     "_id": id,
//     "firstName": firstName,
//     "lastName": lastName,
//     "email": email,
//     "phone": phone,
//     "password": password,
//     "date": date,
//     "month": month,
//     "year": year,
//     "createdAt": createdAt,
//     "updatedAt": updatedAt,
//     "__v": v,
//     "deviceId": deviceId,
//     "lastLocationUpdate": lastLocationUpdate,
//     "vehicleDetails": vehicleDetails,
//     "rating": rating,
//   };
// }

// class States {
//   Documents require;
//   Default statesDefault;
//   Map<String, bool> init;

//   States({
//     required this.require,
//     required this.statesDefault,
//     required this.init,
//   });

//   factory States.fromJson(Map<String, dynamic> json) => States(
//     require: Documents.fromJson(json["require"]),
//     statesDefault: Default.fromJson(json["default"]),
//     init: Map.from(json["init"]).map((k, v) => MapEntry<String, bool>(k, v)),
//   );

//   Map<String, dynamic> toJson() => {
//     "require": require.toJson(),
//     "default": statesDefault.toJson(),
//     "init": Map.from(init).map((k, v) => MapEntry<String, dynamic>(k, v)),
//   };
// }

// class Default {
//   bool status;
//   bool completedOrderCount;
//   bool vehicleDetails;
//   bool rating;

//   Default({
//     required this.status,
//     required this.completedOrderCount,
//     required this.vehicleDetails,
//     required this.rating,
//   });

//   factory Default.fromJson(Map<String, dynamic> json) => Default(
//     status: json["status"],
//     completedOrderCount: json["completedOrderCount"],
//     vehicleDetails: json["vehicleDetails"],
//     rating: json["rating"],
//   );

//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "completedOrderCount": completedOrderCount,
//     "vehicleDetails": vehicleDetails,
//     "rating": rating,
//   };
// }

// class Wallet {
//   String id;
//   String user;
//   int balance;
//   bool isDisable;
//   bool isDeleted;
//   int date;
//   int month;
//   int year;
//   int createdAt;
//   int updatedAt;

//   Wallet({
//     required this.id,
//     required this.user,
//     required this.balance,
//     required this.isDisable,
//     required this.isDeleted,
//     required this.date,
//     required this.month,
//     required this.year,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
//     id: json["_id"],
//     user: json["user"],
//     balance: json["balance"],
//     isDisable: json["isDisable"],
//     isDeleted: json["isDeleted"],
//     date: json["date"],
//     month: json["month"],
//     year: json["year"],
//     createdAt: json["createdAt"],
//     updatedAt: json["updatedAt"],
//   );

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "user": user,
//     "balance": balance,
//     "isDisable": isDisable,
//     "isDeleted": isDeleted,
//     "date": date,
//     "month": month,
//     "year": year,
//     "createdAt": createdAt,
//     "updatedAt": updatedAt,
//   };
// }


// To parse this JSON data, do
//
//     final getProfileModel = getProfileModelFromJson(jsonString);

import 'dart:convert';

GetProfileModel getProfileModelFromJson(String str) =>
    GetProfileModel.fromJson(json.decode(str));

String getProfileModelToJson(GetProfileModel data) =>
    json.encode(data.toJson());

class GetProfileModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  GetProfileModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory GetProfileModel.fromJson(Map<String, dynamic> json) =>
      GetProfileModel(
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
  Empty? empty;
  bool? isNew;
  Doc? doc;
  Wallet? wallet;

  Data({
    this.empty,
    this.isNew,
    this.doc,
    this.wallet,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        empty:
            json["\u0024__"] == null ? null : Empty.fromJson(json["\u0024__"]),
        isNew: json["\u0024isNew"],
        doc: json["_doc"] == null ? null : Doc.fromJson(json["_doc"]),
        wallet:
            json["wallet"] == null ? null : Wallet.fromJson(json["wallet"]),
      );

  Map<String, dynamic> toJson() => {
        "\u0024__": empty?.toJson(),
        "\u0024isNew": isNew,
        "_doc": doc?.toJson(),
        "wallet": wallet?.toJson(),
      };
}

class Doc {
  CurrentLocation? currentLocation;
  Documents? documents;
  String? status;
  int? completedOrderCount;
  String? id;
  String? userType;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? password;
  String? driverStatus;
  int? averageRating;
  dynamic image;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  int? v;
  dynamic deviceId;
  String? socketId;
  DateTime? lastLocationUpdate;
  List<dynamic>? vehicleDetails;
  List<dynamic>? rating;

  Doc({
    this.currentLocation,
    this.documents,
    this.status,
    this.completedOrderCount,
    this.id,
    this.userType,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.password,
    this.driverStatus,
    this.averageRating,
    this.image,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.deviceId,
    this.socketId,
    this.lastLocationUpdate,
    this.vehicleDetails,
    this.rating,
  });

  factory Doc.fromJson(Map<String, dynamic> json) => Doc(
        currentLocation: json["currentLocation"] == null
            ? null
            : CurrentLocation.fromJson(json["currentLocation"]),
        documents: json["documents"] == null
            ? null
            : Documents.fromJson(json["documents"]),
        status: json["status"] ?? "",
        completedOrderCount: json["completedOrderCount"]?.toInt() ?? 0,
        id: json["_id"] ?? "",
        userType: json["userType"] ?? "",
        firstName: json["firstName"] ?? "",
        lastName: json["lastName"] ?? "",
        email: json["email"] ?? "",
        phone: json["phone"] ?? "",
        password: json["password"] ?? "",
        driverStatus: json["driverStatus"] ?? "",
        averageRating: json["averageRating"]?.toInt() ?? 0,
        image: json["image"],
        isDisable: json["isDisable"] ?? false,
        isDeleted: json["isDeleted"] ?? false,
        date: json["date"]?.toInt() ?? 0,
        month: json["month"]?.toInt() ?? 0,
        year: json["year"]?.toInt() ?? 0,
        createdAt: json["createdAt"]?.toInt() ?? 0,
        updatedAt: json["updatedAt"]?.toInt() ?? 0,
        v: json["__v"]?.toInt() ?? 0,
        deviceId: json["deviceId"],
        socketId: json["socketId"] ?? "",
        lastLocationUpdate: json["lastLocationUpdate"] == null
            ? null
            : DateTime.tryParse(json["lastLocationUpdate"]),
        vehicleDetails: json["vehicleDetails"] == null
            ? []
            : List<dynamic>.from(json["vehicleDetails"].map((x) => x)),
        rating: json["rating"] == null
            ? []
            : List<dynamic>.from(json["rating"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "currentLocation": currentLocation?.toJson(),
        "documents": documents?.toJson(),
        "status": status,
        "completedOrderCount": completedOrderCount,
        "_id": id,
        "userType": userType,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "password": password,
        "driverStatus": driverStatus,
        "averageRating": averageRating,
        "image": image,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
        "deviceId": deviceId,
        "socketId": socketId,
        "lastLocationUpdate": lastLocationUpdate?.toIso8601String(),
        "vehicleDetails": vehicleDetails ?? [],
        "rating": rating ?? [],
      };
}

class CurrentLocation {
  String? type;
  List<double>? coordinates;

  CurrentLocation({this.type, this.coordinates});

  factory CurrentLocation.fromJson(Map<String, dynamic> json) =>
      CurrentLocation(
        type: json["type"],
        coordinates: json["coordinates"] == null
            ? []
            : List<double>.from(
                json["coordinates"].map((x) => x?.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates ?? [],
      };
}

class Documents {
  Documents();

  factory Documents.fromJson(Map<String, dynamic> json) => Documents();

  Map<String, dynamic> toJson() => {};
}

class Empty {
  ActivePaths? activePaths;
  bool? skipId;

  Empty({this.activePaths, this.skipId});

  factory Empty.fromJson(Map<String, dynamic> json) => Empty(
        activePaths: json["activePaths"] == null
            ? null
            : ActivePaths.fromJson(json["activePaths"]),
        skipId: json["skipId"],
      );

  Map<String, dynamic> toJson() => {
        "activePaths": activePaths?.toJson(),
        "skipId": skipId,
      };
}

class ActivePaths {
  Paths? paths;
  States? states;

  ActivePaths({this.paths, this.states});

  factory ActivePaths.fromJson(Map<String, dynamic> json) => ActivePaths(
        paths: json["paths"] == null ? null : Paths.fromJson(json["paths"]),
        states:
            json["states"] == null ? null : States.fromJson(json["states"]),
      );

  Map<String, dynamic> toJson() => {
        "paths": paths?.toJson(),
        "states": states?.toJson(),
      };
}

class Paths {
  String? currentLocationCoordinates;
  String? userType;
  String? driverStatus;
  String? status;
  String? currentLocationType;
  String? completedOrderCount;
  String? averageRating;
  String? image;
  String? socketId;
  String? isDisable;
  String? isDeleted;
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? password;
  String? date;
  String? month;
  String? year;
  String? createdAt;
  String? updatedAt;
  String? v;
  String? deviceId;
  String? lastLocationUpdate;
  String? vehicleDetails;
  String? rating;

  Paths({
    this.currentLocationCoordinates,
    this.userType,
    this.driverStatus,
    this.status,
    this.currentLocationType,
    this.completedOrderCount,
    this.averageRating,
    this.image,
    this.socketId,
    this.isDisable,
    this.isDeleted,
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.password,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.deviceId,
    this.lastLocationUpdate,
    this.vehicleDetails,
    this.rating,
  });

  factory Paths.fromJson(Map<String, dynamic> json) => Paths(
        currentLocationCoordinates: json["currentLocation.coordinates"],
        userType: json["userType"],
        driverStatus: json["driverStatus"],
        status: json["status"],
        currentLocationType: json["currentLocation.type"],
        completedOrderCount: json["completedOrderCount"],
        averageRating: json["averageRating"],
        image: json["image"],
        socketId: json["socketId"],
        isDisable: json["isDisable"],
        isDeleted: json["isDeleted"],
        id: json["_id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
        date: json["date"],
        month: json["month"],
        year: json["year"],
        createdAt: json["createdAt"],
        updatedAt: json["updatedAt"],
        v: json["__v"],
        deviceId: json["deviceId"],
        lastLocationUpdate: json["lastLocationUpdate"],
        vehicleDetails: json["vehicleDetails"],
        rating: json["rating"],
      );

  Map<String, dynamic> toJson() => {
        "currentLocation.coordinates": currentLocationCoordinates,
        "userType": userType,
        "driverStatus": driverStatus,
        "status": status,
        "currentLocation.type": currentLocationType,
        "completedOrderCount": completedOrderCount,
        "averageRating": averageRating,
        "image": image,
        "socketId": socketId,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "_id": id,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "password": password,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
        "__v": v,
        "deviceId": deviceId,
        "lastLocationUpdate": lastLocationUpdate,
        "vehicleDetails": vehicleDetails,
        "rating": rating,
      };
}

class States {
  Documents? require;
  Default? statesDefault;
  Map<String, bool>? init;

  States({
    this.require,
    this.statesDefault,
    this.init,
  });

  factory States.fromJson(Map<String, dynamic> json) => States(
        require:
            json["require"] == null ? null : Documents.fromJson(json["require"]),
        statesDefault: json["default"] == null
            ? null
            : Default.fromJson(json["default"]),
        init: json["init"] == null
            ? {}
            : Map.from(json["init"]).map((k, v) => MapEntry<String, bool>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "require": require?.toJson(),
        "default": statesDefault?.toJson(),
        "init": init ?? {},
      };
}

class Default {
  bool? status;
  bool? completedOrderCount;
  bool? vehicleDetails;
  bool? rating;

  Default({
    this.status,
    this.completedOrderCount,
    this.vehicleDetails,
    this.rating,
  });

  factory Default.fromJson(Map<String, dynamic> json) => Default(
        status: json["status"],
        completedOrderCount: json["completedOrderCount"],
        vehicleDetails: json["vehicleDetails"],
        rating: json["rating"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "completedOrderCount": completedOrderCount,
        "vehicleDetails": vehicleDetails,
        "rating": rating,
      };
}

class Wallet {
  String? id;
  String? user;
  int? balance;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  Wallet({
    this.id,
    this.user,
    this.balance,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json["_id"] ?? "",
        user: json["user"] ?? "",
        balance: json["balance"]?.toInt() ?? 0,
        isDisable: json["isDisable"] ?? false,
        isDeleted: json["isDeleted"] ?? false,
        date: json["date"]?.toInt() ?? 0,
        month: json["month"]?.toInt() ?? 0,
        year: json["year"]?.toInt() ?? 0,
        createdAt: json["createdAt"]?.toInt() ?? 0,
        updatedAt: json["updatedAt"]?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "user": user,
        "balance": balance,
        "isDisable": isDisable,
        "isDeleted": isDeleted,
        "date": date,
        "month": month,
        "year": year,
        "createdAt": createdAt,
        "updatedAt": updatedAt,
      };
}
