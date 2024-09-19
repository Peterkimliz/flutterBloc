import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plugme/models/chat.dart';
import 'package:plugme/models/user.dart';
import 'package:plugme/screens/chats/components/receiver_offer_widget.dart';
import 'package:plugme/utils/date_formatter.dart';

import '../../../utils/style.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/full_image.dart';

Widget receiverWidget(
  Chat chatData,
  context,
  UserModel userModel,
  String uid,
) {
  return Container(
    margin: const EdgeInsets.only(right: 40, left: 10),
    constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.1,
        maxWidth: MediaQuery.of(context).size.width * 0.7),
    child: chatData.type == "attachment" && chatData.attachment == null ||
            chatData.message == "" ||
            chatData.receiverMessage == ""
        ? const Text("")
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: CommonText(
                    color: greyColor,
                    text: DateFormatter.getVerboseDateTimeRepresentation(
                        context, chatData.addTime!),
                    size: 12,
                    fontFamily: "RedHatDisplay",
                  ),
                ),
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
                child: chatData.type == "offer"
                    ? receiverOfferWidget(
                        chatData: chatData,
                        context: context,
                        userModel: userModel,
                        type: "receiver",
                        uid: uid)
                    : chatData.type == "attachment"
                        ? InkWell(
                            onTap: () {
                              Get.to(
                                  () =>
                                      FullImagePageRoute(imageDownloadUrl:chatData.attachment!),
                                  duration: const Duration(milliseconds: 3000));
                            },
                            child: SizedBox(
                              height: 200,
                              width: 150,
                              child: CachedNetworkImage(
                                imageUrl: chatData.attachment!,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
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
                                        "Review from ${chatData.senderId!.firstname}",
                                    size: 12,
                                    fontFamily: "RedHatLight",
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 15,
                                      ),
                                      const SizedBox(
                                        width: 3,
                                      ),
                                      CommonText(
                                        color: whiteColor,
                                        text: "${chatData.userReview}",
                                        size: 12,
                                        fontFamily: "RedHatDisplay",
                                      )
                                    ],
                                  ),
                                ],
                              )
                            : CommonText(
                                color: whiteColor,
                                text: chatData.receiverMessage!,
                                size: 12,
                                fontFamily: "RedHatDisplay",
                              ),
              ),
              const SizedBox(height: 20)
            ],
          ),
  );
}
