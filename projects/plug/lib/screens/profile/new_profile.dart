import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/user_controller.dart';
import 'package:plug/controllers/wallet_controller.dart';
import 'package:plug/models/request.dart';
import 'package:plug/models/work.dart';
import 'package:plug/screens/auth/landing_page.dart';
import 'package:plug/screens/profile/profile.dart';
import 'package:plug/screens/profile/reviews_page.dart';
import 'package:plug/screens/profile/settings.dart';
import 'package:plug/screens/rooms/live.dart';
import 'package:plug/utils/style.dart';
import 'package:plug/widgets/common_text.dart';
import 'package:plug/widgets/custom_roundedbutton.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/service_controller.dart';
import '../../service/dynamic_links.dart';
import '../chats/chats_inbox.dart';
import '../chats/chats_page.dart';
import 'components/image_container.dart';
import 'follower_following.dart';

class NewProfile extends StatefulWidget {
  final UserController userController = Get.find<UserController>();
  final ServiceController serviceController = Get.find<ServiceController>();

  final AuthController authController = Get.find<AuthController>();

  NewProfile({Key? key}) : super(key: key) {
    userController.getCurrentUser(userController.currentProfile.value!.id);
    serviceController.getRequestsByProviderId(
      id: userController.currentProfile.value!.id!,
    );
    if (userController.currentProfile.value!.id ==
        FirebaseAuth.instance.currentUser?.uid &&
        authController.currentUser.value?.accountNumber != null) {
      Get.find<WalletController>().getAccountBalances(
          accountNumber: authController.currentUser.value?.accountNumber!);
    }
  }

  @override
  State<NewProfile> createState() => _NewProfileState();
}

class _NewProfileState extends State<NewProfile> {
  final UserController userController = Get.find<UserController>();
  final ServiceController serviceController = Get.find<ServiceController>();
  final AuthController authController = Get.find<AuthController>();
  final ChatController chatController = Get.find<ChatController>();

  late WebViewController _controller;
  ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 485) {
          userController.canScrollMore.value = false;
      } else {
        userController.canScrollMore.value = true;
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (val) {
        userController.initialSize.value = 0.0;
      },
      child: Obx(() => SingleChildScrollView(
            physics: userController.canScrollMore.value == true
                ? const ScrollPhysics()
                : const NeverScrollableScrollPhysics(),
            controller: _scrollController,
            child: SizedBox(
              height:userController.currentTab.value==1?MediaQuery.of(context).size.height:  1200,
              child: Scaffold(
                  backgroundColor: blueColor,
                  appBar: AppBar(
                    backgroundColor: blueColor,
                    elevation: 0,
                    leading: Get.find<HomeController>().selectedPage.value == 2
                        ? const Icon(null)
                        : IconButton(
                            onPressed: () {
                              Get.back();
                            },
                            icon: const Icon(Icons.arrow_back_ios,
                                color: whiteColor)),
                    centerTitle: false,
                    actions: [
                      if (userController.currentProfile.value?.id ==
                          FirebaseAuth.instance.currentUser?.uid)
                        InkWell(
                          onTap: () {
                            Get.to(() => SettingsPage());
                          },
                          child: const Icon(
                            Icons.filter_list,
                            color: whiteColor,
                          ),
                        ),
                      if (userController.currentProfile.value!.id !=
                          FirebaseAuth.instance.currentUser?.uid)
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 1,
                              child: Text(authController
                                              .currentUser.value?.blockedUsers!
                                              .indexWhere((element) =>
                                                  element ==
                                                  userController.currentProfile
                                                      .value!.id!) ==
                                          -1 ||
                                      authController.currentUser.value == null
                                  ? "Block User"
                                  : "Unblock User"),
                            ),
                            const PopupMenuItem(
                              value: 2,
                              child: Text("Report User"),
                            ),
                          ],
                          color: Colors.white,
                          elevation: 2,
                          onSelected: (value) {
                            if (value == 1) {
                              if (FirebaseAuth.instance.currentUser == null) {
                                Get.back();
                                Get.to(() => LandingPage());
                              } else {
                                if (authController
                                        .currentUser.value!.blockedUsers!
                                        .indexWhere((element) =>
                                            element ==
                                            userController
                                                .currentProfile.value!.id!) ==
                                    -1) {
                                  userController.blockUser(
                                      id: userController
                                          .currentProfile.value!.id!,
                                      context: context);
                                } else {}
                              }
                            } else if (value == 2) {
                              showReportUserDialog(context: Get.context);
                            }
                          },
                        ),
                      SizedBox(width: 15.w),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0)
                                    .copyWith(top: 20),
                            decoration: const BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(40),
                                    topRight: Radius.circular(40))),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                          onTap: () {
                                            authController
                                                .textEditingControllerBio
                                                .clear();
                                            authController
                                                    .textEditingControllerBio
                                                    .text =
                                                userController
                                                    .currentProfile.value!.bio!;
                                            showUserModal(context: context);
                                          },
                                          child: const Icon(
                                            Icons.info,
                                            color: Colors.amber,
                                          )),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${userController.currentProfile.value!.firstname} ${userController.currentProfile.value!.lastname}",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            color: blackColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      buildProductRatingWidget(userController
                                                  .currentProfile
                                                  .value!
                                                  .totalRating ==
                                              0
                                          ? 0.0
                                          : userController.currentProfile.value!
                                                  .totalRating! /
                                              userController.currentProfile
                                                  .value!.totalRatingCount!),
                                      if (userController.currentProfile.value!
                                              .isServiceProvider ==
                                          true)
                                        const Icon(
                                          Icons.verified_user_sharp,
                                          color: blueColor,
                                          size: 28,
                                        )
                                    ],
                                  ),
                                  Obx(() {
                                    return userController.currentProfile.value!
                                                .isServiceProvider ==
                                            true
                                        ? Column(
                                            children: [
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Center(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 8,
                                                      horizontal: 12),
                                                  decoration: BoxDecoration(
                                                      color: lightGrey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25)),
                                                  child: CommonText(
                                                      color: blackColor,
                                                      text:
                                                          "${userController.currentProfile.value!.service!.icon} ${userController.currentProfile.value!.service!.name}"
                                                              .capitalize!,
                                                      fontFamily:
                                                          "RedHatLight"),
                                                ),
                                              )
                                            ],
                                          )
                                        : Container(
                                            height: 0,
                                          );
                                  }),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Obx(() => InkWell(
                                            onTap: () {
                                              Get.to(
                                                  () => FollowersFollowingPage(
                                                        type: 'following',
                                                        id: userController
                                                            .currentProfile
                                                            .value!
                                                            .id!,
                                                      ));
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  userController.currentProfile
                                                      .value!.followingCount
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: blackColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  width: 0.01.sw,
                                                ),
                                                Text(
                                                  "following".capitalize!,
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color: blackColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                      SizedBox(
                                        width: 0.01.sh,
                                      ),
                                      const Text("~"),
                                      SizedBox(
                                        width: 0.01.sh,
                                      ),
                                      Obx(() => InkWell(
                                            onTap: () {
                                              Get.to(
                                                  () => FollowersFollowingPage(
                                                        type: 'followers',
                                                        id: userController
                                                            .currentProfile
                                                            .value!
                                                            .id!,
                                                      ));
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  userController.currentProfile
                                                      .value!.followersCount
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 13.sp,
                                                      color: blackColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(
                                                  width: 0.01.sw,
                                                ),
                                                Text(
                                                  "followers".capitalize!,
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    color: blackColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ))
                                    ],
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5.0),
                                      child: Obx(() => InkWell(
                                            onTap: () {
                                              Get.to(() => ReviewsPage(
                                                  id: userController
                                                      .currentProfile
                                                      .value!
                                                      .id!));
                                            },
                                            child: IgnorePointer(
                                              ignoring: true,
                                              child: RatingBar.builder(
                                                initialRating: double.parse(
                                                    (userController
                                                                .currentProfile
                                                                .value!
                                                                .totalRating! /
                                                            userController
                                                                .currentProfile
                                                                .value!
                                                                .totalRatingCount!)
                                                        .toString()),
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4.0),
                                                itemBuilder: (context, _) =>
                                                    const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate: (rating) {},
                                                // onRatingUpdate: (rating) {
                                                //   print(rating);
                                                // },
                                              ),
                                            ),
                                          )),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Obx(() {
                                        return userController
                                                    .currentProfile.value!.id ==
                                                FirebaseAuth
                                                    .instance.currentUser?.uid
                                            ? InkWell(
                                                onTap: () {
                                                  Get.to(() => ProfilePage());
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                      color: lightGrey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25)),
                                                  child: const Icon(
                                                    Icons.edit,
                                                    color: blueColor,
                                                    size: 18,
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () {
                                                  if (authController
                                                          .currentUser.value ==
                                                      null) {
                                                    Get.to(() => LandingPage());
                                                  } else if (userController
                                                          .currentProfile
                                                          .value!
                                                          .followers!
                                                          .indexWhere((element) =>
                                                              element.id ==
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid) ==
                                                      -1) {
                                                    userController.followUser(
                                                        userModel:
                                                            userController
                                                                .currentProfile
                                                                .value!);
                                                  } else {
                                                    userController.unfollowUser(
                                                        user: userController
                                                            .currentProfile
                                                            .value!
                                                            .id!);
                                                  }
                                                },
                                                child: IntrinsicWidth(
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.4,
                                                    decoration: BoxDecoration(
                                                        color: whiteColor,
                                                        border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25)),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 12,
                                                          horizontal: 15),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            userController
                                                                        .currentProfile
                                                                        .value!
                                                                        .followers!
                                                                        .indexWhere((element) =>
                                                                            element.id ==
                                                                            FirebaseAuth.instance.currentUser!.uid) ==
                                                                    -1
                                                                ? "Follow"
                                                                : "Unfollow",
                                                            style: const TextStyle(
                                                                color:
                                                                    blackColor,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                      }),
                                      InkWell(
                                        onTap: () async {
                                          if (authController
                                                  .currentUser.value ==
                                              null) {
                                            Get.to(() => LandingPage());
                                          } else if (userController
                                                  .currentProfile.value!.id ==
                                              FirebaseAuth
                                                  .instance.currentUser?.uid) {
                                            Get.to(() => ChatsPage());
                                          } else {
                                            String uid =
                                                await Get.find<ChatController>()
                                                    .getChatIdInboxes(
                                                        user: userController
                                                            .currentProfile
                                                            .value!
                                                            .id!);
                                            Get.to(() => ChatsInbox(
                                                userModel: userController
                                                    .currentProfile.value!,
                                                uid: uid));
                                          }
                                        },
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          decoration: BoxDecoration(
                                              color: blueColor,
                                              border: Border.all(
                                                  color: Colors.white),
                                              borderRadius:
                                                  BorderRadius.circular(25)),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 15),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.email_outlined,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "Message",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          Get.defaultDialog(
                                              title: "Just a moment",
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              content:
                                                  const CircularProgressIndicator(),
                                              barrierDismissible: false);
                                          DynamicLinkService()
                                              .generateShareLink(
                                                  userController.currentProfile
                                                      .value!.id!,
                                                  type: "profile",
                                                  title:
                                                      "Check ${userController.currentProfile.value!.firstname} profile on plug",
                                                  imageurl: userController
                                                      .currentProfile
                                                      .value!
                                                      .profileUrl)
                                              .then((value) async {
                                            Get.back();
                                            await Share.share(value,
                                                subject:
                                                    "Share ${userController.currentProfile.value!.firstname} Profile");
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                              color: lightGrey,
                                              borderRadius:
                                                  BorderRadius.circular(25)),
                                          child: const Icon(
                                            Icons.share,
                                            color: blueColor,
                                            size: 18,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Row(
                                      mainAxisAlignment: userController
                                                  .currentProfile
                                                  .value!
                                                  .isServiceProvider ==
                                              false
                                          ? MainAxisAlignment.center
                                          : MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (userController.currentProfile.value!
                                                .isServiceProvider ==
                                            false)
                                          const SizedBox(
                                            width: 20,
                                          ),
                                        if (userController.currentProfile.value!
                                                .isServiceProvider ==
                                            true)
                                          Column(
                                            children: [
                                              Obx(() => Text(
                                                    userController
                                                        .currentProfile
                                                        .value!
                                                        .totalJobs
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: blueColor,
                                                        fontSize: 18.sp,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                "Incomplete Tasks",
                                                style: TextStyle(
                                                    color: blueColor,
                                                    fontSize: 14.sp),
                                              ),
                                            ],
                                          ),
                                        Obx(() {
                                          return userController
                                                      .currentProfile
                                                      .value!
                                                      .isServiceProvider ==
                                                  true
                                              ? Container(
                                                  height: 40,
                                                  color: blueColor,
                                                  width: 0.8)
                                              : Container(
                                                  height: 0,
                                                );
                                        }),
                                        Obx(() {
                                          return userController
                                                      .currentProfile
                                                      .value!
                                                      .isServiceProvider ==
                                                  true
                                              ? Column(
                                                  children: [
                                                    Text(
                                                      userController
                                                          .currentProfile.value!
                                                          .getTotalRehires()
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: blueColor,
                                                          fontSize: 18.sp,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    const SizedBox(
                                                      height: 3,
                                                    ),
                                                    Text(
                                                      "Rehired",
                                                      style: TextStyle(
                                                          color: blueColor,
                                                          fontSize: 14.sp),
                                                    ),
                                                  ],
                                                )
                                              : Container(
                                                  height: 0,
                                                );
                                        }),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TabBar(
                                      indicatorWeight: 2.0,
                                      indicatorColor: const Color(0XFF6C6EEF),
                                      labelColor: blueColor,
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      unselectedLabelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                      unselectedLabelColor: blackColor,
                                      controller: userController.tabController,
                                      onTap: (value) {
                                        userController.currentTab.value=value;
                                        if (value == 1) {
                                          userController.canScrollMore.value =
                                              true;
                                          serviceController
                                              .getRequestsByProviderId(
                                            id: userController
                                                .currentProfile.value!.id!,
                                          );
                                        } else {
                                          userController.canScrollMore.value=true;

                                        }
                                      },
                                      tabs: const [
                                        Tab(
                                          child: Text(
                                            "Work Gallery",
                                          ),
                                        ),
                                        Tab(
                                          child: Text(
                                            "Waiting List",
                                          ),
                                        ),
                                      ]),
                                  Expanded(
                                      child: TabBarView(
                                        physics:
                                        const NeverScrollableScrollPhysics(),
                                    controller: userController.tabController,
                                    children: [
                                      Obx(() {
                                        return userController.currentProfile
                                                .value!.workProfile!.isEmpty
                                            ? const Center(
                                                child: CommonText(
                                                    color: Colors.black,
                                                    text: "No Work hostory"),
                                              )
                                            : Container(
                                          padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 2,
                                                ).copyWith(top: 20),
                                                height: 500,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: InkWell(
                                                  onTap: () async {
                                                    Uri url = Uri.parse(
                                                        userController
                                                                .currentProfile
                                                                .value!
                                                                .workProfile ??
                                                            "");
                                                    if (await canLaunchUrl(
                                                        url)) {
                                                      await launchUrl(url);
                                                    } else {
                                                      throw 'Could not launch $url';
                                                    }
                                                  },
                                                  child: WebView(
                                                    gestureNavigationEnabled:
                                                        true,
                                                    initialUrl: userController
                                                            .currentProfile
                                                            .value!
                                                            .workProfile ??
                                                        "",
                                                    javascriptMode:
                                                        JavascriptMode
                                                            .unrestricted,
                                                    onWebViewCreated:
                                                        (WebViewController
                                                            webViewController) {
                                                      _controller =
                                                          webViewController; // Assign controller after creation
                                                      _getHeight(); // Get WebView content height after page is loaded
                                                    },
                                                    onPageFinished:
                                                        (String url) {
                                                      print("page finished");
                                                      // After page is finished loading, get its content height
                                                      _getHeight();
                                                    },
                                                    navigationDelegate:
                                                        (NavigationRequest
                                                    request) async {
                                                      print("Called");
                                                      Uri url = Uri.parse(
                                                          request.url);
                                                      if (await canLaunchUrl(
                                                          url)) {
                                                        await launchUrl(url);
                                                        return NavigationDecision
                                                            .navigate;
                                                      } else {
                                                        throw 'Could not launch $url';
                                                      }
                                                    },
                                                  ),
                                                ),
                                              );
                                      }),
                                      Obx(() {
                                        return serviceController
                                                .fetchingRequests.value
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            : serviceController.request.isEmpty
                                                ? const Center(
                                                    child: CommonText(
                                                    color: blackColor,
                                                    text:
                                                        "No available requests!",
                                                    size: 16,
                                                  ))
                                                : userController.currentProfile
                                                            .value?.id ==
                                                        FirebaseAuth.instance
                                                            .currentUser?.uid
                                                    ? ReorderableListView(
                                                        onReorder: (oldIndex,
                                                            newIndex) {
                                                          setState(() {
                                                            if (newIndex >
                                                                oldIndex) {
                                                              newIndex -= 1;
                                                            }
                                                            final item =
                                                                serviceController
                                                                    .request
                                                                    .removeAt(
                                                                        oldIndex);
                                                            serviceController
                                                                .request
                                                                .insert(
                                                                    newIndex,
                                                                    item);
                                                            Get.find<
                                                                    ChatController>()
                                                                .updateRequestPositions(
                                                                    serviceController
                                                                        .request);
                                                          });
                                                        },
                                                        children:
                                                            serviceController
                                                                .request
                                                                .map((work) =>
                                                                    Dismissible(
                                                                      onDismissed:
                                                                          (direction) {
                                                                        chatController.deleteRequestWithPosition(
                                                                            work:
                                                                                work);
                                                                      },
                                                                      key: Key(work
                                                                          .position
                                                                          .toString()),
                                                                      direction:
                                                                          DismissDirection
                                                                              .endToStart,
                                                                      background:
                                                                          Container(
                                                                        color: Colors
                                                                            .red,
                                                                      ),
                                                                      secondaryBackground:
                                                                          Container(
                                                                        color: Colors
                                                                            .red,
                                                                        child:
                                                                            const Padding(
                                                                          padding:
                                                                              EdgeInsets.only(right: 8.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                            children: <Widget>[
                                                                              Icon(Icons.delete, color: Colors.white),
                                                                              CommonText(text: 'Delete', color: Colors.white),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          ListTile(
                                                                        key: Key(work
                                                                            .position
                                                                            .toString()),
                                                                        title:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            var selectIndex = serviceController.selectedRequests.indexWhere((element) =>
                                                                                element.requestId ==
                                                                                work.requestId);

                                                                            if (selectIndex ==
                                                                                -1) {
                                                                              serviceController.selectedRequests.add(work);
                                                                              serviceController.selectedRequests.refresh();
                                                                            } else {
                                                                              serviceController.selectedRequests.removeWhere((element) => element.requestId == work.requestId);
                                                                              serviceController.selectedRequests.refresh();
                                                                            }
                                                                          },
                                                                          child: jobCard(
                                                                              work: work,
                                                                              context: context),
                                                                        ),
                                                                      ),
                                                                    ))
                                                                .toList(),
                                                      )
                                                    : ListView.builder(
                                                        itemCount:
                                                            serviceController
                                                                .request.length,
                                                        shrinkWrap: true,
                                                        itemBuilder:
                                                            (context, index) {
                                                          Request work =
                                                              serviceController
                                                                  .request
                                                                  .elementAt(
                                                                      index);
                                                          return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          3),
                                                              child: jobCard(
                                                                  work: work,
                                                                  context:
                                                                      context));
                                                        });
                                      }),
                                    ],
                                  ))
                                ])),
                        Positioned(
                          top: -40,
                          left: MediaQuery.of(context).size.width * 0.38,
                          child: CircleAvatar(
                            backgroundColor: whiteColor,
                            radius: 47,
                            child: profileImage(
                                upload: true,
                                showCam: false,
                                radi: 45,
                                context: context,
                                imageProvider: userController.currentProfile
                                        .value!.profileUrl!.isEmpty
                                    ? const AssetImage(
                                        "assets/images/profile.png")
                                    : NetworkImage(userController
                                            .currentProfile.value!.profileUrl ??
                                        "") as ImageProvider),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  )),
            ),
          )),
    );
  }

  Future<void> _getHeight() async {
    var height =
        (await _controller.evaluateJavascript('document.body.scrollHeight'));
    userController.initialSize.value = double.parse(height);
    print("Height one ${userController.initialSize.value}");
  }

  Widget jobCard({required Request work, required context}) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              offset: const Offset(0.1, 0.1),
              spreadRadius: 1.8,
              blurRadius: 1.8)
        ],
      ),
      child: Row(
        children: [
          Obx(() => Checkbox(
              value: serviceController.selectedRequests.indexWhere(
                      (element) => element.requestId == work.requestId) ==
                  -1
                  ? false
                  : true,
              onChanged: (value) {})),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      work.provider!.id == FirebaseAuth.instance.currentUser?.uid
                          ? profileImage(
                          upload: true,
                          showCam: false,
                          radi: 12,
                          context: context,
                          imageProvider: work.provider!.profileUrl == null
                              ? const AssetImage("assets/images/profile.png")
                              : NetworkImage(work.provider!.profileUrl ?? "")
                          as ImageProvider)
                          : profileImage(
                          upload: true,
                          showCam: false,
                          radi: 12,
                          context: context,
                          imageProvider: work.userId!.profileUrl == null
                              ? const AssetImage("assets/images/profile.png")
                              : NetworkImage(work.userId!.profileUrl ?? "")
                          as ImageProvider),
                      const SizedBox(width: 3),
                      CommonText(
                        color: blackColor,
                        text:
                        "${work.provider!.id == FirebaseAuth.instance.currentUser?.uid ? work.userId!.firstname : work.provider!.firstname!}",
                        size: 15,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 3.0),
                        child: CommonText(
                          color: blackColor,
                          text: work.provider!.service!.name!,
                          size: 16,
                        ),
                      ),
                      CommonText(
                        color: blueColor,
                        text: "\$${work.price}",
                        size: 15,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              )),
        ],
      ),
    );
  }

  showUserModal({required BuildContext context}) {
    return showBottomSheet(
        context: context,
        enableDrag: true,
        backgroundColor: const Color(0XFFF2F2F2),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            )),
        builder: (_) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return DraggableScrollableSheet(
                    initialChildSize: 0.7,
                    expand: false,
                    builder: (BuildContext productContext,
                        ScrollController scrollController) {
                      return SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin: const EdgeInsets.only(right: 5, top: 5),
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: whiteColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: IconButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      icon: const Icon(
                                        Icons.clear,
                                        color: blackColor,
                                      )),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0)
                                    .copyWith(top: 20),
                                child: TextFormField(
                                  controller:
                                  authController.textEditingControllerBio,
                                  enabled:
                                  userController.currentProfile.value!.id ==
                                      FirebaseAuth.instance.currentUser?.uid
                                      ? true
                                      : false,
                                  style: const TextStyle(
                                      color: blackColor, fontSize: 15),
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: whiteColor,
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: const BorderSide(
                                              color: greyColor, width: 1)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: const BorderSide(
                                              color: greyColor, width: 1)),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          borderSide: const BorderSide(
                                              color: greyColor, width: 1))),
                                  maxLines: 10,
                                  minLines: 10,
                                ),
                              ),
                              Obx(() {
                                return userController.currentProfile.value!.id ==
                                    FirebaseAuth.instance.currentUser?.uid
                                    ? Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Center(
                                      child: SizedBox(
                                        width: 150,
                                        child: customRoundedButton(
                                            title: "Update",
                                            bgColor: blackColor,
                                            fgColor: whiteColor,
                                            voidCallback: () async {
                                              await authController
                                                  .updateSingleItem(
                                                  body: {
                                                    "bio": authController
                                                        .textEditingControllerBio
                                                        .text
                                                  },
                                                  id: FirebaseAuth
                                                      .instance
                                                      .currentUser!
                                                      .uid);
                                              userController.currentProfile
                                                  .value!.bio =
                                                  authController
                                                      .textEditingControllerBio
                                                      .text;
                                              userController.currentProfile
                                                  .refresh();
                                              authController
                                                  .textEditingControllerBio
                                                  .clear();
                                              Get.back();
                                            }),
                                      ),
                                    ),
                                  ],
                                )
                                    : const Text("");
                              })
                            ]),
                      );
                    });
              });
        });
  }

  showReportUserDialog({required context}) {
    UserController userController = Get.find<UserController>();
    return showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            )),
        context: context,
        builder: (_) {
          return SizedBox(
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CommonText(
                            color: blackColor,
                            text: "Report User",
                            fontFamily: "RedHatMedium",
                            size: 18,
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 5, top: 5),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: const Icon(
                                  Icons.clear,
                                  color: blackColor,
                                )),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0)
                          .copyWith(top: 20),
                      child: TextFormField(
                        controller: userController.textEditingMessage,
                        style: const TextStyle(color: blackColor, fontSize: 15),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: whiteColor,
                            hintText: "Write message...",
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: greyColor, width: 1)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: greyColor, width: 1)),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: greyColor, width: 1))),
                        maxLines: null,
                        minLines: 10,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 200,
                        child: customRoundedButton(
                            title: "Report",
                            bgColor: blackColor,
                            fgColor: whiteColor,
                            voidCallback: () {
                              if (userController.textEditingMessage.text
                                  .trim()
                                  .isEmpty) {
                                Get.back();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        backgroundColor: blackColor,
                                        content: CommonText(
                                            color: whiteColor,
                                            text: "Please write a message")));
                              } else {
                                Get.back();
                                userController.sendReportMessage(
                                    id: userController
                                        .currentProfile.value!.id!,
                                    message: userController
                                        .textEditingMessage.text
                                        .trim());
                              }
                            }),
                      ),
                    ),
                  ]),
            ),
          );
        });
  }
}

Widget jobListViewBuilder({required context}) {
  return Padding(
    padding: const EdgeInsets.only(left: 10, top: 10.0, right: 10),
    child: ListView.builder(
        shrinkWrap: true,
        // physics: const NeverScrollableScrollPhysics(),
        itemCount: Get.find<ServiceController>().myJobs.length,
        itemBuilder: (BuildContext ctx, index) {
          Work work = Get.find<ServiceController>().myJobs.elementAt(index);
          return InkWell(
            onTap: () {
              if (work.isLive == true) {
                Get.to(() => Livestream(roomId: work.roomId!));
              }
            },
            child: Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(
                  bottom: 10,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                      colors: [
                        linearGradientTwo,
                        linearGradientOne,
                      ],
                      stops: [
                        0.0,
                        1.0
                      ],
                      begin: FractionalOffset.topLeft,
                      end: FractionalOffset.bottomRight,
                      tileMode: TileMode.clamp),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                          color: whiteColor,
                          text: work
                              .provider!.service!.name!.capitalize!.capitalize!,
                          size: 16,
                        ),
                        CommonText(
                          color: whiteColor,
                          text: DateFormat("MMM dd yyyy")
                              .format(work.time!)
                              .capitalize!
                              .capitalize!,
                          size: 16,
                          fontFamily: "RedHatLight",
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        if (work.isLive == true) {
                          Get.to(() => Livestream(roomId: work.roomId!));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: whiteColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    work
                                        .provider!.id ==
                                        FirebaseAuth
                                            .instance.currentUser?.uid
                                        ? profileImage(
                                        upload: true,
                                        showCam: false,
                                        radi: 12,
                                        context: ctx,
                                        imageProvider: work
                                            .provider!.profileUrl ==
                                            null
                                            ? const AssetImage(
                                            "assets/images/profile.png")
                                            : NetworkImage(work
                                            .provider!.profileUrl ??
                                            "") as ImageProvider)
                                        : profileImage(
                                        upload: true,
                                        showCam: false,
                                        radi: 12,
                                        context: ctx,
                                        imageProvider: work
                                            .userId!.profileUrl ==
                                            null
                                            ? const AssetImage(
                                            "assets/images/profile.png")
                                            : NetworkImage(
                                            work.userId!.profileUrl ??
                                                "") as ImageProvider),
                                    const SizedBox(width: 3),
                                    CommonText(
                                      color: blackColor,
                                      text:
                                      "${work.provider!.id == FirebaseAuth.instance.currentUser?.uid ? work.userId!.firstname : work.provider!.firstname!}",
                                      size: 15,
                                    ),
                                  ],
                                ),
                                if (work.isLive == true)
                                  const Icon(Icons.video_call_sharp,
                                      color: blueColor)
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CommonText(
                                      color: blueColor,
                                      text: "\$${work.price! * work.hours!}",
                                      size: 15,
                                    ),
                                    CommonText(
                                      color: blueColor,
                                      text: "/ ${work.workType}",
                                      fontFamily: "RedHatLight",
                                      size: 15,
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 5),
                                  decoration: BoxDecoration(
                                      color: work.status == "pending"
                                          ? yellowColor
                                          : Colors.green,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: CommonText(
                                    color: whiteColor,
                                    text: work.status.toString().capitalize!,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              work.reviewMessage ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              style: const TextStyle(
                                fontFamily: "RedHatLight",
                                color: blackColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          );
        }),
  );
}

Widget buildProductRatingWidget(double rating) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text("(",
          style: TextStyle(
            color: yellowColor,
            fontWeight: FontWeight.bold,
            fontSize: 23.sp,
          )),
      Icon(
        Icons.star,
        color: yellowColor,
        size: 18.sp,
      ),
      Text(
        rating.toStringAsFixed(0),
        style: TextStyle(
          color: yellowColor,
          fontWeight: FontWeight.w900,
          fontSize: 18.sp,
        ),
      ),
      Text(")",
          style: TextStyle(
            color: yellowColor,
            fontWeight: FontWeight.bold,
            fontSize: 23.sp,
          )),
    ],
  );
}
