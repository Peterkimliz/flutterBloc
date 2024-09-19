import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/utils/style.dart';

import '../../widgets/common_text.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);
 final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: blueColor,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios, color: whiteColor)),
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            color: blueColor,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const CommonText(
                      text: "Enter Phone Number",
                      color: blackColor,
                      size: 21,
                      fontWeight: FontWeight.bold,
                      fontFamily: "RedHatMedium",
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: blueColor)),
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          authController.phoneNumber.value =
                              number.phoneNumber!;
                        },
                        onInputValidated: (bool value) {},
                        scrollPadding: EdgeInsets.zero,
                        textFieldController:
                            authController.textEditingControllerPhoneNumber,
                        inputDecoration: const InputDecoration(
                            hintText: "Phone Number", border: InputBorder.none),
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        ),
                        ignoreBlank: false,
                        autoValidateMode: AutovalidateMode.disabled,
                        selectorTextStyle: const TextStyle(color: Colors.black),
                        formatInput: true,
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: true, decimal: true),
                        inputBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: blueColor, width: 1)),
                        onSaved: (PhoneNumber number) {},
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (authController.textEditingControllerPhoneNumber
                              .text.isNotEmpty) {
                            authController.signInWithPhone(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                backgroundColor: blackColor,
                                content: CommonText(
                                    color: whiteColor,
                                    text: "Please enter phone number")));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: yellowColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 10),
                          textStyle: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        child: const CommonText(
                          text: "Login",
                          color: whiteColor,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
