import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/utils/style.dart';
import 'package:plugme/widgets/common_text.dart';

class VerificationSuccess extends StatelessWidget {
   VerificationSuccess({Key? key}) : super(key: key);
  final AuthController authController = Get.find<AuthController>();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blueColor,
      appBar: AppBar(
        backgroundColor: blueColor,
        title: const CommonText(color: whiteColor, text: "Provider"),
        leading: IconButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios, color: whiteColor)),
        elevation: 0.0,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0).copyWith(top: 10),
        margin: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(40), topLeft: Radius.circular(40))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 500,
              child: Image.asset("assets/images/thankyouIcon.png"),
            ),
            const SizedBox(height: 15),
            Obx(() => Center(
                  child: FlutterSwitch(
                    width: 100.0,
                    height: 40.0,
                    valueFontSize: 16.0,
                    toggleSize: 20.0,
                    activeColor: yellowColor,
                    inactiveColor: Colors.grey,
                    activeTextColor: whiteColor,
                    inactiveTextColor: whiteColor,
                    activeText: "Online",
                    inactiveText: "Offline",
                    value: authController.currentUser.value!.isOnline ?? false,
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
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
