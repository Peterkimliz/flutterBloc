import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/user_controller.dart';
import 'package:plug/models/rating.dart';
import 'package:plug/utils/style.dart';
import 'package:plug/widgets/common_text.dart';

import 'image_container.dart';

Widget reviewsCard({required context, required Rating rating}) {
  UserController userController = Get.find<UserController>();
  return Container(
    margin: const EdgeInsets.only(bottom: 5),
    padding: const EdgeInsets.all(3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            profileImage(
                upload: false,
                showCam: false,
                radi: 25,
                context: context,
                imageProvider: rating.profileImage == null
                    ? const AssetImage("assets/images/profile.png")
                    : NetworkImage("${rating.profileImage}") as ImageProvider),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CommonText(
                        text: rating.username!,
                        color: Colors.black,
                        size: 17,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: blackColor, width: 1)),
                        child:
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: CommonText(
                                text: "${rating.rating}",
                                color: blackColor,
                                size: 18,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  if ((userController.currentProfile.value!.id ==
                          FirebaseAuth.instance.currentUser!.uid) ||
                      (userController.currentProfile.value!.id !=
                              FirebaseAuth.instance.currentUser!.uid &&
                          userController.currentProfile.value!.showComments ==
                              true))
                    CommonText(
                      color: greyColor,
                      text: rating.message!,
                    )
                ],
              ),
            )
          ],
        ),
      ],
    ),
  );
}
