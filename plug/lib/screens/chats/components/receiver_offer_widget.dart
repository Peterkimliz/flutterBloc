import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/controllers/chat_controller.dart';
import 'package:plugme/controllers/room_controller.dart';
import 'package:plugme/models/chat.dart';
import 'package:plugme/models/user.dart';

import '../../../controllers/service_controller.dart';
import '../../../controllers/wallet_controller.dart';
import '../../../models/location_model.dart';
import '../../../utils/style.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custom_roundedbutton.dart';
import '../../profile/components/rating_dialog.dart';

Widget receiverOfferWidget(
    {required Chat chatData,
    required context,
    required UserModel userModel,
    required String type,
    required String uid}) {
  ChatController chatController = Get.find<ChatController>();
  AuthController authController = Get.find<AuthController>();
  return Column(
    children: [
      CommonText(
        color: whiteColor,
        size: 12,
        fontFamily: "RedHatDisplay",
        text: type == "sender"
            ? "${chatData.message}"
            : "${chatData.receiverMessage}",
      ),
      if (chatData.finished == true)
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CommonText(
              color: chatData.rejected == true ? Colors.red : Colors.green,
              size: 12,
              fontFamily: "RedHatDisplay",
              text: "${chatData.action}".capitalize!,
            ),
          ),
        ),
      chatData.action == "accept" &&
              chatData.finished == false &&
              type == "receiver"
          ? switchActions(
              chatData: chatData,
              context: context,
              firstTitle: "Decline",
              secondTitle: "Hire Now",
              firstAction: () {
                Chat chatModelData = Chat(
                  message:
                      "You have rejected ${userModel.firstname!} offer. \nOffer: \$${chatData.price}.00\nProcessing Fee: \$${0.030}\nTotal: \$${chatData.price! + 0.030}",
                  senderInboxMessage:
                      "You have rejected ${userModel.firstname!} offer. \nOffer: \$${chatData.price}.00\nProcessing Fee: \$${0.030}\nTotal: \$${chatData.price! + 0.030}",
                  type: "offer",
                  addTime: DateTime.now(),
                  senderId: Get.find<AuthController>().currentUser.value,
                  receiverId: userModel,
                  offerType: chatData.offerType,
                  rejected: true,
                  price: chatData.price,
                  providerReview: 0,
                  reviewed: false,
                  workId: chatData.workId,
                  userReview: 0,
                  attachment: "",
                  action: "declined",
                  finished: true,
                  receiverInboxMessage:
                      " ${authController.currentUser.value!.firstname!} has rejected your offer please review your offer or submit a new one \nOffer: \$${chatData.price}.00 ${chatData.offerType} \nProcessing Fee: \$${0.030}\nTotal: \$${chatData.price! + 0.030}",
                  receiverMessage:
                      " ${authController.currentUser.value!.firstname!} has rejected your offer please review your offer or submit a new one \nOffer: \$${chatData.price}.00 ${chatData.offerType} \nProcessing Fee: \$${0.030}\nTotal: \$${chatData.price! + 0.030}",
                  hours: chatData.hours,
                  transactionId: chatData.transactionId,
                  pickUp: LocationModel(),
                  destination: LocationModel(),
                  workType: "",
                );

                chatController.sendMessage(
                    docId: uid, chatModel: chatModelData);
                chatController.updateChatById(
                    uid: uid,
                    chatId: chatData.id,
                    body: {
                      "finished": true,
                      "rejected": true,
                      "action": "Offer rejected"
                    });
              },
              secondAction: () async {
                Get.find<ServiceController>().choosePaymentMethodBottomSheet(
                    context: context,
                    chatData: chatData,
                    userModel: userModel,
                    uid: uid);
              },
              firstBgColor: const Color(0XFFAE0000),
              secondBgColor: const Color(0XFF2DCE6D),
              showSecondButton: true,
              showFirstButton: true)
          : chatData.action == "coming" &&
                  type == "receiver" &&
                  chatData.finished == false
              ? switchActions(
                  chatData: chatData,
                  context: context,
                  firstTitle: "Arrived",
                  secondTitle: "Cancel Job",
                  firstBgColor: const Color(0XFF2DCE6D),
                  secondBgColor: const Color(0XFFAE0000),
                  firstAction: () {
                    chatController.updateChatById(
                        uid: uid,
                        chatId: chatData.id,
                        body: {"action": "arrived"});

                    Chat chatModelData = Chat(
                      message:
                          "You have arrived at your client’s location. Please act professionally and respectfully.Please advise client to confirm your arrival on the app. Once you completed your job please confirm transaction completed ",
                      senderInboxMessage:
                          "You have arrived at your client’s location. Please act professionally and respectfully.Please advise client to confirm your arrival on the app. Once you completed your job please confirm transaction completed ",
                      receiverInboxMessage:
                          "${authController.currentUser.value!.firstname} has arrived ",
                      type: "offer",
                      addTime: DateTime.now(),
                      senderId: Get.find<AuthController>().currentUser.value,
                      receiverId: userModel,
                      offerType: chatData.offerType,
                      price: chatData.price,
                      providerReview: 0,
                      reviewed: false,
                      userReview: 0,
                      attachment: "",
                      action: "arrivedProvider",
                      finished: false,
                      workId: chatData.workId,
                      receiverMessage: "",
                      hours: chatData.hours,
                      transactionId: chatData.transactionId,
                      pickUp: LocationModel(),
                      destination: LocationModel(),
                      workType: "",
                    );

                    chatController.sendMessage(
                      chatModel: chatModelData,
                      docId: uid,
                    );
                    chatController.sendChatNotification(
                        chatId: uid,
                        type: "offer",
                        id: userModel.playerId!,
                        userModel: authController.currentUser.value!,
                        message:
                            "${authController.currentUser.value!.firstname} has arrived",
                        screen: "ChatInbox");
                    chatController
                        .updateOffer(uid: uid, body: {'status': "arrived"});
                  },
                  secondAction: () async {
                    await Get.find<ServiceController>().cancelTransaction(
                        uid: uid, userModel: userModel, chaData: chatData);
                    chatController.updateChatById(
                        uid: uid,
                        chatId: chatData.id,
                        body: {"finished": true, "rejected": true});
                  },
                  showSecondButton: true,
                  showFirstButton: true)
              : (chatData.action == "arrived" || chatData.action == "coming") &&
                      type == "sender" &&
                      chatData.finished == false
                  ? switchActions(
                      chatData: chatData,
                      context: context,
                      firstTitle: "Arrived",
                      secondTitle: "No show",
                      showFirstButton:
                          chatData.action == "coming" ? false : true,
                      showSecondButton:
                          chatData.action == "arrived" ? false : true,
                      firstBgColor: const Color(0XFF2DCE6D),
                      secondBgColor: const Color(0XFFAE0000),
                      firstAction: () async {
                        if (chatData.action == "arrived") {
                          var workId = await chatController.createWork(
                              chatId: chatData.id!,
                              uid: uid,
                              workType: chatData.offerType,
                              userModel: userModel,
                              transactionId: chatData.transactionId!,
                              price: chatData.price! * chatData.hours!,
                              rateType: userModel.service!.name,
                              hours: chatData.hours);

                          chatController.updateChatByLoop(
                              uid: uid,
                              param: "arrivedProvider",
                              body: {
                                "action": "workingProvider",
                                "workId": workId
                              });

                          chatController.updateChatById(
                              uid: uid,
                              chatId: chatData.id,
                              body: {"finished": true, "workId": workId});

                          Chat chatModelData = Chat(
                            message:
                                "Thank you for confirming Provider’s arrival. At the end of ${chatData.receiverId!.firstname} ‘s service please make sure to come back on the app and confirm transaction was completed. ",
                            senderInboxMessage:
                                "Thank you for confirming Provider’s arrival. At the end of ${chatData.receiverId!.firstname} ‘s service please make sure to come back on the app and confirm transaction was completed. ",
                            receiverInboxMessage:
                                "${Get.find<AuthController>().currentUser.value!.firstname} has  confirmed your arrival.",
                            type: "offer",
                            addTime: DateTime.now(),
                            senderId:
                                Get.find<AuthController>().currentUser.value,
                            receiverId: userModel,
                            offerType: chatData.offerType,
                            price: chatData.price,
                            providerReview: 0,
                            reviewed: false,
                            userReview: 0,
                            workId: workId,
                            attachment: "",
                            action: "working",
                            finished: false,
                            receiverMessage: "",
                            hours: chatData.hours,
                            transactionId: chatData.transactionId,
                            pickUp: LocationModel(),
                            destination: LocationModel(),
                            workType: "",
                          );

                          chatController.sendMessage(
                            chatModel: chatModelData,
                            docId: uid,
                          );

                          Get.find<WalletController>().createTransaction(
                              amount: chatData.price! * chatData.hours!,
                              userId: userModel.id!,
                              workId: workId,
                              type: "received");

                          Get.find<WalletController>().createTransaction(
                              amount: chatData.price! * chatData.hours!,
                              userId: authController.currentUser.value!.id!,
                              workId: workId,
                              type: "transfered");

                          chatController.sendChatNotification(
                              chatId: uid,
                              type: "offer",
                              id: userModel.playerId!,
                              userModel: authController.currentUser.value!,
                              message:
                                  "You have started working for ${authController.currentUser.value!.firstname}",
                              screen: "ChatInbox");
                        }
                      },
                      secondAction: () async {
                        chatController.updateChatById(
                            uid: uid,
                            chatId: chatData.id,
                            body: {"finished": true});
                        await Get.find<ServiceController>().cancelTransaction(
                            uid: uid, userModel: userModel, chaData: chatData);
                      })
                  : chatData.action == "working" &&
                          type == "sender" &&
                          chatData.finished == false
                      ? Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            width: 150,
                            child: Obx(() {
                              return Get.find<ServiceController>()
                                      .capturePaymentLoad
                                      .value
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : customRoundedButton(
                                      voidCallback: () {
                                        if (userModel.accountType ==
                                            "flutterWave") {
                                          print(
                                              "user model ${userModel.accountType}");
                                        } else if (userModel.accountType ==
                                            "stripe") {
                                          Get.find<ServiceController>()
                                              .capturePayment(
                                                  uid: uid,
                                                  userModel: userModel,
                                                  chatData: chatData);

                                          sendWorkCompleteMessage(
                                              chatData: chatData, uid: uid);
                                        }
                                      },
                                      title: "Task Completed",
                                      bgColor: const Color(0XFF2DCE6D),
                                      fgColor: whiteColor,
                                    );
                            }),
                          ),
                        )
                      : (chatData.action == "arrivedProvider" ||
                                  chatData.action == "workingProvider" ||
                                  chatData.action == "workingCompleted" ||
                                  chatData.action == "Transaction Completed") &&
                              type == "sender" &&
                              chatData.finished == false
                          ? chatData.action == "Transaction Completed"
                              ? Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 2),
                                          textStyle: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () async {
                                        await showRatingDialog(
                                            chatData: chatData,
                                            context: context,
                                            type: "sender",
                                            uid: uid,
                                            userModel: userModel);

                                        chatController.updateChatById(
                                            uid: uid,
                                            chatId: chatData.id,
                                            body: {
                                              "action": "Reviewed Client",
                                              "finished": true
                                            });

                                        chatController.sendChatNotification(
                                            chatId: uid,
                                            type: "review",
                                            id: userModel.playerId!,
                                            userModel: authController
                                                .currentUser.value!,
                                            message:
                                                "${authController.currentUser.value!.firstname} has reviewed you",
                                            screen: "ChatInbox");
                                      },
                                      child: const CommonText(
                                        color: whiteColor,
                                        text: "Review",
                                        size: 12,
                                        fontFamily: "RedHatDisplay",
                                      )),
                                )
                              : switchActions(
                                  context: context,
                                  chatData: chatData,
                                  firstTitle: "Task Completed",
                                  secondTitle: "Couldn't Complete Task",
                                  showLiveButton:
                                      chatData.action == "workingProvider",
                                  showSecondButton:
                                      (chatData.action == "arrivedProvider" ||
                                                  chatData.action ==
                                                      "workingProvider") &&
                                              chatData.finished == false
                                          ? true
                                          : false,
                                  showFirstButton:
                                      chatData.action == "workingCompleted" &&
                                              chatData.finished == false
                                          ? true
                                          : false,
                                  firstBgColor: const Color(0XFF2DCE6D),
                                  secondBgColor: const Color(0XFFAE0000),
                                  firstAction: () {
                                    chatController.updateChatById(
                                        uid: uid,
                                        chatId: chatData.id,
                                        body: {
                                          "finished": false,
                                          "action": "Transaction Completed"
                                        });
                                    List<String> users = [];
                                    users.add(chatData.receiverId!.id!);
                                    users.add(chatData.senderId!.id!);
                                    chatController.updateWork(users, {
                                      'completionTime': DateTime.now(),
                                      "status": "completed"
                                    });

                                    chatController.sendChatNotification(
                                        chatId: uid,
                                        type: "offer",
                                        id: userModel.playerId!,
                                        userModel:
                                            authController.currentUser.value!,
                                        message: "Payment Completed",
                                        screen: "ChatInbox");
                                  },
                                  secondAction: () async {},
                                )
                          : chatData.action == "review" &&
                                  type == "sender" &&
                                  chatData.finished == false
                              ? Align(
                                  alignment: Alignment.bottomRight,
                                  child: chatData.reviewed == true
                                      ? const Text("")
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.amber,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 15,
                                                      vertical: 2),
                                              textStyle: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold)),
                                          onPressed: () async {
                                            if (chatData.reviewed == false) {
                                              await showRatingDialog(
                                                  chatData: chatData,
                                                  context: context,
                                                  type: "sender",
                                                  uid: uid,
                                                  userModel: userModel);
                                              chatController.sendChatNotification(
                                                  chatId: uid,
                                                  type: "review",
                                                  id: userModel.playerId!,
                                                  userModel: authController
                                                      .currentUser.value!,
                                                  message:
                                                      "${authController.currentUser.value!.firstname} has reviewed you",
                                                  screen: "ChatInbox");
                                            }
                                          },
                                          child: const CommonText(
                                            color: whiteColor,
                                            text: "Review",
                                            size: 12,
                                            fontFamily: "RedHatDisplay",
                                          )),
                                )
                              : const Text(""),
    ],
  );
}

sendWorkCompleteMessage({required Chat chatData, required String uid}) {
  ChatController chatController = Get.find<ChatController>();
  chatController.updateChatById(uid: uid, chatId: chatData.id, body: {
    "finished": true,
    "workId": chatData.workId,
    "action": "Task completed"
  });

  chatController.updateChatByLoop(
      uid: uid, param: "", body: {"action": "workingCompleted"});
  Get.find<WalletController>()
      .updateTransactionByWorkId(workId: chatData.workId!);
}

Widget switchActions({
  required firstTitle,
  required secondTitle,
  required Chat chatData,
  required Function firstAction,
  required Function secondAction,
  required Color firstBgColor,
  required Color secondBgColor,
  required bool showSecondButton,
  required bool showFirstButton,
  bool? showLiveButton = false,
  required context,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 5.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showFirstButton == true)
          Expanded(
            child: actionButton(
                firstTitle: firstTitle,
                chatData: chatData,
                firstAction: firstAction,
                firstBgColor: firstBgColor,
                context: context),
          ),
        const SizedBox(
          width: 10,
        ),
        if (showSecondButton == true)
          Expanded(
              child: actionButton(
                  firstTitle: secondTitle,
                  chatData: chatData,
                  firstAction: secondAction,
                  firstBgColor: secondBgColor,
                  context: context)),
        if (showLiveButton == true)
          actionButton(
              firstTitle: "Go Live",
              chatData: chatData,
              firstAction: () {
                Get.find<RoomController>().createRoomInFirestore(
                    context: context, title: "title", workId: chatData.workId!);
              },
              firstBgColor: Colors.green,
              context: context)
      ],
    ),
  );
}

Widget actionButton(
    {required firstTitle,
    required Chat chatData,
    required Function firstAction,
    required Color firstBgColor,
    required context,
    IconData? iconData}) {
  return InkWell(
    onTap: () {
      firstAction();
    },
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonText(
                color: firstBgColor,
                text: firstTitle,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
