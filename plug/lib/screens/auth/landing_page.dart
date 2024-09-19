import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/screens/auth/components/authbutton.dart';
import 'package:plugme/screens/auth/components/background_container.dart';
import 'package:plugme/screens/auth/components/social_login.dart';
import 'package:plugme/screens/auth/login_screen.dart';
import 'package:plugme/screens/auth/register_page.dart';
import 'package:plugme/utils/style.dart';
import 'package:plugme/widgets/common_text.dart';

class LandingPage extends StatelessWidget {
  LandingPage({Key? key}) : super(key: key) {
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
                top: MediaQuery.of(context).size.height * 0.32,
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
                          key: _authController.signInKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 15),
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                controller:
                                    _authController.textEditingControllerEmail,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Email required";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 1),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                        color: Colors.grey, width: 1),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
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
                              const SizedBox(height: 20),
                              authButton(
                                  title: "Sign in",
                                  callBack: () {
                                    _authController.signInWithEmailAndPassword(
                                        context: context);
                                  },
                                  context: context),
                              const SizedBox(height: 10),
                              const Align(
                                alignment: Alignment.topRight,
                                child: CommonText(
                                    color: yellowColor,
                                    text: "Forgot Password?"),
                              ),
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
                                            duration: const Duration(
                                                milliseconds: 2000));
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
                                    text: "Don't have an account? ",
                                    style:
                                        const TextStyle(color: Colors.black54),
                                    children: [
                                      TextSpan(
                                        text: 'Register now',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => Get.to(
                                              () => RegisterPage(),
                                              duration: const Duration(
                                                  milliseconds: 2000)),
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
