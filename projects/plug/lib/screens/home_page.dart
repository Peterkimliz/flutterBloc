import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/user_controller.dart';
import 'package:plug/models/service.dart';
import 'package:badges/badges.dart' as badges;
import 'package:plug/models/user.dart';
import 'package:plug/screens/auth/landing_page.dart';
import 'package:plug/screens/chats/chats_page.dart';
import 'package:plug/screens/profile/components/featured_card.dart';
import 'package:plug/utils/function.dart';
import 'package:plug/utils/style.dart';
import 'package:plug/widgets/searched_user_card.dart';
// import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../controllers/service_controller.dart';
import '../models/inbox.dart';
import '../widgets/common_text.dart';
import 'bank_setup.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);


  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final UserController userController = Get.put(UserController());
  final ServiceController serviceController = Get.put(ServiceController());
  final AuthController authController = Get.put(AuthController());

  @override
  void didChangeMetrics() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final newValue = bottomInset > 0.0;

    if (newValue != userController.isKeyboardVisible.value) {
      userController.isKeyboardVisible.value = newValue;
    }
    if (newValue == true) {
      userController.initialHeight.value = 0.70;
    }
  }

  bool _showSuffix = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(builder: (controller) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Obx(
                    () {
                  return controller.fetchMarker.value
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : serviceController.position.value == null
                          ? const Center(
                              child: CommonText(
                                color: blackColor,
                                text: "Loading...",
                              ),
                            )
                          : GoogleMap(
                              zoomGesturesEnabled: true,
                              zoomControlsEnabled: false,
                              mapType: MapType.normal,
                              markers: Set<Marker>.of(controller.markers),
                              polylines: userController.polyline,
                              myLocationEnabled: true,
                              padding: const EdgeInsets.only(top: 300.0),
                              initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                      serviceController
                                          .position.value!.latitude!,
                                      serviceController
                                          .position.value!.longitude!),
                                  zoom: 14),
                              onMapCreated: (GoogleMapController controller) {
                                if (userController.controller.isCompleted) {
                                  userController.controller
                                      .complete(controller);
                                }
                              },
                            );
                },
              ),
              if (FirebaseAuth.instance.currentUser != null)
                Positioned(
                    right: 10,
                    top: 250,
                    child: InkWell(
                      onTap: () {
                        if (authController.currentUser.value == null) {
                          Get.to(() => LandingPage());
                        } else {
                          Get.to(() => ChatsPage());
                        }
                      },
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                              color: whiteColor, shape: BoxShape.circle),
                          child: Center(
                            child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("messages")
                                  .where("users",
                                      arrayContains: FirebaseAuth
                                          .instance.currentUser?.uid)
                                  .orderBy("time", descending: true)
                                  .snapshots(),
                              builder: (context, AsyncSnapshot snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: Icon(
                                    Icons.notifications,
                                    color: blueColor,
                                  ));
                                }
                                if (snapshot.data?.docs.length != 0) {
                                  int sum = 0;
                                  List data = snapshot.data?.docs!;
                                  for (var i = 0; i < data.length; i++) {
                                    Inbox inbox =
                                        Inbox.fromJson(snapshot.data!.docs[i]);
                                    if (authController.currentUser.value !=
                                            null &&
                                        inbox.getUnreadMessages(authController
                                                .currentUser.value!.id!) >
                                            0) {
                                      sum += 1;
                                    }
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 3.0),
                                    child: sum > 0
                                        ? badges.Badge(
                                            badgeContent: CommonText(
                                                color: whiteColor,
                                                text: "$sum"),
                                            child: const Icon(
                                              Icons.notifications,
                                              color: blueColor,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.notifications,
                                            color: blueColor,
                                          ),
                                  );
                                }
                                return const Icon(
                                  Icons.notifications,
                                  color: blueColor,
                                );
                              },
                            ),
                          )),
                  )),
              Positioned(
                  right: 10,
                  top: 15,
                  child: Obx(() {
                    return authController
                                .currentUser.value?.isServiceProvider ==
                            true
                        ? FlutterSwitch(
                            width: 100.0,
                            height: 40.0,
                            valueFontSize: 16.0,
                            toggleSize: 20.0,
                            activeColor: Colors.green,
                            inactiveColor: Colors.grey,
                            activeTextColor: whiteColor,
                            inactiveTextColor: whiteColor,
                            activeText: "Online",
                            inactiveText: "Offline",
                            value: authController.currentUser.value!.isOnline ??
                                false,
                            borderRadius: 30.0,
                            padding: 8.0,
                            showOnOff: true,
                            onToggle: (val) {
                              authController.currentUser.value!.isOnline = val;
                              authController.currentUser.refresh();
                              authController.updateSingleItem(
                                  body: {"isOnline": val},
                                  id: FirebaseAuth.instance.currentUser!.uid);
                            },
                          )
                        : FlutterSwitch(
                            width: 170.0,
                            height: 30.0,
                            valueFontSize: 12.0,
                            toggleSize: 25.0,
                            activeColor: Colors.green,
                            inactiveColor: Colors.grey,
                            activeTextColor: whiteColor,
                            inactiveTextColor: whiteColor,
                            activeText: "",
                            inactiveText: "Become Service Provider",
                            value: false,
                            borderRadius: 30.0,
                            padding: 6.0,
                            showOnOff: true,
                            onToggle: (val) {
                              if (authController.currentUser.value == null) {
                                Get.to(() => LandingPage());
                              } else {
                                Get.to(() => const BankSetup());
                              }
                            },
                          );
                  })),
              Obx(() => SizedBox.expand(
                    child: DraggableScrollableSheet(
                        initialChildSize: userController.initialHeight.value,
                        minChildSize: 0.2,
                        maxChildSize: 0.9,
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return ListView(
                            controller: scrollController,
                            children: [
                              Container(
                                color: Colors.transparent,
                                height:
                                    MediaQuery.of(context).size.height * 0.8,
                                width: MediaQuery.of(context).size.width,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Obx(() => Positioned(
                                          top: serviceController
                                                          .category.value ==
                                                      null &&
                                                  userController
                                                          .showFuturedProvider
                                                          .value ==
                                                      true
                                              ? 150
                                              : 60,
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3,
                                            decoration: const BoxDecoration(
                                                color: whiteColor,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(25),
                                                  topRight: Radius.circular(25),
                                                )),
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 15),
                                                Center(
                                                    child: Container(
                                                  width: 150,
                                                  height: 5,
                                                  decoration: BoxDecoration(
                                                      color: greyColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30)),
                                                )),
                                                const SizedBox(height: 10),
                                                InkWell(
                                                  onTap: () {
                                                    userController.initialHeight
                                                        .value = 0.70;
                                                    userController
                                                        .scrollController
                                                        .jumpTo(0.70);
                                                  },
                                                  child: Container(
                                                    width: double.infinity,
                                                    color: Colors.white,
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10),
                                                    height:
                                                        kBottomNavigationBarHeight,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 15,
                                                        vertical: 3),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                            child:
                                                                TextFormField(
                                                          controller:
                                                              serviceController
                                                                  .textEditingControllerSearchService,
                                                          decoration:
                                                              InputDecoration(
                                                                hintText: "Search",
                                                            fillColor: blueColor
                                                                .withOpacity(
                                                                    0.06),
                                                            filled: true,
                                                            prefixIcon:
                                                                const Icon(
                                                              Icons.search,
                                                              color: blueColor,
                                                            ),
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        10),
                                                                suffixIcon:
                                                                _showSuffix
                                                                    ? InkWell(
                                                                        onTap:
                                                                            () {
                                                                          if (userController.isKeyboardVisible.value ||
                                                                              serviceController.textEditingControllerSearchService.text.isNotEmpty) {
                                                                            FocusScope.of(context).unfocus();
                                                                            serviceController.textEditingControllerSearchService.clear();
                                                                            serviceController.fetchedServices.clear();
                                                                            serviceController.fetchedServices.value =
                                                                                [
                                                                              ...serviceController.services
                                                                            ];
                                                                            serviceController.fetchedServices.refresh();

                                                                            serviceController.category.value = null;
                                                                            setState(() {
                                                                              _showSuffix=false;
                                                                            });
                                                                          }
                                                                        },
                                                                        child:
                                                                            const Icon(
                                                                          Icons
                                                                              .clear,
                                                                          color:
                                                                              Colors.red,
                                                                        ),
                                                                      )
                                                                    : null,
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  const BorderSide(
                                                                color:
                                                                    blueColor,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            focusedBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              borderSide:
                                                                  const BorderSide(
                                                                color:
                                                                    blueColor,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            enabledBorder:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                10,
                                                              ),
                                                              borderSide:
                                                                  const BorderSide(
                                                                color:
                                                                    blueColor,
                                                                width: 1,
                                                              ),
                                                            ),
                                                          ),
                                                          onChanged: (value) {
                                                            if (value.trim().isNotEmpty) {
                                                              setState(() {
                                                                _showSuffix=true;
                                                              });
                                                              serviceController
                                                                  .searchService(
                                                                      text: value);
                                                              userController
                                                                  .searchUsersBasedOnService(
                                                                      name: value);
                                                            } else {
                                                              setState(() {
                                                                _showSuffix=false;
                                                              });
                                                              serviceController
                                                                  .fetchedServices
                                                                  .clear();
                                                              serviceController.fetchedServices.value =
                                                              [
                                                                ...serviceController.services
                                                              ];
                                                              serviceController.fetchedServices.refresh();
                                                            }
                                                          },
                                                        )),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            if (serviceController
                                                                    .category
                                                                    .value !=
                                                                null) {
                                                              userController
                                                                  .initialHeight
                                                                  .value = 0.50;
                                                              filtersBottomSheetMenu(
                                                                  context);
                                                            } else {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(const SnackBar(
                                                                      content: CommonText(
                                                                          color:
                                                                              whiteColor,
                                                                          text:
                                                                              "Please select atleast one category")));
                                                            }
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10),
                                                            decoration: BoxDecoration(
                                                                color: blueColor
                                                                    .withOpacity(
                                                                        0.06),
                                                                border: Border.all(
                                                                    color:
                                                                        blueColor,
                                                                    width: 1),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Image.asset(
                                                              "assets/images/sliders.png",
                                                              color: blueColor,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Expanded(
                                                  child: ListView(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Obx(() {
                                                                return userController
                                                                        .fetchingUsers
                                                                        .value
                                                                    ? const Center(
                                                                        child:
                                                                            CircularProgressIndicator())
                                                                    : Column(
                                                                        children: [
                                                                        Obx(() =>  Wrap(
                                                                          spacing:
                                                                          6.0,
                                                                          runSpacing:
                                                                          6.0,
                                                                          children: serviceController.fetchedServices.map((e) => serviceChip(context: context, serviceModel: e)).toList(),
                                                                        )),
                                                                          const SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          SizedBox(
                                                                              height: MediaQuery.of(context).size.height * 0.7,
                                                                              child: ListView.builder(
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  shrinkWrap: true,
                                                                                  itemCount: userController.filteredUsers.length,
                                                                                  itemBuilder: (context, index) {
                                                                                    UserModel userModel = userController.filteredUsers.elementAt(index);
                                                                                    return searchedUserWidget(userModel: userModel, index: index, context: context);
                                                                                  }))
                                                                        ],
                                                                      );
                                                              }),
                                                            ]),
                                                      )
                                                    ],
                                                    // itemBuilder: (BuildContext context, int index) {
                                                    //   return ;
                                                    // },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      top: 10,
                                      child: Obx(() {
                                        return serviceController
                                                    .category.value !=
                                                null
                                            ? Container(
                                          height: kToolbarHeight,
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: ListView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        userController
                                                            .initialHeight
                                                            .value = 0.50;
                                                        serviceController
                                                            .category
                                                            .value = null;
                                                        userController
                                                            .selectedUser
                                                            .value = null;
                                                        userController.markers
                                                            .clear();
                                                        userController.markers
                                                            .refresh();
                                                        userController.polyline
                                                            .clear();
                                                        userController.polyline
                                                            .refresh();
                                                        userController
                                                            .filteredUsers
                                                            .clear();
                                                        userController
                                                            .filteredUsers
                                                            .refresh();
                                                      },
                                                      child: Chip(
                                                        label: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            CommonText(
                                                                color:
                                                                    whiteColor,
                                                                text: "${serviceController.category.value!.icon!} ${serviceController.category.value!.name!}"
                                                                    .capitalize!),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          8.0),
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(3),
                                                                decoration: const BoxDecoration(
                                                                    color:
                                                                        whiteColor,
                                                                    shape: BoxShape
                                                                        .circle),
                                                                child:
                                                                    const Icon(
                                                                  Icons.clear,
                                                                  size: 16,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        backgroundColor:
                                                            blueColor,
                                                      ),
                                                    ),
                                                    // Obx(() {
                                                    //   return userController
                                                    //               .rangeValues
                                                    //               .value!
                                                    //               .end !=
                                                    //           20.0
                                                    //       ? InkWell(
                                                    //           onTap: () {
                                                    //             // userController
                                                    //             //         .rangeValues
                                                    //             //         .value =
                                                    //             //     const SfRangeValues(
                                                    //             //         0.0,
                                                    //             //         20.0);
                                                    //
                                                    //             userController
                                                    //                 .searchUsersBasedOnService();
                                                    //           },
                                                    //           child: Padding(
                                                    //               padding:
                                                    //                   const EdgeInsets
                                                    //                       .only(
                                                    //                       left:
                                                    //                           5.0),
                                                    //               child: Chip(
                                                    //                 label: Row(
                                                    //                   mainAxisAlignment:
                                                    //                       MainAxisAlignment
                                                    //                           .start,
                                                    //                   mainAxisSize:
                                                    //                       MainAxisSize
                                                    //                           .min,
                                                    //                   children: [
                                                    //                     CommonText(
                                                    //                         color:
                                                    //                             whiteColor,
                                                    //                         text:
                                                    //                             "\$${userController.rangeValues.value!.start}-${userController.rangeValues.value!.end}"),
                                                    //                     const Padding(
                                                    //                       padding:
                                                    //                           EdgeInsets.only(left: 8.0),
                                                    //                       child:
                                                    //                           Icon(
                                                    //                         Icons.clear,
                                                    //                         color:
                                                    //                             whiteColor,
                                                    //                         size:
                                                    //                             16,
                                                    //                       ),
                                                    //                     )
                                                    //                   ],
                                                    //                 ),
                                                    //                 backgroundColor:
                                                    //                     const Color(
                                                    //                         0XFF8C90F3),
                                                    //               )),
                                                    //         )
                                                    //       : const Text("");
                                                    // }),
                                                    Obx(() {
                                                      return userController
                                                              .selectedDays
                                                              .isNotEmpty
                                                          ? InkWell(
                                                              onTap: () {
                                                                userController
                                                                    .selectedDays
                                                                    .clear();
                                                                userController
                                                                    .selectedDays
                                                                    .refresh();
                                                                userController
                                                                    .searchUsersBasedOnService();
                                                              },
                                                              child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              5.0),
                                                                  child: Chip(
                                                                    label: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        CommonText(
                                                                            color:
                                                                                whiteColor,
                                                                            text:
                                                                                "${userController.selectedDays.map((element) => element.toString())}"),
                                                                        const Padding(
                                                                          padding:
                                                                              EdgeInsets.only(left: 8.0),
                                                                          child:
                                                                              Icon(
                                                                            Icons.clear,
                                                                            color:
                                                                                whiteColor,
                                                                            size:
                                                                                16,
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                    backgroundColor:
                                                                        const Color(
                                                                            0XFF8C90F3),
                                                                  )),
                                                            )
                                                          : const Text("");
                                                    }),
                                                  ],
                                                ),
                                              )
                                            : const Text("");
                                      }),
                                    ),

                                    Positioned(
                                      left: 0,
                                      right: 0,
                                      top: 20,
                                      child: Obx(() {
                                        return serviceController
                                                        .category.value ==
                                                    null &&
                                                userController
                                                        .showFuturedProvider
                                                        .value ==
                                                    true
                                            ? Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height: 120,
                                                    child: ListView.builder(
                                                        itemCount:
                                                            userController
                                                                .featuredUsers
                                                                .length,
                                                        shrinkWrap: true,
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemBuilder:
                                                            (context, index) {
                                                          UserModel usermodel =
                                                              userController
                                                                  .featuredUsers
                                                                  .elementAt(
                                                                      index);
                                                          return FeaturedCard(
                                                              userModel:
                                                                  usermodel);
                                                        }),
                                                  ),
                                                  Positioned(
                                                    right: 10,
                                                    top: -20,
                                                    child: InkWell(
                                                      onTap: () {
                                                        userController
                                                            .showFuturedProvider
                                                            .value = false;
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: lightGrey,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.clear,
                                                            color: blackColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                            : const Text("");
                                      }),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                  )),
            ],
          ),
        ),
      );
    });
  }

  Widget serviceChip({required ServiceModel serviceModel, required context}) {
    return InkWell(
      onTap: () {
        print("Hello ${serviceModel.isSubcategory}");
        if (serviceModel.isSubcategory == true) {
          serviceController.category.value = serviceModel;
          userController.searchUsersBasedOnService();
        } else if (serviceModel.subcategory!.isNotEmpty) {
          int index = serviceController.services
              .indexWhere((element) => element.id == serviceModel.id);
          serviceController.services[index].expand = true;
          serviceController.services[index].subcategory![0] = "All";
          serviceController.services.refresh();
        } else {
          serviceController.category.value = serviceModel;
          userController.searchUsersBasedOnService();
        }
      },
      child: serviceModel.expand == true
          ? InkWell(
              onTap: () {
                print("wewe");
                int index = serviceController.services.indexWhere((element) => element.id == serviceModel.id);
                serviceController.services[index].expand = false;
                serviceController.services.refresh();
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: lightGrey, borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                            text: serviceModel.name!.capitalize!,
                            color: const Color(0XFF121212),
                            size: 14,
                            fontFamily: "RedHatMedium"),
                        const Icon(Icons.clear),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 30,
                      width: MediaQuery.of(context).size.width,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: serviceModel.subcategory!
                            .map((e) => Padding(
                                  padding: const EdgeInsets.only(right: 5.0),
                                  child: InkWell(
                                    onTap: () {
                                      serviceController.category.value =
                                          serviceModel;
                                      serviceController
                                          .category.value!.subCategory = e;
                                      int index = serviceController.services
                                          .indexWhere((element) =>
                                              element.id == serviceModel.id);
                                      serviceController.services[index].expand =
                                          false;
                                      serviceController.services.refresh();
                                      userController
                                          .searchUsersBasedOnService();
                                    },
                                    child: Chip(
                                      backgroundColor: serviceController
                                                  .category
                                                  .value
                                                  ?.subCategory ==
                                              e
                                          ? blackColor
                                          : whiteColor,
                                      label: CommonText(
                                          text: e,
                                          color: serviceController.category
                                                      .value?.subCategory ==
                                                  e
                                              ? whiteColor
                                              : blackColor,
                                          fontFamily: "RedHatLight"),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    )
                  ],
                ),
              ),
            )
          : Chip(
              backgroundColor: lightGrey,
              label: CommonText(
                  text:
                      "${serviceModel.icon!} ${serviceModel.name!.toString().capitalize!}",
                  color: blueColor,
                  fontFamily: "RedHatLight"),
            ),
    );
  }
}
