import 'package:flutter/material.dart';

import '../utils/style.dart';
import 'common_text.dart';

Widget pendingWidget(){
  return Container(
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: const Color(0XFFFDF39A),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Center(
      child: Row(
        children: [
          Icon(
            Icons.watch_later_outlined,
            size: 18,
            color: blackColor,
          ),
          SizedBox(width: 5),
          CommonText(
            color: blackColor,
            text:  "Pending",
            size: 16,
            fontFamily:  "RedHatMedium",
            fontWeight: FontWeight.w400,
          )
        ],
      ),
    ),
  );
}