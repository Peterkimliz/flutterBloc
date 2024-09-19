import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:plug/models/user.dart';
import 'package:plug/widgets/place_card.dart';

import '../controllers/service_controller.dart';
import '../models/place_prediction.dart';
import '../screens/chats/chats_inbox.dart';
import '../utils/style.dart';
import 'common_text.dart';
import 'custom_roundedbutton.dart';

destinationBottomSheet(
    {required context, required UserModel userModel, required uid}) {
  ServiceController serviceController = Get.find<ServiceController>();
  return showBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.35,
          decoration: const BoxDecoration(
            color: lightGrey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Center(
                    child: CommonText(
                        color: blackColor, text: "Select Route", size: 12)),
                const SizedBox(height: 10),
                const CommonText(
                    color: blackColor, text: "Pickup Location", size: 12),
                const SizedBox(height: 10),
                // TypeAheadField<PlacePrediction?>(
                //   debounceDuration: const Duration(milliseconds: 500),
                //   // textFieldConfiguration: TextFieldConfiguration(
                //   //   controller: serviceController.textEditingControllerSearch,
                //   //   decoration: InputDecoration(
                //   //       hintText: "",
                //   //       focusedBorder: OutlineInputBorder(
                //   //           borderRadius: BorderRadius.circular(100),
                //   //           borderSide: BorderSide.none),
                //   //       enabledBorder: OutlineInputBorder(
                //   //           borderRadius: BorderRadius.circular(100),
                //   //           borderSide: BorderSide.none),
                //   //       contentPadding:
                //   //           const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                //   //       border: OutlineInputBorder(
                //   //           borderRadius: BorderRadius.circular(100),
                //   //           borderSide: BorderSide.none),
                //   //       filled: true,
                //   //       fillColor: greyColor.withOpacity(0.1)),
                //   // ),
                //   suggestionsCallback: (pattern) async {
                //     return await serviceController
                //         .findPlacesNamePrediction(pattern);
                //   },
                //   itemBuilder: (context, PlacePrediction? suggestion) {
                //     final request = suggestion!;
                //     return placePredictionCard(placePrediction: request);
                //   },
                //   // onSuggestionSelected: (PlacePrediction? suggestion) async {
                //   //   final request = suggestion!;
                //   //   await serviceController.getPlaceAddressDetails(
                //   //       placeid: request.placeId);
                //   // },
                //   errorBuilder: (BuildContext context, error) {
                //     return Container(
                //         padding: const EdgeInsets.all(10),
                //         child: const Text("error Occurred"));
                //   },
                // ),
                const SizedBox(height: 10),
                const CommonText(
                    color: blackColor, text: "Destination Location", size: 12),
                const SizedBox(height: 10),
                // TypeAheadField<PlacePrediction?>(
                //   debounceDuration: const Duration(milliseconds: 500),
                //   // textFieldConfiguration: TextFieldConfiguration(
                //   //   controller:
                //   //       serviceController.textEditingControllerDestination,
                //   //   decoration: InputDecoration(
                //   //       focusedBorder: OutlineInputBorder(
                //   //           borderRadius: BorderRadius.circular(100),
                //   //           borderSide: BorderSide.none),
                //   //       enabledBorder: OutlineInputBorder(
                //   //           borderRadius: BorderRadius.circular(100),
                //   //           borderSide: BorderSide.none),
                //   //       contentPadding:
                //   //           const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                //   //       border: OutlineInputBorder(
                //   //           borderRadius: BorderRadius.circular(100),
                //   //           borderSide: BorderSide.none),
                //   //       filled: true,
                //   //       fillColor: greyColor.withOpacity(0.1)),
                //   // ),
                //   suggestionsCallback: (pattern) async {
                //     return await serviceController
                //         .findPlacesNamePrediction(pattern);
                //   },
                //   itemBuilder: (context, PlacePrediction? suggestion) {
                //     final request = suggestion!;
                //     return placePredictionCard(placePrediction: request);
                //   },
                //   // onSuggestionSelected: (PlacePrediction? suggestion) async {
                //   //   final request = suggestion!;
                //   //   await serviceController.getPlaceAddressDetails(
                //   //       placeid: request.placeId, destination: "destination");
                //   // },
                //   errorBuilder: (BuildContext context, error) {
                //     return Container(
                //         padding: const EdgeInsets.all(10),
                //         child: const Text("error Occurred"));
                //   },
                // ),
                const SizedBox(height: 15),
                Center(
                  child: customRoundedButton(
                      title: "Done",
                      bgColor: Colors.black,
                      fgColor: whiteColor, voidCallback: () {
                        if (serviceController.address.value != null &&
                            serviceController.destinationAddress.value !=
                                null) {
                          Navigator.pop(context);
                          Get.to(() => ChatsInbox(
                                uid: uid,
                            userModel: userModel,
                              ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: CommonText(
                                      color: whiteColor,
                                      text: "Please fill all the fields"),
                                  backgroundColor: blackColor));
                        }
                      }),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      });
}
