import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/chat_controller.dart';
import 'package:plug/utils/style.dart';
import 'package:plug/widgets/common_text.dart';

import '../../controllers/room_controller.dart';
import '../profile/components/image_container.dart';

class Livestream extends StatefulWidget {
  final String roomId;

  const Livestream({Key? key, required this.roomId}) : super(key: key);

  @override
  State<Livestream> createState() => _LivestreamState();
}

class _LivestreamState extends State<Livestream> {
  AuthController authController = Get.find<AuthController>();
  RoomController roomController = Get.find<RoomController>();
  ChatController chatController = Get.find<ChatController>();

  @override
  void initState() {
    roomController.getRoomById(roomId: widget.roomId);
    roomController.initEngine(roomId: widget.roomId);
    roomController.createClient();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Obx(() {
        return roomController.isCurrentRoomLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Stack(
                  children: [
                    _renderVideo(),
                    Obx(() {
                      return roomController.currentRoom.value!.sid!
                              .trim()
                              .isNotEmpty
                          ? Positioned(
                              top: 20,
                              left: 10,
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: const Center(
                                    child: Icon(Icons.live_tv,
                                        color: Colors.white, size: 16),
                                  )),
                            )
                          : Container(
                              height: 0,
                            );
                    }),
                    if (roomController.currentRoom.value?.ownerId!.id !=
                        FirebaseAuth.instance.currentUser!.uid)
                      Positioned(
                        top: 20,
                        left: 10,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 20,
                              ),
                              profileImage(
                                  upload: true,
                                  showCam: false,
                                  radi: 25,
                                  context: context,
                                  imageProvider: roomController.currentRoom
                                          .value!.ownerId!.profileUrl!.isEmpty
                                      ? const AssetImage("assets/images/profile.png")
                                      : NetworkImage(
                                              roomController.currentRoom.value!.ownerId!.profileUrl ?? "")
                                          as ImageProvider),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "${roomController.currentRoom.value!.ownerId!.firstname}"
                                    .capitalize!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: whiteColor,
                                    fontWeight: FontWeight.bold),
                              )
                            ]),
                      ),
                    Positioned(
                      bottom: 20,
                      left: 15,
                      right: 15,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() {
                            return roomController.showInputField.value
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 230,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.7,
                                        child: SingleChildScrollView(
                                          reverse: true,
                                          child: ListView(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            children: roomController
                                                .currentRoomChat
                                                .map((e) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 8.0),
                                                      child: Row(
                                                        children: [
                                                          profileImage(
                                                              upload: false,
                                                              showCam: false,
                                                              radi: 15,
                                                              context: context,
                                                              imageProvider: e
                                                                          .senderId!
                                                                          .profileUrl ==
                                                                      null
                                                                  ? const AssetImage(
                                                                      "assets/images/profile.png")
                                                                  : NetworkImage(
                                                                          "${e.senderId!.profileUrl}")
                                                                      as ImageProvider),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              e.message!,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 3,
                                                              softWrap: true,
                                                              style: const TextStyle(
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 20.0, top: 10, bottom: 20),
                                        child: TextField(
                                          controller:
                                              roomController.messageController,
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.done,
                                          maxLines: 10,
                                          minLines: 1,
                                          autofocus: false,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
                                            hintText: "Say something...",
                                            hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11.sp,
                                            ),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                borderSide: BorderSide.none),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                borderSide: BorderSide.none),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                borderSide: BorderSide.none),
                                            fillColor: whiteColor,
                                            filled: true,
                                            suffixIcon: InkWell(
                                              onTap: () {
                                                if (roomController
                                                    .messageController.text
                                                    .trim()
                                                    .isNotEmpty) {
                                                  chatController.sendRoomMessage(
                                                      roomId: roomController
                                                          .currentRoom
                                                          .value!
                                                          .id,
                                                      message: roomController
                                                          .messageController
                                                          .text);
                                                  roomController
                                                      .messageController
                                                      .clear();
                                                }
                                              },
                                              child: const Icon(
                                                Icons.send,
                                                color: blueColor,
                                              ),
                                            ),
                                          ),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14.sp),
                                        ),
                                      )
                                    ],
                                  )
                                : Container(
                                    height: 0,
                                  );
                          }),
                          const SizedBox(height: 10),
                          _toolbar(),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              );
      }),
    );
  }

  _renderVideo() {
    return SizedBox(
        height: double.infinity,
        child: Obx(() {
          return roomController.currentRoom.value?.ownerId!.id ==
                  FirebaseAuth.instance.currentUser!.uid
              ? roomController.localUserJoined.value
                  ? const rtc_local_view.SurfaceView(
                      zOrderMediaOverlay: true,
                      zOrderOnTop: true,
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
              : roomController.localUserJoined.value
                  ? rtc_remote_view.SurfaceView(
                      uid: int.parse(roomController.remoteUid.value),
                      channelId: roomController.currentRoom.value!.id!,
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
        }));
  }

  Widget _toolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        if (roomController.currentRoom.value!.ownerId!.id ==
            FirebaseAuth.instance.currentUser!.uid)
          Obx(() => InkWell(
                onTap: () {
                  roomController.muteMic();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      color: whiteColor, shape: BoxShape.circle),
                  child: Icon(
                    roomController.isMuted.value ? Icons.mic_off : Icons.mic,
                    color:
                        roomController.isMuted.value ? Colors.red : blueColor,
                    size: 25.0,
                  ),
                ),
              )),
        if (roomController.currentRoom.value!.ownerId!.id ==
            FirebaseAuth.instance.currentUser!.uid)
          InkWell(
            onTap: () {
              roomController.switchCamera();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration:
                  const BoxDecoration(color: whiteColor, shape: BoxShape.circle),
              child: const Icon(
                Icons.switch_camera,
                color: blueColor,
                size: 25.0,
              ),
            ),
          ),
        InkWell(
          onTap: () {
            showDialog(
                context: context,
                builder: (_) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      height: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 15.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: blueColor,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                CommonText(
                                    color: blueColor, text: "Leave Room"),
                              ],
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 15.0),
                            child: Center(
                              child: Text(
                                "Are you sure you want to leave room?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: "RedHatLight",
                                    color: greyColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.only(
                                bottom: 15, left: 20, right: 20),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              width: 1, color: greyColor)),
                                      child: const Center(
                                          child: CommonText(
                                              color: greyColor,
                                              text: "Cancel")),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      Get.back();
                                      Get.back();
                                      roomController.showInputField.value =
                                          false;
                                      roomController.leaveChannel();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: const Center(
                                        child: CommonText(
                                            color: whiteColor, text: "Leave"),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration:
                const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: const Icon(
              Icons.call_end,
              color: whiteColor,
              size: 25.0,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            roomController.showInputField.value =
                !roomController.showInputField.value;
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: whiteColor, shape: BoxShape.circle),
            child: const Icon(
              Ionicons.chatbubbles,
              color: blueColor,
              size: 25.0,
            ),
          ),
        ),
      ],
    );
  }
}
