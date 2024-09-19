import 'package:flutter/material.dart';

import '../../../utils/style.dart';

Widget socialLogin({required String image, required onTap}) {
  return InkWell(
    onTap: () {
      onTap();
    },
    child: Material(
      elevation: 3,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Image.asset(
            image,
            height: 30,
            width: 30,
          ),
        ),
      ),
    ),
  );
}
