import 'package:flutter/material.dart';

import '../utils/style.dart';

Widget completedWidget({IconData? iconData, Color? color}) {
  return Container(
    padding: const EdgeInsets.all(7),
    decoration: BoxDecoration(
      color: color ?? Colors.green,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Center(
      child: Icon(
        iconData ?? Icons.check_circle_outline,
        size: 15,
        color: whiteColor,
      ),
    ),
  );
}