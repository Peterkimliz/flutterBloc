import 'package:flutter/material.dart';

class CommonText extends StatelessWidget {
  final Color color;
  final String text;
  final String ?fontFamily;
  final  double?size ;
  final FontWeight? fontWeight;

   const CommonText(
      {Key? key,
      required this.color,
      required this.text,
      this.size=14.0,
      this.fontWeight,this.fontFamily=""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,

      style: TextStyle(

          color: color,
          fontSize: size,
          fontFamily: fontFamily,
          fontWeight: fontWeight ?? FontWeight.w700),
    );
  }
}
