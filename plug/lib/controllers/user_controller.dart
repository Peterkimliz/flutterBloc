import 'dart:async';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/controllers/chat_controller.dart';
import 'package:plugme/controllers/service_controller.dart';
import 'package:plugme/models/rating.dart';
import 'package:plugme/utils/constants.dart';
import 'package:plugme/utils/style.dart';
import 'package:plugme/widgets/common_text.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../models/chat.dart';
import '../models/location_model.dart';
import '../models/user.dart';

class UserController extends GetxController with GetSingleTickerProviderStateMixin {
  RxBool showFuturedProvider = RxBool(false);
  final firestoreReference = FirebaseFirestore.instance.collection("users");
  late TabController tabController;

  final _chats = FirebaseFirestore.instance.collection("messages");
  RxBool fetchingUsers = RxBool(false);
  RxBool fetchingReviews = RxBool(false);
  RxDouble initialHeight = RxDouble(0.5);
  RxDouble minChildSize = RxDouble(0.4);
  late DraggableScrollableController scrollController;
  Rxn<UserModel> currentProfile = Rxn(null);
  RxList<Rating> userReviews = RxList([]);

  RxBool loadingFollowers = RxBool(false);
  RxBool fetchMarker = RxBool(false);
  RxList<UserModel> filteredUsers = RxList([]);
  RxList<UserModel> featuredUsers = RxList([]);
  Completer<GoogleMapController> controller = Completer();
  Rxn<UserModel> selectedUser = Rxn(null);
  TextEditingController textEditingMessage = TextEditingController();
  RxDouble ratingValue = RxDouble(0.0);
  var markers = RxSet<Marker>();
  var polyline = RxSet<Polyline>();
  RxList selectedDays = RxList([]);
  List daysOfTheWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  RxBool allDaysOfWeek = RxBool(false);
  final GlobalKey<ScaffoldState> scaffoldKey =  GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> completer = Completer();

  RxBool isKeyboardVisible = RxBool(false);

  RxBool showUpButton = RxBool(false);

  Rxn<SfRangeValues> rangeValues = Rxn(const SfRangeValues(0.0, 20.0));

  void getMarkers(double lat, double long) async {
    markers.clear();
    MarkerId markerId = MarkerId(lat.toString() + long.toString());
    Marker marker = Marker(
      markerId: markerId,
      position: LatLng(lat, long),
      icon: BitmapDescriptor.fromBytes(await getBytesFromAsset()),
    );

    markers.add(marker);
    markers.refresh();
    getDirections(lat, long);
  }

  getDirections(double lat, double long) async {
    ServiceController serviceController = Get.find<ServiceController>();
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      mapKey,
      PointLatLng(serviceController.position.value!.latitude!,
          serviceController.position.value!.longitude!),
      PointLatLng(lat, long),
      travelMode: TravelMode.driving,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {}
    Polyline pollinates = Polyline(
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
      polylineId: const PolylineId("poly"),
    );
    polyline.add(pollinates);
    polyline.refresh();
  }

  drawPolylines(double lat, long) async {
    ServiceController serviceController = Get.find<ServiceController>();

    polyline.add(Polyline(
      polylineId: PolylineId(lat.toString()),
      visible: true,
      width: 5,
      //width of polyline
      points: [
        LatLng(serviceController.position.value!.latitude!,
            serviceController.position.value!.longitude!), //start point
        LatLng(lat, long)
      ],
      color: Colors.deepOrangeAccent, //color of polyline
    ));

    polyline.refresh();
  }

  void searchUsersBasedOnService() async {
    ServiceController serviceController = Get.find<ServiceController>();
    filteredUsers.clear();
    try {
      fetchingUsers.value = true;
      var queryies = firestoreReference
          .where("service.name",
              isEqualTo: serviceController.category.value!.name!)
          .where("isServiceProvider", isEqualTo: true)
          .where("isOnline", isEqualTo: true)
          .where("accountEnabled", isEqualTo: true);
      if (Get.find<AuthController>().currentUser.value != null) {
        queryies = queryies.where("id",
            isNotEqualTo: FirebaseAuth.instance.currentUser!.uid);
      }

      if (serviceController.category.value!.subCategory!.trim().isNotEmpty &&
          serviceController.category.value!.subCategory!.trim().toLowerCase() !=
              "all") {
        queryies = queryies.where("service.subCategory",
            isEqualTo: serviceController.category.value!.subCategory!);
      }

      QuerySnapshot query = await queryies
          .orderBy('id')
          .orderBy('firstname', descending: true)
          .get();

      if (query.docs.isNotEmpty) {
        for (var element in query.docs) {
          UserModel userModel =
              UserModel.fromJson(element.data() as Map<String, dynamic>);

          if (selectedDays.isNotEmpty) {
            var contain =
                userModel.availability!.toSet().containsAll(selectedDays);
            if (contain) {
              filteredUsers.add(userModel);
            }
          } else {
            filteredUsers.add(userModel);
          }
        }

        List<UserModel> filteredUsersnew = filteredUsers.where((element) {
          return (element.pricePerHour! >=
                  int.parse("${rangeValues.value!.start}") &&
              element.pricePerHour! <= int.parse("${rangeValues.value!.end}"));
        }).toList();
        filteredUsers.clear();
        filteredUsers.addAll(filteredUsersnew);
        filteredUsers.refresh();
      } else {
        filteredUsers.value = [];
      }
      fetchingUsers.value = false;
    } catch (e) {
      fetchingUsers.value = false;
    }
  }

  void getFeaturedProviders() async {
      var queries = firestoreReference.where("featured", isEqualTo: true);
      if (FirebaseAuth.instance.currentUser != null) {
        queries = queries.where("id",
            isNotEqualTo: FirebaseAuth.instance.currentUser!.uid);
      }

      QuerySnapshot query = await queries
          .orderBy('id')
          .orderBy('firstname', descending: true)
          .get();

      if (query.docs.isNotEmpty) {
        for (var element in query.docs) {
          UserModel userModel =
              UserModel.fromJson(element.data() as Map<String, dynamic>);
          featuredUsers.add(userModel);
        }
        featuredUsers.refresh();
        showFuturedProvider.value = true;
      } else {
        featuredUsers.value = [];
      }
  }

  void rateUser(
      {required message,
      required rateValue,
      required type,
      required uid,
      required UserModel userModel,
      required Chat chatData}) async {
    AuthController authController = Get.find<AuthController>();
    ChatController chatController = Get.find<ChatController>();


      Rating rating = Rating(
        message: message,
        userid: authController.currentUser.value!.id,
        username: authController.currentUser.value!.firstname!,
        reviewedId: userModel.id,
        profileImage: userModel.profileUrl,
        rating: (rateValue),
      );
      await firestoreReference
          .doc(userModel.id)
          .collection("ratings")
          .doc(authController.currentUser.value!.id)
          .set(rating.toJson());

      await firestoreReference.doc(userModel.id).update({
        'totalRating': FieldValue.increment(rateValue),
        'totalRatingCount': FieldValue.increment(1)
      });
      await _chats
          .doc(uid)
          .collection("chats")
          .doc(chatData.id)
          .update({"reviewed": true});

      if (type == "sender") {
        Chat chat = Chat(
          message: message,
          senderInboxMessage: "You have reviewed ${userModel.firstname}",
          receiverInboxMessage:
              "${authController.currentUser.value!.firstname} has reviewed you",
          type: "review",
          addTime: DateTime.now(),
          senderId: Get.find<AuthController>().currentUser.value,
          receiverId: userModel,
          offerType: chatData.offerType,
          price: 0,
          providerReview: 0,
          reviewed: false,
          userReview: rateValue,
          workId: chatData.workId,
          attachment: "",
          action: "coming",
          finished: false,
          receiverMessage:
              "${authController.currentUser.value!.firstname} has reviewed you",
          hours: 0,
          transactionId: "",
          pickUp: LocationModel(),
          destination: LocationModel(),
          workType: "",
        );

        chatController.sendMessage(
          chatModel: chat,
          docId: uid,
        );
        chatController.updateWorkByWorkId(chatData.workId!,
            {"totalReview": rateValue, "reviewMessage": message});
      } else {
        Chat chat = Chat(
          message: message,
          senderInboxMessage: "You have reviewed ${userModel.firstname}",
          receiverInboxMessage:
              "${authController.currentUser.value!.firstname} has reviewed you",
          type: "review",
          addTime: DateTime.now(),
          senderId: Get.find<AuthController>().currentUser.value,
          receiverId: userModel,
          offerType: chatData.offerType,
          price: 0,
          providerReview: 0,
          reviewed: false,
          userReview: rateValue,
          attachment: "",
          workId: chatData.workId,
          action: "coming",
          finished: false,
          receiverMessage:
              "${authController.currentUser.value!.firstname} has reviewed you",
          hours: 0,
          transactionId: "",
          pickUp: LocationModel(),
          destination: LocationModel(),
          workType: "",
        );

        chatController.sendMessage(
          chatModel: chat,
          docId: uid,
        );
      }
      textEditingMessage.clear();
      ratingValue.value = 0.0;

  }

  createMarkers({required UserModel userModel}) async {
    try {
      fetchMarker.value = true;
      markers.clear();
      markers.add(
        Marker(
          // icon: BitmapDescriptor.fromBytes(markerIcon),
          markerId: MarkerId(userModel.id!),
          infoWindow: InfoWindow(title: userModel.firstname),
          onTap: () {},
          position: LatLng(
              userModel.geoPoint!.latitude, userModel.geoPoint!.longitude),
        ),
      );

      fetchMarker.value = false;
    } catch (e) {
      fetchMarker.value = false;
    }
  }

  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });
    return await Geolocator.getCurrentPosition();
  }

  getBytesFromAsset() async {
    ByteData data = await rootBundle.load('assets/images/blackmarker.png');
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: 100);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  @override
  void onInit() {
    scrollController = DraggableScrollableController();
    scrollController.addListener(() {
      if (scrollController.size <= 0.05) {
        showUpButton.value = true;
      } else {
        showUpButton.value = false;
      }
    });
    getFeaturedProviders();
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
  }

  unfollowUser({required String user, String? type}) {
      AuthController authController = Get.find<AuthController>();
      if (type != null) {
        currentProfile.value?.followingCount =
            currentProfile.value!.followingCount! - 1;
        currentProfile.value!.following!
            .removeWhere((element) => element.id == user);
        currentProfile.refresh();
      } else {
        currentProfile.value?.followersCount =
            currentProfile.value!.followersCount! - 1;
        currentProfile.value!.followers!.removeWhere(
            (element) => element.id == FirebaseAuth.instance.currentUser!.uid);
        currentProfile.refresh();
      }
      firestoreReference
          .doc(user)
          .collection("follower")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
      firestoreReference
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("following")
          .doc(user)
          .delete();
      authController.updateSingleItem(
          body: {"followersCount": FieldValue.increment(-1)}, id: user);
      authController.updateSingleItem(
          body: {"followingCount": FieldValue.increment(-1)},
          id: FirebaseAuth.instance.currentUser!.uid);

  }

  followUser({required UserModel userModel, String? type}) {
      AuthController authController = Get.find<AuthController>();
      if (type != null) {
        UserModel userModels = UserModel(
          id: userModel.id,
          firstname: userModel.firstname,
          profileUrl: userModel.profileUrl,
        );
        currentProfile.value!.following!.add(userModels);
        currentProfile.value?.followingCount =
            currentProfile.value!.followingCount! + 1;
        currentProfile.refresh();
      } else {
        UserModel userModels = UserModel(
          id: authController.currentUser.value!.id,
          firstname: authController.currentUser.value!.firstname,
          profileUrl: authController.currentUser.value!.profileUrl,
        );
        currentProfile.value!.followers!.add(userModels);
        currentProfile.value?.followersCount =
            currentProfile.value!.followersCount! + 1;
        currentProfile.refresh();
      }
      firestoreReference
          .doc(userModel.id)
          .collection("followers")
          .doc(authController.currentUser.value!.id)
          .set({
        "id": authController.currentUser.value!.id,
        "firstname": authController.currentUser.value!.firstname,
        "profileUrl": authController.currentUser.value!.profileUrl,
        "playerId": authController.currentUser.value!.playerId,
      });
      firestoreReference
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("following")
          .doc(userModel.id)
          .set({
        "id": userModel.id,
        "firstname": userModel.firstname,
        "profileUrl": userModel.profileUrl,
        "playerId": userModel.playerId,
      });
      authController.updateSingleItem(
          body: {"followersCount": FieldValue.increment(1)}, id: userModel.id!);
      authController.updateSingleItem(
          body: {"followingCount": FieldValue.increment(1)},
          id: FirebaseAuth.instance.currentUser!.uid);

  }
  getUserFollowers({required String id, required String type}) async {
    try {
      loadingFollowers.value = true;

      List<UserModel> followers = [];
      QuerySnapshot query = await firestoreReference.doc(id).collection(type).get();
      if (query.docs.isNotEmpty) {
        for (var element in query.docs) {
          UserModel userModel =
              UserModel.fromJson(element.data() as Map<String, dynamic>);
          followers.add(userModel);
        }
      }
      if (type == "followers") {
        Get.find<AuthController>().currentUser.value!.followers = followers;
        currentProfile.value?.followers = followers;
      } else {
        currentProfile.value?.following = followers;
        Get.find<AuthController>().currentUser.value!.following = followers;
      }
      Get.find<AuthController>().currentUser.refresh();
      currentProfile.refresh();
      loadingFollowers.value = false;
    } catch (e) {
      loadingFollowers.value = false;
    }
  }

  getCurrentUser(uid) async {

      final snap = await firestoreReference.doc(uid).get();
      var data = snap.data();
      UserModel userModel = UserModel.fromJson(data as Map<String, dynamic>);
      currentProfile.value = userModel;
      getUserFollowers(id: currentProfile.value!.id!, type: "followers");
      currentProfile.refresh();

  }

  getUserReviews(uid) async {
    try {
      fetchingReviews.value = true;
      userReviews.clear();
      QuerySnapshot query = await firestoreReference
          .doc(uid)
          .collection("ratings")
          .where("reviewedId", isEqualTo: uid)
          .get();
      if (query.docs.isNotEmpty) {
        for (var element in query.docs) {
          Rating userModel =
              Rating.fromJson(element.data() as Map<String, dynamic>);
          userReviews.add(userModel);
        }
        userReviews.refresh();
      } else {
        userReviews.value = [];
      }
      fetchingReviews.value = false;
    } catch (e) {
      fetchingReviews.value = false;
    }
  }

  blockUser({required String id, required context}) async {
      Get.defaultDialog(
          title: "Just a moment",
          contentPadding: const EdgeInsets.all(10),
          content: const CircularProgressIndicator(),
          barrierDismissible: false);

      await firestoreReference.doc(id).update({
        "blockedUsers": FieldValue.arrayUnion([id])
      });
      Get.find<AuthController>().currentUser.value?.blockedUsers!.add(id);
      Get.find<AuthController>().currentUser.refresh();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: CommonText(color: whiteColor, text: "User blocked"),
        backgroundColor: Colors.green,
      ));
      Get.back();

  }

  sendReportMessage({required String id, required String message}) async {
       Get.defaultDialog(
          title: "Just a moment",
          contentPadding: const EdgeInsets.all(10),
          content: const CircularProgressIndicator(),
          barrierDismissible: false);

      await firestoreReference
          .doc(id)
          .collection("reporting")
          .doc(firestoreReference.doc(id).collection("reporting").doc().id)
          .set({"message": message});
      textEditingMessage.clear();
      Get.back();

  }
}
