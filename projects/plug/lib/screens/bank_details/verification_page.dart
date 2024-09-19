import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/bank_controller.dart';

import '../../utils/style.dart';
import '../../widgets/common_text.dart';
import '../profile/components/input_field.dart';

class VerificationPage extends StatelessWidget {
  VerificationPage({Key? key}) : super(key: key);

  final String address = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    Get.find<BankController>().assignFields();
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonText(color: blackColor, text: "First Name"),
              const SizedBox(height: 10),
              InputFields(
                textEditingController:
                    Get.find<BankController>().textEditingControllerFirstName,
                hint: "eg.John",
              ),
              const SizedBox(height: 20),
              const CommonText(color: blackColor, text: "Last Name"),
              const SizedBox(height: 10),
              InputFields(
                textEditingController:
                    Get.find<BankController>().textEditingControllerLastName,
                hint: "eg.Doe",
              ),
              const SizedBox(height: 20),
              Obx(() => CSCPicker(
                    showStates: true,
                    flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                    showCities: true,

                    dropdownDecoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    disabledDropdownDecoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: whiteColor,
                        border: Border.all(color: Colors.grey, width: 1)),
                    currentCountry: Get.find<BankController>()
                            .accountCountry
                            .value
                            .isEmpty
                        ? "Country"
                        : Get.find<BankController>().accountCountry.value,
                    currentState:
                        Get.find<BankController>().accountState.value.isEmpty
                            ? "States"
                            : Get.find<BankController>().accountState.value,
                    currentCity:
                        Get.find<BankController>().accountCity.value.isEmpty
                            ? "City"
                            : Get.find<BankController>().accountCity.value,
                    countrySearchPlaceholder: "Country",
                    stateSearchPlaceholder: "State",
                    citySearchPlaceholder: "City",
                    countryDropdownLabel: "Country",
                    stateDropdownLabel: "State",
                    cityDropdownLabel: "City",
                    dropdownDialogRadius: 10.0,
                    searchBarRadius: 10.0,
                    onCountryChanged: (value) {
                      Get.find<BankController>().accountCountry.value = value;
                    },
                    onStateChanged: (value) {
                      if (value != null) {
                        Get.find<BankController>().accountState.value = value;
                      }
                    },
                    onCityChanged: (value) {
                      if (value != null) {
                        Get.find<BankController>().accountCity.value = value;
                      }
                    },
                  )),
              const SizedBox(height: 15),
              const CommonText(color: blackColor, text: "Government Documents"),
              const SizedBox(height: 15),
              const CommonText(
                color: blackColor,
                text: "Front Page",
                fontFamily: "RedHatMedium",
                fontWeight: FontWeight.w100,
              ),
              const SizedBox(height: 5),
              InkWell(
                onTap: () {
                  Get.find<BankController>()
                      .pickImage(type: "front", context: context);
                },
                child: DottedBorder(
                  color: yellowColor,
                  strokeWidth: 1,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(10),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(() {
                      return Get.find<BankController>().frontImage?.value !=
                          null
                          ? SizedBox(
                        width: 150,
                        height: 200,
                        child: Image.file(
                          File(Get.find<BankController>()
                              .frontImage!
                              .value!
                              .path),
                          fit: BoxFit.cover,
                        ),
                      )
                          : Get.find<BankController>()
                          .fetchedBankDetails
                          .value
                          ?.frontImage !=
                          null
                          ? SizedBox(
                          width: 150,
                          height: 200,
                          child: CachedNetworkImage(
                            imageUrl: Get.find<BankController>()
                                .fetchedBankDetails
                                .value!
                                .frontImage!,
                            imageBuilder: (context, imageProvider) =>
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            placeholder: (context, url) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )

                        // Image.network(
                        //   "${Get.find<BankController>().fetchedBankDetails.value!.backImage}",
                        //   fit: BoxFit.cover,
                        // ),
                      )
                          : const Center(
                          child: Icon(Icons.cloud_upload_sharp,
                              size: 100));
                    }),
                  ),
                ),
              ),


              const SizedBox(height: 15),
              const CommonText(
                color: blackColor,
                text: "Back Page",
                fontFamily: "RedHatMedium",
                fontWeight: FontWeight.w100,
              ),
              const SizedBox(height: 5),

              InkWell(
                onTap: () {
                  Get.find<BankController>()
                      .pickImage(type: "back", context: context);
                },
                child: DottedBorder(
                  color: yellowColor,
                  strokeWidth: 1,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(10),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:  Obx(() {
                      return Get.find<BankController>().backImage?.value != null
                          ? SizedBox(
                        width: 150,
                        height: 200,
                        child: Image.file(
                          File(Get.find<BankController>()
                              .backImage!
                              .value!
                              .path),
                          fit: BoxFit.cover,
                        ),
                      )
                          : Get.find<BankController>()
                          .fetchedBankDetails
                          .value
                          ?.backImage !=
                          null
                          ? SizedBox(
                          width: 150,
                          height: 200,
                          child: CachedNetworkImage(
                            imageUrl: Get.find<BankController>()
                                .fetchedBankDetails
                                .value!
                                .backImage!,
                            imageBuilder: (context, imageProvider) =>
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            placeholder: (context, url) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )

                        // Image.network(
                        //   "${Get.find<BankController>().fetchedBankDetails.value!.backImage}",
                        //   fit: BoxFit.cover,
                        // ),
                      )
                          : const Center(
                          child: Icon(Icons.cloud_upload_sharp,
                              size: 100));
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
