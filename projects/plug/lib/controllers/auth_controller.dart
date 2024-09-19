import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plug/controllers/chat_controller.dart';
import 'package:plug/controllers/home_controller.dart';
import 'package:plug/controllers/service_controller.dart';
import 'package:plug/controllers/user_controller.dart';
import 'package:plug/models/service.dart';
import 'package:plug/models/user.dart';
import 'package:plug/screens/auth/otp_verification.dart';
import 'package:plug/screens/home.dart';
import 'package:plug/screens/wallet/verification_success.dart';
import 'package:plug/utils/style.dart';
import 'package:plug/widgets/common_text.dart';
import 'package:plug/widgets/update_dialog.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../screens/profile/profile_setup.dart';

class AuthController extends GetxController {
  Rxn<File>? pickedImage = Rxn(null);
  RxBool isSigningIn = RxBool(false);
  RxBool loadinguser = RxBool(false);
  RxBool connectBank = RxBool(false);
  RxBool showPassword = RxBool(true);
  RxBool showConPassword = RxBool(true);
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  Rxn<UserCredential> userCredentialData = Rxn(null);

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  RxBool isSignedIn = RxBool(false);
  Rxn<UserModel> currentUser = Rxn(null);
  final _userRef = FirebaseFirestore.instance.collection("users");
  final _firebaseStorage = FirebaseStorage.instance;
  Rxn<ServiceModel> selectedService = Rxn(null);
  RxString phoneNumber = RxString("");
  RxString verificationOtp = RxString("");
  RxString otp = RxString("");
  late GoogleSignIn googleSignIn;

  TextEditingController textEditingControllerFirstname =
      TextEditingController();
  TextEditingController textEditingControllerLastname = TextEditingController();
  TextEditingController textEditingControllerWork = TextEditingController();
  TextEditingController textEditingControllerAddress = TextEditingController();
  TextEditingController textEditingControllerEmail = TextEditingController();
  TextEditingController textEditingControllerPassword = TextEditingController();
  TextEditingController textEditingControllerBio = TextEditingController();
  TextEditingController textEditingConControllerPassword =
      TextEditingController();
  TextEditingController textEditingControllerPhoneNumber =
      TextEditingController();
  TextEditingController textEditingControllerRate = TextEditingController();
  RxBool workfromHome = RxBool(false);

  RxBool showInputFields = RxBool(false);

  GlobalKey<FormState> signUpKey = GlobalKey<FormState>();
  GlobalKey<FormState> signInKey = GlobalKey<FormState>();

  updateUserOneSignalPlayerId({required userId}) async {
    String playerId = await getOneSignalUserId();
    _userRef.doc(userId).update({"playerId": playerId});
  }

  getCurrentUser() async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    } else {
      final snap = await _userRef.doc(user.uid).get();
      updateUserOneSignalPlayerId(userId: user.uid);
      return snap.data();
    }
  }

  void saveUserTofirestore() async {
    ServiceController serviceController = Get.find<ServiceController>();
    try {
      isSigningIn.value = true;
      String profile = pickedImage!.value == null
          ? userCredentialData.value != null
              ? userCredentialData.value!.user!.photoURL!
              : ""
          : await uploadImage(
              image: pickedImage!.value!, uid: _firebaseAuth.currentUser!.uid);

      GeoPoint geoPoint = GeoPoint(
          serviceController.address.value!.geometry!.location!.lat!,
          serviceController.address.value!.geometry!.location!.lng!);

      String playerId = await getOneSignalUserId();
      var agorauuid = Random().nextInt(999999);
      UserModel user = UserModel(
          email: textEditingControllerEmail.text,
          profileUrl: profile,
          id: FirebaseAuth.instance.currentUser!.uid,
          firstname: textEditingControllerFirstname.text.toLowerCase(),
          lastname: textEditingControllerLastname.text.toLowerCase(),
          address:
              serviceController.address.value?.addressComponents![0].longName,
          isServiceProvider: false,
          workFromHome: false,
          geoPoint: geoPoint,
          service: null,
          totalRating: 0,
          agorauuid: agorauuid,
          playerId: playerId,
          totalRatingCount: 0,
          accountConnected: false,
          followersCount: 0,
          followingCount: 0,
          totalJobs: 0,
          rehire: [],
          followers: [],
          following: [],
          availability: [],
          accountType: "",
          accountEnabled: true,
          featured: false,
          lastSeen: DateTime.now(),
          blockedUsers: [],
          bio: "",
          workProfile: textEditingControllerWork.text);

      await _userRef
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set(user.toJson());
      currentUser.value = user;
      isSigningIn.value = false;

      Get.off(() => Home());
      clearInputs();
    } catch (e) {
      isSigningIn.value = false;
    }
  }

  Future pickImage(
      {required type, required context, bool? upload = true}) async {
    try {
      XFile? image = await ImagePicker().pickImage(
          source: type == "camera" ? ImageSource.camera : ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      pickedImage?.value = imageTemp;
      if (upload == true) {
        updateDialog(title: "Updating profile image", context: context);
        String url = await uploadImage(
            image: pickedImage!.value!, uid: _firebaseAuth.currentUser!.uid);
        updateSingleItem(
            body: {"profileUrl": url},
            id: FirebaseAuth.instance.currentUser!.uid);
        Navigator.pop(context);
        currentUser.value!.profileUrl = url;
        currentUser.refresh();
      }
    } on PlatformException {
      Navigator.pop(context);
    }
  }

  Future<String> uploadImage({required File image, required uid}) async {
    Reference reference = _firebaseStorage.ref().child("profiles").child(uid);
    UploadTask uploadTask =
        reference.putFile(image, SettableMetadata(contentType: "image/jpg"));

    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  void assignFields() {
    textEditingControllerAddress.text = currentUser.value!.address!;
    textEditingControllerFirstname.text = currentUser.value!.firstname!;
    textEditingControllerLastname.text = currentUser.value!.lastname!;
    textEditingControllerEmail.text = currentUser.value!.email!;
    textEditingControllerBio.text = currentUser.value!.bio ?? "";
    selectedService.value = currentUser.value!.service;
    Get.find<ServiceController>().textEditingControllerSearch.text =
        currentUser.value!.address!;
    textEditingControllerRate.text = currentUser.value!.pricePerHour.toString();
    if (currentUser.value!.availability != null) {
      Get.find<UserController>().selectedDays.value = [
        ...currentUser.value!.availability!
      ];
    }
  }

  updateProfile(context) async {
    ServiceController serviceController = Get.find<ServiceController>();
    if (Get.find<AuthController>().currentUser.value?.isServiceProvider ==
            true &&
        selectedService.value == null) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: const Center(
                child: CommonText(
                  text: "Error Occurred",
                  color: blackColor,
                ),
              ),
              content: const CommonText(
                text: "Please select atleast one service to proceed",
                color: blackColor,
                fontFamily: "RedHatLight",
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const CommonText(
                      text: "Okay",
                      color: Colors.deepPurpleAccent,
                    ))
              ],
            );
          });
    } else {
      try {
        Map<String, dynamic> body = {
          "email": textEditingControllerEmail.text.isEmpty
              ? currentUser.value?.email
              : textEditingControllerEmail.text,
          "firstname": textEditingControllerFirstname.text.isEmpty
              ? currentUser.value!.firstname
              : textEditingControllerFirstname.text,
          "lastname": textEditingControllerLastname.text.isEmpty
              ? currentUser.value!.lastname
              : textEditingControllerLastname.text,
          "pricePerHour": textEditingControllerRate.text.isEmpty
              ? currentUser.value!.pricePerHour!
              : int.parse(textEditingControllerRate.text),
          if (serviceController.textEditingControllerSearch.text !=
                  currentUser.value!.address &&
              serviceController.address.value != null)
            "address": "${serviceController.address.value?.formattedAddress}",
          if (serviceController.address.value != null)
            "geoPoint": GeoPoint(
                serviceController.address.value!.geometry!.location!.lat!,
                serviceController.address.value!.geometry!.location!.lng!),
          "bio": textEditingControllerBio.text.isEmpty
              ? currentUser.value!.bio
              : textEditingControllerBio.text,
          if (selectedService.value != null)
            "service": selectedService.value!.toJson(),
          "availability": Get.find<UserController>()
              .selectedDays
              .map((element) => element)
              .toList()
        };
        updateDialog(title: "Updating profile", context: context);
        await _userRef.doc(FirebaseAuth.instance.currentUser!.uid).update(body);
        await _userRef
            .doc(_firebaseAuth.currentUser!.uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          UserModel userModel = UserModel.fromJson(
              documentSnapshot.data() as Map<String, dynamic>);
          currentUser.value = userModel;
          currentUser.refresh();
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            backgroundColor: Colors.green,
            content: CommonText(color: whiteColor, text: "Profile Updated")));
      } catch (e) {
        Navigator.pop(context);
      }
    }
  }

  updateSingleItem(
      {required Map<String, dynamic> body, required String id}) async {
    await _userRef.doc(id).update(body);
  }

  Future<String> getOneSignalUserId() async {
    final status = await OneSignal.shared.getDeviceState();
    final String? osUserID = status?.userId;
    return osUserID!;
  }

  void signInWithPhone(context) async {
    Get.defaultDialog(
        title: "Login in",
        contentPadding: const EdgeInsets.all(10),
        content: const CircularProgressIndicator(),
        barrierDismissible: false);
    // await _firebaseAuth.setSettings(appVerificationDisabledForTesting:true );
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber.value,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        Get.back();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CommonText(
              text: "${e.message}",
              color: whiteColor,
            ),
          ),
        );
      },
      codeSent: (String verificationId, int? resendToken) async {
        verificationOtp.value = verificationId;
        Get.back();
        textEditingControllerPhoneNumber.clear();
        Get.off(() => const OtpVerification());
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        Get.back();
      },
    );
  }

  verifyOtp(String token, context) async {
    try {
      Get.defaultDialog(
          title: "Verifying Number",
          contentPadding: const EdgeInsets.all(10),
          content: const CircularProgressIndicator(),
          barrierDismissible: false);
      var credential = await _firebaseAuth.signInWithCredential(
          PhoneAuthProvider.credential(
              verificationId: verificationOtp.value, smsCode: token));
      if (credential.user != null) {
        checkUserOnFirestore(uid: credential.user!.uid);
      }
    } catch (e) {
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: CommonText(
            text: "Verification Failed! Try after some time.",
            color: whiteColor,
          ),
        ),
      );
    }
  }

  emailValidator(email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  logout() async {
    final UserController userController = Get.put(UserController());
    final ServiceController serviceController = Get.put(ServiceController());
    final ChatController chatController = Get.put(ChatController());
    Get.defaultDialog(
        title: "Signing out..",
        contentPadding: const EdgeInsets.all(10),
        content: const CircularProgressIndicator(),
        barrierDismissible: false);

    await _firebaseAuth.signOut();
    await FacebookAuth.i.logOut();
    Get.back();
    Get.offAll(
      () => Home(),
    );
    Get.find<HomeController>().selectedPage.value = 0;
    Get.find<UserController>().initialHeight.value = 0.5;
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.disconnect();
    }
    clearInputs();
    currentUser.value = null;
    currentUser.refresh();
    userController.selectedUser.value = null;
    userController.filteredUsers.clear();
    serviceController.selectedRequests.clear();
    serviceController.category.value = null;
    serviceController.checkWeeks.value = false;
    serviceController.selectedDays.clear();
    chatController.showTabBar.value = false;
  }

  void signInWithGoogle() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      Get.snackbar("", "failed to log in");
    } else {
      Get.defaultDialog(
          title: "Signing in",
          contentPadding: const EdgeInsets.all(10),
          content: const CircularProgressIndicator(),
          barrierDismissible: false);
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credentials = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credentials);
      userCredentialData.value = userCredential;
      checkUserOnFirestore(uid: userCredential.user!.uid);
      textEditingControllerEmail.text = userCredential.user!.email!;
    }
  }

  void signInWithApple() async {
    final appleUser = AppleAuthProvider();

    Get.defaultDialog(
        title: "Signing in",
        contentPadding: const EdgeInsets.all(10),
        content: const CircularProgressIndicator(),
        barrierDismissible: false);
    UserCredential userCredential =
        await _firebaseAuth.signInWithProvider(appleUser);
    userCredentialData.value = userCredential;
    checkUserOnFirestore(uid: userCredential.user!.uid);
    textEditingControllerEmail.text = userCredential.user!.email!;
  }

  @override
  void onInit() {
    googleSignIn = GoogleSignIn();
    super.onInit();
  }

  void checkUserOnFirestore({required uid}) async {
    await _userRef.doc(uid).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        UserModel userModel =
            UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>);
        currentUser.value = userModel;
        Get.back();

        Get.off(() => Home());
        updateUserOneSignalPlayerId(userId: userModel.id);
      } else {
        Get.back();
        Get.off(() => ProfileSetUp());
      }
    });
  }

  void signInWithFacebook() async {
    LoginResult result =
        await FacebookAuth.i.login(permissions: ['public_profile']);
    switch (result.status) {
      case LoginStatus.success:
        Get.defaultDialog(
            title: "Signing in",
            contentPadding: const EdgeInsets.all(10),
            content: const CircularProgressIndicator(),
            barrierDismissible: false);
        await FacebookAuth.i.getUserData();
        OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);
        await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);
        checkUserOnFirestore(uid: FirebaseAuth.instance.currentUser!.uid);
        break;
      case LoginStatus.cancelled:
        break;
      case LoginStatus.failed:
        break;
      default:
        return null;
    }
  }

  void verifyProvider() {
    updateSingleItem(
        body: {"isServiceProvider": true},
        id: FirebaseAuth.instance.currentUser!.uid);
    currentUser.value?.isServiceProvider = true;
    currentUser.refresh();
    Get.to(() => VerificationSuccess());
  }

  signUpWithEmailAndPassword({required context}) async {
    try {
      if (signUpKey.currentState!.validate()) {
        Get.defaultDialog(
            title: "Signing up",
            contentPadding: const EdgeInsets.all(10),
            content: const CircularProgressIndicator(),
            barrierDismissible: false);
        await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: textEditingControllerEmail.text.trim(),
                password: textEditingControllerPassword.text.trim())
            .then((value) {
          Get.back();
          textEditingControllerPassword.clear();
          Get.off(() => ProfileSetUp());
        });
      }
    } on FirebaseAuthException catch (error) {
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: CommonText(color: whiteColor, text: error.message!),
        backgroundColor: blackColor,
      ));
    } catch (error) {
      Get.back();
    }
  }

  signInWithEmailAndPassword({required BuildContext context}) async {
    try {
      if (signInKey.currentState!.validate()) {
        Get.defaultDialog(
            title: "Signing in",
            contentPadding: const EdgeInsets.all(10),
            content: const CircularProgressIndicator(),
            barrierDismissible: false);
        await _firebaseAuth
            .signInWithEmailAndPassword(
                email: textEditingControllerEmail.text.trim(),
                password: textEditingControllerPassword.text.trim())
            .then((value) {
          Get.back();
          _userRef
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get()
              .then((value) {
            if (value.exists) {
              UserModel userModel =
                  UserModel.fromJson(value.data() as Map<String, dynamic>);
              Get.find<AuthController>().currentUser.value = userModel;
              clearInputs();
              Get.off(() => Home());
            } else {
              textEditingControllerPassword.clear();
              Get.off(() => ProfileSetUp());
            }
          });
        });
      }
    } on FirebaseAuthException catch (error) {
      Get.back();
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
        content: CommonText(color: whiteColor, text: error.message!),
        backgroundColor: blackColor,
      ));
    } catch (e) {
      Get.back();
    }
  }

  clearInputs() {
    Get.find<ServiceController>().textEditingControllerSearchService.clear();
    textEditingControllerEmail.clear();
    textEditingControllerPassword.clear();
    textEditingControllerFirstname.clear();
    textEditingControllerLastname.clear();
    textEditingControllerAddress.clear();
    textEditingControllerWork.clear();
  }
}
