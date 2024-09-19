import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plugme/controllers/user_controller.dart';
import 'package:plugme/models/rating.dart';
import 'package:plugme/utils/style.dart';
import 'package:plugme/widgets/common_text.dart';

import 'components/review_card.dart';

class ReviewsPage extends StatelessWidget {
  final String id;
  final UserController userController = Get.find<UserController>();

  ReviewsPage({Key? key, required this.id}) : super(key: key) {
    userController.getUserReviews(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: const CommonText(text: "Reviews", color: Colors.black),
      ),
      body: Obx(() {
        return userController.fetchingReviews.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : userController.userReviews.isEmpty
                ? const Center(
                    child:
                        CommonText(color: blackColor, text: "No reviews yet!"),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: userController.userReviews.length,
                    itemBuilder: (context, index) {
                      Rating rating =
                          userController.userReviews.elementAt(index);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            reviewsCard(context: context, rating: rating),
                            const Divider(
                              color: Colors.grey,
                            )
                          ],
                        ),
                      );
                    });
      }),
    );
  }
}
