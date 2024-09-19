import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:plug/bindings.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/chat_controller.dart';
import 'package:plug/controllers/user_controller.dart';
import 'package:plug/models/user.dart';
import 'package:plug/screens/chats/chats_inbox.dart';
import 'package:plug/screens/onboard/splash_screen.dart';
import 'package:plug/screens/rooms/live.dart';
import 'package:plug/service/dynamic_links.dart';
import 'package:plug/utils/constants.dart';
import 'package:plug/utils/style.dart';
import 'package:plug/widgets/common_text.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  oneSignal();

  Stripe.publishableKey = stripePublishableKey;
  Stripe.merchantIdentifier = 'plug';
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

Future<void> oneSignal() async {
  initOneSignal();
  oneSignalObservers();
}

void initOneSignal() {
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  OneSignal.shared.setAppId(oneSignalKey);
  OneSignal.shared.promptUserForPushNotificationPermission().then((value) {});


}

oneSignalObservers() {
  AudioPlayer _audioPlayer = AudioPlayer();
  final UserController userController = Get.put(UserController());
  final ChatController chatController =
      Get.put<ChatController>(ChatController());
  OneSignal.shared.setNotificationWillShowInForegroundHandler(
      (OSNotificationReceivedEvent event) async {

    chatController.notificationId.value = event.notification.notificationId;
    if (event.notification.additionalData!["screen"] == "ChatInbox" &&
        chatController.isChatPage.value == true) {
      event.complete(null);
    } else if (event.notification.additionalData!["screen"] == "room") {
      event.notification.sound="assets/sounds/notification.wav";
      event.complete(event.notification);
    } else {
     // UrlSource sound =UrlSource("assets/sounds/notification.wav");
     // print(sound.url);
     //  await _audioPlayer.play(sound
     //     );

      event.notification.sound="assets/sounds/notification.wav";
      print("end new sound");
      event.complete(event.notification);
      if (event.notification.additionalData!["type"] == "offer" &&
          Get.find<ChatController>().isChatPage.value == false) {
        userController.scaffoldKey.currentState?.showBottomSheet((context) =>
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              height: kBottomNavigationBarHeight * 1.1,
              color: blackColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                      color: whiteColor,
                      text: "${event.notification.additionalData!["message"]}"),
                  TextButton(
                      onPressed: () {
                        final myMap = Map<String, dynamic>.from(
                            event.notification.additionalData!["userModel"]);
                        Navigator.pop(context);
                        Get.to(() => ChatsInbox(
                            userModel: UserModel.fromJson(myMap),
                            uid: event.notification.additionalData!["chatId"]));
                      },
                      child: const CommonText(
                        text: "View",
                        color: whiteColor,
                      ))
                ],
              ),
            ));
      }
    }
  });

  OneSignal.shared
      .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    if (result.notification.additionalData!["screen"] == "ChatInbox" &&
        Get.find<ChatController>().isChatPage.value == false) {
      final myMap = Map<String, dynamic>.from(
          result.notification.additionalData!["userModel"]);
      Get.to(() => ChatsInbox(
          userModel: UserModel.fromJson(myMap),
          uid: result.notification.additionalData!["chatId"]));
    } else if (result.notification.additionalData!["screen"] == "room") {
      String roomId = result.notification.additionalData!["roomId"];
      Get.to(() => Livestream(
            roomId: roomId,
          ));
    }
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final AuthController _authController = Get.put(AuthController());

  @override
  void initState() {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      DateTime timenow = DateTime.now();
      if (_authController.currentUser.value != null) {
        _authController.updateSingleItem(
            body: {"lastSeen": timenow},
            id: _authController.currentUser.value!.id!);
      }
    });

    DynamicLinkService().handleDynamicLinks();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (FirebaseAuth.instance.currentUser != null) {
        _authController.updateSingleItem(
            body: {"isUserOnline": true},
            id: FirebaseAuth.instance.currentUser!.uid);
      }
    } else {
      if (FirebaseAuth.instance.currentUser != null) {
        _authController.updateSingleItem(
            body: {"isUserOnline": true},
            id: FirebaseAuth.instance.currentUser!.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(builder: (BuildContext context, c) {
      return GetMaterialApp(
          title: 'plug',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: whiteColor,
            appBarTheme: const AppBarTheme(
                elevation: 0.0,
                backgroundColor: whiteColor,
                titleTextStyle:
                    TextStyle(color: blackColor, fontWeight: FontWeight.w500),
                iconTheme: IconThemeData(color: blackColor)),
            primarySwatch: Colors.blue,
          ),
          initialBinding: AppBindings(),
          home: const SplashScreen());
    });
  }
}
