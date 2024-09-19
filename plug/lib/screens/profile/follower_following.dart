import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:plugme/models/user.dart';
import 'package:plugme/utils/style.dart';
import 'package:plugme/widgets/common_text.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';

class FollowersFollowingPage extends StatelessWidget {
  final String type;
  final String id;
  final UserController _userController = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();

  FollowersFollowingPage({Key? key, required this.type, required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _userController.getUserFollowers(id: id, type: "followers");
    _userController.getUserFollowers(id: id, type: "following");

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.clear,
            color: blackColor,
            size: 25,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          type.capitalize!,
        ),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Obx(() {
            return _userController.loadingFollowers.value
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : type == "followers" &&
                        _userController.currentProfile.value!.followers!.isEmpty
                    ? const Center(
                        child: CommonText(
                          color: blackColor,
                          text: "You have no followers yet!",
                          size: 17,
                        ),
                      )
                    : type == "following" &&
                            _userController
                                .currentProfile.value!.following!.isEmpty
                        ? const Center(
                            child: CommonText(
                              color: blackColor,
                              text: "You haven't followed any one yet!",
                              size: 17,
                            ),
                          )
                        : ListView.builder(
                            itemCount: type == "following"
                                ? _userController
                                    .currentProfile.value!.following!.length
                                : _userController
                                    .currentProfile.value!.followers!.length,
                            itemBuilder: (context, index) {
                              UserModel user = type == "following"
                                  ? _userController
                                      .currentProfile.value!.following!
                                      .elementAt(index)
                                  : _userController
                                      .currentProfile.value!.followers!
                                      .elementAt(index);
                              return InkWell(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          user.profileUrl == "" ||
                                                  user.profileUrl == null
                                              ? const CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage: AssetImage(
                                                      "assets/icons/profile_placeholder.png"),
                                                )
                                              : CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage: NetworkImage(
                                                      user.profileUrl!),
                                                ),
                                          SizedBox(
                                            width: 0.03.sw,
                                          ),
                                          Text(
                                            "${user.firstname}",
                                            style: TextStyle(
                                                color: blackColor,
                                                fontSize: 14.sp),
                                          ),
                                        ],
                                      ),
                                      if (user.id !=
                                          FirebaseAuth
                                              .instance.currentUser!.uid)
                                        InkWell(
                                          onTap: () async {
                                            if (user.followers!.indexWhere(
                                                    (element) =>
                                                        element.id ==
                                                        FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid) ==
                                                -1) {
                                              await _userController.followUser(
                                                  userModel: user,type: "follow");
                                            } else {
                                              await _userController.unfollowUser(user: user.id!,type: "unfollow");
                                            }
                                          },
                                          child: Container(
                                            width: 0.25.sw,
                                            height: 0.034.sh,
                                            decoration: BoxDecoration(
                                                color: user.followers!
                                                    .indexWhere((element) => element.id==FirebaseAuth
                                                    .instance
                                                    .currentUser!
                                                    .uid)==-1
                                                    ?  Colors.transparent
                                                    :Colors.green
                                                ,
                                                border: Border.all(
                                                    color: user.followers!
                                                            .indexWhere((element) => element.id==FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid)==-1
                                                        ? blackColor
                                                        :Colors.green),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: Center(
                                              child: Text(
                                                _userController.currentProfile
                                                            .value!.following!
                                                            .indexWhere(
                                                                (element) =>
                                                                    element
                                                                        .id ==
                                                                    user.id) ==
                                                        -1
                                                    ? "follow"
                                                    : "following",
                                                style: TextStyle(
                                                    color: user.followers!.indexWhere(
                                                                (element) =>
                                                                    element.id ==
                                                                    FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid) !=
                                                            -1
                                                        ? Colors.white
                                                        : blackColor,
                                                    fontSize: 12.sp),
                                              ),
                                            ),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              );
                            });
          })),
    );
  }
}
