import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/models/work.dart';
import 'package:plug/screens/joblist/components/receipt_body.dart';
import 'package:plug/utils/style.dart';
import 'package:plug/widgets/common_text.dart';

import '../../models/user.dart';

class ReceiptPage extends StatelessWidget {
  final Work work;
  final UserModel userModel;

  const ReceiptPage({Key? key, required this.work, required this.userModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios, color: blackColor)),
        title: const CommonText(color: blackColor, text: "Receipt"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: ReceiptBody(userModel: userModel, work: work),
      ),
    );
  }
}
