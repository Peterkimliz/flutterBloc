import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/controllers/room_controller.dart';
import 'package:plugme/models/chat.dart';
import 'package:plugme/models/inbox.dart';
import 'package:plugme/models/user.dart';
import 'package:plugme/models/work.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../models/location_model.dart';

class ChatController extends GetxController with GetSingleTickerProviderStateMixin {
  final _chatRef = FirebaseFirestore.instance.collection("messages");
  final roomChatRef = FirebaseFirestore.instance.collection("rooms");
  final _offers = FirebaseFirestore.instance.collection("offers");
  final _work = FirebaseFirestore.instance.collection("work");
  final _firebaseStorage = FirebaseStorage.instance;
  late TabController tabController;
  RxBool showTabBar = RxBool(false);

  TextEditingController textEditingController = TextEditingController();
  TextEditingController textEditingControllerPrice = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();
  RxInt selectedPrice = RxInt(0);
  RxInt hours = RxInt(0);

  Rxn<File>? pickedImage = Rxn(null);

  List<String> orderType = ["Flat Rate", "Hourly"];
  RxString selectedOrderType = RxString("Flat Rate");

  TextEditingController textEditingControllerHours = TextEditingController();
  RxBool isChatPage = RxBool(false);

  sendMessage({required docId, required Chat chatModel}) async {
    String chatId = "";
    List<String> users = [];
    users.add(FirebaseAuth.instance.currentUser!.uid);
    users.add(chatModel.receiverId!.id!);
    await _chatRef
        .doc(docId)
        .collection("chats")
        .add(chatModel.toJson())
        .then((value) {
      chatId = value.id;
      _chatRef.doc(docId).get().then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
          List items = data["unreadMessages"][chatModel.receiverId!.id!];
          items.add(chatId);
          _chatRef.doc(docId).update({
            "senderMessage": chatModel.senderInboxMessage,
            "receiverMessage": chatModel.receiverInboxMessage,
            "senderId": Get.find<AuthController>().currentUser.value!.toJson(),
            "reciverId": chatModel.receiverId!.toJson(),
            "price": chatModel.price,
            "type": chatModel.type,
            "time": DateTime.now(),
            "unreadMessages": {
              "${chatModel.receiverId!.id}": items,
              "${Get.find<AuthController>().currentUser.value!.id}": []
            }
          });
        } else {
          _chatRef.doc(docId).set(
                Inbox(
                        senderId: Get.find<AuthController>().currentUser.value!,
                        reciverId: chatModel.receiverId,
                        senderMessage: chatModel.senderInboxMessage,
                        receiverMessage: chatModel.receiverInboxMessage,
                        users: users,
                        price: chatModel.price,
                        attachment: chatModel.attachment,
                        type: chatModel.type,
                        unreadMessages: {
                          "${chatModel.receiverId!.id}": [chatId],
                          "${Get.find<AuthController>().currentUser.value!.id}":
                              []
                        },
                        time: DateTime.now())
                    .toJson(),
              );
        }
      });
    });

    sendChatNotification(
        chatId: docId,
        id: chatModel.receiverId!.playerId!,
        userModel: Get.find<AuthController>().currentUser.value!,
        message: chatModel.message!,
        screen: "ChatInbox",
        type: "message");

    return chatId;
  }

  sendRoomMessage({required roomId, required String message}) async {
    Chat chat = Chat(
      message: message,
      senderInboxMessage: message,
      receiverInboxMessage: message,
      type: "message",
      addTime: DateTime.now(),
      senderId: Get.find<AuthController>().currentUser.value,
      receiverId: UserModel(),
      offerType: "",
      price: 0,
      providerReview: 0,
      reviewed: false,
      userReview: 0,
      attachment: "",
      action: "message",
      finished: false,
      receiverMessage: message,
      hours: 0,
      transactionId: "",
      workId: "",
      pickUp: LocationModel(),
      destination: LocationModel(),
      workType: "",
    );
    await roomChatRef
        .doc(roomId)
        .collection("chats")
        .add(chat.toJson())
        .then((value) {
      Get.find<RoomController>().currentRoom.value!.chatsList!.add(chat);
      Get.find<RoomController>().currentRoom.refresh();
    });
  }

  updateOffer({required String uid, required Map<String, dynamic> body}) async {
    await _offers.doc(uid).update(body);
  }

  getChatIdInboxes({required user}) async {
    String chatId = "";
    await _chatRef.where("users", arrayContains: user).get().then((value) {
      List data = value.docs;
      var index = data.indexWhere((element) =>
          element["users"].contains(FirebaseAuth.instance.currentUser!.uid));
      chatId = index == -1 ? _chatRef.doc().id : value.docs[index].id;
    });

    return chatId;
  }

  getAllInboxes() async {
    QuerySnapshot querySnapshot = await _chatRef
        .where("users",
            arrayContainsAny: [FirebaseAuth.instance.currentUser!.uid])
        .orderBy("time")
        .get();

    return querySnapshot;
  }

  Stream<List<Inbox>> getInbox(String idUser) => _chatRef
      .where("users",
          arrayContainsAny: [FirebaseAuth.instance.currentUser!.uid])
      .orderBy("time", descending: true)
      .snapshots()
      .map(_getInboxes);

  List<Inbox> _getInboxes(QuerySnapshot c) {
    return c.docs.map((event) => Inbox.fromJson(event)).toList();
  }

  Stream<List<Chat>> getMessages({required String id}) {
    final stream = _chatRef.doc(id).collection("chats").snapshots();
    return stream.map((event) => event.docs.map((doc) {
          return Chat.fromJson(doc);
        }).toList());
  }

  createWork({
    String? workType,
    required UserModel userModel,
    required price,
    required rateType,
    required hours,
    LocationModel? puckUp,
    LocationModel? destination,
    required uid,
    required String chatId, required String transactionId,
  }) async {
    AuthController authController = Get.find<AuthController>();
    try {
      List<String> users = [];
      users.add(Get.find<AuthController>().currentUser.value!.id!);
      users.add(userModel.id!);
      Work work = Work(
        price: price,
        rateType: rateType,
        provider: userModel,
        userId: Get.find<AuthController>().currentUser.value,
        status: "pending",
        workType: workType,
        transactionId:transactionId,
        hours: hours,
        users: users,
        arrivalTime: DateTime.now(),
        pickUp: puckUp,
        totalReview: 0.0,
        destination: destination,
        completionTime: null,
        reviewMessage: "",
        time: DateTime.now(),
        roomId: "",
        isLive: false,
      );
      var workId = _work.doc().id;
      await _work.doc(workId).set(work.toJson());
      authController.updateSingleItem(
          body: {"totalJobs": FieldValue.increment(1)}, id: userModel.id!);
      await _work
          .where("users",
              arrayContainsAny: [FirebaseAuth.instance.currentUser!.uid])
          .get()
          .then((value) {
            authController.updateSingleItem(body: {
              "rehire": [
                {
                  "id": FirebaseAuth.instance.currentUser!.uid,
                  "value": value.docs.length
                }
              ]
            }, id: userModel.id!);
          });
      return workId;
    } catch (e) {
      return null;

    }
  }

  updateWork(List<String> uid, Map<String, dynamic> body) async {
    String chatId = "";
    await _work.where("users", isEqualTo: uid).get().then((value) {
      chatId = value.docs.isNotEmpty ? value.docs[0].id : "";
    });
    await _work.doc(chatId).get().then((value) {
      _work.doc(chatId).update(body);
    });
  }

  void sendChatNotification(
      {required String id,
      required UserModel userModel,
      required String message,
      required screen,
      required chatId,
      required String type}) async {
    AuthController authController = Get.find<AuthController>();
    var notification = OSCreateNotification(
      playerIds: [id],
      content: message,
      androidLargeIcon: authController.currentUser.value!.profileUrl ?? "",
      additionalData: {
        "userModel": UserModel(
                email: userModel.email,
                id: userModel.id,
                firstname: userModel.firstname,
                lastname: userModel.lastname,
                playerId: userModel.playerId,
                profileUrl: userModel.profileUrl,
                service: userModel.service)
            .toJson(),
        "screen": screen,
        "type": type,
        "message": message,
        "chatId": chatId
      },
      heading: authController.currentUser.value!.firstname!,
    );

    sendNotification(notification: notification);
  }

  void roomNotification(
      {required String message, required List<String> playersId}) async {
    AuthController authController = Get.find<AuthController>();
    var notification = OSCreateNotification(
      playerIds: playersId,
      content: message,
      androidLargeIcon: authController.currentUser.value!.profileUrl ?? "",
      additionalData: {
        "userModel": UserModel(
                email: authController.currentUser.value!.email,
                id: authController.currentUser.value!.id,
                firstname: authController.currentUser.value!.firstname,
                lastname: authController.currentUser.value!.lastname,
                playerId: authController.currentUser.value!.playerId,
                profileUrl: authController.currentUser.value!.profileUrl,
                service: authController.currentUser.value!.service)
            .toJson(),
        "screen": "room",
        "type": "room",
        "roomId": Get.find<RoomController>().currentRoom.value!.id,
        "message": message,
      },
      heading: authController.currentUser.value!.firstname!,
    );
    sendNotification(notification: notification);
  }

  Future pickImage(
      {required type,
      required context,
      required UserModel userModel,
      required uid}) async {
    try {
      XFile? image = await ImagePicker().pickImage(
          source: type == "camera" ? ImageSource.camera : ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      pickedImage?.value = imageTemp;
      Chat chat = Chat(
        message: "Attachment",
        type: "attachment",
        addTime: DateTime.now(),
        senderId: Get.find<AuthController>().currentUser.value,
        receiverId: userModel,
        offerType: "",
        price: 0,
        providerReview: 0,
        reviewed: false,
        userReview: 0,
        attachment: "",
        action: "",
        finished: false,
        receiverMessage: "Attachment",
        hours: 0,
        transactionId: "",
        pickUp: LocationModel(),
        destination: LocationModel(),
        workType: "",
      );
      var chatId = await sendMessage(
        chatModel: chat,
        docId: uid,
      );
      String url = await uploadImage(
          image: pickedImage!.value!,
          uid: FirebaseAuth.instance.currentUser!.uid +
              DateTime.now().toIso8601String());
      updateChatById(uid: uid, chatId: chatId, body: {"attachment": url});
    } on PlatformException {
      Navigator.pop(context);

    }
  }

  Future<String> uploadImage({required File image, required uid}) async {
    Reference reference = _firebaseStorage.ref().child("chatsImage").child(uid);
    UploadTask uploadTask =
        reference.putFile(image, SettableMetadata(contentType: "image/jpg"));

    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  updateChatById(
      {required uid, required chatId, required Map<String, dynamic> body}) {
    _chatRef.doc(uid).collection("chats").doc(chatId).update(body);
  }

  deleteUnreadMessages({required String id, required String docId}) {
    _chatRef.doc(docId).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
        documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> unreadMessages = data["unreadMessages"];
        unreadMessages[id] = [];
        _chatRef.doc(docId).update({"unreadMessages": unreadMessages});
      }
    });
  }

  void updateWorkByWorkId(String workId, Map<String, dynamic> map) async {
    await _work.doc(workId).update(map);
  }

  void updateChatByLoop(
      {required String uid,
      required String param,
      required Map<String, dynamic> body}) {
    _chatRef
        .doc(uid)
        .collection("chats")
        .where("action", isEqualTo: param)
        .get()
        .then((value) {
      var id = value.docs[0].id;
      updateChatById(uid: uid, chatId: id, body: body);
    });
  }

  void sendNotification({required OSCreateNotification notification}) async {
    await OneSignal.shared.postNotification(notification);
  }

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
  }
}
