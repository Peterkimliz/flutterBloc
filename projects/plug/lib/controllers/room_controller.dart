import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_engine.dart' as rtcengine;
import 'package:agora_rtm/agora_rtm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/chat_controller.dart';
import 'package:plug/controllers/user_controller.dart';
import 'package:plug/models/chat.dart';
import 'package:plug/models/room_model.dart';
import 'package:plug/screens/rooms/live.dart';
import 'package:plug/utils/style.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class RoomController extends FullLifeCycleController
    with GetTickerProviderStateMixin {
  rtcengine.RtcEngine? engine;
  AgoraRtmClient? agoraRtmClient;
  AgoraRtmChannel? rtmChannel;

  RxBool switchedCamera = RxBool(false);
  RxBool showInputField = RxBool(false);
  RxBool localUserJoined = RxBool(false);
  RxBool isCurrentRoomLoading = RxBool(false);
  RxBool isMuted = RxBool(false);
  RxString remoteUid = RxString("");
  RxList<Chat> currentRoomChat = RxList([]);
  late StreamSubscription<QuerySnapshot> roomChatStream;

  final roomFirestore = FirebaseFirestore.instance.collection("rooms");
  Rxn<RoomModel> currentRoom = Rxn(null);
  final client = http.Client();

  TextEditingController messageController = TextEditingController();

  createRoomInFirestore(
      {required context, required title, required String workId}) async {
    AuthController authController = Get.find<AuthController>();
    try {
      Get.defaultDialog(
          title: "Going Live",
          contentPadding: const EdgeInsets.all(10),
          content: const CircularProgressIndicator(),
          barrierDismissible: false);

      if (((await roomFirestore
              .doc("${authController.currentUser.value!.id}")
              .get())
          .exists)) {
        deleteRoomFromFirestore(currentRoom.value!.id!);
      }

      RoomModel livestream = RoomModel(
          workId: workId,
          ownerId: authController.currentUser.value!,
          id: authController.currentUser.value!.id,
          title: title,
          startedtAt: DateTime.now(),
          started: false,
          users: [],
          sid: "",
          resourceId: "",
          ended: false);

      roomFirestore
          .doc(authController.currentUser.value!.id)
          .set(livestream.toJson())
          .then((value) async {
        currentRoom.value = livestream;
        String token = await generateRtcToken(channelName: livestream.id!);
        updateRoomById(uid: livestream.id!, body: {"roomToken": token});
        currentRoom.value!.roomToken = token;
        currentRoom.refresh();
        Get.to(() => Livestream(roomId: currentRoom.value!.id!));
      });
      Get.back();
    } on FirebaseException {
      Get.back();
    }
  }

  getRoomById({required String roomId}) async {
    try {
      isCurrentRoomLoading.value = true;
      var snap = await roomFirestore.doc(roomId).get();
      var roomData = snap.data();
      RoomModel roomModel =
          RoomModel.fromJson(roomData as Map<String, dynamic>);
      currentRoom.value = roomModel;
      currentRoom.refresh();

      isCurrentRoomLoading.value = false;
      return roomModel;
    } catch (e) {
      isCurrentRoomLoading.value = false;
    }
  }

  Future<String> generateRtcToken({required String channelName}) async {
    Uri url=Uri.parse("$baseUrl/rooms/generateRtcToken/$channelName");
    print("URL IS ${url}");
    var response = await client
        .get(url);
    print("result is  ${response}");
    var result = jsonDecode(response.body);
    print("result is ${result}");

    return result["token"];
  }

  generateRtmToken() async {
    var url =
        "$baseUrl/rooms/generateRtmToken/${Get.find<AuthController>().currentUser.value!.agorauuid!}";
    var response = await client.get(Uri.parse(url));
    var result = jsonDecode(response.body);

    return result["token"];
  }

  void initEngine({required String roomId}) async {
    if (currentRoom.value != null) {
      leaveAgoraEngine();
    }
    await getRoomById(roomId: roomId);
    singleRoomChatStream(roomId);
    _initAgora(roomId: roomId);
  }

  _initAgora({required String roomId}) async {
    await [Permission.microphone, Permission.camera].request();
    engine =
        await RtcEngine.createWithContext(RtcEngineContext(agoraId.trim()));
    await engine?.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await engine?.enableAudioVolumeIndication(250, 10, true);
    await engine?.setDefaultAudioRouteToSpeakerphone(true);
    await engine?.enableVideo();
    await engine?.enableAudio();
    await engine?.setVideoEncoderConfiguration(
      VideoEncoderConfiguration(
        dimensions: const VideoDimensions(width: 640, height: 360),
        frameRate: VideoFrameRate.Fps30,
        bitrate: 0,
        orientationMode: VideoOutputOrientationMode.FixedPortrait,
      ),
    );
    await engine?.startPreview();
    engine?.setClientRole(ClientRole.Broadcaster);

    if (FirebaseAuth.instance.currentUser!.uid ==
        currentRoom.value!.ownerId!.id) {
      await engine?.muteLocalAudioStream(false);
      await engine?.enableAudio();
    } else {
      await engine?.setClientRole(rtcengine.ClientRole.Audience);
    }
    await _joinChannel(roomId: roomId);
    login();
  }

  void _addListeners() {
    engine?.setEventHandler(
      RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
        localUserJoined.value = true;
      }, userJoined: (uid, elapsed) {
        remoteUid.value = uid.toString();
      }, userOffline: (uid, reason) {
        remoteUid.value = "";
      }, leaveChannel: (stats) {
        remoteUid.value = "";
      }),
    );
  }

  _joinChannel({required roomId}) async {
    await engine?.joinChannel(
        currentRoom.value!.roomToken!,
        currentRoom.value!.id!,
        null,
        int.parse(
            "${Get.find<AuthController>().currentUser.value!.agorauuid!}"));
    _addListeners();
    sendRoomNotification();
    if (currentRoom.value!.ownerId!.id ==
        FirebaseAuth.instance.currentUser!.uid) {
      Get.find<ChatController>().updateWorkByWorkId(currentRoom.value!.workId!,
          {"roomId": currentRoom.value!.id!, "isLive": true});
    }
    if (currentRoom.value!.ownerId!.id !=
        FirebaseAuth.instance.currentUser!.uid) {
      addUserToRoom(
          userModel: Get.find<AuthController>().currentUser.value!,
          roomId: roomId);
    }
  }

  void switchCamera() {
    engine?.switchCamera().then((value) {
      switchedCamera.value = !switchedCamera.value;
    });
  }

  void muteMic() async {
    isMuted.value = !isMuted.value;
    await engine?.muteLocalAudioStream(isMuted.value);
  }

  leaveChannel() async {
    if (currentRoom.value!.ownerId!.id ==
        FirebaseAuth.instance.currentUser!.uid) {
      deleteRoomFromFirestore(currentRoom.value!.id!);
    }
    UserModel userModel = Get.find<AuthController>().currentUser.value!;
    await emitRoom(
        currentUser: userModel.toJson(),
        action: "leave",
        roomId: currentRoom.value!.id!,
        agoraRtmChannel: rtmChannel);

    removeUserFromRoom(
        roomId: currentRoom.value!.id,
        userModel: Get.find<AuthController>().currentUser.value!);
    leaveAgoraEngine();
  }

  void sendRoomNotification() async {
    ChatController chatController = Get.find<ChatController>();
    AuthController authController = Get.find<AuthController>();
    await Get.find<UserController>().getUserFollowers(
        id: FirebaseAuth.instance.currentUser!.uid, type: "followers");
    List<String?> playersId = Get.find<AuthController>()
        .currentUser
        .value!
        .followers!
        .map((e) => e.playerId)
        .toList();

    if (playersId.isNotEmpty) {
      List<String> ids = [];
      for (int i = 0; i < playersId.length; i++) {
        ids.add(playersId[i]!);
      }

      chatController.roomNotification(
          message: "${authController.currentUser.value!.firstname} is live",
          playersId: ids);
    }
  }

  Future<void> leaveAgoraEngine() async {
    await engine?.leaveChannel();
    await engine?.destroy();
    currentRoom.value = null;
    currentRoom.refresh();
    localUserJoined.value = false;
  }

  Future<void> deleteRoomFromFirestore(String id) async {
    Get.find<ChatController>().updateWorkByWorkId(
        currentRoom.value!.workId!, {"isLive": false, "workId": ""});

    await roomFirestore.doc(id).delete();
    currentRoom.value = null;
    currentRoom.refresh();
  }

  Future<void> deleteRoomMessages(String id) async {
    await roomFirestore
        .doc(id)
        .collection('chats')
        .snapshots()
        .forEach((querySnapshot) {
      for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
        docSnapshot.reference.delete();
      }
    });
  }

  addUserToRoom({required roomId, required UserModel userModel}) async {
    await roomFirestore.doc(roomId).update({
      "users": FieldValue.arrayUnion([userModel.toJson()])
    });
    if (currentRoom.value!.users!
            .indexWhere((element) => element.id == userModel.id) ==
        -1) {
      currentRoom.value!.users!.add(userModel);
      currentRoom.refresh();
    }
  }

  removeUserFromRoom({required roomId, required UserModel userModel}) async {
    await roomFirestore.doc(roomId).update({
      "users": FieldValue.arrayRemove([userModel.toJson()])
    });
    currentRoom.value!.users!
        .removeWhere((element) => element.id == userModel.id);
    currentRoom.refresh();
  }

  void createClient() async {
    agoraRtmClient = await AgoraRtmClient.createInstance(agoraId.trim());
    agoraRtmClient?.onMessageReceived = (RtmMessage message, String peerId) {};

    agoraRtmClient?.onConnectionStateChanged2 =
        (RtmConnectionState state, RtmConnectionChangeReason reason) {
      if (state == RtmConnectionState.aborted) {
        agoraRtmClient?.logout();
      }
    };
  }

  void login() async {
    var token = await generateRtmToken();
    await agoraRtmClient?.login(token,
        Get.find<AuthController>().currentUser.value!.agorauuid!.toString());
    joinRtmChannel();
  }

  void joinRtmChannel() async {
    rtmChannel = await _createChannel(currentRoom.value!.id!);
    await rtmChannel?.join();
    UserModel userModel = Get.find<AuthController>().currentUser.value!;
    userModel.geoPoint = null;
    emitRoom(
        action: "user_joined",
        currentUser: userModel.toJson(),
        roomId: currentRoom.value!.id!,
        agoraRtmChannel: rtmChannel);

    _initRoomData();
  }

  Future<AgoraRtmChannel?> _createChannel(String name) async {
    AgoraRtmChannel? channel = await agoraRtmClient?.createChannel(name);

    channel?.onMemberJoined = (RtmChannelMember member) {};
    channel?.onMemberLeft = (RtmChannelMember member) {};
    channel?.onMessageReceived = (RtmMessage message, RtmChannelMember member) {
      var decodedData = jsonDecode(message.text);
      roomListeners(
          decodedData, member.channelId, agoraRtmClient, engine, rtmChannel);
    };

    return channel;
  }

  void _initRoomData() {
    Get.find<ChatController>().sendRoomMessage(
        message:
            "${Get.find<AuthController>().currentUser.value!.firstname} joined 👋",
        roomId: currentRoom.value!.id);
  }

  emitRoom(
      {Map? currentUser,
      required String action,
      String roomId = "",
      bool? extra = false,
      Map<String, dynamic>? otherData,
      AgoraRtmChannel? agoraRtmChannel}) {
    sendChannelMessage(currentUser!,
        action: action, extra: extra!, roomId: roomId, otherData: otherData);
  }

  sendChannelMessage(Map<dynamic, dynamic> user,
      {String action = "",
      bool extra = false,
      AgoraRtmChannel? rtmChannell,
      String? roomId,
      Map<dynamic, dynamic>? otherData}) async {
    await rtmChannel?.sendMessage2(RtmMessage.fromText(jsonEncode({
      "action": action,
      "userData": user,
      "otherData": otherData,
      "roomId": currentRoom.value!.id,
      "extra": extra
    })));
  }

  roomListeners(decodedData, String roomId, AgoraRtmClient? rtmClient,
      RtcEngine? engine, AgoraRtmChannel? rtmChannel) {
    if (decodedData["roomId"] == roomId) {
      var user = UserModel.fromJson(decodedData["userData"]);
      if (decodedData["action"] == "leave") {
        currentRoom.value!.users!
            .removeWhere((element) => element.id == user.id);
        if (user.id == currentRoom.value!.ownerId!.id!) {
          currentRoom.value = RoomModel();
          Get.back();
          Get.snackbar('', "Room Has ended",
              backgroundColor: blackColor,
              colorText: Colors.white,
              duration: const Duration(seconds: 2));
        }

        currentRoom.refresh();
      }

      if (decodedData["action"] == "user_joined") {
        if (user.id != currentRoom.value!.ownerId!.id!) {
          currentRoom.value!.users!.add(user);
        }

        currentRoom.refresh();
      } else if (decodedData["action"] == "room_ended") {
        Get.snackbar('', "Room ended",
            backgroundColor: blackColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 2));

        Future.delayed(const Duration(seconds: 3), () {
          currentRoom.value = RoomModel();
          Get.back();
        });
      }
    }

    currentRoom.refresh();
  }

  Future<void> leaveRoomWhenKilled() async {
    if (currentRoom.value != null) {
      UserModel userModel = Get.find<AuthController>().currentUser.value!;
      userModel.geoPoint = null;
      await emitRoom(
          action: "leave",
          roomId: currentRoom.value!.id!,
          currentUser: userModel.toJson());
    }
  }

  void onResumed() async {
    if (currentRoom.value!.id != null &&
        currentRoom.value!.ownerId!.id ==
            FirebaseAuth.instance.currentUser!.uid) {
      engine?.muteLocalVideoStream(false);
      engine?.enableLocalVideo(true);
      engine?.enableVideo();
    }
  }

  @override
  void onClose() {
    leaveRoomWhenKilled();
    super.onClose();
  }

  startRecordingAudio() async {
    try {
      Get.defaultDialog(
          title: "Just a moment",
          contentPadding: const EdgeInsets.all(10),
          content: const CircularProgressIndicator(),
          barrierDismissible: false);
      var resourceGroup = await generateResourceGroup();
      var recordingResponse =
          await client.post(Uri.parse("$baseUrl/rooms/startrecordings"), body: {
        "token": currentRoom.value!.roomToken!,
        "channel": currentRoom.value!.id,
        "resource": resourceGroup,
        "uid":
            Get.find<AuthController>().currentUser.value!.agorauuid!.toString()
      });
      var response = jsonDecode(recordingResponse.body);

      Get.back();
      if (response["status"] == true) {
        updateRoomById(uid: currentRoom.value!.id!, body: {
          "resourceId": resourceGroup,
          "sid": response["recording"]["sid"]
        });
        currentRoom.value!.resourceId = resourceGroup;
        currentRoom.value!.sid = response["recording"]["sid"];
        currentRoom.refresh();
      } else {
        Get.snackbar("", "Room could not start",
            backgroundColor: Colors.red,
            snackPosition: SnackPosition.TOP,
            colorText: whiteColor);
      }
    } catch (e) {
      Get.back();
    }
  }

  generateResourceGroup() async {
    var response =
        await client.post(Uri.parse("$baseUrl/rooms/getResourcegroup/"), body: {
      "channel": currentRoom.value!.id,
      "uid": Get.find<AuthController>().currentUser.value!.agorauuid!.toString()
    });

    return response.body;
  }

  updateRoomById(
      {required String uid, required Map<String, dynamic> body}) async {
    await roomFirestore.doc(uid).update(body);
  }

  stopRecording(
      {required String sid,
      required String resourceId,
      required String channel}) async {
    var response =
        await client.post(Uri.parse("$baseUrl/rooms/stopRecording"), body: {
      "sid": sid,
      "channel": channel,
      "resource": resourceId,
      "uid": Get.find<AuthController>().currentUser.value!.agorauuid!.toString()
    });

    var jsonResponse = jsonDecode(response.body);

    if (jsonResponse["status"] == true) {
      currentRoom.value!.resourceId = "";
      currentRoom.value!.sid = "";
      currentRoom.refresh();
      updateRoomById(
          uid: currentRoom.value!.id!, body: {"resourceId": "", "sid": ""});
    }
  }

  singleRoomChatStream(String id) {
    currentRoomChat.value = [];
    roomChatStream = FirebaseFirestore.instance
        .collection("rooms/$id/chats")
        .orderBy("addTime", descending: false)
        .snapshots()
        .listen((event) {
      var chatty = event.docs.map((e) {
        Map<String, dynamic> data = e.data();

        Chat chatRoomModel = Chat(
          message: data['message'],
          senderId: UserModel.fromJson(data['senderId']),
        );

        return chatRoomModel;
      }).toList();
      // chatty.sort((a, b) => a.addTime!.compareTo(b.addTime));
      currentRoomChat.assignAll(chatty);
    });
  }

  @override
  void dispose() {
    leaveChannel();
    leaveAgoraEngine();
    engine?.leaveChannel();
    engine?.destroy();
    super.dispose();
  }
}
