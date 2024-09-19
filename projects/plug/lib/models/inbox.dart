import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plug/models/user.dart';

class Inbox {
  String? id;
  UserModel? senderId;
  UserModel? reciverId;
  String? receiverMessage;
  String? senderMessage;
  DateTime? time;
  String? type;
  List? users;
  List? deletedFor;
  Map<String, dynamic>? unreadMessages;

  final int? price;
  final String? attachment;
  final String? lmi;
  final bool? deleted;

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
      this.id,
      this.lmi,
      this.deleted,
      this.deletedFor});

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
        deletedFor:List<String>.from(json["deletedFor"].map((e)=>e)) ,
        lmi: json["lmi"],
        deleted: json["deleted"],
      );

  Map<String, dynamic> toJson() =>
      {
        "lmi": lmi,
        "reciverId": reciverId?.toJson(),
        "senderId": senderId?.toJson(),
        "senderMessage": senderMessage,
        "receiverMessage": receiverMessage,
        "attachment": attachment ?? "",
        "type": type,
        "price": price,
        "time": time,
        "users": users,
        "deletedFor": [],
        "deleted": false,
        "unreadMessages": unreadMessages,
      };
  getUnreadMessages(String id){
    List data=unreadMessages![id];
    return data.length;

  }
}
