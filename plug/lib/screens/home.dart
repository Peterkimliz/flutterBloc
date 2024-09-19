import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/controllers/chat_controller.dart';
import 'package:plugme/controllers/home_controller.dart';
import 'package:plugme/controllers/user_controller.dart';
import 'package:plugme/screens/auth/landing_page.dart';
import 'package:plugme/utils/style.dart';

import '../controllers/service_controller.dart';

class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final HomeController homeController = Get.find<HomeController>();

  final ServiceController serviceController = Get.find<ServiceController>();

  final UserController userController = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();

  final ChatController chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Obx(() {
        return homeController.pages[homeController.selectedPage.value];
      }),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30), topLeft: Radius.circular(30)),
          gradient: const LinearGradient(
              colors: [
                blueColor,
                yellowColor,
                linearGradientOne,
              ],
              stops: [
                0.0,
                0.5,
                1.0
              ],
              begin: FractionalOffset.topLeft,
              end: FractionalOffset.bottomRight,
              tileMode: TileMode.decal),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: Colors.black.withOpacity(0.5),
                iconSize: 24,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: const Duration(milliseconds: 400),
                tabBackgroundColor: Colors.grey[100]!,
                color: Colors.white,
                tabs: const [
                  GButton(
                    icon: Icons.home,
                    text: 'Home',
                    iconSize: 27,
                  ),
                  GButton(
                    icon: Icons.check_circle_outline,
                    text: 'Tasks',
                    iconSize: 27,
                  ),
                  GButton(
                    icon: Icons.person_outline,
                    text: 'Profile',
                    iconSize: 27,
                  ),
                ],
                selectedIndex: homeController.selectedPage.value,
                onTabChange: (index) {
                  if (index == 0) {
                    userController.initialHeight.value = 0.5;
                    homeController.selectedPage.value = 0;
                    homeController.openSettings.value = false;
                    if (userController.featuredUsers.isNotEmpty) {
                      userController.showFuturedProvider.value = true;
                    }
                  } else if (index == 1) {
                    if (authController.currentUser.value != null) {
                      homeController.selectedPage.value = 1;
                      userController.initialHeight.value = 0.0;
                      serviceController.getWorkHistoryByUserId(
                          id: FirebaseAuth.instance.currentUser!.uid,
                          checkByProvider: false);
                    } else {
                      Get.to(() => LandingPage());
                    }
                  } else if (index == 2) {
                    if (authController.currentUser.value != null) {
                      homeController.selectedPage.value = 2;
                      userController.initialHeight.value = 0.0;
                    } else {
                      Get.to(() => LandingPage());
                    }
                  }
                }),
          ),
        ),
      ),
    );
  }
}
