import 'package:plug/models/user.dart';

import 'location_model.dart';

class Work {
  DateTime? time;
  DateTime? arrivalTime;
  DateTime? completionTime;
  UserModel? provider;
  String? workType;
  String? reviewMessage;
  UserModel? userId;
  int? price;
  int? hours;
  String? rateType;
  String? status;
  List<String>? users;
  LocationModel? pickUp;
  LocationModel? destination;
  bool? isLive;
  String? roomId;
  String? workId;
  String? transactionId;
  double? totalReview;


  Work(
      {this.workType,
      this.price,
      this.time,
      this.provider,
      this.rateType,
      this.status,
      this.userId,
      this.arrivalTime,
      this.completionTime,
      this.hours,
      this.users,
      this.pickUp,
      this.destination,
      this.isLive,
      this.roomId,
      this.totalReview,this.reviewMessage,this.transactionId,this.workId});

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
        price: json["price"],
        workId: json["workId"],
        workType: json["workType"],
        userId: json["userId"] == null ? null : UserModel.fromJson(json["userId"]),
        rateType: json["rateType"],
        status: json["status"],
        isLive: json["isLive"],
        roomId: json["roomId"],
        time: json["time"].toDate(),
        hours: json["hours"],
        transactionId: json["transactionId"],

        reviewMessage: json["reviewMessage"],
        provider: json["provider"] == null
            ? null
            : UserModel.fromJson(json["provider"]),
        arrivalTime: json["arrivalTime"].toDate(),
        completionTime: json["completionTime"] == null
            ? null
            : json["completionTime"].toDate(),
        pickUp: json["pickUp"] == null ? null : LocationModel.fromJson(json["pickUp"]),
        destination: json["destination"] == null
            ? null
            : LocationModel.fromJson(json["destination"]),
        totalReview:json["totalReview"]==null?0.0:json["totalReview"].toDouble());
  }

  Map<String, dynamic> toJson() => {
        "workId": workId,
        "arrivalTime": arrivalTime,
        "completionTime": completionTime,
        "pickUp": pickUp == null ? null : pickUp!.toJson(),
        "destination": destination == null ? null : destination!.toJson(),
        "price": price,
        "status": status,
        "userId": userId!.toJson(),
        "workType": workType,
        "rateType": rateType,
        "hours": hours,
        "time": time,
        "users": users,
         "reviewMessage": reviewMessage,
        "isLive": isLive,
        "roomId": roomId,

    "transactionId":transactionId,
        "totalReview": totalReview,
        "provider": provider!.toJson(),
      };
}
