import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:plug/screens/wallet/transactiions.dart';
import 'package:plug/screens/wallet/wallet_withdraw.dart';
import 'package:plug/utils/style.dart';
import 'package:plug/widgets/common_text.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../profile/components/image_container.dart';

class WalletPage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final WalletController _walletController = Get.put(WalletController());

  WalletPage({Key? key}) : super(key: key) {
    if (authController.currentUser.value !=null && authController.currentUser.value!.isServiceProvider == true) {
      _walletController.getConnectedStripeBanks(
          accountNumber: authController.currentUser.value?.accountNumber!);
      _walletController.getAccountBalances(
          accountNumber: authController.currentUser.value?.accountNumber!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blueColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Wallet",
          style: TextStyle(fontSize: 18.0.sp, color: whiteColor),
        ),
        iconTheme: const IconThemeData(color: blackColor),
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: whiteColor,
            )),
        backgroundColor: blueColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
        },
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 20),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40), topRight: Radius.circular(40)),
              color: whiteColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  profileImage(
                      upload: true,
                      showCam: false,
                      radi: 30,
                      context: context,
                      imageProvider: authController
                              .currentUser.value!.profileUrl!.isEmpty
                          ? const AssetImage("assets/images/profile.png")
                          : NetworkImage(
                                  authController.currentUser.value!.profileUrl ?? "")
                              as ImageProvider),
                  const SizedBox(width: 10),
                  CommonText(
                      color: blackColor,
                      size: 20,
                      text:
                          "Hey ${authController.currentUser.value!.firstname},")
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        offset: Offset(1.0, 1.0),
                        blurRadius: 2,
                        color: greyColor)
                  ],
                  color: whiteColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          color: yellowColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                          top: 10.0, left: 20, bottom: 10),
                      child: CommonText(
                        color: yellowColor,
                        text: "Your Account Balance",
                        size: 20,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 20),
                      decoration: const BoxDecoration(
                          color: yellowColor,
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Obx(() => Text(
                                    "\$${authController.currentUser.value!.availableAmount??0}",
                                    style: TextStyle(
                                        color: whiteColor,
                                        fontSize: 31.sp,
                                        fontWeight: FontWeight.bold),
                                  )),
                              const SizedBox(
                                height: 15,
                              ),
                              const CommonText(
                                  color: whiteColor, text: "Pending Balance"),
                              Obx(() => Text(
                                    "\$${authController.currentUser.value!.pendingAmount??0}",
                                    style: TextStyle(
                                      color: whiteColor,
                                      fontSize: 25.sp,
                                    ),
                                  )),
                              const SizedBox(height: 15),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: Image.asset(
                              "assets/images/cards.png",
                              height: 80,
                              width: 80,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.to(() => WithdrawPage());
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Image.asset(
                                  "assets/images/bankImage.png",
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CommonText(
                                  color: blackColor,
                                  text: "Bank\nAccount",
                                  fontFamily: "RedHatMedium",
                                  size: 18,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: blackColor,
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: InkWell(
                    onTap: () {
                      Get.to(() => TransactionsPage());
                    },
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: blueColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        height: 200,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(15),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Image.asset(
                                  "assets/images/bankHistory.png",
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Row(
                              children: [
                                CommonText(
                                  color: blackColor,
                                  text: "Transaction\n History",
                                  fontFamily: "RedHatMedium",
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: blackColor,
                                )
                              ],
                            )
                          ],
                        )),
                  ))
                ],
              ),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}

