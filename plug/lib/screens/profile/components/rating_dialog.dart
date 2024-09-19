import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:plugme/controllers/user_controller.dart';
import 'package:plugme/models/chat.dart';
import 'package:plugme/models/user.dart';
import 'package:plugme/utils/style.dart';
import 'package:plugme/widgets/common_text.dart';
import 'package:plugme/widgets/custom_roundedbutton.dart';

showRatingDialog(
    {required context,
    required type,
    required uid,
    required UserModel userModel,
    required Chat chatData}) {
 final UserController userController = Get.find<UserController>();
  return showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            height:400,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                CommonText(
                    color: blackColor,
                    text: "Review ${type == "sender" ? "Provider" : "Client"}",
                    size: 25),
                const SizedBox(height: 20),
                const CommonText(
                  color: blackColor,
                  text: "How was your experience?",
                  fontFamily: "RedHatLight",
                  size: 16,
                ),
                const SizedBox(height: 10),
                RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    userController.ratingValue.value = rating;
                  },
                ),
                const SizedBox(height: 10),
                CommonText(
                  color: blackColor,
                  text: "Say something about the ${type == "sender" ? "provider" : "client"}",
                  fontFamily: "RedHatLight",
                  size: 16,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: userController.textEditingMessage,
                  minLines: 4,
                  maxLines: 12,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey, width: 1)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey, width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.grey, width: 1)),
                      hintText: "",
                      fillColor: greyColor.withOpacity(0.1),
                      filled: true),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: customRoundedButton(
                          voidCallback: () {
                            Get.back();
                          },
                          title: "Cancel",
                          bgColor: greyColor,
                          fgColor: whiteColor),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: customRoundedButton(
                          voidCallback: () {
                            Get.back();
                            if (userController
                                .textEditingMessage.text.isNotEmpty) {
                              userController.rateUser(
                                  message:
                                      userController.textEditingMessage.text,
                                  rateValue:
                                      userController.ratingValue.value.round(),
                                  type: type,
                                  chatData: chatData,
                                  uid: uid,
                                  userModel: userModel);
                            }
                          },
                          title: "Submit",
                          bgColor: Colors.amber,
                          fgColor: whiteColor),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      });
}
