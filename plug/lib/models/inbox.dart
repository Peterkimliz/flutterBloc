import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plugme/models/user.dart';

class Inbox {
  String? id;
  UserModel? senderId;
  UserModel? reciverId;
  String? receiverMessage;
  String? senderMessage;
  DateTime? time;
  String? type;
  List? users;
  Map<String, dynamic>? unreadMessages;

  final int? price;
  final String? attachment;

  Inbox(
      {this.senderId,
      this.reciverId,
      this.receiverMessage,
      this.senderMessage,
      this.time,
      this.price,
      this.type,
      this.users,
      this.attachment,
      this.unreadMessages,
      this.id});

  factory Inbox.fromJson(DocumentSnapshot json) => Inbox(
        id: json.id,
        senderId: json["senderId"] == null
            ? UserModel()
            : UserModel.fromJson(json["senderId"]),
        reciverId: json["reciverId"] == null
            ? UserModel()
            : UserModel.fromJson(json["reciverId"]),
        receiverMessage: json["receiverMessage"],
        senderMessage: json["senderMessage"],
        unreadMessages: json["unreadMessages"],
        time: json["time"].toDate(),
        type: json["type"],
        price: json["price"],
        attachment: json["attachment"],
        users: json["users"],
      );

  Map<String, dynamic> toJson() => {
        "reciverId": reciverId?.toJson(),
        "senderId": senderId?.toJson(),
        "senderMessage": senderMessage,
        "receiverMessage": receiverMessage,
        "attachment": attachment ?? "",
        "type": type,
        "price": price,
        "time": time,
        "users": users,
        "unreadMessages": unreadMessages,
      };
  getUnreadMessages(String id){
    List data=unreadMessages![id];
    return data.length;

  }
}
