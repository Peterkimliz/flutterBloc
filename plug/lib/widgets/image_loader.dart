import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget imageLoader({required height,required width}){
  return SizedBox(
    width: height,
    height:width,
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10)
        ),
      ),
    ),
  );
}