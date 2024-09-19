import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:plug/controllers/user_controller.dart';
import 'package:plug/models/rating.dart';
import 'package:plug/models/user.dart';
import 'package:plug/models/work.dart';
import '../../controllers/service_controller.dart';
import '../../utils/function.dart';
import '../../utils/style.dart';
import '../../widgets/common_text.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/job_button_card.dart';
import '../profile/components/image_container.dart';

class JobListPage extends StatelessWidget {
  JobListPage({Key? key}) : super(key: key);
  final UserController userController = Get.put(UserController());
  final ServiceController serviceController = Get.put(ServiceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const CommonText(
            color: blackColor,
            text: "Tasks",
            size: 20,
          ),
          elevation: 0.3,
        ),
        body: SafeArea(
          child: Obx(() {
            return Get.find<ServiceController>().fetchingJobs.value
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Get.find<ServiceController>().myJobs.isEmpty
                    ? const Center(
                        child: CommonText(
                          text: "No available job history",
                          color: Colors.black,
                        ),
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 5),
                          Expanded(
                            child: ListView.builder(
                                itemCount:
                                    Get.find<ServiceController>().myJobs.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  Work work = Get.find<ServiceController>()
                                      .myJobs
                                      .elementAt(index);
                                  return InkWell(
                                    onTap: () async {
                                      Get.defaultDialog(
                                          title: "Just a moment",
                                          content:
                                              const CircularProgressIndicator(),
                                          barrierDismissible: false);
                                      try {
                                        String? id = work.provider!.id ==
                                                FirebaseAuth
                                                    .instance.currentUser!.uid
                                            ? work.userId!.id
                                            : work.provider!.id;
                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(id)
                                            .get()
                                            .then((value) {
                                          UserModel userModel = UserModel();
                                          Rating ratings = Rating();
                                          userModel = UserModel.fromJson(value
                                              .data() as Map<String, dynamic>);
                                          FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(id)
                                              .collection("ratings")
                                              .doc(work.provider!.id !=
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid
                                                  ? work.userId!.id
                                                  : work.provider!.id)
                                              .get()
                                              .then((value) {
                                            ratings = Rating.fromJson(
                                                value.data()
                                                    as Map<String, dynamic>);
                                            showJobsBottomSheet(context, work,
                                                userModel, ratings.message);
                                          });
                                        });
                                        Get.back();
                                      } catch (e) {
                                        Get.back();

                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      margin: const EdgeInsets.only(
                                          bottom: 10, left: 10, right: 10),
                                      decoration: BoxDecoration(
                                          color: greyColor.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              CommonText(
                                                color: blackColor,
                                                text:
                                                    work.provider!.service!.name!
                                                        .capitalize!
                                                        .capitalize!,
                                                size: 16,
                                              ),
                                              CommonText(
                                                color: Colors.black,
                                                text:
                                                    DateFormat("MMM dd yyyy").format(work.time!)
                                                        .capitalize!
                                                        .capitalize!,
                                                size: 16,
                                                fontFamily: "RedHatLight",
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: whiteColor,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    profileImage(
                                                        upload: true,
                                                        showCam: false,
                                                        radi: 14,
                                                        context: context,
                                                        imageProvider: work
                                                                    .provider!
                                                                    .profileUrl ==
                                                                null
                                                            ? const AssetImage(
                                                                "assets/images/profile.png")
                                                            : NetworkImage(
                                                                    work.provider!.profileUrl ?? "")
                                                                as ImageProvider),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    CommonText(
                                                        color: blackColor,
                                                        text: work.provider!
                                                                    .id ==
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid
                                                            ? work.userId!.firstname!
                                                            : work.provider!.firstname!,
                                                        size: 16,
                                                        fontFamily:
                                                            "RedHatMedium",
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    const Spacer(),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 15,
                                                              vertical: 5),
                                                      decoration: BoxDecoration(
                                                          color: work.status ==
                                                                  "pending"
                                                              ? Colors.amber
                                                              : Colors.green,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30)),
                                                      child: CommonText(
                                                        color: whiteColor,
                                                        text: work.status
                                                            .toString()
                                                            .capitalize!,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Row(
                                                  children: [
                                                    jobBottomCard(
                                                        widget: Center(
                                                          child: CommonText(
                                                            color: blackColor,
                                                            text:
                                                                "${work.price}\$",
                                                            size: 12,
                                                            fontFamily:
                                                                "RedHatMedium",
                                                          ),
                                                        ),
                                                        bgColor: lightGrey),
                                                    Expanded(
                                                        child: jobBottomCard(
                                                            widget: Center(
                                                              child: Row(
                                                                children: [
                                                                  CommonText(
                                                                    color:
                                                                        blackColor,
                                                                    text: work.workType!
                                                                        .capitalize!,
                                                                    size: 12,
                                                                    fontFamily:
                                                                        "RedHatMedium",
                                                                  ),
                                                                  const CommonText(
                                                                    color:
                                                                        blackColor,
                                                                    text:
                                                                        " Work Type",
                                                                    size: 12,
                                                                    fontFamily:
                                                                        "RedHatLight",
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            bgColor:
                                                                lightGrey)),
                                                    Container(
                                                      padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 15,
                                                          vertical: 5),
                                                      decoration: BoxDecoration(
                                                          color:blueColor,
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              30)),
                                                      child: CommonText(
                                                        color: whiteColor,
                                                        text:work.rateType
                                                            .toString()
                                                            .capitalize!,
                                                      ),
                                                    ),
                                                    // Expanded(
                                                    //   flex: 2,
                                                    //   child: jobBottomCard(
                                                    //       bgColor: lightGrey,
                                                    //       widget: Center(
                                                    //         child: Row(
                                                    //           children: [
                                                    //             CommonText(
                                                    //               color:
                                                    //                   blackColor,
                                                    //               text:
                                                    //                   "${work.rateType}",
                                                    //               size: 12,
                                                    //               fontfamily:
                                                    //                   "RedHatMedium",
                                                    //             ),
                                                    //           ],
                                                    //         ),
                                                    //       )),
                                                    // )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ],
                      );
          }),
        ));
  }

  showJobsBottomSheet(
      BuildContext context, Work work, UserModel userModel, message) {
    return showBottomSheet(
        context: context,
        enableDrag: true,
        backgroundColor: const Color(0XFFF2F2F2),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        builder: (_) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
                initialChildSize: 0.9,
                expand: false,
                builder: (BuildContext productContext,
                    ScrollController scrollController) {
                  return SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: userModel.profileUrl!.isEmpty
                                              ? const DecorationImage(
                                                  image: AssetImage(
                                                      "assets/images/profile.png"),
                                                  fit: BoxFit.cover)
                                              : DecorationImage(
                                                  image: NetworkImage(
                                                      userModel.profileUrl!),
                                                  fit: BoxFit.cover)),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CommonText(
                                          color: blackColor,
                                          text: userModel.firstname!
                                              .capitalize!,
                                          size: 16,
                                          fontFamily: "RedHatMedium",
                                          fontWeight: FontWeight.bold,
                                        ),
                                        const SizedBox(height: 5),
                                        CommonText(
                                          color: blackColor,
                                          text:
                                              userModel.service?.name ?? '',
                                          size: 12,
                                          fontFamily: "RedHatLight",
                                          fontWeight: FontWeight.bold,
                                        )
                                      ],
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {},
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.yellow,
                                          ),
                                          CommonText(
                                            color: greyColor,
                                            text: userModel.totalRatingCount ==
                                                        0 ||
                                                    userModel.totalRating == 0
                                                ? "0"
                                                : "${num.parse((userModel.totalRating! / userModel.totalRatingCount!).toStringAsExponential(2))}",
                                            size: 12,
                                            fontFamily: "RedHatLight",
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: blackColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 5),
                                    CommonText(
                                      color: blackColor,
                                      text: "${userModel.address}",
                                      size: 12,
                                      fontFamily: "RedHatMedium",
                                      fontWeight: FontWeight.bold,
                                    )
                                  ],
                                ),
                                if (work.pickUp?.name != null)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 20),
                                      const CommonText(
                                        color: greyColor,
                                        text: "Pickup Location",
                                        size: 12,
                                        fontFamily: "RedHatLight",
                                      ),
                                      const SizedBox(height: 5),
                                      CommonText(
                                        color: blackColor,
                                        text: "${work.pickUp?.name!}",
                                        size: 14,
                                        fontFamily: "RedHatLight",
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 20),
                                          const CommonText(
                                            color: greyColor,
                                            text: "Dropoff Location",
                                            size: 12,
                                            fontFamily: "RedHatLight",
                                          ),
                                          const SizedBox(height: 5),
                                          CommonText(
                                            color: blackColor,
                                            text: work.destination!.name!,
                                            size: 14,
                                            fontFamily: "RedHatLight",
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 20),
                                const CommonText(
                                  color: greyColor,
                                  text: "Time Arrival",
                                  size: 12,
                                  fontFamily: "RedHatLight",
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.watch_later_outlined,
                                      color: blackColor,
                                    ),
                                    const SizedBox(width: 3),
                                    CommonText(
                                      color: blackColor,
                                      text:
                                          DateFormat("hh:mm a").format(work.arrivalTime!),
                                      size: 14,
                                      fontFamily: "RedHatLight",
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const CommonText(
                                  color: greyColor,
                                  text: "Time of Completion",
                                  size: 12,
                                  fontFamily: "RedHatLight",
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.watch_later_outlined,
                                      color: blackColor,
                                    ),
                                    const SizedBox(width: 3),
                                    CommonText(
                                      color: blackColor,
                                      text: work.completionTime == null
                                          ? ""
                                          : DateFormat("hh:mm a").format(work.completionTime!),
                                      size: 14,
                                      fontFamily: "RedHatLight",
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const CommonText(
                                  color: greyColor,
                                  text: "Review",
                                  size: 12,
                                  fontFamily: "RedHatLight",
                                ),
                                const SizedBox(height: 5),
                                CommonText(
                                  color: blackColor,
                                  text: message,
                                  size: 14,
                                  fontFamily: "RedHatLight",
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            width: double.infinity,
                            color: whiteColor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CommonText(
                                    color: greyColor,
                                    text:
                                        DateFormat("dd MM yyyy hh:mm a").format(work.time!),
                                    // text: "24 Nov 2022 07:51 PM",
                                    size: 12,
                                    fontFamily: "RedHatLight"),
                                CommonText(
                                  color: blackColor,
                                  text: "\$${work.price! + 0.03}",
                                  size: 24,
                                  fontFamily: "RedHatMedium",
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          Center(
                            child: SizedBox(
                              width: 200,
                              child: CustomButton(
                                  text: "View Receipt",
                                  voidCallback: () {
                                    Get.back();
                                    showReceiptBottomSheet(
                                        context, work, userModel);
                                  }),
                            ),
                          )
                        ]),
                  );
                });
          });
        });
  }
}
