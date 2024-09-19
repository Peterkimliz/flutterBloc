import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/models/user.dart';
import 'package:plug/screens/profile/components/image_container.dart';
import 'package:plug/screens/profile/new_profile.dart';
import 'package:plug/utils/style.dart';
import 'package:plug/widgets/common_text.dart';

import '../../../controllers/user_controller.dart';
import '../../../widgets/job_button_card.dart';

class FeaturedCard extends StatelessWidget {
  final UserModel userModel;
  const FeaturedCard({Key? key, required this.userModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: MediaQuery.of(context).size.width * 0.9,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.find<UserController>().getCurrentUser(userModel.id);
                      Get.find<UserController>().currentProfile.value =
                          userModel;
                      Get.to(() => NewProfile());
                    },
                    child: profileImage(
                        upload: false,
                        showCam: false,
                        radi: 25,
                        context: context,
                        imageProvider: userModel.profileUrl == null
                            ? const AssetImage("assets/images/profile.png")
                            : NetworkImage("${userModel.profileUrl}")
                                as ImageProvider),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        color: blackColor,
                        text: userModel.firstname.toString(),
                        size: 18,
                        fontFamily: "RedHatMedium",
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      CommonText(
                        color: greyColor,
                        size: 12,
                        text: "${userModel.totalJobs.toString()} Jobs",
                        fontFamily: "RedHatLight",
                      ),
                    ],
                  )
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: CommonText(
                      text: userModel.totalRating == 0
                          ? "0.0"
                          : (userModel.totalRating! /
                                  userModel.totalRatingCount!)
                              .toStringAsFixed(1),
                      color: greyColor,
                      size: 14,
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          Row(
            children: [
              jobBottomCard(
                  bgColor: lightGrey,
                  widget: Center(
                    child: Row(
                      children: [
                        CommonText(
                          color: blackColor,
                          text: "${userModel.pricePerHour}\$",
                          size: 14,
                          fontFamily: "RedHatMedium",
                        ),
                        const CommonText(
                          color: blackColor,
                          text: "/hour",
                          size: 14,
                          fontFamily: "RedHatLight",
                        )
                      ],
                    ),
                  )),
              jobBottomCard(
                  bgColor: lightGrey,
                  widget: Center(
                    child: Row(
                      children: [
                        CommonText(
                          color: blackColor,
                          text: "${userModel.service!.name}".capitalize!,
                          size: 14,
                          fontFamily: "RedHatMedium",
                        ),
                        const CommonText(
                          color: blackColor,
                          text: " Work Type",
                          size: 14,
                          fontFamily: "RedHatLight",
                        )
                      ],
                    ),
                  )),
            ],
          )
        ],
      ),
    );
  }
}
