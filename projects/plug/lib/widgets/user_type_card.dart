import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:plug/models/user.dart';

import '../utils/style.dart';
import 'common_text.dart';

class UserTypeCard extends StatelessWidget {
  final UserModel user;

  const UserTypeCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: double.infinity,
      padding:const  EdgeInsets.all(10),
      margin:const  EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
          color: greyColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    user.profileUrl!.isEmpty
                        ? const CircleAvatar(
                            backgroundImage:
                               AssetImage("assets/images/profile.png"),
                            radius: 40,
                          )
                        :  CircleAvatar(
                            backgroundImage: NetworkImage(
                              "${user.profileUrl}",
                            ),
                          ),
                   const SizedBox(
                      width: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CommonText(
                                color: blackColor,
                                fontWeight: FontWeight.bold,
                                text:
                                    "${user.firstname}".toString().capitalize!),
                            const Icon(
                              Icons.star,
                              color: lightAmber,
                            ),
                            const CommonText(color: blackColor, text: "4.5"),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Row(
                          children: [
                            CommonText(
                                color: blackColor,
                                fontWeight: FontWeight.bold,
                                text: "3km"),
                            CommonText(color: blackColor, text: " from you"),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(30)),
                      child: const Row(
                        children: [
                          CommonText(
                            color: blackColor,
                            text: "30\$/",
                            size: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          CommonText(
                            color: blackColor,
                            text: "hour",
                            size: 12,
                          )
                        ],
                      ),
                    ),
                   const SizedBox(width: 5),
                    Container(
                      padding:
                         const  EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(30)),
                      child: Expanded(
                        child: Row(
                          children: [
                            CommonText(
                              color: blackColor,
                              text: "${user.service}".toString().capitalize!,
                              size: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            const CommonText(
                              color: blackColor,
                              text: "Work Type",
                              size: 12,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
               const SizedBox(height: 10),
                const Row(
                  children: [
                    CommonText(
                      color: blackColor,
                      text: "See More",
                      fontWeight: FontWeight.bold,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: blackColor,
                    )
                  ],
                )
              ],
            ),
          ),
        const  SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: blackColor),
                child: const Center(
                  child: Icon(
                    Ionicons.chatbubble_ellipses,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
