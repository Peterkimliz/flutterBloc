import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plugme/screens/bank_details/availability.dart';

import '../models/bank_details.dart';
import '../screens/bank_details/connected_banks.dart';
import '../screens/bank_details/preview.dart';
import '../screens/bank_details/verification_page.dart';

class BankController extends GetxController {
  final _firestoreDatabase = FirebaseFirestore.instance.collection("kycs");
  Rxn<File>? frontImage = Rxn(null);
  Rxn<File>? backImage = Rxn(null);

  List<String> tabs = ["Verify", "Payouts", "Availability", "Preview"];

  late PageController pageController;
  RxInt pageNumber = RxInt(0);

  RxList<File>? scannedImages = RxList([]);
  RxList<Map<String, dynamic>> dowmloadUrls = RxList([]);
  RxInt selectedTabIndex = RxInt(0);
  RxBool isVerified = RxBool(false);
  RxBool bankDetailsVerified = RxBool(false);
  RxBool previewed = RxBool(false);
  TextEditingController textEditingControllerFirstName =
      TextEditingController();
  TextEditingController textEditingControllerLastName = TextEditingController();

  RxString accountCountry = RxString("");
  RxString accountState = RxString("");
  RxString accountCity = RxString("");

  Rxn<BankDetails> fetchedBankDetails = Rxn(null);

  Future pickImage({required type, required context}) async {
    try {
      XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);
      type == "front"
          ? frontImage?.value = imageTemp
          : backImage?.value = imageTemp;
    } on PlatformException {
      Navigator.pop(context);
    }
  }

  uploadVerificationDetails() async {
    if (frontImage?.value != null) {
      await handleUploadImage(imageType: "frontImage");
    }
    if (backImage?.value != null) {
      await handleUploadImage(imageType: "backImage");
    }
    Map<String, dynamic> data = {
      "frontImage": dowmloadUrls.elementAt(0)["frontImage"],
      "backImage": dowmloadUrls.elementAt(1)["backImage"],
      "firstName": textEditingControllerFirstName.text.trim(),
      "LastName": textEditingControllerLastName.text.trim(),
      "userId": FirebaseAuth.instance.currentUser!.uid,
      "country": accountCountry.value,
      "state": accountState.value,
      "city": accountCity.value,
    };
    await _firestoreDatabase
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(data)
        .then((value) {
      getAcountBankDetails();
    });
  }

  Future handleUploadImage({required imageType}) async {
    var firebaseUser = FirebaseAuth.instance.currentUser!;
    final Reference storageRef = FirebaseStorage.instance.ref().child("kyc");
    final UploadTask task = storageRef
        .child(
            'user_images/${firebaseUser.uid + DateTime.now().microsecondsSinceEpoch.toString()}')
        .putFile(imageType == "backImage"
            ? File(backImage!.value!.path)
            : File(frontImage!.value!.path));
    await task.then((picValue) async {
      await picValue.ref.getDownloadURL().then((downloadUrl) {
        dowmloadUrls.add({"$imageType": downloadUrl});
      });
    });
  }

  bool accountDetailsVerified() {
    if (accountCity.value.isNotEmpty &&
        accountState.value.isNotEmpty &&
        accountCountry.value.isNotEmpty &&
        (frontImage?.value != null || dowmloadUrls.isNotEmpty) &&
        (backImage?.value != null || dowmloadUrls.isNotEmpty) &&
        textEditingControllerFirstName.text.trim().isNotEmpty &&
        textEditingControllerLastName.text.trim().isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  getAcountBankDetails() async {
    if(FirebaseAuth.instance.currentUser !=null) {
      final snapshop = await _firestoreDatabase
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      Map<String, dynamic>? data = snapshop.data();
      if (data != null) {
        BankDetails jsonData = BankDetails.fromJson(data);
        fetchedBankDetails.value = jsonData;
        fetchedBankDetails.refresh();

        isVerified.value = true;
      } else {
        isVerified.value = false;
      }
    }
  }

  List<Widget> pages = [
    VerificationPage(),
    ConnectedBanks(),
    Availability(),
    const PreviewPage()
  ];

  @override
  void onInit() {
    pageController = PageController(initialPage: 0);
    getAcountBankDetails();
    super.onInit();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  assignFields() {
    if (fetchedBankDetails.value != null) {
      textEditingControllerFirstName.text =
          fetchedBankDetails.value!.firstName!;
      textEditingControllerLastName.text = fetchedBankDetails.value!.lastName!;
      accountCountry.value = fetchedBankDetails.value!.country!;
      accountState.value = fetchedBankDetails.value!.state!;
      accountCity.value = fetchedBankDetails.value!.city!;
      dowmloadUrls.add({"frontImage": fetchedBankDetails.value!.frontImage});
      dowmloadUrls.add({"backImage": fetchedBankDetails.value!.backImage});
    }
  }
}
