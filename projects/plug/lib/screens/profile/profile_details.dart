import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/home_controller.dart';
import 'package:plug/screens/profile/components/image_container.dart';
import 'package:plug/screens/profile/profile.dart';

import '../../models/bank_details.dart';
import '../../utils/style.dart';
import '../../widgets/common_text.dart';

class ProfileDetails extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();
  final AuthController authController = Get.find<AuthController>();
   ProfileDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        title: const CommonText(
            color: blackColor,
            text: "Profile",
            fontFamily: "RedHatMedium",
            size: 20),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            )),
        actions: [
          IconButton(
              onPressed: () {
                Get.to(() => ProfilePage());
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.black,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  profileImage(
                      showCam: false,
                      context: context,
                      upload: false,
                      imageProvider: authController
                              .currentUser.value!.profileUrl!.isEmpty
                          ? const AssetImage("assets/images/profile.png")
                          : NetworkImage(
                                  authController.currentUser.value!.profileUrl!)
                              as ImageProvider),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: CommonText(
                      color: blackColor,
                      text:
                          "${authController.currentUser.value!.firstname!} ${authController.currentUser.value!.lastname!}",
                      size: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Center(
                    child: CommonText(
                      color: greyColor,
                      text: authController.currentUser.value!.email!,
                      size: 18.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CommonText(
                                    color: blackColor,
                                    text: "Address",
                                  ),
                                  const SizedBox(height: 10),
                                  CommonText(
                                    color: greyColor,
                                    text:
                                        "${authController.currentUser.value!.address}",
                                    size: 16.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ],
                              ),
                              authController.currentUser.value!.service != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 15),
                                        const CommonText(
                                          color: blackColor,
                                          text: "Service Offered",
                                        ),
                                        const SizedBox(height: 10),
                                        CommonText(
                                          color: greyColor,
                                          text: authController.currentUser
                                                      .value!.service ==
                                                  null
                                              ? ""
                                              : authController.currentUser.value!.service!.icon! + authController.currentUser.value!.service!.name!,
                                          size: 16.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    )
                                  : const Text(""),
                            ],
                          ),
                          const SizedBox(height: 5),
                          authController.currentUser.value?.accountNumber !=
                                  null
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 15),
                                        const CommonText(
                                          color: blackColor,
                                          text: "Connected banks",
                                        ),
                                        const SizedBox(height: 10),
                                        const CommonText(
                                          color: greyColor,
                                          text: "Stripe Test Bank",
                                          size: 16.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        const SizedBox(height: 10),
                                        CommonText(
                                          color: blackColor,
                                          text: authController
                                              .currentUser.value!.accountNumber!,
                                          size: 16.0,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: "RedHatLight",
                                        ),
                                      ],
                                    ),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 15),
                                        const CommonText(
                                          color: blackColor,
                                          text: "Rate Per Hour",
                                        ),
                                        const SizedBox(height: 10),
                                        CommonText(
                                          color: blackColor,
                                          text: "\$${authController.currentUser.value!.pricePerHour==null?0:authController.currentUser.value!.pricePerHour.toString()}",
                                          size: 16.0,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: "RedHatLight",
                                        ),
                                      ],
                                    ),
                                ],
                              )
                              : const Text(""),
                          authController.currentUser.value!.isServiceProvider!
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 15),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const CommonText(
                                          color: blackColor,
                                          text: "Availability",
                                        ),
                                        const SizedBox(height: 10),
                                        Obx(() => Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 3.0),
                                              child:   Wrap(
                                                spacing: 6.0,
                                                runSpacing: 6.0,
                                                children: authController.currentUser.value!.availability!.map((e) => InkWell(
                                                  child: Chip(
                                                    backgroundColor: lightGrey,
                                                    label: CommonText(
                                                        text: e,
                                                        color: const Color(0XFF121212),
                                                        // : whiteColor,
                                                        fontFamily: "RedHatLight"),
                                                  ),
                                                ))
                                                    .toList(),
                                              ),
                                              //
                                              // Row(
                                              //   children: [
                                              //     FlutterSwitch(
                                              //       valueFontSize: 16.0,
                                              //       activeColor: Colors.green,
                                              //       inactiveColor: Colors.grey,
                                              //       activeTextColor: whiteColor,
                                              //       inactiveTextColor:
                                              //           whiteColor,
                                              //       activeText: "On",
                                              //       inactiveText: "Off",
                                              //       value: authController
                                              //           .workfromHome.value,
                                              //       borderRadius: 30.0,
                                              //       padding: 8.0,
                                              //       showOnOff: true,
                                              //       onToggle: (val) {
                                              //         authController
                                              //             .workfromHome
                                              //             .value = val;
                                              //         authController
                                              //             .updateSingleItem({
                                              //           "workFromHome":
                                              //               authController
                                              //                   .workfromHome
                                              //                   .value
                                              //         });
                                              //       },
                                              //     ),
                                              //   ],
                                              // ),


                                            ))
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                )
                              : const Text(""),
                          Obx(() {
                            return authController
                                        .currentUser.value?.isServiceProvider ==
                                    false
                                ? InkWell(
                                    onTap: () {
                                      Get.to(() => BankDetails());
                                    },
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        width: 200,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: whiteColor,
                                            borderRadius:
                                                BorderRadius.circular(80),
                                            border: Border.all(
                                                color: blackColor, width: 1)),
                                        child: const Center(
                                            child: CommonText(
                                                color: blackColor,
                                                text:
                                                    "Become Service Provider")),
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 0,
                                  );
                          }),
                        ],
                      ),
                    ),
                  ),
                  authController.currentUser.value!.bio!.trim() != ""
                      ? Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Card(
                          elevation: 3,
                          child:Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                            child:  Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CommonText(
                                  color: blackColor,
                                  text: "About",
                                ),
                                const SizedBox(height: 10),
                                CommonText(
                                  color: greyColor,
                                  text: authController.currentUser.value!.bio ?? "",
                                  size: 16.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),

                          ),
                        ),
                      )
                      : const Text(""),
                ],
              )),
        ),
      ),
    );
  }
}
