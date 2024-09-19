import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:plug/controllers/auth_controller.dart';
import '../../controllers/service_controller.dart';
import '../../utils/style.dart';
import '../../widgets/common_text.dart';
import '../../widgets/custom_roundedbutton.dart';
import '../../widgets/items_selection_container.dart';
import '../profile/components/input_field.dart';

class PaymentInfo extends StatelessWidget {
  final String paymentOption;

  PaymentInfo({Key? key, required this.paymentOption}) : super(key: key);
  final AuthController authController = Get.find<AuthController>();
  final ServiceController serviceController = Get.find<ServiceController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: blueColor,
        toolbarHeight: 40,
        elevation: 0.0,
        titleSpacing: 0.0,
        title: const CommonText(
          color: whiteColor,
          text: "Provider",
          fontWeight: FontWeight.bold,
          fontFamily: "RedHatMedium",
          size: 20,
        ),
        leading: IconButton(
            onPressed: () {
              Get.back();
              authController.connectBank.value = false;
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: whiteColor,
            )),
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 200,
            color: blueColor,
          ),
          SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(40),
                      topLeft: Radius.circular(40))),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ).copyWith(top: 30, bottom: 10),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: whiteColor,
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CommonText(
                            color: blueColor, text: "Card Information"),
                        const SizedBox(height: 10),
                        const CommonText(
                            color: greyColor, text: "Account Number"),
                        const SizedBox(height: 3),
                        buildAccountNumber(
                          controller: serviceController
                              .textEditingControllerAccountNumber,
                          hint: "",
                        ),
                        if (paymentOption != "stripe")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              const CommonText(
                                  color: greyColor, text: "Email Address"),
                              const SizedBox(height: 3),
                              buildEmail(
                                hint: "",
                                controller: serviceController
                                    .textEditingControllerEmail,
                              )
                            ],
                          ),
                        if (paymentOption == "stripe")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              const CommonText(
                                  color: greyColor, text: "Routing Number"),
                              const SizedBox(height: 3),
                              buildAccountNumber(
                                hint: "",
                                controller: serviceController
                                    .textEditingControllerRoutingNumber,
                              )
                            ],
                          ),
                        const SizedBox(height: 10),
                        const CommonText(
                            color: greyColor, text: "Phone Number"),
                        const SizedBox(height: 3),
                        buildPhoneNumber(
                          controller: serviceController
                              .textEditingControllerPhoneNumber,
                          hint: "",
                        ),
                        if (paymentOption == "stripe")
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              const CommonText(
                                  color: greyColor,
                                  text:
                                      "Last 4 digits of social security number"),
                              const SizedBox(height: 3),
                              buildAccountNumber(
                                controller: serviceController
                                    .textEditingControllerPhoneCvc,
                                hint: "",
                              ),
                              const SizedBox(height: 10),
                              const CommonText(
                                  color: greyColor, text: "Address"),
                              const SizedBox(height: 3),
                              InputFields(
                                textEditingController: serviceController
                                    .textEditingControllerAddress,
                                hint: "",
                              ),
                              const SizedBox(height: 10),
                              const CommonText(
                                  color: greyColor, text: "Postal code"),
                              const SizedBox(height: 3),
                              InputFields(
                                textEditingController: serviceController
                                    .textEditingControllerPostalNumber,
                                hint: "",
                              ),
                              const SizedBox(height: 10),
                              Obx(() => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CommonText(
                                        color: greyColor,
                                        text: "",
                                      ),
                                      ItemSelectionContainer(
                                          voidCallback: () async {
                                            final picked = await showDatePicker(
                                              initialDate: DateTime(1989),
                                              context: context,
                                              lastDate: DateTime(2079),
                                              firstDate: DateTime(1900),
                                            );

                                            serviceController
                                                    .birthDateHolder.value =
                                                DateFormat("dd/MM/yyyy")
                                                    .format(picked!);
                                          },
                                          text: serviceController
                                                      .birthDateHolder.value ==
                                                  ""
                                              ? "Date of birth"
                                              : serviceController
                                                  .birthDateHolder.value),
                                    ],
                                  )),
                            ],
                          ),
                        if (paymentOption != "stripe")
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CommonText(
                                  color: greyColor, text: "Currency"),
                              const SizedBox(height: 3),
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8.0, right: 8),
                                  child: Center(
                                    child: Obx(() => DropdownButton<String>(
                                          value: serviceController
                                              .selectedCurrency.value,
                                          // icon: Icon(Icons.arrow_downward),
                                          iconSize: 24,
                                          elevation: 16,
                                          isExpanded: true,
                                          underline: Container(
                                            height: 0,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                          onChanged: (newValue) {
                                            serviceController
                                                .selectedCurrency.value = newValue!;
                                          },
                                          items: serviceController.currencies
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(
                                                value,
                                                textAlign: TextAlign.right,
                                              ),
                                            );
                                          }).toList(),
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: kBottomNavigationBarHeight,
          padding: const EdgeInsets.all(10),
          child: Center(
              child: SizedBox(
                  width: 150,
                  child: customRoundedButton(
                      title: "Proceed",
                      bgColor: blueColor,
                      fgColor: whiteColor,
                      voidCallback: () {
                        if (paymentOption=="stripe") {
                          serviceController.createStripeConnectAccount(
                              context: context);
                        } else{
                          serviceController.connectFlutterWave(
                              context: context);
                        }

                      }))),
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
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 1, color: greyColor)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 1, color: greyColor)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(width: 1, color: greyColor)),
          filled: true,
          fillColor: whiteColor),
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
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(width: 1, color: greyColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(width: 1, color: greyColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(width: 1, color: greyColor)),
            filled: true,
            fillColor: whiteColor));
  }

  buildEmail({required hint, required controller}) {
    return TextFormField(
        keyboardType: TextInputType.emailAddress,
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
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(width: 1, color: greyColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(width: 1, color: greyColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(width: 1, color: greyColor)),
            filled: true,
            fillColor: whiteColor));
  }

  void showDisconnectDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Center(
                child:
                    CommonText(color: blackColor, text: "Disconnect Stripe")),
            content: const CommonText(
              color: blackColor,
              text:
                  "Once you disconnect your Stripe account you will no longer be a service provider, you will need to set up payment method again.",
              size: 16,
              fontFamily: "RedHatLight",
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const CommonText(color: blackColor, text: "CANCEL")),
              TextButton(
                  onPressed: () {
                    Get.back();
                    serviceController.disconnectStripe(context);
                  },
                  child: const CommonText(color: blackColor, text: "OKAY")),
            ],
          );
        });
  }
}
