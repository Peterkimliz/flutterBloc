import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/service_controller.dart';
import 'package:plug/location_allow.dart';
import 'package:plug/utils/style.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    handleAuth();
    super.initState();
    Timer(const Duration(seconds: 5), () {

      Get.find<ServiceController>().checkLocation(proceed:true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: splashScreen());
  }

  Widget splashScreen() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [
              linearGradientOne,
              linearGradientTwo,
            ],
            stops: [
              0.0,
              1.0
            ],
            begin: FractionalOffset.topLeft,
            end: FractionalOffset.bottomRight,
            tileMode: TileMode.decal),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset("assets/images/logo.png"),
          ),
        ],
      ),
    );
  }

  handleAuth() async {
    var documentSnapshot = await Get.find<AuthController>().getCurrentUser();
    if (documentSnapshot == null) {
      _authController.currentUser.value = null;
    }
    if (documentSnapshot != null) {
      UserModel userModel = UserModel.fromJson(documentSnapshot);
      _authController.currentUser.value = userModel;
      _authController.currentUser.refresh();
    }

  }
}
