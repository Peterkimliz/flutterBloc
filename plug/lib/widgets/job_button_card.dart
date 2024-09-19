import 'package:flutter/material.dart';

import '../utils/style.dart';

Widget jobBottomCard({required Widget widget,Color? bgColor}) {
  return Padding(
    padding: const EdgeInsets.only(right: 10.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
          color:bgColor ?? whiteColor, borderRadius: BorderRadius.circular(20)),
      child: widget,
    ),
  );
}