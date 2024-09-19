import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:plugme/utils/style.dart';
import 'package:plugme/widgets/common_text.dart';

import '../../controllers/wallet_controller.dart';
import '../../models/stripe_account.dart';

//ignore: must_be_immutable
class WithdrawPage extends StatelessWidget {
  final StripeAccount? stripeAccountModel;

  WithdrawPage({
    Key? key,
    this.stripeAccountModel,
  }) : super(key: key);

  final WalletController _walletController = Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blueColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: blueColor,
        title: Text(
          "Withdraw",
          style: TextStyle(fontSize: 18.0.sp, color: whiteColor),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        width: double.infinity,
        decoration: const BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child:
            SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(
                height: 20,
            ),
            const Center(
                child: Text(
                  "Withdraw Fund",
                  style: TextStyle(
                      fontSize: 16,
                      color: blackColor,
                      fontWeight: FontWeight.bold),
                ),
            ),
            const SizedBox(
                height: 50,
            ),
            Center(
                child: Container(
                  width: 0.5.sw,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: blueColor, width: 1)),
                  child: Column(
                    children: [
                      const Center(
                          child: CommonText(
                        color: blackColor,
                        text: "Input Amount",
                        fontFamily: "RedHatLight",
                      )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CommonText(
                            color: Colors.pinkAccent.withOpacity(0.7),
                            text: "\$",
                            size: 17.sp,
                          ),
                          Container(
                            width: 80,
                            margin: const EdgeInsets.only(left: 3),
                            child: TextFormField(
                              controller:
                                  _walletController.withdrawAmountController,
                              autofocus: true,
                              maxLength: null,
                              maxLines: null,
                              decoration: InputDecoration(
                                  hintStyle: TextStyle(
                                    fontSize: 17.sp,
                                    color: Colors.pinkAccent.withOpacity(0.7),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  border: InputBorder.none,
                                  hintText: "0.00"),
                              keyboardType: const TextInputType.numberWithOptions(
                                  signed: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: TextStyle(
                                fontSize: 17.sp,
                                color: Colors.pinkAccent.withOpacity(0.7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ),
            const SizedBox(
                height: 20,
            ),
            SizedBox(
                width: double.infinity,
                height: 100,
                child: GridView.builder(
                    itemCount: _walletController.prices.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 2.3,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0),
                    itemBuilder: (context, index) {
                      return Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: blueColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1, color: blueColor)),
                        child: Center(
                          child: CommonText(
                            color: blueColor,
                            text: "\$ ${_walletController.prices[index]}",
                          ),
                        ),
                      );
                    }),
            ),
            const SizedBox(
                height: 40,
            ),
            const Row(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: blueColor,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: CommonText(
                      color: blackColor,
                      text: "Withdraw Money to",
                      fontFamily: "RedHatLight",
                      size: 20,
                    ),
                  )
                ],
            ),
            const SizedBox(
                height: 20,
            ),
            InkWell(
                onTap: () {
                  _walletController.selectedOption.value = 1;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                  color: blueColor, shape: BoxShape.circle),
                              child: Center(
                                child: Image.asset(
                                  "assets/images/stripe.png",
                                  width: 15,
                                  height: 15,
                                  color: whiteColor,
                                ),
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          const CommonText(color: blueColor, text: "Stripe Account")
                        ],
                      ),
                      Obx(() => Radio(
                          value: 1,
                          groupValue: _walletController.selectedOption.value,
                          onChanged: (value) {
                            _walletController.selectedOption.value = value!;
                          }))
                    ],
                  ),
                ),
            ),
            const SizedBox(
                height: 20,
            ),
            InkWell(
                onTap: () {
                  _walletController.selectedOption.value = 2;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                  color: Colors.amber, shape: BoxShape.circle),
                              child: Center(
                                child: Image.asset(
                                  "assets/images/paypal.png",
                                  width: 20,
                                  height: 20,
                                ),
                              )),
                          const SizedBox(
                            width: 5,
                          ),
                          const CommonText(color: blueColor, text: "Paypal Account")
                        ],
                      ),
                      Obx(() => Radio(
                          value: 2,
                          groupValue: _walletController.selectedOption.value,
                          onChanged: (value) {
                            _walletController.selectedOption.value = value!;
                          }))
                    ],
                  ),
                ),
            )
          ]),
              ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.all(10),
          height: kBottomNavigationBarHeight,
          color: whiteColor,
          child: Obx(() {
            return _walletController.withdrawing.isFalse
                ? Center(
                    child: InkWell(
                      onTap: () {
                        int amount = int.parse(
                            _walletController.withdrawAmountController.text);

                        if (amount > 0) {
                          _walletController.withdraw();
                        } else {
                          const GetSnackBar(
                            message: "Amount has to be greater",
                            duration: Duration(seconds: 3),
                          ).show();
                        }
                      },
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.all(10),
                        child: const Center(
                          child: CommonText(
                              color: whiteColor, text: "Confirm Withdraw"),
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(
                    color: blackColor,
                  ));
          }),
        ),
      ),
    );
  }
}
