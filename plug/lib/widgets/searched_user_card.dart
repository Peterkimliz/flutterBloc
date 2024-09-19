import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/controllers/user_controller.dart';
import 'package:plugme/models/user.dart';
import 'package:plugme/screens/profile/new_profile.dart';
import 'package:plugme/utils/function.dart';

import '../utils/style.dart';
import 'common_text.dart';

Widget searchedUserWidget(
    {required UserModel userModel, required index, required context}) {
  UserController userController = Get.find<UserController>();
  AuthController authController = Get.find<AuthController>();

  return InkWell(
    onTap: () {
      userController.selectedUser.value = userModel;
      userController.selectedUser.refresh();
      userController.getMarkers(
          userModel.geoPoint!.latitude, userModel.geoPoint!.longitude);
    },
    child: Obx(() => Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
              color: const Color(0XFFF2F2F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: userController.selectedUser.value?.id == userModel.id
                      ? blackColor
                      : Colors.transparent,
                  width: 1)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Get.find<UserController>().currentProfile.value = userModel;
                  Get.to(() => NewProfile());
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(userModel.profileUrl!),
                  radius: 25,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CommonText(
                                fontFamily: "RedHatMedium",
                                color: blackColor,
                                text:
                                    "${userModel.firstname!} ${userModel.lastname!}"
                                        .capitalize!),
                            const SizedBox(
                              width: 3,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "(",
                                  style: TextStyle(color: yellowColor),
                                ),
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                CommonText(
                                  color: yellowColor,
                                  text: userModel.totalRatingCount == 0 ||
                                          userModel.totalRating == 0
                                      ? "0"
                                      : "${num.parse((userModel.totalRating! / userModel.totalRatingCount!).toStringAsExponential(2))},",
                                  fontFamily: "RedHatMedium",
                                ),
                                const Text(
                                  ")",
                                  style: TextStyle(color: yellowColor),
                                ),
                              ],
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.verified,
                              color: userModel.isAccountVerified == true
                                  ? Colors.blueAccent
                                  : greyColor,
                              size: 20,
                            ),
                          ],
                        ),
                        InkWell(
                            onTap: () {
                              Get.find<UserController>().currentProfile.value =
                                  userModel;
                              Get.to(() => NewProfile());
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: yellowColor,
                                  borderRadius: BorderRadius.circular(20)),
                              child: const CommonText(
                                  color: whiteColor, text: "View Profile"),
                            ))
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        CommonText(
                            fontFamily: "RedHatLight",
                            color: greyColor,
                            text: "${userModel.followersCount} Followers"),
                        const SizedBox(width: 5),
                        Container(height: 15, width: 1, color: yellowColor),
                        const SizedBox(width: 5),
                        CommonText(
                          color: greyColor,
                          text: "${userModel.totalJobs} tasks",
                          fontFamily: "RedHatLight",
                        ),
                        const SizedBox(width: 5),
                        Container(height: 15, width: 1, color: yellowColor),
                        const SizedBox(width: 5),
                        CommonText(
                          color: greyColor,
                          text: "${userModel.getTotalRehires()} rehires",
                          fontFamily: "RedHatLight",
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CommonText(
                              text: "\$ ${userModel.pricePerHour}/".capitalize!,
                              color: yellowColor,
                              size: 16,
                            ),
                            const CommonText(
                              text: "hour",
                              color: yellowColor,
                              fontFamily: "RedHatLight",
                              size: 16,
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on_rounded, color: yellowColor),
                            CommonText(
                              color: Colors.grey.shade600,
                              text:
                              "${ authController.currentUser.value==null?0.0:calculateDistance(userModel.geoPoint!.latitude.toInt(), userModel.geoPoint!.longitude.toInt(), authController.currentUser.value?.geoPoint!.latitude.toInt(), authController.currentUser.value?.geoPoint!.longitude.toInt()).toString()} km away",
                              fontFamily: "RedHatLight",
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        )),
  );
}
