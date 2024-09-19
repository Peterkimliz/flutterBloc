import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/screens/bank_details/payment_info.dart';
import '../../controllers/service_controller.dart';
import '../../utils/style.dart';
import '../../widgets/common_text.dart';

class ConnectedBanks extends StatelessWidget {
  final ServiceController serviceController = Get.find<ServiceController>();
  final AuthController authController = Get.find<AuthController>();

  ConnectedBanks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.to(() => PaymentInfo(
                              paymentOption: "stripe",
                            ));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0XFF5c54fe),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        height: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  child: Image.asset(
                                    "assets/images/stripe.png",
                                    height: 30,
                                    width: 30,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    if (authController.currentUser.value!
                                            .accountConnected ==
                                        true) {
                                      showDisconnectDialog(context);
                                    }
                                  },
                                  child: const Icon(
                                    Icons.more_vert,
                                    color: whiteColor,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(() => CommonText(
                                      color: whiteColor,
                                      text: authController.currentUser.value!
                                                      .accountConnected ==
                                                  true &&
                                              authController.currentUser.value!
                                                      .accountType ==
                                                  "stripe"
                                          ? "Stripe\nConnected "
                                          : "Connect\n Stripe",
                                      fontFamily: "RedHatMedium",
                                      size: 18,
                                    )),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: whiteColor,
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
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: yellowColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          height: 160,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: Image.asset(
                                      "assets/images/paypal.png",
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.more_vert,
                                    color: whiteColor,
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const Row(
                                children: [
                                  CommonText(
                                    color: whiteColor,
                                    text: "Connect\n Paypal",
                                    fontFamily: "RedHatMedium",
                                    size: 18,
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: whiteColor,
                                  )
                                ],
                              )
                            ],
                          )))
                ],
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                Get.to(() => PaymentInfo(
                      paymentOption: "flutterWave",
                    ));
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0XFF2c3262),
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 160,
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Image.asset(
                            "assets/images/flutterwave.png",
                            height: 30,
                            width: 30,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                          },
                          child: const Icon(
                            Icons.more_vert,
                            color: whiteColor,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() => CommonText(
                              color: whiteColor,
                              text: authController.currentUser.value!
                                              .accountConnected ==
                                          true &&
                                      authController
                                              .currentUser.value!.accountType ==
                                          "flutterWave"
                                  ? "Flutterwave\n Connected "
                                  : "Connect\n Flutterwave",
                              fontFamily: "RedHatMedium",
                              size: 18,
                            )),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: whiteColor,
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(color: blackColor, text: "Cards".toUpperCase()),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                              color: blueColor, shape: BoxShape.circle),
                          child: const Icon(
                            Icons.credit_card,
                            color: whiteColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: CommonText(
                            color: blackColor,
                            fontFamily: "RedHatLight",
                            text:
                                "Add a card to enjoy a seamless payment experince!",
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: lightGrey,
                          borderRadius: BorderRadius.circular(30)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline_outlined,
                            color: greyColor.withOpacity(0.2),
                          ),
                          const SizedBox(width: 10),
                          CommonText(
                              color: greyColor.withOpacity(0.2),
                              text: "Add Card")
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  buildAccountNumber({required hint, required controller}) {
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: controller,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "please fill this field";
        }
        return null;
      },
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
          hintText: hint,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: greyColor.withOpacity(0.1)),
    );
  }

  buildPhoneNumber({required hint, required controller}) {
    return TextFormField(
      keyboardType: TextInputType.phone,
      controller: controller,
      validator: (value) {
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
              borderRadius: BorderRadius.circular(100),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: greyColor.withOpacity(0.1)),
    );
  }

  void showDisconnectDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(20),
              ),
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: blueColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        CommonText(color: blueColor, text: "Disconnect Stripe"),
                      ],
                    ),
                  ),
                  const Divider(
                    thickness: 1,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Center(
                      child: Text(
                        "Are you sure you want to Disconnect Stripe?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: "RedHatLight",
                            color: greyColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin:
                        const EdgeInsets.only(bottom: 15, left: 20, right: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                      Border.all(width: 1, color: blackColor)),
                              child: const Center(
                                  child: CommonText(
                                      color: blackColor, text: "Cancel")),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Get.back();
                              serviceController.disconnectStripe(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(5)),
                              child: const Center(
                                child: CommonText(
                                    color: whiteColor, text: "Disconnect"),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
