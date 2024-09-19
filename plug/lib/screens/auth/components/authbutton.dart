import 'package:flutter/material.dart';

import '../../../utils/style.dart';
import '../../../widgets/common_text.dart';

Widget authButton({required title,required callBack,required context}){
  return   ElevatedButton(
      onPressed: () {
        callBack();
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: yellowColor,
          minimumSize: Size(
              MediaQuery.of(context).size.width, 20),
          padding: const EdgeInsets.symmetric(
              horizontal: 50, vertical: 15),
          textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold)),
      child: CommonText(
          color: whiteColor,
          text: "$title".toUpperCase()));
}