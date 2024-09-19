import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linear_step_indicator/linear_step_indicator.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/controllers/bank_controller.dart';
import 'package:plugme/controllers/user_controller.dart';

import '../controllers/service_controller.dart';
import '../utils/style.dart';
import '../widgets/common_text.dart';

class BankSetup extends StatefulWidget {
  const BankSetup({Key? key}) : super(key: key);

  @override
  State<BankSetup> createState() => _BankSetupState();
}

class _BankSetupState extends State<BankSetup> {
  BankController bankController = Get.find<BankController>();

  AuthController authController = Get.find<AuthController>();

  ServiceController serviceController = Get.find<ServiceController>();
  UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      if (authController.currentUser.value?.isServiceProvider == true) {
        bankController.pageNumber.value = 2;
        bankController.pageController.animateToPage(
            bankController.pageNumber.value,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeIn);
      }else{
        bankController.pageNumber.value = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          backgroundColor: blueColor,
          appBar: AppBar(
            backgroundColor: blueColor,
            toolbarHeight: 40,
            elevation: 0.0,
            titleSpacing: 0.0,
            title: const CommonText(
              color: whiteColor,
              text: "Provider",
              fontWeight: FontWeight.bold,
              fontFamily: "RedHatMedium",
              size: 20,
            ),
            leading: IconButton(
                onPressed: () {
                  Get.back();
                  authController.connectBank.value = false;
                },
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: whiteColor,
                )),
          ),
          body: Container(
            margin: const EdgeInsets.only(top: 20),
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            decoration: const BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40))),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
              ).copyWith(top: 20),
              child: StepIndicatorPageView(
                steps: bankController.pages.length,
                indicatorPosition: IndicatorPosition.top,
                spacing: 10,
                activeBorderColor: yellowColor,
                activeLineColor: yellowColor,
                activeNodeColor: yellowColor,
                inActiveLabelStyle:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                activeLabelStyle: const TextStyle(
                    fontSize: 11,
                    color: yellowColor,
                    fontWeight: FontWeight.w500),
                physics: const NeverScrollableScrollPhysics(),
                labels: bankController.tabs,
                controller: bankController.pageController,
                complete: () {
                  return Future.value(true);
                },
                children: bankController.pages,
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Container(
              padding: const EdgeInsets.all(10),
              height: kBottomNavigationBarHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    return bankController.pageNumber.value > 0 &&
                            authController
                                    .currentUser.value?.isServiceProvider ==
                                false
                        ? InkWell(
                            onTap: () {
                              bankController.pageNumber.value =
                                  bankController.pageNumber.value - 1;
                              bankController.pageController.animateToPage(
                                  bankController.pageNumber.value,
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeIn);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              margin: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                  color: greyColor,
                                  borderRadius: BorderRadius.circular(30)),
                              child: const CommonText(
                                color: whiteColor,
                                text: "Back",
                              ),
                            ),
                          )
                        : const SizedBox(height: 0, width: 0);
                  }),
                  Obx(() => InkWell(
                        onTap: () {
                          if (bankController.pageNumber.value == 0) {
                            if (bankController.accountDetailsVerified() ==
                                false) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      backgroundColor: blackColor,
                                      content: CommonText(
                                          color: whiteColor,
                                          text: "Please fill all the fields")));
                            } else {
                              bankController.pageNumber.value = 1;
                              bankController.pageController.animateToPage(
                                  bankController.pageNumber.value,
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeIn);
                              bankController.uploadVerificationDetails();
                            }
                          } else if (bankController.pageNumber.value == 1) {
                            if (authController
                                    .currentUser.value!.accountConnected ==
                                true) {
                              bankController.pageNumber.value = 2;
                              bankController.pageController.animateToPage(
                                  bankController.pageNumber.value,
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeIn);
                            } else if (authController
                                    .currentUser.value!.accountConnected ==
                                false) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: CommonText(
                                      color: whiteColor,
                                      text:
                                          "Connect at least one payout method")));
                            } else {
                              bankController.pageNumber.value = 2;
                              bankController.pageController.animateToPage(
                                  bankController.pageNumber.value,
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeIn);
                            }
                          } else if (bankController.pageNumber.value == 2) {
                            if (authController.selectedService.value == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: CommonText(
                                          color: whiteColor,
                                          text:
                                              "Please enter your rate hour")));
                            } else if (authController
                                .textEditingControllerRate.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: CommonText(
                                          color: whiteColor,
                                          text:
                                              "Please enter your rate hour")));
                            } else if (int.parse(authController
                                    .textEditingControllerRate.text) <
                                1) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: CommonText(
                                          color: whiteColor,
                                          text: "Rate cannot be less than 1")));
                            } else if (userController.selectedDays.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: CommonText(
                                          color: whiteColor,
                                          text: "Select your availability")));
                            } else {
                              saveTheAvailabilityDetails();
                            }
                          } else if (bankController.pageNumber.value == 3) {
                            if (authController
                                    .currentUser.value?.isServiceProvider ==
                                false) {
                              authController.verifyProvider();
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                              color: yellowColor,
                              borderRadius: BorderRadius.circular(30)),
                          child: CommonText(
                            color: whiteColor,
                            text: bankController.pageNumber.value == 3
                                ? "Verify"
                                : "Next",
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
        onWillPop: () async {
          authController.connectBank.value = false;
          return true;
        });
  }

  saveTheAvailabilityDetails() {
    authController.updateSingleItem(
        body: {"service": authController.selectedService.value!.toJson()},
        id: FirebaseAuth.instance.currentUser!.uid);
    authController.updateSingleItem(body: {
      "pricePerHour": int.parse(authController.textEditingControllerRate.text)
    }, id: FirebaseAuth.instance.currentUser!.uid);

    authController.updateSingleItem(body: {
      "availability":
          userController.selectedDays.map((element) => element).toList()
    }, id: FirebaseAuth.instance.currentUser!.uid);

    authController.currentUser.value?.service =
        authController.selectedService.value;
    authController.currentUser.value?.pricePerHour =
        int.parse(authController.textEditingControllerRate.text);
    authController.currentUser.refresh();
    bankController.pageNumber.value = 3;
    bankController.pageController.animateToPage(bankController.pageNumber.value,
        duration: const Duration(milliseconds: 1000), curve: Curves.easeIn);
  }
}
