import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plugme/controllers/chat_controller.dart';
import 'package:plugme/models/inbox.dart';
import 'package:plugme/utils/date_formatter.dart';
import 'package:plugme/utils/style.dart';

import '../../widgets/common_text.dart';
import 'chats_inbox.dart';

class ChatsPage extends StatelessWidget {
  ChatsPage({Key? key}) : super(key: key);
  final ChatController chatController = Get.put<ChatController>(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blueColor,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: blueColor,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: whiteColor,
            )),
        toolbarHeight: kToolbarHeight * 0.8,
        title: const CommonText(
          color: whiteColor,
          text: "Messages",
          size: 20,
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        margin: const EdgeInsets.only(top: 30),
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("messages")
              .where("users",
                  arrayContains: FirebaseAuth.instance.currentUser!.uid)
              .orderBy("time", descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data?.docs.length != 0) {
              return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Inbox inbox = Inbox.fromJson(snapshot.data?.docs[index]);
                    return InkWell(
                      onTap: () {
                        Get.to(() => ChatsInbox(
                              uid: inbox.id!,
                              userModel: inbox.reciverId!.id ==
                                      FirebaseAuth.instance.currentUser!.uid
                                  ? inbox.senderId!
                                  : inbox.reciverId!,
                            ));
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 3, 25, 3),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ((inbox.reciverId!.id ==
                                                FirebaseAuth.instance
                                                    .currentUser!.uid) &&
                                            inbox.senderId!.profileUrl!
                                                .isEmpty) ||
                                        ((inbox.reciverId!.id !=
                                                FirebaseAuth.instance
                                                    .currentUser!.uid) &&
                                            inbox
                                                .reciverId!.profileUrl!.isEmpty)
                                    ? const CircleAvatar(
                                        backgroundImage: AssetImage(
                                            "assets/images/profile.png"),
                                        radius: 27,
                                      )
                                    : CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          inbox.reciverId!.id ==
                                                  FirebaseAuth
                                                      .instance.currentUser!.uid
                                              ? inbox.senderId!.profileUrl!
                                              : inbox.reciverId!.profileUrl!,
                                        ),
                                        radius: 27,
                                      ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 5.0),
                                                    child: CommonText(
                                                      color: blackColor,
                                                      text:
                                                          "${inbox.senderId!.firstname} ${inbox.senderId!.service != null ? "(${inbox.senderId!.service!.name.toString().capitalize})" : ''}",
                                                      size: 16,
                                                      fontFamily:
                                                          "RedHatMedium",
                                                    ),
                                                  ),
                                                  CommonText(
                                                    color: greyColor,
                                                    text:
                                                        DateFormatter.getVerboseDateTimeRepresentation(context, inbox.time!),
                                                    size: 14,
                                                    fontFamily: "RedHatLight",
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                      flex: 3,
                                                      child: inbox.type ==
                                                              "attachment"
                                                          ? const Row(
                                                              children: [
                                                                Icon(
                                                                    Icons.photo,
                                                                    color:
                                                                        greyColor),
                                                                CommonText(
                                                                    color: Colors
                                                                        .grey,
                                                                    text:
                                                                        " Attachment"),
                                                              ],
                                                            )
                                                          : Text(
                                                              "${inbox.senderId!.id == FirebaseAuth.instance.currentUser!.uid ? inbox.senderMessage : inbox.receiverMessage}",
                                                              style: const TextStyle(
                                                                color:
                                                                    blackColor,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                fontSize: 15,
                                                              ),
                                                              maxLines: 2,
                                                            )),
                                                  inbox.getUnreadMessages(
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid) >
                                                          0
                                                      ? Align(
                                                          alignment: Alignment
                                                              .topRight,
                                                          child: Container(
                                                            // margin: EdgeInsets.only(left: 3),
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        10),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: blueColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                            ),
                                                            child: Center(
                                                              child: CommonText(
                                                                color:
                                                                    whiteColor,
                                                                text:
                                                                    "${inbox.getUnreadMessages(FirebaseAuth.instance.currentUser!.uid)}",
                                                                size: 13,
                                                                fontFamily:
                                                                    "RedHatMedium",
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : const Text("")
                                                ],
                                              ),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            }

            return const Center(
                child: CommonText(
              text: "No chats available yet",
              fontFamily: "RedHatLight",
              color: Colors.black,
              size: 16,
            ));

          },
        ),
      ),
    );
  }
}
