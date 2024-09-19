import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/controllers/auth_controller.dart';
import 'package:plug/models/service.dart';
import '../controllers/service_controller.dart';
showServicesDialog(context, bool update) {
  AuthController authController = Get.find<AuthController>();
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return SimpleDialog(
          children: Get.find<ServiceController>()
              .services
              .map((element) => SimpleDialogOption(
                    onPressed: () {
                      ServiceModel serviceOffered = element;
                      authController.selectedService.value = serviceOffered;
                      authController.selectedService.refresh();
                      Get.back();
                      if (authController.selectedService.value != null &&
                          update == true) {
                        authController.updateSingleItem(body: {
                          "service":
                              authController.selectedService.value!.toJson()
                        }, id: FirebaseAuth.instance.currentUser!.uid);
                        authController.currentUser.value!.isServiceProvider =
                            true;
                        authController.updateSingleItem(
                            body: {"isServiceProvider": true},
                            id: FirebaseAuth.instance.currentUser!.uid);
                        authController.currentUser.refresh();
                        authController.selectedService.value = serviceOffered;
                      }
                    },
                    child: Text(element.icon! + element.name!),
                  ))
              .toList(),
        );
      });
}

showSubServicesDialog(
    {required context,
    required List<String> subCategories,
    required bool connect}) {
  AuthController authController = Get.find<AuthController>();
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return SimpleDialog(
          children: subCategories
              .map((element) => SimpleDialogOption(
                    onPressed: () {
                      Get.back();
                      if (connect == true) {
                        authController.selectedService.value!.subCategory =
                            element;
                        authController.selectedService.refresh();
                      } else {
                        authController.selectedService.value!.subCategory =
                            element;
                        authController.selectedService.refresh();

                        authController.updateSingleItem(body: {
                          "service":
                              authController.selectedService.value!.toJson()
                        }, id: FirebaseAuth.instance.currentUser!.uid);
                      }
                    },
                    child: Text(element),
                  ))
              .toList(),
        );
      });
}
