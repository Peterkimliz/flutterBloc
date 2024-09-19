import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/widgets/common_text.dart';

import '../../../utils/style.dart';

class AuthBackgroundContainer extends StatelessWidget {
  const AuthBackgroundContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            color: blueColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(top: 40, left: 10),
                    child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child:
                            const Icon(Icons.clear, color: Colors.white, size: 30))),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                      child: Image.asset("assets/images/logoIcon.png"),
                    ),
                    const SizedBox(width: 10),
                    const CommonText(
                      color: whiteColor,
                      text: "plug",
                      size: 40,
                      fontFamily: "RedHatMedium",
                    )
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              text: 'By signing up. You agree with our ',
              style: const TextStyle(color: Colors.black54),
              children: [
                TextSpan(
                  text: 'Terms & Conditions',
                  recognizer: TapGestureRecognizer(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: yellowColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
