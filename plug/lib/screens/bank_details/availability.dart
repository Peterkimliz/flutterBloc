import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/controllers/user_controller.dart';

import '../../utils/style.dart';
import '../../widgets/common_text.dart';
import '../../widgets/items_selection_container.dart';
import '../../widgets/service_popup.dart';

class Availability extends StatelessWidget {
  Availability({Key? key}) : super(key: key);
  final UserController userController = Get.find<UserController>();
final  AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            color: blackColor,
            text: "Service Offered",
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CommonText(
                color: greyColor,
                text: "",
              ),
              Obx(() => ItemSelectionContainer(
                    text: authController.selectedService.value == null
                        ? "Select Service"
                        : authController.selectedService.value!.icon! + authController.selectedService.value!.name!,
                    voidCallback: () {
                      showServicesDialog(context, false);
                    },
                  )),
            ],
          ),
          const SizedBox(height: 15),
          Obx(() {
            return authController.selectedService.value != null &&
                    authController
                        .selectedService.value!.subcategory!.isNotEmpty
                ? Column(
                    children: [
                      ItemSelectionContainer(
                        text: authController
                                    .selectedService.value?.subCategory!
                                    .trim()
                                    .isEmpty ==
                                true
                            ? "Select  SubService"
                            : "${authController.selectedService.value?.subCategory}",
                        voidCallback: () {
                          showSubServicesDialog(
                              context: context,
                              subCategories: authController
                                  .selectedService.value!.subcategory!,
                              connect: true);
                        },
                      ),
                      const SizedBox(height: 15),
                    ],
                  )
                : Container(
                    height: 0,
                  );
          }),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CommonText(
                  color: blackColor,
                  text: "Rate per Hour",
                ),
                const SizedBox(height: 5),
                TextFormField(
                  controller: authController.textEditingControllerRate,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {}
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "please fill this field";
                    }
                    return null;
                  },
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(width: 1, color: greyColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(width: 1, color: greyColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(width: 1, color: greyColor),
                      ),
                      filled: true,
                      fillColor: whiteColor),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const CommonText(
            color: blackColor,
            text: "Availability",
            fontFamily: "RedHatMedium",
          ),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: userController.daysOfTheWeek
                .map((e) => InkWell(
                      onTap: () {
                        var index = userController.selectedDays
                            .indexWhere((element) => element == e);
                        if (index == -1) {
                          userController.selectedDays.add(e);
                          userController.selectedDays.refresh();
                        } else {
                          userController.selectedDays
                              .removeWhere((element) => element == e);
                          userController.selectedDays.refresh();
                        }
                      },
                      child: Obx(() => Chip(
                            backgroundColor: userController.selectedDays
                                        .indexWhere(
                                            (element) => element == e) ==
                                    -1
                                ? lightGrey
                                : const Color(0XFF8C90F3),
                            label: CommonText(
                                text: "$e",
                                color: userController.selectedDays.indexWhere(
                                            (element) => element == e) ==
                                        -1
                                    ? const Color(0XFF121212)
                                    : whiteColor,
                                fontFamily: "RedHatLight"),
                          )),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

}
