import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/room_controller.dart';
import 'package:plug/controllers/service_controller.dart';
import 'package:plug/controllers/user_controller.dart';
import 'package:plug/models/chat.dart';
import 'package:plug/models/inbox.dart';
import 'package:plug/models/user.dart';
import 'package:plug/models/work.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:plug/utils/style.dart';
import 'package:plug/widgets/common_text.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';
import '../models/request.dart';

class ChatController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final _chatRef = FirebaseFirestore.instance.collection("messages");
  final _offerCancel = FirebaseFirestore.instance.collection("offerCancel");
  final roomChatRef = FirebaseFirestore.instance.collection("rooms");
  final _offers = FirebaseFirestore.instance.collection("offers");
  final _work = FirebaseFirestore.instance.collection("work");
  final _request = FirebaseFirestore.instance.collection("request");
  final _firebaseStorage = FirebaseStorage.instance;
  late TabController tabController;
  RxBool showTabBar = RxBool(false);
  RxBool downloadingAudio = RxBool(false);
  RxBool recordingAudio = RxBool(false);
  RxBool playingAudio = RxBool(false);

  RxList<Chat> selectedMessages = RxList([]);

  RxString playingAudioId = RxString("");
  final RxString _filePath = RxString("");

  TextEditingController textEditingController = TextEditingController();
  TextEditingController textEditingControllerPrice = TextEditingController();
  ScrollController scrollController = ScrollController();
  FocusNode focusNode = FocusNode();
  RxInt selectedPrice = RxInt(0);
  RxInt hours = RxInt(0);
  Rxn<Duration> duration = Rxn(Duration.zero);
  Rxn<Duration> position = Rxn(Duration.zero);

  Rxn<File>? pickedImage = Rxn(null);

  List<String> orderType = ["Flat Rate", "Hourly"];
  RxString selectedOrderType = RxString("Flat Rate");

  TextEditingController textEditingControllerHours = TextEditingController();
  RxBool isChatPage = RxBool(false);

  late Timer _timer;
  RxInt secondsElapsed = RxInt(0);
  late AudioRecorder audioRecord = AudioRecorder();
  late AudioPlayer audioPlayer = AudioPlayer();
  RxString notificationId = RxString("");


  static const int _maxCancellationCount = 3;
  static const Duration _timeFrame = Duration(hours: 24);

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      secondsElapsed.value = secondsElapsed.value + 1;
    });
  }

  void stopTimer() {
    _timer.cancel();
    secondsElapsed.value = 0;
  }

  Future<void> startRecording() async {
    try {
      final bool isPermissionGranted = await audioRecord.hasPermission();
      if (!isPermissionGranted) {
        return;
      }
      final directory = await getApplicationDocumentsDirectory();
      String fileName =
          'recording_${DateTime.now().millisecondsSinceEpoch}.mp3';
      _filePath.value = '${directory.path}/$fileName';
      const config = RecordConfig(
          encoder: AudioEncoder.aacLc, sampleRate: 44100, bitRate: 128000);

      await audioRecord.start(config, path: _filePath.value);
      startTimer();
      recordingAudio.value = true;
    } catch (e) {
      ScaffoldMessenger.of(Get.context!)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> stopRecording({required userModel, required uid}) async {
    try {
      recordingAudio.value = false;
      stopTimer();
      String? path = await audioRecord.stop();
      Chat chat = Chat(
        message: "Audio",
        type: "audio",
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
        receiverMessage: "Audio",
        senderInboxMessage: "Audio",
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
      String url = await uploadAudioToStorage(File(path!));
      updateChatById(uid: uid, chatId: chatId, body: {"attachment": url});
    } catch (e) {
      ScaffoldMessenger.of(Get.context!)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    audioRecord.dispose();
    _timer.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesStr = minutes < 10 ? '0$minutes' : '$minutes';
    String secondsStr =
        remainingSeconds < 10 ? '0$remainingSeconds' : '$remainingSeconds';
    return '$minutesStr:$secondsStr';
  }

  sendMessage({required docId, required Chat chatModel}) async {
    String chatId = "";
    List<String> users = [];
    users.add(FirebaseAuth.instance.currentUser!.uid);
    users.add(chatModel.receiverId!.id!);
    chatModel.users = users;
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
            "lmi": chatId,
            "senderMessage": chatModel.senderInboxMessage,
            "receiverMessage": chatModel.receiverInboxMessage,
            "senderId": Get.find<AuthController>().currentUser.value!.toJson(),
            "reciverId": chatModel.receiverId!.toJson(),
            "price": chatModel.price,
            "type": chatModel.type,
            "time": DateTime.now(),
            "deletedFor":[],
            "deleted":false,
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
                        lmi: chatId,
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

      await _work.get().then((value) async {
        if (value.docs.isNotEmpty) {
          for (var element in value.docs) {
            int currentPosition = element.data()['position'];
            await element.reference.update({'position': currentPosition + 1});
          }
        }
      });
      var workId = _work.doc().id;
      Work work = Work(
        workId: workId,
        price: price,
        rateType: rateType,
        provider: userModel,
        userId: Get.find<AuthController>().currentUser.value,
        status: "pending",
        workType: workType,
        transactionId: transactionId,
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
      await _work.doc(workId).set(work.toJson());
      authController.updateSingleItem(body: {"totalJobs": FieldValue.increment(1)}, id: userModel.id!);

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

  createRequest({
    required UserModel userModel,
    required price,
    required String uid,
  }) async {
    try {
      List<String> users = [];
      users.add(Get.find<AuthController>().currentUser.value!.id!);
      users.add(userModel.id!);
      await _request.get().then((value) async {
        if (value.docs.isNotEmpty) {
          for (var element in value.docs) {
            int currentPosition = element.data()['position'];
            await element.reference.update({'position': currentPosition + 1});
          }
        }
      });
      var requestId = _request.doc().id;
      Request work = Request(
        requestId: requestId,
        price: price,
        provider: userModel,
        userId: Get.find<AuthController>().currentUser.value,
        position: 0,
        users: users,
        time: DateTime.now(),
      );
      await _request.doc(requestId).set(work.toJson());
      return requestId;
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
    print("player id is $id");
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
    audioPlayer.onPlayerStateChanged.listen((event) {
      playingAudio.value = event == PlayerState.playing;
    });
    audioPlayer.onDurationChanged.listen((event) {
      print("position Change is ${event}");
      duration.value = event;
    });
    audioPlayer.onPositionChanged.listen((event) {
      print("position Change is ${event}");
      position.value = event;
    });

    tabController = TabController(length: 2, vsync: this);
    super.onInit();
  }

  Future<String> uploadAudioToStorage(File audioFile) async {
    try {
      downloadingAudio.value = true;
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('chatAudios/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask =
          ref.putFile(audioFile, SettableMetadata(contentType: 'audio/mp3'));

      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      downloadingAudio.value = false;
      return downloadUrl;
    } catch (error) {
      downloadingAudio.value = false;
      return "";
    }
  }

  String formatPlayTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [if (duration.inHours > 60) hours, minutes, seconds].join(":");
  }

  void updateRequestPositions(List<Request> myJobs) async {
    for (int i = 0; i < myJobs.length; i++) {
      await _request.doc(myJobs[i].requestId).update({'position': i});
      sendChatNotification(
          id: myJobs[i].userId!.playerId!,
          userModel: myJobs[i].userId!,
          message: "Your request has been shifted to $i",
          screen: "profile",
          chatId: "",
          type: "");
    }
  }

  deleteRequest({required String id}) async {
    await _request.doc(id).delete();
  }

  addChatToDeleteList({required Chat chatData}) {
    var index =
        selectedMessages.indexWhere((element) => element.id == chatData.id);
    if (index == -1) {
      selectedMessages.add(chatData);
    } else {
      selectedMessages.removeWhere((element) => element.id == chatData.id);
    }
    selectedMessages.refresh();
  }

  bool checkChatExistInDeleteList({required Chat chatData}) {
    var index =
        selectedMessages.indexWhere((element) => element.id == chatData.id);
    if (index == -1) {
      return false;
    } else {
      return true;
    }
  }

  bool checkMessageAreOfSamePerson() {
    var deletedIndex =
        selectedMessages.indexWhere((element) => element.deleted == true);

    var index = selectedMessages.indexWhere((element) =>
        element.senderId!.id == FirebaseAuth.instance.currentUser!.uid);
    if (index == -1 || deletedIndex != -1) {
      return false;
    }

    String firstItem = selectedMessages[index].senderId!.id!;
    for (int i = 1; i < selectedMessages.length; i++) {
      if (selectedMessages[i].senderId!.id != firstItem) {
        return false;
      }
    }
    return true;
  }

  deleteDialog({required String uid}) {
    showDialog(
        context: Get.context!,
        builder: (_) {
          return AlertDialog(
            title: Center(
              child: CommonText(
                  color: Colors.black,
                  text: "Delete ${selectedMessages.length} Message "),
            ),
            content: Row(
              children: [
                const Spacer(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (checkMessageAreOfSamePerson() == true)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: InkWell(
                          onTap: () {
                            Get.back();
                            deleteMessage(type: "all", uid: uid);

                          },
                          child: const CommonText(
                              color: linearGradientOne,
                              text: "Delete for every one"),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          deleteMessage(type: "me", uid: uid);
                        },
                        child: const CommonText(
                            color: linearGradientOne, text: "Delete for me"),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: const CommonText(
                            color: linearGradientOne, text: "Cancel"))
                  ],
                ),
              ],
            ),
          );
        });
  }

  deleteMessage({required String type, required String uid}) {
    for (var item in selectedMessages) {
      if (type == "all") {
        _chatRef
            .doc(uid)
            .collection("chats")
            .doc(item.id)
            .update({"deleted": true}).then((value) {
          FirebaseFirestore.instance
              .collection("messages")
              .where("lmi", isEqualTo: item.id)
              .get()
              .then((value) {
            String id = value.docs[0].id;
            FirebaseFirestore.instance.collection("messages").doc(id).update({
              "senderMessage": "You deleted this message",
              "receiverMessage": "This message was deleted",
              "deleted": true
            });
          });
        });
      } else {
        _chatRef.doc(uid).collection("chats").doc(item.id).update({
          "users":
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        }).then((value) {
          FirebaseFirestore.instance
              .collection("messages")
              .where("lmi", isEqualTo: item.id)
              .get()
              .then((value) {
            String id = value.docs[0].id;
            FirebaseFirestore.instance.collection("messages").doc(id).update({
              "deletedFor": FieldValue.arrayUnion(
                  [FirebaseAuth.instance.currentUser!.uid])
            });
          });
        });
      }
    }
    selectedMessages.clear();
    selectedMessages.refresh();
  }

  deleteRequestWithPosition({required Request work}) async {
    ServiceController serviceController = Get.find<ServiceController>();
    serviceController.request
        .removeWhere((element) => element.requestId == work.requestId);
    String uid = await getChatIdInboxes(
        user: Get.find<UserController>().currentProfile.value!.id!);
    _chatRef
        .doc(uid)
        .collection("chats")
        .where("action", isEqualTo: "coming")
        .get()
        .then((value) {
      Chat chat = Chat.fromJson(value.docs[0]);
      print("DOC is ${chat.toJson()}");
      var id = value.docs[0].id;
      updateChatById(
          uid: uid, chatId: id, body: {"finished": true, "rejected": true});
      Get.find<ServiceController>().cancelTransaction(
          uid: uid,
          userModel: Get.find<UserController>().currentProfile.value!,
          chaData: chat);

      sendChatNotification(
          id: work.userId!.playerId!,
          userModel: work.userId!,
          message: "Your request has been deleted",
          screen: "profile",
          chatId: "chatId",
          type: "type");
      deleteRequest(id: work.requestId.toString());
    });
  }

  Future<void> cancelOffer(String userId, VoidCallback voidCallback) async {
    final bool exceededLimit = await hasExceededCancellationLimit(userId);
    if (exceededLimit) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
        content: CommonText(
            color: Colors.white, text: "Your offer cancel limit has exceeded for today"),
        backgroundColor: Colors.red,
      ));
    } else {
      await trackCancellationForUser(userId);
      voidCallback();
      ScaffoldMessenger.of(Get.context!).showSnackBar(const SnackBar(
        content: CommonText(color: Colors.white, text: "Offer Cancelled"),
        backgroundColor: Colors.green,
      ));
    }
  }

  Future<int> getCancelledCountForUser(String userId) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot = await _offerCancel.doc(userId).get();
    final Map<String, dynamic>? data = snapshot.data();
    final List<dynamic>? cancellations = data?['cancellations'];
    return cancellations?.length ?? 0;

    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String key = _keyPrefix + userId;
    // final List<String>? cancellations = prefs.getStringList(key);
    // return cancellations?.length ?? 0;
  }

  Future<void> trackCancellationForUser(String userId) async {
    final DocumentReference<Map<String, dynamic>> userRef = _offerCancel.doc(userId);
    final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userRef.get();
    final List<dynamic> cancellations = List<dynamic>.from(userSnapshot.data()?['cancellations'] ?? []);
    cancellations.add(DateTime.now().toString());
    await userRef.set({'cancellations': cancellations});
    _removeOldCancellations(userId, cancellations);
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String key = _keyPrefix + userId;
    // final List<String> cancellations = prefs.getStringList(key) ?? [];
    // cancellations.add(DateTime.now().toString());
    // _removeOldCancellations(cancellations);
    // prefs.setStringList(key, cancellations);
  }

  Future<bool> hasExceededCancellationLimit(String userId) async {
    final int cancellationCount = await getCancelledCountForUser(userId);
    return cancellationCount >= _maxCancellationCount;
  }

  void _removeOldCancellations(String userId, List<dynamic> cancellations)async {
    final DateTime now = DateTime.now();

    final List<String> oldCancellations = cancellations
        .where((cancelDate) {
      final DateTime cancelDateTime = DateTime.parse(cancelDate);
      return now.difference(cancelDateTime) > _timeFrame;
    })
        .cast<String>()
        .toList();

    if (oldCancellations.isNotEmpty) {
      final DocumentReference<Map<String, dynamic>> userRef = _offerCancel.doc(userId);
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userRef.get();
      final List<dynamic> updatedCancellations = List<dynamic>.from(userSnapshot.data()?['cancellations'] ?? []);
      updatedCancellations.removeWhere((cancelDate) => oldCancellations.contains(cancelDate));
      await userRef.set({'cancellations': updatedCancellations});
    }
    // final DateTime now = DateTime.now();
    // cancellations.removeWhere((cancelDate) {
    //   final DateTime cancelDateTime = DateTime.parse(cancelDate);
    //   return now.difference(cancelDateTime) > _timeFrame;
    // });
  }
}
