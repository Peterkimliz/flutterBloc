import 'package:get/get.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/bank_controller.dart';
import 'package:plug/controllers/chat_controller.dart';
import 'package:plug/controllers/home_controller.dart';
import 'package:plug/controllers/location_controller.dart';
import 'package:plug/controllers/room_controller.dart';
import 'package:plug/controllers/user_controller.dart';
import 'package:plug/controllers/wallet_controller.dart';

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
    Get.put<LocationController>(LocationController(), permanent: true);
  }
}
