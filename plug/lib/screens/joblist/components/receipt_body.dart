import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plugme/models/user.dart';
import 'package:plugme/models/work.dart';

import '../../../utils/style.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/completed_widget.dart';
import '../../../widgets/pending_widget.dart';

class ReceiptBody extends StatelessWidget {
  final UserModel userModel;
  final Work work;
   const ReceiptBody({Key? key, required this.userModel,required this.work}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: userModel.profileUrl!.isEmpty
                        ? const DecorationImage(
                        image: AssetImage(
                            "assets/images/profile.png"),
                        fit: BoxFit.cover)
                        : DecorationImage(
                        image:
                        NetworkImage(userModel.profileUrl!),
                        fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      color: blackColor,
                      text:
                      userModel.firstname.toString().capitalize!,
                      size: 16,
                      fontFamily: "RedHatMedium",
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 5),
                    CommonText(
                      color: blackColor,
                      text: userModel.service?.name!
                          .toString()
                          .capitalize ??
                          "",
                      size: 12,
                      fontFamily: "RedHatLight",
                    )
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.yellow,
                    ),
                    CommonText(
                      color: greyColor,
                      text: userModel.totalRatingCount == 0 ||
                          userModel.totalRating == 0
                          ? "0"
                          : "${num.parse((userModel.totalRating! / userModel.totalRatingCount!).toStringAsExponential(2))}",
                      size: 12,
                      fontFamily: "RedHatLight",
                    ),
                  ],
                )
              ],
            ),
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: Container(
                  width: work.status == "pending" ? 100 : 50,
                  margin: const EdgeInsets.only(right: 10),
                  child: Center(
                      child: work.status == "pending"
                          ? pendingWidget()
                          : completedWidget()))),
          const SizedBox(height: 20),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            width: double.infinity,
            color: const Color(0XFFF2F2F2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CommonText(
                  color: blackColor,
                  text: "Total",
                  fontFamily: "RedHatLight",
                  size: 14,
                ),
                CommonText(
                  color: blackColor,
                  text: "\$${work.price!+0.03}",
                  size: 24,
                  fontFamily: "RedHatMedium",
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommonText(
                  color: greyColor,
                  text: "Service",
                  size: 12,
                  fontFamily: "RedHatLight",
                ),
                const SizedBox(height: 5),
                CommonText(
                  color: blackColor,
                  text: "${work.workType}",
                  size: 14,
                  fontFamily: "RedHatLight",
                ),
                const SizedBox(height: 20),
                const CommonText(
                  color: greyColor,
                  text: "Offer Amount",
                  size: 12,
                  fontFamily: "RedHatLight",
                ),
                const SizedBox(height: 5),
                CommonText(
                  color: blackColor,
                  text: "\$${work.price!}",
                  size: 12,
                  fontFamily: "RedHatLight",
                ),
                const SizedBox(height: 20),
                const CommonText(
                  color: greyColor,
                  text: "Flat Fee / Hourly",
                  size: 12,
                  fontFamily: "RedHatLight",
                ),
                const SizedBox(height: 5),
                const CommonText(
                  color: blackColor,
                  text: "\$5",
                  size: 14,
                  fontFamily: "RedHatLight",
                ),
                const SizedBox(height: 20),
                const CommonText(
                  color: greyColor,
                  text: "Total Hours",
                  size: 12,
                  fontFamily: "RedHatLight",
                ),
                const SizedBox(height: 5),
                CommonText(
                  color: blackColor,
                  text: "${work.hours}",
                  size: 14,
                  fontFamily: "RedHatLight",
                ),
                const SizedBox(height: 20),
                const CommonText(
                  color: greyColor,
                  text: "Service Fee (10%)",
                  size: 12,
                  fontFamily: "RedHatLight",
                ),
                const SizedBox(height: 5),
                const CommonText(
                  color: blackColor,
                  text: "\$90",
                  size: 14,
                  fontFamily: "RedHatLight",
                ),
                const SizedBox(height: 20),
                const CommonText(
                  color: greyColor,
                  text: "Sub Total",
                  size: 12,
                  fontFamily: "RedHatLight",
                ),
                const SizedBox(height: 5),
                CommonText(
                    color: blackColor,
                    text: "\$${work.price!+0.03}",
                    size: 14,
                    fontFamily: "RedHatLight")
              ],
            ),
          ),
        ]);
  }
}
