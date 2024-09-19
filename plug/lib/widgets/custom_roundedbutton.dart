import 'package:flutter/material.dart';
import 'common_text.dart';

Widget customRoundedButton(
    {required title,
    required bgColor,
    required fgColor,
    FontWeight? fontWeight,
     String? fontfamily,
      double?fontSize,
    required VoidCallback voidCallback}) {
  return InkWell(
    onTap: () {
      voidCallback();
    },
    child: Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(horizontal:10, vertical: 8),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: CommonText(
          color: fgColor,
          text: title,
          size: fontSize ?? 14,
          fontWeight: fontWeight,
          fontFamily:fontfamily ?? "RedHatMedium",
        ),
      ),
    ),
  );
}
