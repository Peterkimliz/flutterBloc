import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/models/user.dart';

import '../../../utils/style.dart';
import '../../../widgets/common_text.dart';

Widget usersOnMapWidget({required UserModel userModel}) {
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
        color: whiteColor, borderRadius: BorderRadius.circular(20)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage(
            "${userModel.profileUrl}",
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                  color: blackColor,
                  text: "${userModel.firstname}".capitalize!,
                  size: 16,
                  fontFamily: "RedHatMedium",
                  fontWeight: FontWeight.bold),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amberAccent,
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  CommonText(
                    color: greyColor,
                    text:
                        "${userModel.totalRating! / userModel.totalRatingCount!}",
                    fontFamily: "RedHatLight",
                  )
                ],
              )
            ],
          ),
        )
      ],
    ),
  );
}
