
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationModel {
  final String? name;
  final GeoPoint? geoPoint;

  LocationModel({this.geoPoint, this.name});

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    name: json["name"],
    geoPoint: json["geoPoint"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "geoPoint": geoPoint,
  };
}