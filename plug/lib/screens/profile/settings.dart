import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/controllers/user_controller.dart';
import 'package:plugme/screens/bank_setup.dart';
import 'package:plugme/utils/style.dart';
import 'package:plugme/widgets/common_text.dart';

import '../../controllers/service_controller.dart';
import '../../widgets/items_selection_container.dart';
import '../../widgets/service_popup.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key) {
    authController.assignFields();
    authController.textEditingControllerRate.text =
        authController.currentUser.value!.pricePerHour.toString();
  }

  final AuthController authController = Get.find<AuthController>();
  final UserController userController = Get.find<UserController>();
  final ServiceController serviceController = Get.find<ServiceController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: blueColor,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Get.back();
                  authController.updateSingleItem(body: {
                    "availability": userController.selectedDays
                        .map((element) => element)
                        .toList()
                  }, id: FirebaseAuth.instance.currentUser!.uid);
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: whiteColor,
                )),
            title: const CommonText(
              color: whiteColor,
              text: "Settings",
              size: 20,
            ),
            elevation: 0.0,
            backgroundColor: blueColor,
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(top: 30),
              decoration: const BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CommonText(
                      color: blackColor,
                      text: "Account Information",
                      size: 18,
                    ),
                    SizedBox(
                      height: 0.02.sh,
                    ),
                    Obx(() {
                      return authController
                                  .currentUser.value?.isServiceProvider ==
                              true
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                const CommonText(
                                  color: blackColor,
                                  text: "Service Offered",
                                ),
                                const SizedBox(height: 10),
                                Obx(() => ItemSelectionContainer(
                                      changeVerticalPadding: true,
                                      text: authController
                                                  .selectedService.value ==
                                              null
                                          ? " "
                                          : "${authController.selectedService.value!.icon!} ${authController.selectedService.value!.name!.toString().capitalize!}",
                                      voidCallback: () {
                                        showServicesDialog(context, true);
                                      },
                                    )),
                                const SizedBox(height: 10),
                              ],
                            )
                          : Container(
                              height: 0,
                            );
                    }),
                    Obx(() {
                      return authController.selectedService.value != null &&
                              (authController.selectedService.value!
                                      .subcategory!.isNotEmpty ||
                                  authController
                                      .selectedService.value!.subCategory!
                                      .trim()
                                      .isNotEmpty)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                const CommonText(
                                  color: blackColor,
                                  text: "Select Subservice",
                                ),
                                const SizedBox(height: 5),
                                ItemSelectionContainer(
                                  text: authController.selectedService.value
                                              ?.subCategory!
                                              .trim()
                                              .isEmpty ==
                                          true
                                      ? "Select  SubService"
                                      : "${authController.selectedService.value?.subCategory}",
                                  voidCallback: () {
                                    showSubServicesDialog(
                                        context: context,
                                        subCategories: authController
                                            .selectedService
                                            .value!
                                            .subcategory!,
                                        connect: false);
                                  },
                                ),
                                SizedBox(
                                  height: 0.02.sh,
                                ),
                              ],
                            )
                          : Container(height: 0);
                    }),
                    Obx(() {
                      return authController
                                  .currentUser.value?.isServiceProvider ==
                              true
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CommonText(
                                    color: blackColor,
                                    text: "Rate per Hour",
                                  ),
                                  const SizedBox(height: 5),
                                  TextFormField(
                                    controller: authController
                                        .textEditingControllerRate,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        authController.updateSingleItem(
                                            body: {
                                              "pricePerHour": int.parse(
                                                  authController
                                                      .textEditingControllerRate
                                                      .text)
                                            },
                                            id: FirebaseAuth
                                                .instance.currentUser!.uid);
                                        authController.currentUser.value!
                                                .pricePerHour =
                                            int.parse(authController
                                                .textEditingControllerRate
                                                .text);
                                        authController.currentUser.refresh();
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "please fill this field";
                                      }
                                      return null;
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              width: 1, color: greyColor),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              width: 1, color: greyColor),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                              width: 1, color: greyColor),
                                        ),
                                        filled: true,
                                        fillColor: whiteColor),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              height: 0,
                            );
                    }),
                    Obx(() {
                      return authController
                                  .currentUser.value?.isServiceProvider ==
                              true
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CommonText(
                                  color: blackColor,
                                  text: "Availability",
                                  fontFamily: "RedHatMedium",
                                ),
                                Wrap(
                                  spacing: 6.0,
                                  runSpacing: 6.0,
                                  children: userController.daysOfTheWeek
                                      .map((e) => InkWell(
                                            onTap: () {
                                              var index = userController
                                                  .selectedDays
                                                  .indexWhere((element) =>
                                                      element == e);
                                              if (index == -1) {
                                                userController.selectedDays
                                                    .add(e);
                                                userController.selectedDays
                                                    .refresh();
                                              } else {
                                                userController.selectedDays
                                                    .removeWhere((element) =>
                                                        element == e);
                                                userController.selectedDays
                                                    .refresh();
                                              }
                                            },
                                            child: Obx(() => Chip(
                                                  backgroundColor: userController
                                                              .selectedDays
                                                              .indexWhere(
                                                                  (element) =>
                                                                      element ==
                                                                      e) ==
                                                          -1
                                                      ? lightGrey
                                                      : const Color(0XFF8C90F3),
                                                  label: CommonText(
                                                      text: "$e",
                                                      color: userController
                                                                  .selectedDays
                                                                  .indexWhere(
                                                                      (element) =>
                                                                          element ==
                                                                          e) ==
                                                              -1
                                                          ? const Color(
                                                              0XFF121212)
                                                          : whiteColor,
                                                      fontFamily:
                                                          "RedHatLight"),
                                                )),
                                          ))
                                      .toList(),
                                ),
                                const SizedBox(height: 10),
                              ],
                            )
                          : Container(
                              height: 0,
                            );
                    }),
                    const CommonText(color: blackColor, text: "Action"),
                    SizedBox(
                      height: 0.02.sh,
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(() => CommonText(
                                        color: blackColor,
                                        text: authController.currentUser.value!
                                                    .isServiceProvider ==
                                                true
                                            ? "Verified Service provider"
                                            : "Become Service provider")),
                                    Obx(
                                      () => Text(
                                          authController.currentUser.value!
                                                      .isServiceProvider ==
                                                  true
                                              ? "You are now a service provider clients will be able to view your profile when they search for a service."
                                              : "By enabling this function clients will be able to see your profile when they search for providers.",
                                          style: TextStyle(fontSize: 11.sp)),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Obx(() {
                                      return authController.currentUser.value?.isServiceProvider ==
                                              true
                                          ? const Icon(
                                              Icons.verified,
                                              color: Colors.blueAccent,
                                            )
                                          : Switch(
                                              activeColor: blackColor,
                                              value: authController
                                                  .connectBank.value,
                                              onChanged: (value) async {
                                                authController
                                                    .connectBank.value = value;
                                                if (authController
                                                        .connectBank.value ==
                                                    true) {
                                                  Get.to(
                                                      () => const BankSetup());
                                                }
                                              });
                                    }),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Obx(() {
                                        return authController.currentUser.value!=null&& authController.currentUser.value!
                                                    .isServiceProvider ==
                                                true
                                            ? InkWell(
                                                onTap: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        return AlertDialog(
                                                          title:
                                                              const CommonText(
                                                            color: blackColor,
                                                            text:
                                                                "Disable Provider",
                                                          ),
                                                          content:
                                                              const CommonText(
                                                            color: blackColor,
                                                            text:
                                                                "Once you disable, you will no longer be a service provider",
                                                            fontFamily:
                                                                "RedHatLight",
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                                onPressed: () {
                                                                  Get.back();
                                                                },
                                                                child: const CommonText(
                                                                    color: Colors
                                                                        .deepPurple,
                                                                    text:
                                                                        "CANCEL")),
                                                            TextButton(
                                                                onPressed: () {
                                                                  Get.back();
                                                                  serviceController
                                                                      .disconnectStripe(
                                                                          context);
                                                                },
                                                                child: const CommonText(
                                                                    color: Colors
                                                                        .deepPurple,
                                                                    text:
                                                                        "OKAY"))
                                                          ],
                                                        );
                                                      });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 3,
                                                      horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      color: Colors.redAccent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: const CommonText(
                                                    color: whiteColor,
                                                    text: "Disable",
                                                    size: 14,
                                                  ),
                                                ),
                                              )
                                            : const Text("");
                                      }),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 0.02.sh,
                    ),
                    Container(
                      width: 0.9.sw,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.withOpacity(0.25)),
                      child: InkWell(
                        onTap: () async {
                          showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return Dialog(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Container(
                                    height: 0.3.sh,
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.block,
                                            color: blackColor,
                                            size: 45,
                                          ),
                                          SizedBox(height: 0.03.sh),
                                          Obx(() => Text(
                                                "${authController.currentUser.value!.accountEnabled == true ? "Disable" : "Enable"} your account",
                                                style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 16.sp),
                                              )),
                                          SizedBox(height: 0.02.sh),
                                          Text(
                                            " Your profile ${authController.currentUser.value!.accountEnabled == true ? "enabled" : "disabled"}",
                                            style: TextStyle(
                                                color: blackColor,
                                                fontSize: 14.sp),
                                          ),
                                          SizedBox(height: 0.03.sh),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  Navigator.pop(
                                                      dialogContext, false);
                                                  try {
                                                    Get.defaultDialog(
                                                        title: "Just a moment",
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .all(10),
                                                        content:
                                                            const CircularProgressIndicator(),
                                                        barrierDismissible:
                                                            false);

                                                    authController
                                                        .updateSingleItem(
                                                            body: {
                                                          "accountEnabled":
                                                              authController
                                                                          .currentUser
                                                                          .value!
                                                                          .accountEnabled ==
                                                                      true
                                                                  ? false
                                                                  : true
                                                        },
                                                            id: FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid);
                                                    authController
                                                            .currentUser
                                                            .value!
                                                            .accountEnabled =
                                                        !authController
                                                            .currentUser
                                                            .value!
                                                            .accountEnabled!;
                                                    authController.currentUser
                                                        .refresh();
                                                    Get.back();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: CommonText(
                                                                color:
                                                                    whiteColor,
                                                                text:
                                                                    "Your Account has been ${authController.currentUser.value!.accountEnabled == true ? "enabled" : "disabled"}")));
                                                  } catch (e) {
                                                    Get.back();
                                                  }
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                                  child: Text(
                                                    "Yes",
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  Get.back();
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                                  child: Text(
                                                    "No",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.block,
                              color: blackColor,
                              size: 20,
                            ),
                            SizedBox(
                              width: 0.02.sh,
                            ),
                            Obx(() => Text(
                                  authController.currentUser.value != null &&
                                          authController.currentUser.value!
                                                  .accountEnabled ==
                                              true
                                      ? "Disable account"
                                      : "Enable Account",
                                  style: TextStyle(
                                      color: blackColor, fontSize: 16.sp),
                                )),
                            const Spacer(),
                            const Icon(
                              Icons.navigate_next,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 0.01.sh,
                    ),
                    Text(
                      "Help",
                      style: TextStyle(
                          fontSize: 18.0.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 0.01.sh,
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 0.01.sh,
                    ),
                    _itemRow("FAQ & Info", () {},
                        svg: "Question mark.svg",
                        iconData: Icons.question_mark),
                    _itemRow("Contact Us", () async {},
                        iconData: Icons.email_outlined),
                    SizedBox(
                      height: 0.01.sh,
                    ),
                    Text(
                      "Legal",
                      style: TextStyle(
                          fontSize: 18.0.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 0.01.sh,
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 0.01.sh,
                    ),
                    _itemRow("Privacy Policy", () async {},
                        iconData: Icons.lock),
                    _itemRow("Terms & Conditions", () async {},
                        iconData: Icons.note_outlined),
                    SizedBox(
                      height: 0.02.sh,
                    ),
                    Text(
                      "Other",
                      style: TextStyle(
                          fontSize: 18.0.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    SizedBox(
                      height: 0.01.sh,
                    ),
                    _itemRow("Logout", () async {
                      showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: const CommonText(
                                color: blackColor,
                                text: "Logout",
                              ),
                              content: const CommonText(
                                color: blackColor,
                                text: "Are you sure you want to logout?",
                                fontFamily: "RedHatLight",
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    child: const CommonText(
                                        color: Colors.deepPurple,
                                        text: "CANCEL")),
                                TextButton(
                                    onPressed: () {
                                      Get.back();
                                      authController.logout();
                                    },
                                    child: const CommonText(
                                        color: Colors.deepPurple, text: "OKAY"))
                              ],
                            );
                          });
                    }, iconData: Icons.power_settings_new, showArrow: false),
                  ],
                ),
              ),
            ),
          ),
        ),
        onWillPop: () async {
          authController.updateSingleItem(body: {
            "availability":
                userController.selectedDays.map((element) => element).toList()
          }, id: FirebaseAuth.instance.currentUser!.uid);
          return true;
        });
  }

  _itemRow(String title, Function function,
      {String? icon,
      IconData? iconData,
      String? svg,
      bool? showArrow = true,
      Color color = Colors.black}) {
    return Column(
      children: [
        SizedBox(
          height: 0.01.sh,
        ),
        InkWell(
          onTap: () => function(),
          child: Row(
            children: [
              if (icon != null)
                Image.asset(
                  "assets/icons/$icon",
                  width: 25,
                  color: color,
                ),
              if (iconData != null)
                CircleAvatar(
                  radius: 15,
                  backgroundColor: yellowColor,
                  child: Icon(
                    iconData,
                    size: 16,
                    color: whiteColor,
                  ),
                ),
              SizedBox(
                width: 0.01.sh,
              ),
              Text(
                title,
                style: TextStyle(color: color, fontSize: 14.sp),
              ),
              const Spacer(),
              if (showArrow == true)
                const Icon(
                  Icons.navigate_next,
                  color: Colors.black,
                ),
            ],
          ),
        ),
        SizedBox(
          height: 0.01.sh,
        ),
        const Divider(
          color: Colors.grey,
        ),
        SizedBox(
          height: 0.01.sh,
        ),
      ],
    );
  }
}
