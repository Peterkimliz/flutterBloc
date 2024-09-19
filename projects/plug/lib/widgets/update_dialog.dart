import 'package:flutter/material.dart';

import '../utils/style.dart';
import 'common_text.dart';

updateDialog({required title,required context}){
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 10),
                CommonText(
                    color: blackColor, text:title)
              ],
            ),
          ),
        );
      });
}