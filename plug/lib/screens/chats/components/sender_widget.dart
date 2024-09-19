import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plugme/controllers/chat_controller.dart';
import 'package:plugme/models/chat.dart';
import 'package:plugme/models/user.dart';
import 'package:plugme/models/work.dart';
import 'package:plugme/screens/chats/components/receiver_offer_widget.dart';
import 'package:plugme/widgets/full_image.dart';

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
  return Container(
    margin: const EdgeInsets.only(bottom: 20, right: 10),
    constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.1,
        maxWidth: MediaQuery.of(context).size.width * 0.8),
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
              horizontal: chatData.type == "attachment" ? 0: 20,
              vertical: chatData.type == "attachment" ? 0 : 10),
          decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                    offset: Offset(1, 1), blurRadius: 3, color: Colors.grey)
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
          child: chatData.message == null || chatData.receiverMessage == null
              ? const Text("")
              : chatData.type == "offer"
                  ? receiverOfferWidget(
                      chatData: chatData,
                      context: context,
                      userModel: userModel,
                      type: "sender",
                      uid: uid)
                  : chatData.type == "attachment"
                      ? InkWell(
            onTap: (){
              Get.to(()=>FullImagePageRoute(imageDownloadUrl:chatData.attachment!), duration:
                  const Duration(milliseconds: 3000));
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
                placeholder: (context, url) {
                  return chatController.pickedImage!.value == null
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : Stack(
                    children: [
                      Container(
                        height: 200,
                        width: 150,
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(15),
                            image: DecorationImage(
                                image: FileImage(File(
                                    chatController
                                        .pickedImage!
                                        .value!
                                        .path)))),
                      ),
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    ],
                  );
                },
                errorWidget: (context, url, error) => Stack(
                  children: [
                    Container(
                      height: 200,
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image: FileImage(File(chatController
                                  .pickedImage!.value!.path)))),
                    ),
                    const Center(child: CircularProgressIndicator())
                  ],
                ),
              ),
            ),
          )
                      : chatData.type == "review"
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CommonText(
                                  color: whiteColor,
                                  text:
                                      "Review sent to ${chatData.receiverId!.firstname}",
                                  size: 12,
                                  fontFamily: "RedHatLight",
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.yellow, size: 15),
                                    const SizedBox(width: 3),
                                    CommonText(
                                        color: whiteColor,
                                        text: "${chatData.userReview}",
                                        size: 12,
                                        fontFamily: "RedHatDisplay")
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
                    Get.to(() => ReceiptPage(work: work, userModel: userModel));
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
  );
}
