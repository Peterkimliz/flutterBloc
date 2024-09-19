import 'package:get/get.dart';

import 'package:plugme/screens/home_page.dart';
import 'package:plugme/screens/joblist/joblist_page.dart';
import '../screens/profile/accounts_page.dart';

class HomeController extends GetxController {
  RxInt selectedPage = RxInt(0);
  RxString selectedProfilePage = RxString("profileDetails");
  RxBool openSettings = RxBool(false);
  RxBool openProfileDetails = RxBool(false);
  RxBool activeOnline = RxBool(false);
  RxInt selectedWidget = RxInt(0);



  List pages = [
    const HomePage(),
    JobListPage(),
    const AccountPage()
  ];





}
