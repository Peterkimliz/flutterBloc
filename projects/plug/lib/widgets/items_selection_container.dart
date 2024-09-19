import 'package:flutter/material.dart';

import '../utils/style.dart';
import 'common_text.dart';

class ItemSelectionContainer extends StatelessWidget {
  final VoidCallback voidCallback;
  final String text;
  final bool? changeVerticalPadding;

  const ItemSelectionContainer(
      {Key? key,
      required this.voidCallback,
      required this.text,
      this.changeVerticalPadding = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        voidCallback();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: 20, vertical: changeVerticalPadding == true ? 6 : 10),
        decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: greyColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              color: blackColor.withOpacity(0.7),
              text: text,
              fontFamily: "RedHatLight",
            ),
            const Icon(
              Icons.arrow_drop_down_outlined,
              color: yellowColor,
              size: 25,
            )
          ],
        ),
      ),
    );
  }
}
