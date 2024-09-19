import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/utils/style.dart';

import 'controllers/service_controller.dart';

class LocationAllow extends StatefulWidget {
  const LocationAllow({Key? key}) : super(key: key);

  @override
  State<LocationAllow> createState() => _LocationAllowState();
}

class _LocationAllowState extends State<LocationAllow> {
  final ServiceController serviceController = Get.find<ServiceController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Image.asset(
            "assets/images/logo.png",
            color: blueColor,
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              serviceController.checkLocationEnabled();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), color: blueColor),
              child: const Text(
                "Allow Location",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: const Center(
              child: Text(
                "plug will access your location only when using the app and its only to show distance between you and the provider or the service provider",
                style: TextStyle(fontSize: 16, height: 1.2),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Spacer()
        ],
      ),
    );
  }
}
