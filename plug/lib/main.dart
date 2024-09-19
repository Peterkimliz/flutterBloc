import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:plugme/bindings.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/controllers/chat_controller.dart';
import 'package:plugme/controllers/user_controller.dart';
import 'package:plugme/models/user.dart';
import 'package:plugme/screens/chats/chats_inbox.dart';
import 'package:plugme/screens/onboard/splash_screen.dart';
import 'package:plugme/screens/rooms/live.dart';
import 'package:plugme/service/dynamic_links.dart';
import 'package:plugme/utils/constants.dart';
import 'package:plugme/utils/style.dart';
import 'package:plugme/widgets/common_text.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initOneSignal();

  Stripe.publishableKey = stripePublishableKey;
  Stripe.merchantIdentifier = 'plugme';
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

void initOneSignal() {
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  OneSignal.shared.setAppId(oneSignalKey);
  OneSignal.shared.promptUserForPushNotificationPermission().then((value) {

  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {

  final AuthController _authController = Get.put(AuthController());


  final UserController _userController = Get.put(UserController());


  oneSignalObservers() {
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
      if (event.notification.additionalData!["screen"] == "ChatInbox" &&
          Get.find<ChatController>().isChatPage.value == true) {
        event.complete(null);
      } else if (event.notification.additionalData!["screen"] == "room") {
        event.complete(event.notification);
      } else {
        event.complete(event.notification);
        if (event.notification.additionalData!["type"] == "offer" &&
            Get.find<ChatController>().isChatPage.value == false) {
          _userController.scaffoldKey.currentState
              ?.showBottomSheet((context) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    height: kBottomNavigationBarHeight * 1.1,
                    color: blackColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                            color: whiteColor,
                            text:
                                "${event.notification.additionalData!["message"]}"),
                        TextButton(
                            onPressed: () {
                              final myMap = Map<String, dynamic>.from(event
                                  .notification.additionalData!["userModel"]);
                              Navigator.pop(context);
                              Get.to(() => ChatsInbox(
                                  userModel: UserModel.fromJson(myMap),
                                  uid: event
                                      .notification.additionalData!["chatId"]));
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

    oneSignalObservers();
    DynamicLinkService().handleDynamicLinks();
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed) {
      if(FirebaseAuth.instance.currentUser !=null) {
        _authController.updateSingleItem(
            body: {"isUserOnline": true},
            id: FirebaseAuth.instance.currentUser!.uid);
      }
    } else {
      if(FirebaseAuth.instance.currentUser !=null) {
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
          title: 'plugme',
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
