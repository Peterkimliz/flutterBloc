import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plug/screens/auth/components/background_container.dart';

import '../../controllers/auth_controller.dart';
import '../../utils/style.dart';
import '../../widgets/common_text.dart';
import 'components/authbutton.dart';
import 'components/social_login.dart';
import 'login_screen.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key) {
    _authController.clearInputs();
  }

  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            const AuthBackgroundContainer(),
            Positioned(
                left: 0,
                right: 0,
                top: MediaQuery.of(context).size.height * 0.28,
                bottom: MediaQuery.of(context).size.height * 0.06,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Form(
                          key: _authController.signUpKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              TextFormField(
                                controller:
                                    _authController.textEditingControllerEmail,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Email required";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  hintText: "Email",
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide:
                                        const BorderSide(color: Colors.red, width: 1),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide:
                                        const BorderSide(color: Colors.red, width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Obx(() => TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: _authController
                                        .textEditingControllerPassword,
                                    obscureText:
                                        _authController.showPassword.value,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Password required";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        hintText: "Password",
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: const BorderSide(
                                              color: Colors.grey, width: 1),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 1),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: const BorderSide(
                                              color: Colors.grey, width: 1),
                                        ),
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              _authController
                                                      .showPassword.value =
                                                  !_authController
                                                      .showPassword.value;
                                            },
                                            icon: Icon(
                                              _authController.showPassword.value
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: greyColor,
                                            ))),
                                  )),
                              const SizedBox(height: 10),
                              Obx(() => TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: _authController
                                        .textEditingConControllerPassword,
                                    obscureText:
                                        _authController.showConPassword.value,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Confirm required";
                                      } else if (_authController
                                              .textEditingConControllerPassword
                                              .text
                                              .trim() !=
                                          _authController
                                              .textEditingControllerPassword
                                              .text
                                              .trim()) {
                                        return "Password mismatched";
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        hintText: "Confirm Password",
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: const BorderSide(
                                              color: Colors.grey, width: 1),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 1),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: const BorderSide(
                                              color: Colors.red, width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          borderSide: const BorderSide(
                                              color: Colors.grey, width: 1),
                                        ),
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              _authController
                                                      .showConPassword.value =
                                                  !_authController
                                                      .showConPassword.value;
                                            },
                                            icon: Icon(
                                              _authController.showConPassword.value
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: greyColor,
                                            ))),
                                  )),
                              const SizedBox(height: 20),
                              authButton(
                                  title: "Sign up",
                                  callBack: () {
                                    _authController.signUpWithEmailAndPassword(
                                        context: context);
                                  },
                                  context: context),
                              const SizedBox(height: 10),
                              const Center(
                                child: CommonText(
                                    color: greyColor, text: "or sign in with"),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  socialLogin(
                                      image: "assets/images/phone.png",
                                      onTap: () {
                                        Get.to(() => LoginScreen(),
                                            duration:
                                                const Duration(milliseconds: 2000));
                                      }),
                                  socialLogin(
                                      image: "assets/images/google.png",
                                      onTap: () {
                                        _authController.signInWithGoogle();
                                      }),
                                  socialLogin(
                                      image: "assets/images/facebook.png",
                                      onTap: () {
                                        _authController.signInWithFacebook();
                                      }),
                                  if (Platform.isIOS)
                                  socialLogin(
                                      image: "assets/images/appleIcon.png",
                                      onTap: () {
                                        _authController.signInWithApple();
                                      })
                                ],
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: "Already have an account? ",
                                    style: const TextStyle(color: Colors.black54),
                                    children: [
                                      TextSpan(
                                        text: 'Login now',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => Get.back(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: yellowColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
