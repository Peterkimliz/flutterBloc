import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/utils/style.dart';
import 'package:plugme/widgets/common_text.dart';



import '../../widgets/custom_button.dart';

class OtpVerification extends StatefulWidget {
  const OtpVerification({Key? key}) : super(key: key);

  @override
  State<OtpVerification> createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const CommonText(
                color: blackColor,
                text: "Enter OTP",
                size: 30,
                fontWeight: FontWeight.bold,
                fontFamily: "RedHatMedium",
              ),
              const SizedBox(
                height: 10,
              ),
              CommonText(
                  color: blackColor,
                  fontFamily: "RedHatLight",
                  text:
                      "OTP has been successfully sent to your  ${authController.phoneNumber.value}"),
              const SizedBox(height: 20),
            OtpTextField(
              numberOfFields: 6,
              filled: true,
             fieldWidth: 45,
             borderWidth: 0,
             enabledBorderColor: Colors.transparent,
             focusedBorderColor: Colors.transparent,
             borderRadius: BorderRadius.circular(10),
             borderColor: Colors.black.withOpacity(0.1),
             fillColor: Colors.black.withOpacity(0.1),
              showFieldAsBox: true,
              onCodeChanged: (String code) {

              },
              onSubmit: (String verificationCode){
                authController.otp.value=verificationCode;

              }, // end onSubmit
            ),
              const SizedBox(height: 100),
              CustomButton(
                  text: "Verify",
                  voidCallback: () {
                    if (authController.otp.value.length>=6) {
                      authController.verifyOtp(authController.otp.value,context);
                    }  else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: CommonText(
                            text: "Verification Failed! Try after some time.",
                            color: whiteColor,
                          ),
                        ),
                      );
                    }

                  })
            ],
          ),
        ),
      ),
    );
  }
}
