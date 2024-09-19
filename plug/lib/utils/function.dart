import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/controllers/user_controller.dart';
import 'package:plugme/screens/joblist/components/receipt_body.dart';
import 'package:plugme/utils/style.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../models/user.dart';
import '../models/work.dart';
import '../widgets/common_text.dart';

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  var result = 12742 * asin(sqrt(a));
  return result.toPrecision(2);
}

showReceiptBottomSheet(BuildContext context, Work work, UserModel userModel) {
  return showBottomSheet(
    context: context,
    backgroundColor: const Color(0XFFFFFFFF),
    builder: (context) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return DraggableScrollableSheet(
            initialChildSize: 0.92,
            expand: false,
            builder: (BuildContext productContext,
                ScrollController scrollController) {
              return SingleChildScrollView(
                  child: ReceiptBody(userModel: userModel, work: work));
            });
      });
    },
  );
}

showImageSelectionDialog(
    {required context, required galleryPickImage, required cameraPickImage}) {
  return showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(5),
          actionsPadding: const EdgeInsets.all(0),
          buttonPadding: const EdgeInsets.all(0),
          title: const Center(
              child: CommonText(text: "Select Image", color: Colors.black)),
          content: Container(
            height: MediaQuery.of(context).size.width * 0.4,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  onTap: () {
                    cameraPickImage();
                  },
                  title: const CommonText(text: "Camera", color: Colors.black),
                  leading: const Icon(Icons.camera_alt_rounded),
                  minVerticalPadding: 0,
                  contentPadding: const EdgeInsets.all(0),
                ),
                ListTile(
                  onTap: () {
                    galleryPickImage();
                  },
                  minVerticalPadding: 10,
                  contentPadding: const EdgeInsets.all(5),
                  title: const CommonText(text: "Gallery", color: Colors.black),
                  leading: const Icon(Icons.camera),
                )
              ],
            ),
          ),
        );
      });
}

filtersBottomSheetMenu(context) {
  UserController userController = Get.find<UserController>();
  return showBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        topRight: Radius.circular(25),
        topLeft: Radius.circular(25),
      )),
      context: context,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0).copyWith(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          "assets/images/sliders.png",
                          color: Colors.black,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: CommonText(
                            color: blackColor,
                            text: "Filters",
                            fontWeight: FontWeight.bold,
                            size: 18,
                          ),
                        )
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: lightGrey,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.clear),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const CommonText(
                  color: blackColor,
                  text: "Rate Per Hour",
                  fontWeight: FontWeight.bold,
                  size: 18,
                ),
                const SizedBox(height: 5),
                Center(
                  child: Obx(() => SfRangeSlider(
                        min: 0.0,
                        max: 100.0,
                        enableTooltip: true,
                        values: userController.rangeValues.value!,
                        interval: 20,
                        tooltipShape: const SfPaddleTooltipShape(),
                        numberFormat: NumberFormat("\$"),
                        showLabels: true,
                        minorTicksPerInterval: 1,
                        activeColor: const Color(0XFF8C90F3),
                        inactiveColor: lightGrey,
                        onChanged: (value) {
                          double start = value.start;
                          double end = value.end;
                          String finalStart = start.toStringAsFixed(1);
                          String finalEnd = end.toStringAsFixed(1);
                          userController.rangeValues.value = SfRangeValues(
                              double.parse(finalStart), double.parse(finalEnd));
                        },
                      )),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CommonText(
                      color: blackColor,
                      text: "Availability",
                      fontFamily: "RedHatMedium",
                      size: 18,
                    ),
                    Row(
                      children: [
                        Obx(() => Checkbox(
                            activeColor: const Color(0XFF8C90F3),
                            value: (userController.allDaysOfWeek.value ||
                                userController.selectedDays.length >= 7),
                            onChanged: (value) {
                              userController.allDaysOfWeek.value = value!;
                              if (value == true) {
                                userController.selectedDays.value = [
                                  ...userController.daysOfTheWeek
                                ];
                                userController.selectedDays.refresh();
                              } else {
                                userController.selectedDays.clear();
                                userController.selectedDays.refresh();
                              }
                            })),
                        const CommonText(
                          color: blackColor,
                          text: "All Days",
                          fontFamily: "RedHatLight",
                          size: 15,
                        )
                      ],
                    )
                  ],
                ),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: Get.find<UserController>()
                      .daysOfTheWeek
                      .map((e) => InkWell(
                            onTap: () {
                              var index = Get.find<UserController>()
                                  .selectedDays
                                  .indexWhere((element) => element == e);
                              if (index == -1) {
                                Get.find<UserController>().selectedDays.add(e);
                                Get.find<UserController>()
                                    .selectedDays
                                    .refresh();
                              } else {
                                Get.find<UserController>()
                                    .selectedDays
                                    .removeWhere((element) => element == e);
                                Get.find<UserController>()
                                    .selectedDays
                                    .refresh();
                                userController.allDaysOfWeek.value = false;
                              }
                            },
                            child: Obx(() => Chip(
                                  backgroundColor: Get.find<UserController>()
                                              .selectedDays
                                              .indexWhere(
                                                  (element) => element == e) ==
                                          -1
                                      ? lightGrey
                                      : const Color(0XFF8C90F3),
                                  label: CommonText(
                                      text: "$e",
                                      color: Get.find<UserController>()
                                                  .selectedDays
                                                  .indexWhere((element) =>
                                                      element == e) ==
                                              -1
                                          ? const Color(0XFF121212)
                                          : whiteColor,
                                      fontFamily: "RedHatLight"),
                                )),
                          ))
                      .toList(),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      userController.initialHeight.value = 0.70;
                      userController.searchUsersBasedOnService(
                          );
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                          color: const Color(0XFF8C90F3),
                          borderRadius: BorderRadius.circular(50)),
                      child: const CommonText(color: whiteColor, text: "Filter"),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      });
}

 showImageDialogPop({required context,required bool upload}){
  AuthController authController=Get.find<AuthController>();
   showDialog(
       context: context,
       builder: (_) {
         return AlertDialog(
           contentPadding: const EdgeInsets.all(5),
           actionsPadding: const EdgeInsets.all(0),
           buttonPadding: const EdgeInsets.all(0),
           title: const Center(
               child: CommonText(
                   text: "Select Image", color: Colors.black)),
           content: Container(
             height: MediaQuery.of(context).size.width * 0.4,
             padding: const EdgeInsets.symmetric(horizontal: 10.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 ListTile(
                   onTap: () {
                     Get.back();
                     authController.pickImage(
                         type: "camera",
                         context: context,
                         upload: upload);
                   },
                   title: const CommonText(
                       text: "Camera", color: Colors.black),
                   leading: const Icon(Icons.camera_alt_rounded),
                   minVerticalPadding: 0,
                   contentPadding: const EdgeInsets.all(0),
                 ),
                 ListTile(
                   onTap: () {
                     Get.back();
                     authController.pickImage(
                         type: "gallery",
                         context: context,
                         upload: upload);
                   },
                   minVerticalPadding: 10,
                   contentPadding: const EdgeInsets.all(5),
                   title: const CommonText(
                       text: "Gallery", color: Colors.black),
                   leading: const Icon(Icons.camera),
                 )
               ],
             ),
           ),
         );
       });
 }

