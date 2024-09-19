import 'package:flutter/material.dart';
import 'package:plug/utils/style.dart';
import 'package:plug/widgets/common_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
 final Function voidCallback;

  const CustomButton({Key? key, required this.text, required this.voidCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        voidCallback();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: blackColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
            child: CommonText(
          color: whiteColor,
          text: text,
          fontFamily: "RedHatMedium",
        )),
      ),
    );
  }
}
