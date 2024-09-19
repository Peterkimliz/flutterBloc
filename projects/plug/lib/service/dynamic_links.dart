import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/user_controller.dart';
import 'package:plug/screens/auth/landing_page.dart';
import 'package:plug/screens/profile/new_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class DynamicLinkService {
  Future<String> generateShareLink(String groupId,
      {String? type,
      String? title = "",
      String? msg = "",
      String? imageurl = ""}) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: deepLinkUriPrefix,
      link: Uri.parse(_createLink(groupId, type!)),
      androidParameters: const AndroidParameters(
        packageName: packageName,
      ),

      iosParameters: const IOSParameters(
        bundleId: packageName,
        minimumVersion: '1.7',
        appStoreId: '1630634917',
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
          title: title ?? "plug",
          description: msg,
          imageUrl: Uri.parse(imageurl!)),
    );
    final ShortDynamicLink dynamicUrl =
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);
    return dynamicUrl.shortUrl.toString();
  }

  Future handleDynamicLinks() async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (data != null) {
      _handleDeepLink(data);
    }

    FirebaseDynamicLinks.instance.onLink.listen(
        (PendingDynamicLinkData dynamicLink) async {
      _handleDeepLink(dynamicLink);
    }, onError: (error) async {

    });
  }

  Future<void> _handleDeepLink(PendingDynamicLinkData data) async {
    final Uri deepLink = data.link;

    if (deepLink.queryParameters['type'] == "refer") {
      var groupId = deepLink.queryParameters['groupid'];
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("referrer", groupId!);
    } else if (deepLink.queryParameters['type'] == "profile") {
      var groupId = deepLink.queryParameters['groupid'];
      if (Get.find<AuthController>().currentUser.value != null) {
        await Get.find<UserController>().getCurrentUser(groupId!);
        Get.to(() => NewProfile());
      } else {
        Get.to(() => LandingPage());
      }
    }
  }
}

_createLink(String groupId, String type) {
  String link;

  link = '$deepLinkUriPrefix/?groupid=$groupId&type=$type';

  return link;
}
