import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/screens/profile/new_profile.dart';

import '../../controllers/user_controller.dart';

class AccountPage extends StatelessWidget {
   const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.find<UserController>().currentProfile.value=Get.find<AuthController>().currentUser.value!;
    return NewProfile();
  }
}
