import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plug/controllers/chat_controller.dart';
import 'package:plug/controllers/location_controller.dart';
import 'package:plug/controllers/service_controller.dart';

import 'package:plug/models/user.dart';
import 'package:plug/screens/location/location_screen.dart';
import '../../controllers/auth_controller.dart';
import '../../models/chat.dart';
import '../../models/location_model.dart';

class LocationPage extends StatelessWidget {
  final String type;
  final String chatId;
  final UserModel userModel;

  LocationPage(
      {Key? key,
      required this.type,
      required this.chatId,
      required this.userModel})
      : super(key: key);

  final LocationController locationController = Get.find<LocationController>();
  final ServiceController serviceController = Get.find<ServiceController>();

  final ChatController chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Obx(() {
              return locationController.loadingPolyLines.value
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : GoogleMap(
                      zoomGesturesEnabled: true,
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      markers: Set<Marker>.of(locationController.markers),
                      polylines: locationController.polyline,
                      myLocationEnabled: true,
                      padding: const EdgeInsets.only(top: 300.0),
                      initialCameraPosition: CameraPosition(
                          target: LatLng(
                              serviceController.position.value!.latitude!,
                              serviceController.position.value!.longitude!),
                          zoom: 14),
                      onMapCreated: (GoogleMapController controller) {
                        locationController.controller.complete(controller);
                      },
                    );
            }),
            if (type != "search")
              Positioned(
                  top: 10,
                  left: 10,
                  child: InkWell(
                      onTap: () => Get.back(),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: Icon(
                          Icons.clear,
                          color: Colors.black,
                          ),
                        ))),
            if (type == "search")
              Container(
                height: 300,
                width: getScreenWidth(context),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 8),
                      color: Colors.black12,
                      blurRadius: 10,
                    ),
                  ],
                ),
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(
                          left: 18, top: 10, bottom: 4),
                      child: InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: const Icon(Icons.clear)),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            const Icon(
                              Icons.trip_origin_rounded,
                              color: Colors.black,
                              size: 28,
                            ),
                            SizedBox(
                              height: 54,
                              child: CustomPaint(
                                  size: const Size(1, double.infinity),
                                  painter: DashedLineVerticalPainter()),
                            ),
                            const Icon(
                              Icons.place_rounded,
                              color: Colors.black,
                              size: 32,
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 0, top: 8, bottom: 4),
                              child: const Text(
                                "From",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size(getScreenWidth(context) - 120, 42),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(21))),
                                  ),
                                  child: Obx(() {
                                    return Text(
                                      locationController
                                          .fromPlace.value !=
                                          null
                                          ? locationController
                                          .fromPlace.value!.address!
                                          : "Enter pickup location",
                                      maxLines: 1,
                                      textAlign: TextAlign.start,
                                    );
                                  }),
                                  onPressed: () {
                                    Get.to(() => LocationSearchScreen(
                                      title: "Enter Pickup Location",
                                      type: "from",
                                    ));
                                  },
                                ),
                                const SizedBox(width: 10,),
                                InkWell(onTap: (){
                                  locationController.getCurrentLocation();
                                },child: const Icon(Icons.my_location)),
                                const SizedBox(width: 10,),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 0, top: 8, bottom: 4),
                              child: const Text(
                                "To",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: Size(
                                    getScreenWidth(context) - 88, 42),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(21))),
                              ),
                              child: Obx(() => Text(
                                locationController
                                    .toPlace.value !=
                                    null
                                    ? locationController
                                    .toPlace.value!.address!
                                    : "Enter drop location",
                                maxLines: 1,
                                textAlign: TextAlign.start,
                              )),
                              onPressed: () {
                                Get.to(() => LocationSearchScreen(
                                  title: "Enter drop Location",
                                  type: "to",
                                ));
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    Obx(() {
                      return locationController.toPlace.value !=
                          null &&
                          locationController.fromPlace.value !=
                              null
                          ? Center(
                        child: Padding(
                          padding:
                          const EdgeInsets.only(top: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(
                                  getScreenWidth(context) - 200,
                                  42),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              shape:
                              const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(
                                      Radius.circular(
                                          21))),
                            ),
                            child: const Text(
                              "Share",
                              maxLines: 1,
                              textAlign: TextAlign.start,
                            ),
                            onPressed: () {
                              Get.back();

                              GeoPoint startgeoPoint = GeoPoint(
                                  locationController.fromPlace
                                      .value!.latitude!,
                                  locationController.fromPlace
                                      .value!.longitude!);
                              GeoPoint endgeoPoint = GeoPoint(
                                  locationController
                                      .toPlace.value!.latitude!,
                                  locationController.toPlace
                                      .value!.longitude!);

                              Chat chat = Chat(
                                message: "location",
                                receiverInboxMessage: "location",
                                senderInboxMessage: "location",
                                type: "location",
                                addTime: DateTime.now(),
                                senderId:
                                Get.find<AuthController>()
                                    .currentUser
                                    .value,
                                receiverId: userModel,
                                offerType: "",
                                price: 0,
                                providerReview: 0,
                                reviewed: false,
                                userReview: 0,
                                attachment: "",
                                action: "",
                                finished: false,
                                receiverMessage: "location",
                                hours: 0,
                                transactionId: "",
                                pickUp: LocationModel(
                                    name: locationController
                                        .fromPlace
                                        .value!
                                        .address!,
                                    geoPoint: startgeoPoint),
                                destination: LocationModel(
                                    name: locationController
                                        .toPlace
                                        .value!
                                        .address!,
                                    geoPoint: endgeoPoint),
                                workType: "",
                              );

                              chatController.sendMessage(
                                  docId: chatId, chatModel: chat);

                              locationController.toPlace.value =
                              null;
                              locationController
                                  .fromPlace.value = null;
                            },
                          ),
                        ),
                      )
                          : const Text("");
                    })
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}

class DashedLineVerticalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}
