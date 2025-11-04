// To parse this JSON data, do
//
//     final DeleteAddressModel = DeleteAddressModelFromJson(jsonString);

import 'dart:convert';

DeleteAddressModel DeleteAddressModelFromJson(String str) => DeleteAddressModel.fromJson(json.decode(str));

String DeleteAddressModelToJson(DeleteAddressModel data) => json.encode(data.toJson());

class DeleteAddressModel {
  String id;
  
  DeleteAddressModel({
    required this.id,
   
  });

  factory DeleteAddressModel.fromJson(Map<String, dynamic> json) =>
      DeleteAddressModel(
        id: json["id"],
      

      );

  Map<String, dynamic> toJson() => {
    "id": id,
   

  };
}


