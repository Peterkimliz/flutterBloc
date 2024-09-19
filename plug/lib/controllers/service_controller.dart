import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/controllers/bank_controller.dart';
import 'package:plugme/controllers/chat_controller.dart';
import 'package:plugme/location_allow.dart';
import 'package:plugme/models/service.dart';
import 'package:plugme/models/user.dart';
import 'package:plugme/models/work.dart';
import 'package:plugme/utils/constants.dart';
import 'package:plugme/widgets/common_text.dart';

import '../models/address_model.dart' as adr;
import '../models/chat.dart';
import '../models/location_model.dart';
import '../models/place_prediction.dart';
import '../models/subservice.dart';
import '../screens/home.dart';
import '../utils/style.dart';

class ServiceController extends GetxController {
  List<String> currencies = ["NG", "RW", "UG", "KE", "ZA", "US", "GH", "TZ"];
  List<String> currency = [
    "NGN",
    "RWF",
    "UGX",
    "KES",
    "ZAR",
    "USD",
    "GHS",
    "TZS"
  ];
  RxString selectedCurrency = RxString("NG");

  var client = http.Client();
  final _serviceRef = FirebaseFirestore.instance.collection("settings");
  final _workRef = FirebaseFirestore.instance.collection("work");
  RxList<ServiceModel> services = RxList([]);
  RxList<ServiceModel> searchedServices = RxList([]);
  RxList<Work> myJobs = RxList([]);
  RxBool loadingPlace = RxBool(false);

  Rxn<ServiceModel> category = Rxn(null);
  Rxn<Subcategory> subCategory = Rxn(null);
  Rxn<loc.LocationData> position = Rxn(null);
  RxBool creatingStripeAccount = RxBool(false);
  RxString birthDateHolder = RxString("");
  RxBool expandBottomsheet = RxBool(false);
  RxBool loadingService = RxBool(false);
  RxBool checkWeeks = RxBool(false);
  RxBool isSearching = RxBool(false);
  RxBool isExpandable = RxBool(false);
  RxBool enableSearchedUsers = RxBool(false);
  RxBool fetchingJobs = RxBool(false);
  RxBool capturePaymentLoad = RxBool(false);
  RxInt bottomSheetNumber = RxInt(0);
  RxList<PlacePrediction> places = RxList([]);
  Rxn<adr.Address> address = Rxn(null);
  Rxn<adr.Address> destinationAddress = Rxn(null);
  RxList selectedDays = RxList([]);
  TextEditingController textEditingControllerSearch = TextEditingController();
  TextEditingController textEditingControllerSearchService =
      TextEditingController();
  TextEditingController textEditingControllerEmail = TextEditingController();
  TextEditingController textEditingControllerDestination =
      TextEditingController();
  TextEditingController textEditingControllerAddress = TextEditingController();
  TextEditingController textEditingControllerAccountNumber =
      TextEditingController();
  TextEditingController textEditingControllerRoutingNumber =
      TextEditingController();
  TextEditingController textEditingControllerPostalNumber =
      TextEditingController();
  TextEditingController textEditingControllerPhoneNumber =
      TextEditingController();
  TextEditingController textEditingControllerPhoneCvc = TextEditingController();

  Future<void> getAllServices({String? name}) async {
    try {
      print("Called");
      loadingService.value = true;
      QuerySnapshot querySnapshot = await _serviceRef.orderBy("name").get();
      List allData = querySnapshot.docs.map((doc) => doc.data()).toList();
      loadingService.value = false;
      if (allData.isNotEmpty) {
        services
            .assignAll(allData.map((e) => ServiceModel.fromJson(e)).toList());
      } else {
        services.value = [];
      }
    } catch (e) {
      loadingService.value = false;
    }
  }

  void checkLocation() async {
    loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      Get.off(() => LocationAllow());
    } else {
      position.value = await location.getLocation();
      position.refresh();
      Get.off(() => Home());
    }
  }

  void checkLocationEnabled() async {
    loc.Location location = loc.Location();
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    print("serviceEnabled  $serviceEnabled");
    if (kDebugMode) {
      print("serviceEnabled  $serviceEnabled");
    }
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    } else {
      position.value = await location.getLocation();
      position.refresh();
      Get.off(() => Home());
    }

    permissionGranted = await location.hasPermission();
    if (kDebugMode) {
      print("serviceEnabled  ${loc.PermissionStatus}");
    }
    if (permissionGranted == loc.PermissionStatus.granted) {
      position.value = await location.getLocation();
      position.refresh();
      Get.off(() => Home());
    }
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return;
      }
    }
  }

  getWorkHistoryByUserId(
      {required String id, required bool checkByProvider, String? type}) async {
    try {
      myJobs.clear();
      fetchingJobs.value = true;
      if (checkByProvider == true) {
        var query = _workRef.where("provider.id", isEqualTo: id);
        if (type != null) {
          query = query.where("status", isEqualTo: type);
        }
        await query.orderBy("time", descending: true).get().then((value) {
          if (value.docs.isNotEmpty) {
            for (var element in value.docs) {
              Work userModel = Work.fromJson(element.data());
              myJobs.add(userModel);
            }
          }
        });
      } else {
        var query = _workRef.where("users", arrayContainsAny: [id]);
        if (type != null) {
          query = query.where("status", isEqualTo: type);
        }

        await query.orderBy("time", descending: true).get().then((value) {
          if (value.docs.isNotEmpty) {
            for (var element in value.docs) {
              Work userModel = Work.fromJson(element.data());
              myJobs.add(userModel);
            }
          }
        });
      }

      fetchingJobs.value = false;
    } catch (e) {
      fetchingJobs.value = false;
    }
  }

  @override
  void onInit() {
    getAllServices();
    super.onInit();
  }

  findPlacesNamePrediction(String placeName) async {
    try {
      loadingPlace.value = true;
      places.clear();
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey";
      print(autoCompleteUrl);
      var response = await client.get(Uri.parse(autoCompleteUrl));
      loadingPlace.value = false;
      final result = json.decode(response.body);
      if (result["status"] == "OK") {
        List placesData = result["predictions"];
        List<PlacePrediction> placePrediction =
            placesData.map((e) => PlacePrediction.fromJson(e)).toList();
        places.assignAll(placePrediction);

        return places.toList();
      } else {
        places.value = RxList([]);
        return places.toList();
      }
    } catch (e) {
      loadingPlace.value = false;
    }
  }

  getPlaceAddressDetails({String? placeid, String? destination}) async {
    String placeDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeid&key=$mapKey";
    var response = await client.get(Uri.parse(placeDetailsUrl));
    final result = json.decode(response.body);
    if (result["status"] == "OK") {
      if (destination != null) {
        destinationAddress.value = adr.Address.fromJson(result["result"]);
        textEditingControllerDestination.text =
            "${destinationAddress.value?.addressComponents![0].longName}";
      } else {
        address.value = adr.Address.fromJson(result["result"]);
        textEditingControllerSearch.text = "${address.value?.formattedAddress}";
      }

      places.clear();
    }
  }

  createStripeConnectAccount({required BuildContext context}) async {
    if (textEditingControllerAccountNumber.text.isEmpty ||
        textEditingControllerRoutingNumber.text.isEmpty ||
        textEditingControllerAddress.text.isEmpty ||
        textEditingControllerPostalNumber.text.isEmpty ||
        textEditingControllerPhoneNumber.text.isEmpty ||
        textEditingControllerPhoneCvc.text.isEmpty ||
        birthDateHolder.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: CommonText(
              color: whiteColor, text: "Please fill all the fields")));
      return;
    }
    AuthController authController = Get.find<AuthController>();
    BankController bankController = Get.find<BankController>();
    creatingStripeAccount.value = true;
    var birthDate = DateTime(1900, 5, 5);
    if (birthDateHolder.value.isNotEmpty) {
      birthDate = DateFormat("dd/MM/yyyy").parse(birthDateHolder.value);
    }
    var payload = {
      "country": "US",
      "currency": "USD",
      "account_number": textEditingControllerAccountNumber.text,
      "routing_number": textEditingControllerRoutingNumber.text,
      "ssn_last_4": textEditingControllerPhoneCvc.text,
      "state": bankController.fetchedBankDetails.value!.state,
      "city": bankController.fetchedBankDetails.value!.city,
      "day": birthDate.day.toString(),
      "month": birthDate.month.toString(),
      "year": birthDate.year.toString(),
      "address_one": textEditingControllerAddress.text,
      "address_two": textEditingControllerAddress.text,
      "postal_code": textEditingControllerPostalNumber.text,
      "phone": textEditingControllerPhoneNumber.text,
      "email": authController.currentUser.value!.email!,
      'name': bankController.fetchedBankDetails.value!.firstName,
      'first_name': bankController.fetchedBankDetails.value!.firstName,
      'last_name': bankController.fetchedBankDetails.value!.lastName,
      'account_holder_name':
          "${bankController.fetchedBankDetails.value!.firstName} ${bankController.fetchedBankDetails.value!.lastName}",
    };
    Get.defaultDialog(
        title: "Just a moment",
        contentPadding: const EdgeInsets.all(10),
        content: const CircularProgressIndicator(),
        barrierDismissible: false);
    final url =
        "$baseUrl/stripe/connect/${authController.currentUser.value!.id}";

    var respnse = await client.post(Uri.parse(url), body: payload);

    Get.back();
    var payments = jsonDecode(respnse.body);

    if (payments["success"] == false) {
      creatingStripeAccount.value = false;
      Get.snackbar(
        "Error",
        "",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 30),
        messageText: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                payments["message"],
                style: const TextStyle(color: Colors.white, fontSize: 21),
              ),
            ),
            SnackBarAction(
              label: "dismiss",
              textColor: Colors.white,
              onPressed: () {
                Get.back();
              },
            )
          ],
        ),
        colorText: Colors.white,
        margin: const EdgeInsets.all(0),
      );
      return;
    } else {
      authController.updateSingleItem(body: {
        "accountNumber": payments["account"]["external_accounts"]["data"][0]
            ["account"]
      }, id: FirebaseAuth.instance.currentUser!.uid);
      authController.updateSingleItem(
          body: {"accountType": "stripe"},
          id: FirebaseAuth.instance.currentUser!.uid);

      authController.updateSingleItem(body: {
        "bankName": payments["account"]["external_accounts"]["data"][0]
            ["bank_name"]
      }, id: FirebaseAuth.instance.currentUser!.uid);
      authController.updateSingleItem(
          body: {"accountConnected": true},
          id: FirebaseAuth.instance.currentUser!.uid);
      authController.currentUser.value?.accountNumber =
          payments["account"]["external_accounts"]["data"][0]["account"];
      authController.currentUser.value?.accountType = "stripe";
      authController.currentUser.value?.bankName =
          payments["account"]["external_accounts"]["data"][0]["bank_name"];
      authController.currentUser.value?.accountConnected = true;
      authController.showInputFields.value = false;
      authController.currentUser.refresh();
      Get.back();
      bankController.pageNumber.value = 2;
      bankController.pageController.animateToPage(
          bankController.pageNumber.value,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeIn);
    }
  }

  connectFlutterWave({required context}) async {
    if (textEditingControllerAccountNumber.text.isEmpty ||
        textEditingControllerEmail.text.isEmpty ||
        textEditingControllerPhoneNumber.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: CommonText(
              color: whiteColor, text: "Please fill all the fields")));
      return;
    }
    AuthController authController = Get.find<AuthController>();
    BankController bankController = Get.find<BankController>();
    creatingStripeAccount.value = true;
    Map<String, dynamic> body = {
      "account_number": textEditingControllerAccountNumber.text.trim(),
      "business_mobile": textEditingControllerPhoneNumber.text.trim(),
      "country": selectedCurrency.value,
      "business_email": textEditingControllerEmail.text.trim(),
    };
    Get.defaultDialog(
        title: "Just a moment",
        contentPadding: const EdgeInsets.all(10),
        content: const CircularProgressIndicator(),
        barrierDismissible: false);
    const url = "$baseUrl/flutterwave/createsubaccount";
    var response = await client.post(Uri.parse(url), body: body);
    Get.back();
    var payments = jsonDecode(response.body);
    if (payments["status"] == "error") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: CommonText(
        color: whiteColor,
        text: payments["message"],
      )));
    } else {
      var accountId = payments["data"]["subaccount_id"];
      authController.updateSingleItem(
          body: {"accountNumber": accountId},
          id: FirebaseAuth.instance.currentUser!.uid);
      authController.updateSingleItem(
          body: {"accountType": "flutterWave"},
          id: FirebaseAuth.instance.currentUser!.uid);

      authController.updateSingleItem(
          body: {"accountConnected": true},
          id: FirebaseAuth.instance.currentUser!.uid);
      authController.currentUser.value?.accountNumber = accountId;
      authController.currentUser.value?.accountType = "flutterWave";

      authController.currentUser.value?.accountConnected = true;
      authController.showInputFields.value = false;
      authController.currentUser.refresh();
      Get.back();
      bankController.pageNumber.value = 2;
      bankController.pageController.animateToPage(
          bankController.pageNumber.value,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeIn);
    }
  }

  Future<void> makePayment(
      {required context,
      required UserModel userModel,
      required String uid,
      required Chat chatData}) async {
    AuthController authController = Get.find<AuthController>();
    try {
      Get.defaultDialog(
          title: "Just a moment",
          contentPadding: const EdgeInsets.all(10),
          content: const CircularProgressIndicator(),
          barrierDismissible: false);
      if (authController.currentUser.value?.customerId == null) {
        await createCustomer();
      }
      const url = "$baseUrl/stripe/createIntent";
      var paymentIntent = await client.post(Uri.parse(url), body: {
        "amount": "${(chatData.price! * chatData.hours!)}",
        "accountno": userModel.accountNumber,
        "customerId": authController.currentUser.value!.customerId,
      });

      Get.back();
      Map<String, dynamic> result =
          jsonDecode(paymentIntent.body) as Map<String, dynamic>;

      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: result["client_secret"],
                  style: ThemeMode.light,
                  merchantDisplayName: 'plugme'))
          .then((value) {});
      displayPaymentSheet(
          amount: (chatData.price! * chatData.hours!),
          context: context,
          userModel: userModel,
          uid: uid,
          chatData: chatData,
          transactionId: result["transactionId"]);
    } catch (err) {
      Get.back();
    }
  }

  Future<void> deleteStripeAccount() async {
    AuthController authController = Get.find<AuthController>();
    try {
      final url =
          "$baseUrl/stripe/deleteaccount/${authController.currentUser.value!.accountNumber}";
      await client.get(Uri.parse(url));
    } catch (err) {
      Get.back();
    }
  }

  displayPaymentSheet(
      {required context,
      required UserModel userModel,
      required String uid,
      required transactionId,
      required Chat chatData,
      required int amount}) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        acceptOffer(
            userModel: userModel,
            chatData: chatData,
            transactionId: transactionId,
            uid: uid);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 100.0,
                ),
                SizedBox(height: 10.0),
                Text("Payment Successful!"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const CommonText(
                    color: Colors.deepPurple,
                    text: "Okay",
                    fontFamily: "RedHatMedium"),
              )
            ],
          ),
        );
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException {
      AlertDialog(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const CommonText(
                color: Colors.deepPurple,
                text: "Okay",
                fontFamily: "RedHatMedium"),
          )
        ],
      );
    }
  }

  Future createCustomer() async {
    AuthController authController = Get.find<AuthController>();
    try {
      var body = {
        "address": authController.currentUser.value!.address,
        "email": authController.currentUser.value!.email,
        "name": authController.currentUser.value!.firstname,
      };
      final response = await client.post(
        Uri.parse("https://api.stripe.com/v1/customers"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization": "Bearer $stripeSecret",
        },
        body: jsonEncode(body),
      );
      var result = jsonDecode(response.body);
      if (result["id"] != null) {
        authController.updateSingleItem(
            body: {"customerId": result["id"]},
            id: FirebaseAuth.instance.currentUser!.uid);
        authController.currentUser.value!.customerId = result["id"];
        authController.currentUser.refresh();
      }
    } catch (err) {
      Get.back();
    }
  }

  Future capturePayment(
      {required String uid,
      required UserModel userModel,
      required Chat chatData}) async {
    try {
      capturePaymentLoad.value = true;
      ChatController chatController = Get.find<ChatController>();
      const url = "$baseUrl/stripe/capturepayment";
      var paymentIntent = await client.post(Uri.parse(url), body: {
        "transactionId": chatData.transactionId,
      });
      Map<String, dynamic> result =
          jsonDecode(paymentIntent.body) as Map<String, dynamic>;
      if (result["response"] == true) {
        Chat chat = Chat(
          message:
              "Thank you for choosing plugme, we hope you had a great experience.Please make sure to leave a review for ${userModel.firstname}.Reviews help us make sure this community remains a safe.",
          senderInboxMessage:
              "Thank you for choosing plugme, we hope you had a great experience.Please make sure to leave a review for ${userModel.firstname}.Reviews help us make sure this community remains a safe.",
          receiverInboxMessage:
              "Thank you for choosing plugme, we hope you had a great experience.Please make sure to leave a review for ${Get.find<AuthController>().currentUser.value!.firstname}.Reviews help us make sure this community remains a safe.",
          type: "offer",
          addTime: DateTime.now(),
          senderId: Get.find<AuthController>().currentUser.value,
          receiverId: userModel,
          offerType: chatData.offerType,
          price: chatData.price,
          providerReview: 0,
          reviewed: false,
          userReview: 0,
          attachment: "",
          action: "review",
          finished: false,
          receiverMessage: "",
          hours: chatData.hours!,
          transactionId: "",
          workId: chatData.workId,
          pickUp: LocationModel(),
          destination: LocationModel(),
          workType: "",
        );

        chatController.sendMessage(
          chatModel: chat,
          docId: uid,
        );
        chatController.updateOffer(uid: uid, body: {'status': "completed"});

        List<String> users = [];
        users.add(chatData.receiverId!.id!);
        users.add(chatData.senderId!.id!);
        chatController.updateWork(users, {'completionTime': DateTime.now()});

        chatController.sendChatNotification(
            chatId: uid,
            type: "offer",
            id: userModel.playerId!,
            userModel: Get.find<AuthController>().currentUser.value!,
            message:
                "${Get.find<AuthController>().currentUser.value!.firstname} finished working",
            screen: "ChatInbox");
      }
      capturePaymentLoad.value = false;
    } catch (err) {
      capturePaymentLoad.value = false;
      Get.back();
    }
  }

  Future cancelTransaction(
      {required String uid,
      required UserModel userModel,
      required Chat chaData}) async {
    try {
      ChatController chatController = Get.find<ChatController>();
      const url = "$baseUrl/stripe/cancel";
      List<String> users = [];
      users.add(chaData.receiverId!.id!);
      users.add(chaData.senderId!.id!);
      chatController.updateWork(users, {'status': "canceled"});

      Chat chatModelData = Chat(
        message: "This job has been cancelled",
        senderInboxMessage: "You have cancelled ${userModel.firstname}",
        receiverInboxMessage:
            "${Get.find<AuthController>().currentUser.value!.firstname!} has cancelled the offer",
        type: "text",
        addTime: DateTime.now(),
        senderId: Get.find<AuthController>().currentUser.value,
        receiverId: userModel,
        offerType: "",
        price: 0,
        providerReview: 0,
        reviewed: false,
        userReview: 0,
        workId: "",
        attachment: "",
        action: "working",
        finished: false,
        receiverMessage: "",
        hours: 0,
        transactionId: "",
        pickUp: LocationModel(),
        destination: LocationModel(),
        workType: "",
      );

      chatController.sendMessage(
        chatModel: chatModelData,
        docId: uid,
      );

      chatController.sendChatNotification(
          chatId: uid,
          type: "offer",
          id: userModel.playerId!,
          userModel: Get.find<AuthController>().currentUser.value!,
          message: "Offer cancelled",
          screen: "ChatInbox");
      await client.post(Uri.parse(url), body: {
        "transactionId": chaData.transactionId,
      });
    } catch (err) {
      Get.back();
    }
  }

  searchService({required String text}) {
    List<ServiceModel> searchResults =
        services.where((item) => item.name!.startsWith(text)).toList();
    searchedServices.assignAll(searchResults);
    searchedServices.refresh();
  }

  clearInputs() {
    textEditingControllerAccountNumber.clear();
    textEditingControllerPhoneCvc.clear();
    textEditingControllerPhoneNumber.clear();
    textEditingControllerPostalNumber.clear();
    textEditingControllerRoutingNumber.clear();
    textEditingControllerAddress.clear();
  }

  disconnectStripe(BuildContext context) async {
    AuthController authController = Get.find<AuthController>();
    try {
      Get.defaultDialog(
          title: "Just a moment",
          contentPadding: const EdgeInsets.all(10),
          content: const CircularProgressIndicator(),
          barrierDismissible: false);
      await deleteStripeAccount();
      await authController.updateSingleItem(
          body: {"isServiceProvider": false},
          id: FirebaseAuth.instance.currentUser!.uid);
      await authController.updateSingleItem(
          body: {"accountNumber": ""},
          id: FirebaseAuth.instance.currentUser!.uid);
      await authController.updateSingleItem(
          body: {"service": null}, id: FirebaseAuth.instance.currentUser!.uid);
      await authController.updateSingleItem(
          body: {"availability": []},
          id: FirebaseAuth.instance.currentUser!.uid);
      await authController.updateSingleItem(
          body: {"accountConnected": false},
          id: FirebaseAuth.instance.currentUser!.uid);
      authController.currentUser.value!.isServiceProvider = false;
      authController.currentUser.value!.accountNumber = null;
      authController.currentUser.value!.service = null;
      authController.currentUser.value!.availability = null;
      authController.currentUser.value!.accountConnected = false;
      authController.currentUser.refresh();
      Get.back();
    } catch (e) {
      Get.back();
    }
  }

  choosePaymentMethodBottomSheet(
      {required context,
      required Chat chatData,
      required UserModel userModel,
      required String uid}) {
    showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                      child: CommonText(
                    color: blueColor,
                    text: "Select Payment Method",
                    fontWeight: FontWeight.bold,
                    size: 18,
                  )),
                  if (userModel.accountType != null &&
                      userModel.accountType == "stripe")
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Get.back();
                            makePayment(
                                context: context,
                                chatData: chatData,
                                userModel: userModel,
                                uid: uid);
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: blueColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/stripe.png",
                                    color: whiteColor,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: CommonText(
                                      color: whiteColor,
                                      text: "Stripe",
                                      size: 25,
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ],
                    ),
                  if (userModel.accountType != null &&
                      userModel.accountType == "flutterWave")
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        InkWell(
                          onTap: () {
                            Get.back();
                            payWithFlutterWave(
                                context: context,
                                chatData: chatData,
                                userModel: userModel,
                                uid: uid);
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0XFF2c3262),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/flutterwave.png",
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8.0),
                                    child: CommonText(
                                      color: whiteColor,
                                      text: "FlutterWave",
                                      size: 20,
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ],
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: yellowColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/paypal.png",
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: CommonText(
                                color: whiteColor,
                                text: "Paypal",
                                size: 25,
                              ),
                            )
                          ],
                        )),
                  ),
                ],
              ),
            ),
          );
        });
  }

  getWorkById(String workId) async {
    try {
      Get.defaultDialog(
          title: "Just a moment",
          contentPadding: const EdgeInsets.all(10),
          content: const CircularProgressIndicator(),
          barrierDismissible: false);
      Map<String, dynamic> query = (await _workRef
          .where("workId", isEqualTo: workId)
          .get()) as Map<String, dynamic>;

      Work work = Work.fromJson(query);
      Get.back();
      return work;
    } catch (e) {
      Get.back();
    }
  }

  void payWithFlutterWave(
      {required Chat chatData,
      required context,
      required UserModel userModel,
      required String uid}) async {
    try {
      AuthController authController = Get.find<AuthController>();
      var url = await createRedirectUrl(chatData: chatData);
      // SubAccount singleAccount = SubAccount(id: userModel.accountNumber!);
      // List<SubAccount> subAccounts = [];
      // subAccounts.add(singleAccount);

      final Customer customer = Customer(
          name: authController.currentUser.value!.firstname!,
          phoneNumber: "",
          email: authController.currentUser.value!.email!);
      final Flutterwave flutterwave = Flutterwave(
          context: context,
          publicKey: fireWavePublicKey,
          currency: "KES",
          redirectUrl: url,
          txRef: generateRandomKey(),
          amount: "${chatData.hours! * chatData.price!}",
          customer: customer,
          paymentOptions: "ussd, card, barter, payattitude",
          customization: Customization(title: "My Payment"),
          isTestMode: true);

      final ChargeResponse response = await flutterwave.charge();
      if (kDebugMode) {
        print("response~${response.transactionId}");
      }
      if (response.success == true) {
        acceptOffer(
            userModel: userModel,
            chatData: chatData,
            transactionId: response.transactionId,
            uid: uid);
      }
    } catch (error) {
      if (kDebugMode) {
        print("error is $error");
      }
    }
  }

  createRedirectUrl({required Chat chatData}) async {
    try {
      AuthController authController = Get.find<AuthController>();
      Get.defaultDialog(
          title: "Just a moment",
          content: const CircularProgressIndicator(),
          barrierDismissible: false);

      Map<String, dynamic> body = {
        "amount": "${chatData.price! * chatData.hours!}",
        "currency": "KE",
        "email": authController.currentUser.value?.email!,
        "phone": "",
        "name": authController.currentUser.value!.firstname! +
            authController.currentUser.value!.lastname!
      };

      var response = await client.post(
          Uri.parse("$baseUrl/flutterwave/createredirecturl"),
          body: body);
      Get.back();
      if (kDebugMode) {
        print("response is ${jsonDecode(response.body)}");
      }
      var decodedResponse = jsonDecode(response.body);

      return decodedResponse["link"];
    } catch (e) {
      Get.back();
    }
  }

  String getPublicKey() {
    return "";
  }

  generateRandomKey() {
    final now = DateTime.now();
    return now.microsecondsSinceEpoch.toString();
  }

  acceptOffer({
    required UserModel userModel,
    required Chat chatData,
    required transactionId,
    required String uid,
  }) {
    ChatController chatController = Get.find<ChatController>();
    AuthController authController = Get.find<AuthController>();

    Chat chat = Chat(
      message:
          "Dear ${authController.currentUser.value!.firstname}, Thank you for accepting ${userModel.firstname!} offer.${userModel.firstname!.toString()} is on their way to your current location now.If you would like them to arrive at a different location please let them know.",
      senderInboxMessage:
          "Dear ${authController.currentUser.value!.firstname}, Thank you for accepting ${userModel.firstname!} offer.${userModel.firstname!.toString()} is on their way to your current location now.If you would like them to arrive at a different location please let them know.",
      type: "offer",
      addTime: DateTime.now(),
      senderId: Get.find<AuthController>().currentUser.value,
      receiverId: userModel,
      offerType: chatData.offerType,
      price: chatData.price!,
      providerReview: 0,
      reviewed: false,
      userReview: 0,
      attachment: "",
      action: "coming",
      finished: false,
      receiverMessage:
          "${authController.currentUser.value!.firstname} accepted your offer. They are now waiting for you. Please start heading over their way. ${authController.currentUser.value!.firstname} address is ${authController.currentUser.value!.address} \nOnce you arrived at client’s location, please confirm your arrival.\nTIP: It is best for you to confirm your client’s address before you start your drive.  ",
      receiverInboxMessage:
          "${authController.currentUser.value!.firstname} accepted your offer. They are now waiting for you. Please start heading over their way. ${authController.currentUser.value!.firstname} address is ${authController.currentUser.value!.address} \nOnce you arrived at client’s location, please confirm your arrival.\nTIP: It is best for you to confirm your client’s address before you start your drive.  ",
      hours: chatData.hours!,
      transactionId: transactionId,
      pickUp: LocationModel(),
      destination: LocationModel(),
      workType: "",
    );

    chatController.sendMessage(
      chatModel: chat,
      docId: uid,
    );
    chatController.updateChatById(
        uid: uid,
        chatId: chatData.id,
        body: {"finished": true, "action": "Offer Accepted"});

    chatController.updateChatById(
        uid: uid, chatId: chatData.id, body: {"transactionId": transactionId});

    chatController.sendChatNotification(
        chatId: uid,
        type: "offer",
        id: userModel.playerId!,
        userModel: authController.currentUser.value!,
        message:
            "Your offer has been accepted by ${authController.currentUser.value!.firstname}",
        screen: "ChatInbox");
  }
}
