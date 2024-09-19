import 'package:flutter/material.dart';
import 'package:plugme/utils/function.dart';


Widget profileImage(
    {required ImageProvider imageProvider, required context,required upload,bool? showCam=true, double? radi}) {
  return Center(
    child: Stack(
      children: [
        CircleAvatar(
          radius:radi ?? 60,
          backgroundImage: imageProvider,
        ),
        if (showCam!)
        Positioned(
          right: 0,
          bottom: 0,
          child: InkWell(
            onTap: () {
              showImageDialogPop(context: context, upload: upload);
            },
            child: const CircleAvatar(
              backgroundColor: Colors.red,
              child: Icon(Icons.camera_alt),
            ),
          ),
        )
      ],
    ),
  );
}