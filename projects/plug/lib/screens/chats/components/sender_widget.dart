import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/chat_controller.dart';
import 'package:plug/controllers/location_controller.dart';
import 'package:plug/models/chat.dart';
import 'package:plug/models/user.dart';
import 'package:plug/models/work.dart';
import 'package:plug/screens/chats/components/receiver_offer_widget.dart';
import 'package:plug/screens/location/location_page.dart';
import 'package:plug/widgets/full_image.dart';

import '../../../utils/date_formatter.dart';
import '../../../utils/style.dart';
import '../../../widgets/common_text.dart';
import '../../joblist/receipt_page.dart';

Widget senderWidget(
    {required Chat chatData,
    required context,
    required UserModel userModel,
    required uid}) {
  ChatController chatController = Get.find<ChatController>();
  return InkWell(
          onTap: () {
            chatController.selectedMessages
                .removeWhere((element) => element.id == chatData.id);
            chatController.selectedMessages.refresh();
          },
          onLongPress: () {
            chatController.addChatToDeleteList(chatData: chatData);
          },
          child: Obx(() => Container(
                color: chatController.checkChatExistInDeleteList(
                            chatData: chatData) ==
                        true
                  ? linearGradientOne.withOpacity(0.2)
                  : Colors.transparent,
          margin: const EdgeInsets.only(bottom: 8, ),
          padding: const EdgeInsets.only(bottom: 10, right: 10,top: 3),
          constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width * 0.1,
              maxWidth: MediaQuery.of(context).size.width * 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: CommonText(
                    color: greyColor,
                    text: DateFormatter.getVerboseDateTimeRepresentation(
                        context, chatData.addTime!),
                    size: 12,
                    fontFamily: "RedHatDisplay"),
              ),
              const SizedBox(height: 3),
              Container(
                constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width * 0.1,
                    maxWidth: MediaQuery.of(context).size.width * 0.8),
                padding: EdgeInsets.symmetric(
                    horizontal: chatData.type == "attachment" ? 0 : 20,
                    vertical: chatData.type == "attachment" ? 0 : 10),
                decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.grey)
                    ],
                    gradient: const LinearGradient(
                        colors: [
                          linearGradientOne,
                          linearGradientTwo,
                        ],
                        stops: [
                          0.0,
                          1.0
                        ],
                        begin: FractionalOffset.topLeft,
                        end: FractionalOffset.bottomRight,
                        tileMode: TileMode.decal),
                    borderRadius: BorderRadius.circular(15)),
                child: chatData.deleted == true
                    ? const Row(
                  children: [
                    Icon(Icons.block_flipped,color: blackColor,),
                    SizedBox(width: 10,),
                    CommonText(
                      color: blackColor,
                      text: "You deleted this message",
                      size: 12,
                      fontFamily: "RedHatDisplay",
                    ),
                  ],
                )
                    :




                chatData.message == null ||
                        chatData.receiverMessage == null
                    ? const Text("")
                    : chatData.type == "offer"
                        ? receiverOfferWidget(
                            chatData: chatData,
                            context: context,
                            userModel: userModel,
                            type: "sender",
                            uid: uid)
                        : chatData.type == "audio"
                            ? chatData.type == "audio" &&
                                    chatData.attachment!.trim().isEmpty
                                ? const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      Icon(
                                        Icons.upload,
                                        color: Colors.white,
                                      ),
                                    ],
                                  )
                                : InkWell(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (chatController
                                                    .playingAudio.value &&
                                                chatController
                                                        .playingAudioId.value ==
                                                    chatData.id) {
                                              chatController.audioPlayer
                                                  .pause();
                                            } else {
                                              chatController.playingAudioId
                                                  .value = chatData.id!;
                                              chatController.audioPlayer.play(
                                                  UrlSource(
                                                      chatData.attachment!));
                                            }
                                          },
                                          child: CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.red,
                                            child: Obx(() => Icon(
                                                  chatController.playingAudio
                                                              .value &&
                                                          chatController
                                                                  .playingAudioId
                                                                  .value ==
                                                              chatData.id
                                                      ? Icons.pause
                                                      : Icons.play_arrow,
                                                  color: Colors.white,
                                                )),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Obx(() => Slider(
                                            value:
                                                chatController.playingAudioId
                                                            .value !=
                                                        chatData.id
                                                    ? 0
                                                    : chatController
                                                        .position.value!.inSeconds
                                                        .toDouble(),
                                            max: chatController
                                                .duration.value!.inSeconds
                                                .toDouble(),
                                            onChanged: (va) {}))
                                      ],
                                    ),
                                  )
                            : chatData.type == "location"
                                ? InkWell(
                                    onTap: () {
                                      Get.find<LocationController>()
                                          .markers
                                          .clear();
                                      Get.find<LocationController>()
                                          .polyline
                                          .clear();
                                      Get.find<LocationController>()
                                          .drawRoute(chatData: chatData);
                                      Get.to(() => LocationPage(
                                          type: "view",
                                          chatId: "",
                                          userModel: userModel));
                                    },
                                    child: const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.location_on_rounded,
                                            color: Colors.white),
                                        Text(
                                          "You shared location",
                                          style: TextStyle(
                                              color: whiteColor,
                                              fontSize: 17,
                                              fontFamily: "RedHatLight",
                                              decoration:
                                                  TextDecoration.underline),
                                        )
                                      ],
                                    ),
                                  )
                                : chatData.type == "attachment"
                                    ? InkWell(
                                        onTap: () {
                                          Get.to(
                                              () => FullImagePageRoute(
                                                  imageDownloadUrl:
                                                      chatData.attachment!),
                                              duration: const Duration(
                                                  milliseconds: 3000));
                                        },
                                        child: SizedBox(
                                          height: 200,
                                          width: 150,
                                          child: CachedNetworkImage(
                                            imageUrl: chatData.attachment!,
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            placeholder: (context, url) {
                                              return chatController
                                                          .pickedImage!.value ==
                                                      null
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    )
                                                  : Stack(
                                                      children: [
                                                        Container(
                                                          height: 200,
                                                          width: 150,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              image: DecorationImage(
                                                                  image: FileImage(File(
                                                                      chatController
                                                                          .pickedImage!
                                                                          .value!
                                                                          .path)))),
                                                        ),
                                                        const Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        )
                                                      ],
                                                    );
                                            },
                                            errorWidget:
                                                (context, url, error) => Stack(
                                              children: [
                                                Container(
                                                  height: 200,
                                                  width: 150,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      image: DecorationImage(
                                                          image: FileImage(File(
                                                              chatController
                                                                  .pickedImage!
                                                                  .value!
                                                                  .path)))),
                                                ),
                                                const Center(
                                                    child:
                                                        CircularProgressIndicator())
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : chatData.type == "review"
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CommonText(
                                                color: whiteColor,
                                                text:
                                                    "Review sent to ${chatData.receiverId!.firstname}",
                                                size: 12,
                                                fontFamily: "RedHatLight",
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  const Icon(Icons.star,
                                                      color: Colors.yellow,
                                                      size: 15),
                                                  const SizedBox(width: 3),
                                                  CommonText(
                                                      color: whiteColor,
                                                      text:
                                                          "${chatData.userReview}",
                                                      size: 12,
                                                      fontFamily:
                                                          "RedHatDisplay")
                                                ],
                                              ),
                                            ],
                                          )
                                        : CommonText(
                                            color: whiteColor,
                                            text: "${chatData.message}",
                                            size: 12,
                                            fontFamily: "RedHatDisplay",
                                          ),
              ),
              if (chatData.type == "review")
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: InkWell(
                      onTap: () async {
                        try {
                          Get.defaultDialog(
                              title: "Just a moment",
                              contentPadding: const EdgeInsets.all(10),
                              content: const CircularProgressIndicator(),
                              barrierDismissible: false);

                          var docSnapshot = await FirebaseFirestore.instance
                              .collection('work')
                              .doc(chatData.workId)
                              .get();
                          Map<String, dynamic>? data = docSnapshot.data();
                          Work work = Work.fromJson(data!);
                          Get.back();
                          Get.to(() =>
                              ReceiptPage(work: work, userModel: userModel));
                        } catch (e) {
                          Get.back();
                        }
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.remove_red_eye, color: whiteColor),
                          SizedBox(width: 10),
                          CommonText(
                            color: whiteColor,
                            text: "View Receipt",
                            size: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: "RedHatMedium",
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        )),
  );
}
