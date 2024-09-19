import 'package:get/get.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/controllers/bank_controller.dart';
import 'package:plugme/controllers/chat_controller.dart';
import 'package:plugme/controllers/home_controller.dart';
import 'package:plugme/controllers/room_controller.dart';
import 'package:plugme/controllers/user_controller.dart';
import 'package:plugme/controllers/wallet_controller.dart';

import 'controllers/service_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<ServiceController>(ServiceController(), permanent: true);
    Get.put<UserController>(UserController(), permanent: true);
    Get.put<ChatController>(ChatController(), permanent: true);
    Get.put<WalletController>(WalletController(), permanent: true);
    Get.put<BankController>(BankController(), permanent: true);
    Get.put<RoomController>(RoomController(), permanent: true);
  }
}
