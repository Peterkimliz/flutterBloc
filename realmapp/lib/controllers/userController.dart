import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realm/realm.dart';
import 'package:realmapp/controllers/realm_controller.dart';
import 'package:realmapp/models/note.dart';
import 'package:realmapp/screens/home.dart';

import '../main.dart';

class UserController extends GetxController {
  RealmController _realmController = Get.find<RealmController>();
  TextEditingController textEditingControllerEmail = TextEditingController();
  TextEditingController textEditingControllerPassword = TextEditingController();
  TextEditingController textEditingControllerUserName = TextEditingController();
  TextEditingController textEditingControllerPhone = TextEditingController();
  final registerKey = GlobalKey<FormState>();
  final loginKey = GlobalKey<FormState>();
  RxBool registerLoad = RxBool(false);
  Rxn<UserModel> currentUser = Rxn(null);

  registerUser({required App app, required context}) async {
    try {
      if (registerKey.currentState!.validate()) {
        registerLoad.value = true;
        EmailPasswordAuthProvider emailPasswordAuthProvider =
            EmailPasswordAuthProvider(app);
        await emailPasswordAuthProvider.registerUser(
            textEditingControllerEmail.text.toLowerCase().trim(),
            textEditingControllerPassword.text.trim());
        final emailPassword = Credentials.emailPassword(
            textEditingControllerEmail.text.toLowerCase().trim(),
            textEditingControllerPassword.text.trim());
        var data = await app.logIn(emailPassword);
        print("data id ${data.id}");
        createUser(
            id: data.id,
            email: textEditingControllerEmail.text.trim(),
            name: textEditingControllerUserName.text.trim(),
            phone: textEditingControllerPhone.text.trim());
        var result = getUser(data.id);
        print("result is ${result}");
        Get.off(() => Home());
      }
      registerLoad.value = false;
    } catch (e) {
      registerLoad.value = false;
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Email address already in use"),
        backgroundColor: Colors.red,
      ));
    }
  }

  loginUser({required App app, required context}) async {
    try {
      if (loginKey.currentState!.validate()) {
        registerLoad.value = true;
        final emailPassword = Credentials.emailPassword(
            textEditingControllerEmail.text.toLowerCase().trim(),
            textEditingControllerPassword.text.trim());
        var data = await app.logIn(emailPassword);
        var result = getUser(data.id);

        print("result is ${result}");
        Get.off(() => Home());
      }
      registerLoad.value = false;
    } catch (e) {
      registerLoad.value = false;
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Invalid email or password"),
        backgroundColor: Colors.red,
      ));
    }
  }

  createUser({required id, required email, required name, required phone}) {
    try {
      print("called ${id}");
      UserModel userModel =
          UserModel(ObjectId.fromHexString(id), email, name, phone);
      _realmController.realm.write(() {
        _realmController.realm.add(userModel);
      });
    } catch (e) {
      print(e);
    }
  }

  getUser(uid) async{
    try {
      print("uid is ${uid}");
      _realmController.initializeApp(appId);
      RealmResults<UserModel> userModel = _realmController.realm.query<UserModel>(r'_id == $0', [ObjectId.fromHexString(uid)]);
      print("uid is ${userModel.first.fullname}");
      if (userModel.isNotEmpty) {
        currentUser.value = userModel.first;
      }
      return userModel.first;
    } catch (e) {
      print("error is $e");
    }
  }
}
