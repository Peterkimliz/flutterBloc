import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/chat_controller.dart';
import 'package:plug/controllers/location_controller.dart';
import 'package:plug/models/chat.dart';
import 'package:plug/models/user.dart';
import 'package:plug/utils/style.dart';
import 'package:plug/widgets/common_text.dart';
import 'package:plug/widgets/custom_roundedbutton.dart';

import '../controllers/service_controller.dart';
import '../models/location_model.dart';

offerDialog(context, UserModel userModel, String uid) {
  ChatController chatController = Get.find<ChatController>();
  ServiceController serviceController = Get.find<ServiceController>();
  AuthController authController = Get.find<AuthController>();
  LocationController locationController = Get.find<LocationController>();
  showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Container(
            height: 220,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  offset: const Offset(0.1,0.1),
                  spreadRadius: 1.8,
                  blurRadius: 1.8

                )
              ],
                color: whiteColor, borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: CommonText(
                    color: blackColor,
                    text: "Are you sure?",
                    size: 18,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                            color: lightGrey,
                            borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                  color: yellowColor, shape: BoxShape.circle),
                              child: const CommonText(color: whiteColor, text: "\$"),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            CommonText(
                              color: blackColor,
                              text:
                                  "${chatController.hours.value * chatController.selectedPrice.value}",
                              fontFamily: "RedHatMedium",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 2,
                      child: customRoundedButton(
                          voidCallback: () {},
                          title: "${chatController.hours.value} Hours",
                          bgColor: greyColor.withOpacity(0.3),
                          fgColor: blackColor),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      Chat chat = Chat(
                        message:
                            "You have sent an offer for \$${chatController.selectedPrice.value * chatController.hours.value}.00\n Your offer is currently pending. You will be notified once it has been accepted or rejected. If User does not take any action offer will automatically expire within 30 minutes.",
                        senderInboxMessage:
                            "You have sent an offer for \$${chatController.selectedPrice.value * chatController.hours.value}.00\n Your offer is currently pending. You will be notified once it has been accepted or rejected. If User does not take any action offer will automatically expire within 30 minutes.",
                        type: "offer",
                        addTime: DateTime.now(),
                        senderId: authController.currentUser.value,
                        receiverId: userModel,
                        offerType: chatController.selectedOrderType.value,
                        price: chatController.selectedPrice.value,
                        providerReview: 0,
                        reviewed: false,
                        receiverInboxMessage:
                            "Dear ${userModel.firstname}, ${authController.currentUser.value!.firstname} has sent you an offer.",
                        userReview: 0,
                        attachment: "",
                        action: "accept",
                        finished: false,
                        receiverMessage:
                            "Dear ${userModel.firstname}, ${authController.currentUser.value!.firstname} has sent you an offer."
                            "\nPlease Accept or Reject within 30 minutes before offer expires.\nOffer: \$${chatController.selectedPrice.value}.00 Flat rate \nProcessing Fee: \$${0.030}\nTotal: \$${chatController.selectedPrice.value * chatController.hours.value + 0.030}",
                        hours: chatController.hours.value,
                        transactionId: "",
                        pickUp: locationController.fromPlace.value == null
                            ? LocationModel()
                            : LocationModel(
                                name:
                                    locationController.fromPlace.value!.address,
                                geoPoint: GeoPoint(
                                    locationController
                                        .fromPlace.value!.latitude!,
                                    locationController
                                        .fromPlace.value!.longitude!)),
                        destination: locationController.toPlace.value == null
                            ? LocationModel()
                            : LocationModel(
                                name: locationController.toPlace.value!.address,
                                geoPoint: GeoPoint(
                                    locationController.toPlace.value!.latitude!,
                                    locationController
                                        .toPlace.value!.longitude!)),
                        workType: Get.find<AuthController>()
                            .currentUser
                            .value
                            ?.service
                            ?.name,
                      );
                      chatController.sendMessage(
                        docId: uid,
                        chatModel: chat,
                      );
                      chatController.sendChatNotification(
                          chatId: uid,
                          type: "offer",
                          id: userModel.playerId!,
                          userModel: authController.currentUser.value!,
                          message:
                              "You have received an offer of ${int.parse(chatController.textEditingControllerPrice.text) * chatController.hours.value} from ${authController.currentUser.value!.firstname}",
                          screen: "ChatInbox");

                      chatController.selectedPrice.value = 0;
                      chatController.textEditingControllerPrice.text = "";
                      chatController.hours.value = 0;
                      chatController.selectedOrderType.value = "Flat Rate";
                      chatController.textEditingControllerHours.clear();
                      locationController.toPlace.value = null;
                      locationController.fromPlace.value = null;
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                          color: blackColor,
                          borderRadius: BorderRadius.circular(30)),
                      child: const CommonText(
                        color: whiteColor,
                        text: "Send Offer",
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      });
}
