import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/user_controller.dart';
import 'package:plug/utils/style.dart';
import 'package:plug/widgets/common_text.dart';

import '../../controllers/service_controller.dart';
import '../../models/place_prediction.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/place_card.dart';
import 'components/image_container.dart';
import 'components/input_field.dart';

class ProfileSetUp extends StatelessWidget {
  ProfileSetUp({Key? key}) : super(key: key) {
    _serviceController.textEditingControllerSearch.clear();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();
  final ServiceController _serviceController = Get.find<ServiceController>();
  final UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const CommonText(
          text: "Profile Setup",
          color: blackColor,
          fontWeight: FontWeight.bold,
          fontFamily: "RedHatMedium",
          size: 20.0,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => profileImage(
                    upload: false,
                    context: context,
                    imageProvider: _authController.pickedImage!.value == null
                        ? const AssetImage("assets/images/profile.png")
                        : _authController.userCredentialData.value != null
                            ? NetworkImage(_authController.userCredentialData
                                .value!.user!.photoURL!) as ImageProvider
                            : FileImage(File(
                                _authController.pickedImage!.value!.path))),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    const CommonText(
                      color: greyColor,
                      text: "Enter your address",
                      fontFamily: "RedHatMedium",
                    ),
                    const SizedBox(height: 5),
                    // TypeAheadField<PlacePrediction?>(
                    //   debounceDuration: const Duration(milliseconds: 500),
                    //   // textFieldConfiguration: TextFieldConfiguration(
                    //   //   controller:
                    //   //       _serviceController.textEditingControllerSearch,
                    //   //   decoration: InputDecoration(
                    //   //       hintText: "Search by area of location",
                    //   //       focusedBorder: OutlineInputBorder(
                    //   //           borderRadius: BorderRadius.circular(10)),
                    //   //       enabledBorder: OutlineInputBorder(
                    //   //           borderRadius: BorderRadius.circular(10)),
                    //   //       contentPadding: const EdgeInsets.symmetric(
                    //   //           horizontal: 20, vertical: 6),
                    //   //       border: OutlineInputBorder(
                    //   //           borderRadius: BorderRadius.circular(100),
                    //   //           borderSide: BorderSide.none),
                    //   //       filled: true,
                    //   //       fillColor: Colors.white),
                    //   // ),
                    //   suggestionsCallback: (pattern) async {
                    //     return await _serviceController
                    //         .findPlacesNamePrediction(pattern);
                    //   },
                    //   itemBuilder: (context, PlacePrediction? suggestion) {
                    //     final request = suggestion!;
                    //
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
                    const SizedBox(height: 20),
                    const CommonText(
                      color: greyColor,
                      text: "First Name",
                      fontFamily: "RedHatMedium",
                    ),
                    const SizedBox(height: 5),
                    InputFields(
                      textEditingController:
                          _authController.textEditingControllerFirstname,
                      hint: "",
                    ),
                    const SizedBox(height: 15),
                    const CommonText(
                      color: greyColor,
                      text: "Last Name",
                      fontFamily: "RedHatMedium",
                    ),
                    const SizedBox(height: 5),
                    InputFields(
                      textEditingController:
                          _authController.textEditingControllerLastname,
                      hint: "",
                    ),
                    const SizedBox(height: 15),
                    const CommonText(
                      color: greyColor,
                      text: "Email",
                      fontFamily: "RedHatMedium",
                    ),
                    const SizedBox(height: 5),
                    buildEmail(),
                    const SizedBox(height: 15),
                    const CommonText(
                      color: greyColor,
                      text: "Work Profile link",
                      fontFamily: "RedHatMedium",
                    ),
                    const SizedBox(height: 5),
                    InputFields(
                      checkValidity: false,
                      textEditingController:
                      _authController.textEditingControllerWork,
                      hint: "",
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Obx(() {
                      return _authController.isSigningIn.value
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Center(
                              child: SizedBox(
                                width: 200,
                                height: 50,
                                child: CustomButton(
                                  text: "Save",
                                  voidCallback: () {
                                    if (_formKey.currentState!.validate() &&
                                        _serviceController.address.value !=
                                            null) {
                                      _authController.saveUserTofirestore();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              backgroundColor: blackColor,
                                              content: CommonText(
                                                text:
                                                    "Please fill all the fields",
                                                color: whiteColor,
                                              )));
                                    }
                                  },
                                ),
                              ),
                            );
                    }),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildEmail() {
    return TextFormField(
      controller: _authController.textEditingControllerEmail,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "please fill this field";
        }
        if (!_authController
            .emailValidator(_authController.textEditingControllerEmail.text)) {
          return "please enter a valid email";
        }
        return null;
      },
      decoration: InputDecoration(
          hintText: "",
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: greyColor.withOpacity(0.1)),
    );
  }
}
