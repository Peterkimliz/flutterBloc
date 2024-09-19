import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/controllers/bank_controller.dart';
import 'package:plug/widgets/common_text.dart';

import '../../utils/style.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: whiteColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonText(
                        color: greyColor,
                        text: "First Name:",
                        size: 17,
                        fontFamily: "RedHatLight",
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CommonText(
                            color: blackColor,
                            text: Get.find<BankController>()
                                .fetchedBankDetails
                                .value!
                                .firstName
                                .toString()
                                .capitalize!,
                            size: 17),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonText(
                          color: greyColor,
                          text: "Last Name:",
                          size: 17,
                          fontFamily: "RedHatLight"),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CommonText(
                            size: 17,
                            color: blackColor,
                            text: Get.find<BankController>()
                                .fetchedBankDetails
                                .value!
                                .lastName
                                .toString()
                                .capitalize!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      const CommonText(color: greyColor, text: "Country:", size: 17),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CommonText(
                            color: blackColor,
                            text: Get.find<BankController>()
                                .fetchedBankDetails
                                .value!
                                .country!,
                            size: 17),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      const CommonText(
                        color: greyColor,
                        text: "State:",
                        size: 17,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CommonText(
                          color: blackColor,
                          text: Get.find<BankController>()
                              .fetchedBankDetails
                              .value!
                              .state!,
                          size: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonText(
                        color: greyColor,
                        text: "City:",
                        size: 17,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CommonText(
                          color: blackColor,
                          text: Get.find<BankController>()
                              .fetchedBankDetails
                              .value!
                              .city!,
                          size: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CommonText(
                        color: blackColor,
                        text: "Govermet Documents",
                        size: 18,
                      ),
                      const SizedBox(height: 10),
                      const CommonText(
                        color: blackColor,
                        text: "Front image",
                        fontFamily: "RedHatMedium",
                        fontWeight: FontWeight.w100,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: CachedNetworkImage(
                          imageUrl: Get.find<BankController>()
                              .fetchedBankDetails
                              .value!
                              .frontImage!,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          placeholder: (context, url) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const CommonText(
                        color: blackColor,
                        text: "Back image",
                        fontFamily: "RedHatMedium",
                        fontWeight: FontWeight.w100,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: CachedNetworkImage(
                          imageUrl: Get.find<BankController>()
                              .fetchedBankDetails
                              .value!
                              .frontImage!,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          placeholder: (context, url) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          CommonText(color: greyColor, text: "Connected Bank:"),
                          Padding(
                            padding: EdgeInsets.only(left: 3.0),
                            child: CommonText(color: blackColor, text: "Stripe"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const CommonText(color: greyColor, size: 14, text: "Account:"),
                          Expanded(
                            flex: 2,
                            child: CommonText(
                                color: blackColor,
                                size: 17,
                                text:
                                    " ${ Get.find<AuthController>().currentUser.value!.bankName!}"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
