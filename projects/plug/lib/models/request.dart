import 'package:plug/models/user.dart';

import 'location_model.dart';

class Request {
  DateTime? time;
  UserModel? provider;
  UserModel? userId;
  int? price;
  List<String>? users;
  String? requestId;
  int? position;

  Request(
      {this.price,
      this.time,
      this.provider,
      this.userId,
      this.users,
      this.position,
      this.requestId});

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      price: json["price"],
      requestId: json["requestId"],
      userId: json["userId"] == null ? null : UserModel.fromJson(json["userId"]),
      time: json["time"].toDate(),
      position: json["position"],
      provider: json["provider"] == null
          ? null
          : UserModel.fromJson(json["provider"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "requestId": requestId,
        "price": price,
        "userId": userId!.toJson(),
        "time": time,
        "users": users,
        "position": position,
        "provider": provider!.toJson(),
      };
}
