import 'package:flutter/material.dart';

import '../../../utils/style.dart';

class InputFields extends StatelessWidget {
  final String hint;
  final bool checkValidity;
  final TextEditingController textEditingController;

  const InputFields(
      {Key? key,
      required this.hint,
      required this.textEditingController,
      this.checkValidity = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      validator: checkValidity == false
          ? (value) {
              return null;
            }
          : (value) {
              if (value == null || value.isEmpty) {
                return "please fill this field";
              }
              return null;
            },
      decoration: InputDecoration(
          hintText: hint,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                width: 1,
                color: greyColor
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                width: 1,
                color: greyColor
              )),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                width: 1,
                color: greyColor
              )),
          filled: true,
          fillColor: whiteColor),
    );
  }
}
