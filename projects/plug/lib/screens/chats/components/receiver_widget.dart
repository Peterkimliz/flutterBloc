import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/chat_controller.dart';
import 'package:plug/models/chat.dart';
import 'package:plug/models/user.dart';
import 'package:plug/screens/chats/components/receiver_offer_widget.dart';
import 'package:plug/utils/date_formatter.dart';

import '../../../controllers/location_controller.dart';
import '../../../utils/style.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/full_image.dart';
import '../../location/location_page.dart';

Widget receiverWidget(
  Chat chatData,
  context,
  UserModel userModel,
  String uid,
) {
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
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.only(bottom: 20, left: 10),
                constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width * 0.1,
                    maxWidth: MediaQuery.of(context).size.width * 1.0),
                child: chatData.type == "attachment" &&
                            chatData.attachment == null ||
                        chatData.message == "" ||
                        chatData.receiverMessage == ""
                    ? const Text("")
                    : chatData.type == "audio" &&
                            chatData.attachment!.trim().isEmpty
                        ? null
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: CommonText(
                                    color: greyColor,
                                    text: DateFormatter
                                        .getVerboseDateTimeRepresentation(
                                            context, chatData.addTime!),
                                    size: 12,
                                    fontFamily: "RedHatDisplay",
                                  ),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                constraints: BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width * 0.1,
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.8),
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        chatData.type == "attachment" ? 0 : 20,
                                    vertical:
                                        chatData.type == "attachment" ? 0 : 10),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          linearGradientOne.withOpacity(0.9),
                                          linearGradientTwo.withOpacity(0.5),
                                        ],
                                        stops: const [
                                          0.0,
                                          1.0
                                        ],
                                        begin: FractionalOffset.topLeft,
                                        end: FractionalOffset.bottomRight,
                                        tileMode: TileMode.clamp),
                                    borderRadius: BorderRadius.circular(20)),
                                child:chatData.deleted == true
                                    ? const Row(
                                  children: [
                                    Icon(Icons.block_flipped,color: blackColor,),
                                    SizedBox(width: 10,),
                                    CommonText(
                                      color: blackColor,
                                      text: "This message was deleted",
                                      size: 12,
                                      fontFamily: "RedHatDisplay",
                                    ),
                                  ],
                                )
                                    : chatData.type == "offer"
                                    ? receiverOfferWidget(
                                        chatData: chatData,
                                        context: context,
                                        userModel: userModel,
                                        type: "receiver",
                                        uid: uid)
                                    : chatData.type == "audio"
                                        ? InkWell(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              // crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    if (chatController
                                                            .playingAudio
                                                            .value &&
                                                        chatController
                                                                .playingAudioId
                                                                .value ==
                                                            chatData.id) {
                                                      chatController.audioPlayer
                                                          .pause();
                                                    } else {
                                                      chatController
                                                          .playingAudioId
                                                          .value = chatData.id!;
                                                      chatController.audioPlayer
                                                          .play(UrlSource(
                                                              chatData
                                                                  .attachment!));
                                                    }
                                                  },
                                                  child: CircleAvatar(
                                                    radius: 20,
                                                    backgroundColor: Colors.red,
                                                    child: Obx(() => Icon(
                                                          chatController
                                                                      .playingAudio
                                                                      .value &&
                                                                  chatController
                                                                          .playingAudioId
                                                                          .value ==
                                                                      chatData
                                                                          .id
                                                              ? Icons.pause
                                                              : Icons
                                                                  .play_arrow,
                                                          color: Colors.white,
                                                        )),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Obx(() => Slider(
                                                    value: chatController
                                                        .position
                                                        .value!
                                                        .inSeconds
                                                        .toDouble(),
                                                    max: chatController.duration
                                                        .value!.inSeconds
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
                                                      .drawRoute(
                                                          chatData: chatData);
                                                  Get.to(() => LocationPage(
                                                      type: "view",
                                                      chatId: "",
                                                      userModel: userModel));
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .location_on_rounded,
                                                        color: Colors.white),
                                                    Text(
                                                      "${chatData.senderId!.firstname} shared location",
                                                      style: const TextStyle(
                                                          color: whiteColor,
                                                          fontSize: 17,
                                                          fontFamily:
                                                              "RedHatLight",
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
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
                                                                  chatData
                                                                      .attachment!),
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      3000));
                                                    },
                                                    child: SizedBox(
                                                      height: 200,
                                                      width: 150,
                                                      child: CachedNetworkImage(
                                                        imageUrl: chatData
                                                            .attachment!,
                                                        imageBuilder: (context,
                                                                imageProvider) =>
                                                            Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        placeholder:
                                                            (context, url) =>
                                                                const Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(
                                                                Icons.error),
                                                      ),
                                                    ),
                                                  )
                                                : chatData.type == "review"
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          CommonText(
                                                            color: whiteColor,
                                                            text:
                                                                "Review from ${chatData.senderId!.firstname}",
                                                            size: 12,
                                                            fontFamily:
                                                                "RedHatLight",
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              const Icon(
                                                                Icons.star,
                                                                color: Colors
                                                                    .yellow,
                                                                size: 15,
                                                              ),
                                                              const SizedBox(
                                                                width: 3,
                                                              ),
                                                              CommonText(
                                                                color:
                                                                    whiteColor,
                                                                text:
                                                                    "${chatData.userReview}",
                                                                size: 12,
                                                                fontFamily:
                                                                    "RedHatDisplay",
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    : CommonText(
                                                        color: whiteColor,
                                                        text: chatData
                                                            .receiverMessage!,
                                                        size: 12,
                                                        fontFamily:
                                                            "RedHatDisplay",
                                                      ),
                              ),
                              const SizedBox(height: 20)
                            ],
                          ),
              )),
        );
}
