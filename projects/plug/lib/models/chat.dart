import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plug/models/user.dart';

import 'location_model.dart';

class Chat {
  final String? id;
  UserModel? senderId;
  UserModel? receiverId;
  final String? message;
  final String? receiverMessage;
  final String? type;
  final String? action;
  final bool? finished;
  final int? price;
  final String? workId;
  final int? hours;
  final bool?deleted;
  final DateTime? addTime;
  final String? offerType;
  final int? providerReview;
  final int? userReview;
  final String? receiverInboxMessage;
  final String? senderInboxMessage;
  final bool? reviewed;
  final bool? rejected;

  final String? attachment;
  final String? transactionId;
  final LocationModel? pickUp;
  final LocationModel? destination;
  final String? workType;
  final String? requestId;
  List? users;

  Chat(
      {this.message,
      this.type,
      this.addTime,
      this.senderId,
      this.receiverId,
      this.offerType,
      this.price,
      this.providerReview,
      this.reviewed,
      this.userReview,
      this.attachment,
      this.id,
      this.action,
      this.finished,
      this.receiverMessage,
      this.hours,
      this.transactionId,
      this.destination,
      this.pickUp,
      this.workType,
      this.workId,
      this.receiverInboxMessage,
      this.senderInboxMessage,
      this.rejected,
      this.requestId,
      this.users,
      this.deleted});

  factory Chat.fromJson(DocumentSnapshot snapshot) =>Chat(
      id: snapshot.id,
      senderId: snapshot["senderId"] == null
          ? UserModel()
          : UserModel.fromJson(snapshot["senderId"]),
      receiverId: snapshot["receiverId"] == null
          ? UserModel()
          : UserModel.fromJson(snapshot["receiverId"]),
      message: snapshot["message"],
      type: snapshot["type"],
      offerType: snapshot["offerType"],
      price: snapshot["price"],
      addTime: snapshot["addTime"].toDate(),
      userReview: snapshot["userReview"],
      reviewed: snapshot["reviewed"] ?? false,
      providerReview: snapshot["providerReview"],
        workId: snapshot["workId"] ?? "",
        attachment: snapshot["attachment"],
        requestId: snapshot["requestId"] ?? "",
        action: snapshot["action"],
        finished: snapshot["finished"] ?? false,
        rejected: snapshot["rejected"] ?? false,
        receiverMessage: snapshot["receiverMessage"],
        senderInboxMessage: "",
        receiverInboxMessage: "",
        hours: snapshot["hours"],
        transactionId: snapshot["transactionId"],
        workType: snapshot["workType"],
        deleted: snapshot["deleted"],
        pickUp: snapshot["pickUp"] == null
            ? null
            : LocationModel.fromJson(snapshot["pickUp"]),
        destination: snapshot["destination"] == null
            ? null
            : LocationModel.fromJson(snapshot["destination"]),
      );


  Map<String, dynamic> toJson() => {
        "receiverId": receiverId?.toJson(),
        "senderId": senderId?.toJson(),
        "message": message,
        "type": type,
        "offerType": offerType,
        "price": price,
        "addTime": addTime,
        "rejected": rejected ?? false,
        "reviewed": reviewed,
        "providerReview": providerReview ?? 0,
        "userReview": userReview ?? 0,
        "attachment": attachment ?? "",
        "action": action,
        "finished": finished,
        "requestId": requestId ?? "",
        "receiverMessage": receiverMessage,
        "hours": hours,
        "users": users,
        "workType": workType,
        "transactionId": transactionId,
        "pickUp": pickUp == null ? null : pickUp!.toJson(),
        "destination": destination == null ? null : destination!.toJson(),
        "workId": workId ?? "",
        "deleted": false,

      };
}
