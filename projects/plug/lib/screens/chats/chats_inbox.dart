import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/chat_controller.dart';
import 'package:plug/controllers/location_controller.dart';
import 'package:plug/controllers/user_controller.dart';
import 'package:plug/models/chat.dart';
import 'package:plug/models/user.dart';
import 'package:plug/screens/chats/components/receiver_widget.dart';
import 'package:plug/screens/chats/components/sender_widget.dart';
import 'package:plug/screens/profile/new_profile.dart';
import 'package:plug/widgets/common_text.dart';
import 'package:plug/widgets/offer_dialog.dart';
import '../../controllers/service_controller.dart';
import '../../models/location_model.dart';
import '../../models/place_prediction.dart';
import '../../utils/style.dart';
import '../../widgets/custom_roundedbutton.dart';
import '../../widgets/destination_bottomsheet.dart';
import '../../widgets/place_card.dart';
import '../location/location_page.dart';
import '../location/location_screen.dart';

class ChatsInbox extends StatelessWidget {
  final UserModel userModel;
  final String uid;

  final ChatController chatController = Get.find<ChatController>();
  final AuthController authController = Get.find<AuthController>();
  final ServiceController serviceController = Get.find<ServiceController>();
  final UserController userController = Get.find<UserController>();

  final LocationController locationController = Get.find<LocationController>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  ChatsInbox({
    Key? key,
    required this.userModel,
    required this.uid,
  }) : super(key: key) {
    chatController.isChatPage.value = true;
    chatController.deleteUnreadMessages(
        id: FirebaseAuth.instance.currentUser!.uid, docId: uid);
  }

  final List chats = [
    "Is it available ?",
    " How long it will take?",
    " Where are you from"
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (value) {
        chatController.isChatPage.value = false;
        print("Has popped ${chatController.isChatPage.value}");
      },
      child: Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0.3,
          titleSpacing: 0.0,
          backgroundColor: whiteColor,
          leading: IconButton(
              onPressed: () {
                if (chatController.selectedMessages.isNotEmpty) {
                  chatController.selectedMessages.clear();
                  chatController.selectedMessages.refresh();
                } else {
                  Get.back();
                }
              },
              icon: const Icon(
                Icons.arrow_back,
                color: blackColor,
              )),
          title: Obx(() {
            return chatController.selectedMessages.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CommonText(
                        color: Colors.black,
                        size: 20,
                        text:
                            chatController.selectedMessages.length.toString()),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        userModel.profileUrl!.isEmpty
                            ? InkWell(
                                onTap: () {
                                  Get.find<UserController>()
                                      .getCurrentUser(userModel.id);
                                  Get.find<UserController>()
                                      .currentProfile
                                      .value = userModel;
                                  Get.to(() => NewProfile());
                                },
                                child: const CircleAvatar(
                                  backgroundImage:
                                      AssetImage("assets/images/profile.png"),
                                  radius: 25,
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  Get.find<UserController>()
                                      .getCurrentUser(userModel.id);
                                  Get.find<UserController>()
                                      .currentProfile
                                      .value = userModel;
                                  Get.to(() => NewProfile());
                                },
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    userModel.profileUrl!,
                                  ),
                                  radius: 25,
                                ),
                              ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              color: blackColor,
                              text:
                                  "${"${userModel.firstname!} ${userModel.lastname!}"}  ${userModel.service != null ? '(${userModel.service!.name.toString().capitalize})' : ''}"
                                      .capitalize!,
                              fontWeight: FontWeight.w600,
                              fontFamily: "RedHatMedium",
                              size: 16,
                            ),
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(userModel.id)
                                  .snapshots(),
                              builder: (context, AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(child: Text(""));
                                }
                                if (snapshot.hasData) {
                                  UserModel user =
                                      UserModel.fromJson(snapshot.data.data());
                                  return CommonText(
                                    color: blackColor,
                                    text: compareTime(user.lastSeen),
                                    size: 12,
                                    fontFamily: "RedHatLight",
                                  );
                                }
                                return const Center(child: Text(""));
                              },
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
          }),
          actions: [
            Obx(() {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: chatController.selectedMessages.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          chatController.deleteDialog(uid: uid);
                        },
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.black54,
                        ))
                    : Text(""),
              );
            })
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("messages")
                        .doc(uid)
                        .collection("chats")
                        .where("users", arrayContainsAny: [
                          FirebaseAuth.instance.currentUser!.uid
                        ])
                        .orderBy("addTime")
                        .snapshots(),
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Text(""));
                      }
                      if (snapshot.hasData) {
                        return ListView.builder(
                            reverse: true,
                            physics: const ScrollPhysics(),
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              chatController.deleteUnreadMessages(
                                  id: FirebaseAuth.instance.currentUser!.uid,
                                  docId: uid);
                              final reversedIndex =
                                  snapshot.data!.docs.length - 1 - index;
                              Chat chat = Chat.fromJson(
                                  snapshot.data!.docs[reversedIndex]);

                              return Align(
                                  alignment: chat.senderId!.id ==
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? Alignment.topRight
                                      : Alignment.topLeft,
                                  child: chat.senderId!.id ==
                                          FirebaseAuth.instance.currentUser!.uid
                                      ? senderWidget(
                                          chatData: chat,
                                          context: context,
                                          uid: uid,
                                          userModel: userModel)
                                      : receiverWidget(
                                          chat, context, userModel, uid));
                            });
                      }
                      return const Center(child: Text("no chats"));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Obx(() => BottomAppBar(
                height: chatController.showTabBar.value
                    ? kBottomNavigationBarHeight * 5
                    : (Get.find<UserController>().currentProfile.value!.id !=
                                FirebaseAuth.instance.currentUser!.uid ||
                            Get.find<UserController>()
                                    .currentProfile
                                    .value!
                                    .isServiceProvider ==
                                false)
                        ? kToolbarHeight * 1.5
                        : kToolbarHeight * 2.5,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0.0)
                      .copyWith(top: 3),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Obx(() {
                            return authController
                                        .currentUser.value?.isServiceProvider ==
                                    true
                                ? SizedBox(
                                    height:
                                        chatController.showTabBar.value == true
                                            ? kBottomNavigationBarHeight * 5
                                            : kBottomNavigationBarHeight * 1.1,
                                    child: authController.currentUser.value
                                                ?.isServiceProvider ==
                                            true
                                        ? tabBarForProvider()
                                        : questionsWidget(),
                                  )
                                : questionsWidget();
                          })),
                          Row(
                            children: [
                              Expanded(
                                child: chatController.recordingAudio.value
                                    ? Container(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        width: double.infinity,
                                        height:
                                            kBottomNavigationBarHeight * 0.8,
                                        decoration: BoxDecoration(
                                          color: greyColor.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.mic,
                                              color: Colors.purple,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Obx(() => Text(chatController
                                                .formatTime(chatController
                                                    .secondsElapsed.value)))
                                          ],
                                        ),
                                      )
                                    : TextFormField(
                                        controller: chatController
                                            .textEditingController,
                                        decoration: InputDecoration(
                                            filled: true,
                                            hintText: "Say Something",
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 20),
                                            fillColor:
                                                greyColor.withOpacity(0.2),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                borderSide: BorderSide.none),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                borderSide: BorderSide.none),
                                            prefixIcon: InkWell(
                                                onTap: () {
                                                  showModalBottomSheet(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return Container(
                                                          height: 170,
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 50),
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Card(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(18),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          10),
                                                              child: Column(
                                                                children: [
                                                                  InkWell(
                                                                    onTap: () {
                                                                      Get.back();
                                                                      locationController
                                                                          .polyline
                                                                          .clear();
                                                                      locationController
                                                                          .markers
                                                                          .clear();
                                                                      Get.to(() => LocationPage(
                                                                          type:
                                                                              'search',
                                                                          chatId:
                                                                              uid,
                                                                          userModel:
                                                                              userModel));
                                                                    },
                                                                    child:
                                                                        const Row(
                                                                      children: [
                                                                        Icon(
                                                                            Icons
                                                                                .location_on_rounded,
                                                                            size:
                                                                                30),
                                                                        SizedBox(
                                                                            width:
                                                                                20),
                                                                        Text(
                                                                            "Location")
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  InkWell(
                                                                    onTap: () {
                                                                      Get.back();
                                                                      showModalBottomSheet(
                                                                          backgroundColor: Colors
                                                                              .transparent,
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (context) {
                                                                            return Container(
                                                                              height: 170,
                                                                              margin: const EdgeInsets.only(bottom: 50),
                                                                              width: MediaQuery.of(context).size.width,
                                                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                              child: Card(
                                                                                margin: const EdgeInsets.all(18),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                                                  child: Column(
                                                                                    children: [
                                                                                      const Spacer(),
                                                                                      Row(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                        children: [
                                                                                          InkWell(
                                                                                            onTap: () {
                                                                                              Get.back();
                                                                                            },
                                                                                            child: const Column(
                                                                                              children: [
                                                                                                CircleAvatar(
                                                                                                  radius: 25,
                                                                                                  backgroundColor: Colors.indigo,
                                                                                                  child: Icon(Icons.insert_drive_file),
                                                                                                ),
                                                                                                Padding(
                                                                                                  padding: EdgeInsets.only(top: 8.0),
                                                                                                  child: CommonText(color: greyColor, text: "Documents"),
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          InkWell(
                                                                                            onTap: () {
                                                                                              Get.back();
                                                                                              chatController.pickImage(type: "camera", context: context, userModel: userModel, uid: uid);
                                                                                            },
                                                                                            child: const Column(
                                                                                              children: [
                                                                                                CircleAvatar(
                                                                                                  radius: 25,
                                                                                                  backgroundColor: Colors.pink,
                                                                                                  child: Icon(Icons.camera_alt),
                                                                                                ),
                                                                                                Padding(
                                                                                                  padding: EdgeInsets.only(top: 8.0),
                                                                                                  child: CommonText(color: greyColor, text: "Camera"),
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          InkWell(
                                                                                            onTap: () {
                                                                                              Get.back();
                                                                                              chatController.pickImage(type: "gallery", context: context, userModel: userModel, uid: uid);
                                                                                            },
                                                                                            child: const Column(
                                                                                              children: [
                                                                                                CircleAvatar(
                                                                                                  radius: 25,
                                                                                                  backgroundColor: Colors.purple,
                                                                                                  child: Icon(Icons.photo),
                                                                                                ),
                                                                                                Padding(
                                                                                                  padding: EdgeInsets.only(top: 8.0),
                                                                                                  child: CommonText(color: greyColor, text: "Gallery"),
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                      const Spacer(),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          });
                                                                    },
                                                                    child:
                                                                        const Row(
                                                                      children: [
                                                                        Icon(
                                                                            Icons
                                                                                .camera_alt,
                                                                            size:
                                                                                30),
                                                                        SizedBox(
                                                                            width:
                                                                                20),
                                                                        Text(
                                                                            "Camera")
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                },
                                                child: const Icon(
                                                  Icons.attach_file,
                                                  color: greyColor,
                                                )),
                                            suffixIcon: InkWell(
                                              onTap: () {
                                                if (chatController
                                                    .textEditingController
                                                    .text
                                                    .isNotEmpty) {
                                                  Chat chat = Chat(
                                                    message: chatController
                                                        .textEditingController
                                                        .text,
                                                    receiverInboxMessage:
                                                        chatController
                                                            .textEditingController
                                                            .text,
                                                    senderInboxMessage:
                                                        chatController
                                                            .textEditingController
                                                            .text,
                                                    type: "text",
                                                    addTime: DateTime.now(),
                                                    senderId: Get.find<
                                                            AuthController>()
                                                        .currentUser
                                                        .value,
                                                    receiverId: userModel,
                                                    offerType: "",
                                                    price: 0,
                                                    providerReview: 0,
                                                    reviewed: false,
                                                    userReview: 0,
                                                    attachment: "",
                                                    action: "",
                                                    finished: false,
                                                    receiverMessage:
                                                        chatController
                                                            .textEditingController
                                                            .text,
                                                    hours: 0,
                                                    transactionId: "",
                                                    pickUp: LocationModel(),
                                                    destination:
                                                        LocationModel(),
                                                    workType: "",
                                                  );
                                                  chatController.sendMessage(
                                                    chatModel: chat,
                                                    docId: uid,
                                                  );
                                                  chatController
                                                      .textEditingController
                                                      .clear();
                                                }
                                              },
                                              child: const Icon(
                                                Ionicons.send,
                                                color: blackColor,
                                              ),
                                            )),
                                      ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Obx(() => InkWell(
                                    onTap: () {
                                      if (chatController.recordingAudio.value ==
                                          true) {
                                        chatController.stopRecording(
                                            uid: uid, userModel: userModel);
                                      } else {
                                        chatController.startRecording();
                                      }
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.purple,
                                      child: Center(
                                        child: Icon(
                                          chatController.recordingAudio.value
                                              ? Icons.stop
                                              : Icons.mic,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ],
                      ),
                      Obx(() {
                        return chatController.showTabBar.value == false
                            ? Container(height: 0)
                            : Positioned(
                                top: -30,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    chatController.showTabBar.value = false;
                                  },
                                  child: Material(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                            color: whiteColor,
                                            shape: BoxShape.circle),
                                        child: InkWell(
                                            onTap: () {
                                              chatController.showTabBar.value =
                                                  false;
                                            },
                                            child: const Icon(Icons.clear))),
                                  ),
                                ),
                              );
                      })
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }

  compareTime(DateTime? lastSeen) {
    DateTime dt1 =
        DateTime.parse(DateFormat("yyyy-MM-dd hh:mm").format(lastSeen!));
    DateTime dt2 =
        DateTime.parse(DateFormat("yyyy-MM-dd hh:mm").format(DateTime.now()));
    Duration diff = dt1.difference(dt2);
    if (dt1.isAtSameMomentAs(dt2)) {
      return "Online";
    } else if (diff.inHours <= 24) {
      return "Last seen today at ${DateFormat("hh:mm a").format(lastSeen)}";
    } else {
      return "Last seen ${DateFormat("yyyy-MM-dd hh:mm a").format(lastSeen)}";
    }
  }

  tabBarForProvider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
            indicatorWeight: 2.0,
            indicatorColor: const Color(0XFF6C6EEF),
            labelColor: blueColor,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            unselectedLabelColor: blackColor,
            controller: chatController.tabController,
            onTap: (value) {
              chatController.showTabBar.value = true;
            },
            tabs: const [
              Tab(
                child: Text(
                  "Questions",
                ),
              ),
              Tab(
                child: Text(
                  "Make an offer",
                ),
              )
            ]),
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: chatController.tabController,
            children: [
              questionsWidget(),
              Container(
                color: whiteColor,
                padding: const EdgeInsets.symmetric(horizontal: 10)
                    .copyWith(top: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.only(right: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                                color: greyColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                const CommonText(
                                  color: blackColor,
                                  text: "\$",
                                  fontFamily: "RedHatMedium",
                                ),
                                Expanded(
                                    child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller:
                                      chatController.textEditingControllerPrice,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onChanged: (value) {
                                    if (value.isNotEmpty) {
                                      chatController.selectedPrice.value =
                                          int.parse(value);
                                    } else {
                                      chatController.selectedPrice.value = 0;
                                    }
                                  },
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontFamily: "RedHatMedium",
                                  ),
                                  decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 2, vertical: 3),
                                      border: InputBorder.none,
                                      hintText: "500"),
                                )),
                              ],
                            ),
                          ),
                        ),
                        Obx(() => Container(
                              margin: const EdgeInsets.only(right: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                  color: greyColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20)),
                              child: PopupMenuButton<String>(
                                itemBuilder: (context) {
                                  return chatController.orderType.map((str) {
                                    return PopupMenuItem(
                                      value: str,
                                      child: Text(str),
                                    );
                                  }).toList();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                        chatController.selectedOrderType.value),
                                    const Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                                onSelected: (v) {
                                  chatController.selectedOrderType.value = v;
                                },
                              ),
                            )),
                        Expanded(
                          flex: 3,
                          child: Container(
                            margin: const EdgeInsets.only(right: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                                color: greyColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20)),
                            child: TextFormField(
                              keyboardType: TextInputType.number,
                              controller:
                                  chatController.textEditingControllerHours,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  chatController.hours.value = int.parse(value);
                                } else {
                                  chatController.hours.value = 0;
                                }
                              },
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontFamily: "RedHatMedium",
                              ),
                              decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 2, vertical: 3),
                                  border: InputBorder.none,
                                  hintText: "Hours"),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Builder(builder: (context) {
                      return Obx(
                            () => Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () {
                              if (chatController.selectedPrice > 0 &&
                                  chatController.hours.value > 0) {
                                if (authController
                                            .currentUser.value!.service!.name!
                                            .trim() ==
                                        "driver" &&
                                    (serviceController
                                                .destinationAddress.value ==
                                            null ||
                                        serviceController.address.value ==
                                            null)) {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.45,
                                          decoration: const BoxDecoration(
                                            color: lightGrey,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const SizedBox(height: 20),
                                                const Center(
                                                    child: CommonText(
                                                        color: blackColor,
                                                        text: "Select Route",
                                                        size: 12)),
                                                const SizedBox(height: 10),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(width: 16),
                                                    Column(
                                                      children: [
                                                        const SizedBox(
                                                            height: 8),
                                                        const Icon(
                                                          Icons
                                                              .trip_origin_rounded,
                                                          color: Colors.black,
                                                          size: 28,
                                                        ),
                                                        SizedBox(
                                                          height: 54,
                                                          child: CustomPaint(
                                                              size: const Size(
                                                                  1,
                                                                  double
                                                                      .infinity),
                                                              painter:
                                                                  DashedLineVerticalPainter()),
                                                        ),
                                                        const Icon(
                                                          Icons.place_rounded,
                                                          color: Colors.black,
                                                          size: 32,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 0,
                                                                  top: 8,
                                                                  bottom: 4),
                                                          child: const Text(
                                                            "From",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        Row(
                                                          children: [
                                                            ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                fixedSize: Size(
                                                                    getScreenWidth(
                                                                            context) -
                                                                        140,
                                                                    42),
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                shape: const RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(21))),
                                                              ),
                                                              child: Obx(() {
                                                                return Text(
                                                                  locationController
                                                                              .fromPlace
                                                                              .value !=
                                                                          null
                                                                      ? locationController
                                                                          .fromPlace
                                                                          .value!
                                                                          .address!
                                                                      : "Enter pickup location",
                                                                  maxLines: 1,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                );
                                                              }),
                                                              onPressed: () {
                                                                Get.to(() =>
                                                                    LocationSearchScreen(
                                                                      title:
                                                                          "Enter Pickup Location",
                                                                      type:
                                                                          "from",
                                                                    ));
                                                              },
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            InkWell(
                                                                onTap: () {
                                                                  locationController
                                                                      .getCurrentLocation();
                                                                },
                                                                child: const Icon(
                                                                    Icons
                                                                        .my_location)),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                          ],
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 0,
                                                                  top: 8,
                                                                  bottom: 4),
                                                          child: const Text(
                                                            "To",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            fixedSize: Size(
                                                                getScreenWidth(
                                                                        context) -
                                                                    130,
                                                                42),
                                                            textStyle:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            21))),
                                                          ),
                                                          child: Obx(() => Text(
                                                                locationController
                                                                            .toPlace
                                                                            .value !=
                                                                        null
                                                                    ? locationController
                                                                        .toPlace
                                                                        .value!
                                                                        .address!
                                                                    : "Enter drop location",
                                                                maxLines: 1,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                              )),
                                                          onPressed: () {
                                                            Get.to(() =>
                                                                LocationSearchScreen(
                                                                  title:
                                                                      "Enter drop Location",
                                                                  type: "to",
                                                                ));
                                                          },
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 15),
                                                Center(
                                                  child: customRoundedButton(
                                                      title: "Done",
                                                      bgColor: Colors.black,
                                                      fgColor: whiteColor,
                                                      voidCallback: () {
                                                        if (locationController
                                                                    .fromPlace
                                                                    .value !=
                                                                null &&
                                                            locationController
                                                                    .toPlace
                                                                    .value !=
                                                                null) {
                                                          Navigator.pop(
                                                              context);
                                                          offerDialog(context,
                                                              userModel, uid);
                                                        } else {
                                                          Get.back();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(const SnackBar(
                                                                  content: CommonText(
                                                                      color:
                                                                          whiteColor,
                                                                      text:
                                                                          "Please fill all the fields"),
                                                                  backgroundColor:
                                                                      blackColor));
                                                        }
                                                      }),
                                                ),
                                                const SizedBox(height: 20),
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                } else if (authController
                                        .currentUser.value?.accountNumber ==
                                    null) {
                                  ScaffoldMessenger.of(Get.context!)
                                      .showSnackBar(const SnackBar(
                                          backgroundColor: blackColor,
                                          content: CommonText(
                                            color: whiteColor,
                                            text:
                                                "Please Set up bankdetails to proceed",
                                          )));
                                } else {
                                  offerDialog(context, userModel, uid);
                                }
                              }
                            },
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    chatController.selectedPrice.value <= 0 ||
                                            chatController.hours.value <= 0
                                        ? lightGrey
                                        : blackColor,
                              ),
                              child: CommonText(
                                size: 12,
                                text: "Send Offer",
                                color:
                                    chatController.selectedPrice.value <= 0 ||
                                            chatController.hours.value <= 0
                                        ? greyColor
                                        : whiteColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  questionsWidget() {
    return Obx(() {
      return chatController.showTabBar.value
          ? ListView.builder(
              itemCount: chats.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Chat chat = Chat(
                          message: chats[index],
                          receiverInboxMessage: chats[index],
                          senderInboxMessage: chats[index],
                          type: "text",
                          addTime: DateTime.now(),
                          senderId:
                              Get.find<AuthController>().currentUser.value,
                          receiverId: userModel,
                          offerType: "",
                          price: 0,
                          providerReview: 0,
                          reviewed: false,
                          userReview: 0,
                          attachment: "",
                          action: "",
                          finished: false,
                          receiverMessage: chats[index],
                          hours: 0,
                          transactionId: "",
                          pickUp: LocationModel(),
                          destination: LocationModel(),
                          workType: "",
                        );
                        chatController.sendMessage(
                          chatModel: chat,
                          docId: uid,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: yellowColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child:
                            CommonText(color: whiteColor, text: chats[index]),
                      ),
                    ),
                  ],
                );
              })
          : Container(
              height: 0,
            );
    });
  }
}
