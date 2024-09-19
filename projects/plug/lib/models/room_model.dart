
import 'package:plug/models/user.dart';

class RoomModel {
  UserModel? ownerId;
  String? title;
  String? id;
  String?sid;
  String ?resourceId;
  DateTime? startedtAt;
  bool? started;
  bool? ended;
  String? workId;
  String ?roomToken;
  List<UserModel> ?users;
  List? chatsList;

  RoomModel(
      {this.ownerId,
      this.title,
      this.startedtAt,
      this.started,
      this.ended,
      this.id,
      this.workId,
        this.roomToken,
        this.users,
        this.sid,
        this.resourceId,
        this.chatsList,
      });

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
        workId: json["workId"],
        id: json["id"],
        ownerId: UserModel.fromJson(json["ownerId"]),
        title: json["title"],
        users: json["users"] == null? []: List<UserModel>.from(json["users"].map((x) => UserModel.fromJson(x))),
        startedtAt: json["startedtAt"].toDate(),
        started: json["started"],
        ended: json["ended"],
        sid: json["sid"],
        resourceId: json["resourceId"],
        roomToken: json["roomToken"],
        chatsList: [],
      );

  Map<String, dynamic> toJson() => {
        "workId": workId,
        "ownerId": ownerId!.toJson(),
        "id": id,
        "title": title,
        "startedtAt": startedtAt,
        "started": started,
        "ended": ended,
        "users":users,
        "sid":sid,
        "resourceId":resourceId,
        "roomToken":roomToken,
      };
}
