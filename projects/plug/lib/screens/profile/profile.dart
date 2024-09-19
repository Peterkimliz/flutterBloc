import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/user_controller.dart';
import 'package:plug/screens/profile/components/input_field.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/service_controller.dart';
import '../../models/place_prediction.dart';
import '../../utils/function.dart';
import '../../utils/style.dart';
import '../../widgets/common_text.dart';
import '../../widgets/place_card.dart';
import 'components/image_container.dart';

class ProfilePage extends StatelessWidget {
  final HomeController homeController = Get.find<HomeController>();
  final AuthController authController = Get.find<AuthController>();
   final ServiceController _serviceController = Get.find<ServiceController>();
  final UserController userController = Get.find<UserController>();

  ProfilePage({Key? key}) : super(key: key) {
    authController.assignFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blueColor,
        elevation: 0.0,
        titleSpacing: 0.0,
        title: const CommonText(
            color: whiteColor,
            text: "Edit Profile",
            fontFamily: "RedHatMedium",
            size: 20),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: whiteColor,
            )),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              color: blueColor,
              height: 200,
            ),
            Container(
              padding: const EdgeInsets.only(top: 15),
              margin: const EdgeInsets.only(top: 25),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade100,
                            ),
                            height: 120,
                            width: 120,
                            child: Stack(
                              children: [
                                profileImage(
                                    showCam: false,
                                    upload: true,
                                    radi: 60,
                                    context: context,
                                    imageProvider: authController.currentUser
                                            .value!.profileUrl!.isEmpty
                                        ? const AssetImage(
                                            "assets/images/profile.png")
                                        : authController.pickedImage!.value !=
                                                null
                                            ? FileImage(File(authController
                                                .pickedImage!.value!.path))
                                            : NetworkImage(
                                                    authController.currentUser.value?.profileUrl ?? "")
                                                as ImageProvider),
                                ClipRRect(
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(100)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        height: 40,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(100),
                                            bottomRight: Radius.circular(100),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 50,
                                  child: Center(
                                      child: InkWell(
                                    onTap: () {
                                      showImageDialogPop(
                                          context: context, upload: true);
                                    },
                                    child: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: whiteColor,
                                    ),
                                  )),
                                ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                    const CommonText(
                      color: blackColor,
                      text: "First Name",
                    ),
                    const SizedBox(height: 10),
                    InputFields(
                      textEditingController:
                          authController.textEditingControllerFirstname,
                      hint: "",
                    ),
                    const SizedBox(height: 10),
                    const CommonText(
                      color: blackColor,
                      text: "Last Name",
                    ),
                    const SizedBox(height: 10),
                    InputFields(
                      textEditingController:
                          authController.textEditingControllerLastname,
                      hint: "",
                    ),
                    const SizedBox(height: 10),
                    const CommonText(
                      color: blackColor,
                      text: "Email",
                    ),
                    const SizedBox(height: 10),
                    InputFields(
                      textEditingController:
                          authController.textEditingControllerEmail,
                      hint: "",
                    ),
                    const SizedBox(height: 10),
                    const CommonText(
                      color: blackColor,
                      text: "Address",
                    ),
                    const SizedBox(height: 10),
                    // TypeAheadField<PlacePrediction?>(
                    //   debounceDuration: const Duration(milliseconds: 500),
                    //   // textFieldConfiguration: TextFieldConfiguration(
                    //   //   controller:
                    //   //       _serviceController.textEditingControllerSearch,
                    //   //   scrollPadding: const EdgeInsets.only(bottom: 800),
                    //   //   decoration: InputDecoration(
                    //   //       hintText: "Search by area of location",
                    //   //       suffixIcon: const Icon(
                    //   //         Icons.arrow_drop_down_outlined,
                    //   //         color: yellowColor,
                    //   //         size: 40,
                    //   //       ),
                    //   //       focusedBorder: OutlineInputBorder(
                    //   //           borderRadius: BorderRadius.circular(10),
                    //   //           borderSide: const BorderSide(width: 1, color: greyColor)),
                    //   //       enabledBorder: OutlineInputBorder(
                    //   //           borderRadius: BorderRadius.circular(10),
                    //   //           borderSide:
                    //   //               const BorderSide(width: 1, color: greyColor)),
                    //   //       contentPadding: const EdgeInsets.symmetric(
                    //   //           horizontal: 20, vertical: 6),
                    //   //       border: OutlineInputBorder(
                    //   //           borderRadius: BorderRadius.circular(10),
                    //   //           borderSide: const BorderSide(width: 1, color: greyColor)),
                    //   //       filled: true,
                    //   //       fillColor: whiteColor),
                    //   // ),
                    //   suggestionsCallback: (pattern) async {
                    //     return await _serviceController
                    //         .findPlacesNamePrediction(pattern);
                    //   },
                    //   itemBuilder: (context, PlacePrediction? suggestion) {
                    //     final request = suggestion!;
                    //     return placePredictionCard(placePrediction: request);
                    //   },
                    //   // onSuggestionSelected:
                    //   //     (PlacePrediction? suggestion) async {
                    //   //   final request = suggestion!;
                    //   //   await _serviceController.getPlaceAddressDetails(
                    //   //       placeid: request.placeId);
                    //   // },
                    //   errorBuilder: (BuildContext context, error) {
                    //     return Container(
                    //         padding: const EdgeInsets.all(10),
                    //         child: const Text("error Occurred"));
                    //   },
                    // ),
                    const SizedBox(height: 5),
                    const CommonText(
                      color: blackColor,
                      text: "About Me",
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      minLines: 5,
                      controller: authController.textEditingControllerBio,
                      maxLines: null,
                      decoration: InputDecoration(
                          labelStyle: const TextStyle(color: blackColor),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(width: 1, color: greyColor)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(width: 1, color: greyColor)),
                          filled: true,
                          fillColor: whiteColor),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: kBottomNavigationBarHeight,
        color: whiteColor,
        padding: const EdgeInsets.all(10),
        child: Center(
          child: InkWell(
            onTap: () {
              authController.updateProfile(context);
            },
            child: Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                  color: yellowColor, borderRadius: BorderRadius.circular(30)),
              child: const Center(
                child: CommonText(
                  color: whiteColor,
                  text: "Update",
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
