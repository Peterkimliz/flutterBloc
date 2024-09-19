import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:plugme/controllers/auth_controller.dart';
import 'package:plugme/models/transactions.dart';
import 'package:plugme/utils/constants.dart';
import 'package:plugme/utils/style.dart';

import '../models/stripe_account.dart';
import '../screens/wallet/wallet_page.dart';

class WalletController extends GetxController {
  TextEditingController withdrawAmountController = TextEditingController();
  final _firestore = FirebaseFirestore.instance.collection("transactions");
  RxBool withdrawing = RxBool(false);
  RxInt selectedOption = RxInt(1);
  RxBool loadingTransactions = RxBool(false);
  RxBool gettingStripeBankAccounts = RxBool(false);
  RxList<StripeAccount> userStripeAccountData = RxList([]);
  RxList<TransactionsModel> transactionsList = RxList([]);
  final client = http.Client();
  List prices = [10.00, 20.00, 30.00, 40.00, 50.00, 60.00, 70.00, 80.00];

  getConnectedStripeBanks({required accountNumber}) async {
    try {
      gettingStripeBankAccounts.value = true;
      userStripeAccountData.value = [];
      var url = "$baseUrl/stripe/accounts/$accountNumber";
      var response = await client.get(Uri.parse(url));
      Map<String, dynamic> result = jsonDecode(response.body);

      if (result["status"] == true) {
        List accounts = result["banks"];
        List<StripeAccount> accountsFetched =
            accounts.map((e) => StripeAccount.fromJson(e)).toList();
        userStripeAccountData.assignAll(accountsFetched);
        userStripeAccountData.refresh();
      }
    } finally {
      gettingStripeBankAccounts.value = false;
    }
  }

  getAccountBalances({required accountNumber}) async {
    AuthController authController = Get.find<AuthController>();
    var response =
        await client.get(Uri.parse("$baseUrl/stripe/balance/$accountNumber"));
    Map<String, dynamic> result = jsonDecode(response.body);
    authController.currentUser.value?.pendingAmount =
        result["pending"][0]["amount"] / 100;
    authController.currentUser.value!.availableAmount =
        result["available"][0]["amount"] / 100;
    authController.currentUser.refresh();
  }

  withdraw() async {
    try {
      withdrawing.value = true;
      int amount = int.parse(withdrawAmountController.text);

      if (amount <=
          Get.find<AuthController>()
              .currentUser
              .value!
              .availableAmount!
              .toInt()) {
        Get.defaultDialog(
            title: "Just a moment",
            content: const CircularProgressIndicator(),
            barrierDismissible: false);
        String total = (amount).toString();
        var data = await withdrawToBank(total);
        var payout = data["response"];

        if (payout["id"] != null) {
          showDialog(
              context: Get.context!,
              builder: (context) {
                return Dialog(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Container(
                    height: 250,
                    padding: const EdgeInsets.all(10.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.check_mark_circled_solid,
                            color: Colors.green,
                            size: 45,
                          ),
                          SizedBox(height: 0.01.sh),
                          Text(
                            "Success",
                            style:
                                TextStyle(color: blackColor, fontSize: 18.sp),
                          ),
                          SizedBox(height: 0.01.sh),
                          Text(
                            "Withdraw request is being processed",
                            style:
                                TextStyle(color: blackColor, fontSize: 14.sp),
                          ),
                          SizedBox(height: 0.02.sh),
                          InkWell(
                            onTap: () {
                              withdrawAmountController.clear();
                              Get.offAll(WalletPage());
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                "okay",
                                style: TextStyle(
                                    color: blackColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              });
        } else {
          const GetSnackBar(
            message: "something went wrong try",
            duration: Duration(seconds: 3),
          ).show();
        }
      } else {
        GetSnackBar(
          message: "Insufficient balance to withdraw \$${amount.toString()}",
          duration: const Duration(seconds: 3),
        ).show();
      }
    } catch (e) {
      Get.back();
    } finally {
      withdrawing.value = false;
    }
  }

  withdrawToBank(String amount) async {
    try {
      var response = await client.post(
          Uri.parse(
              "$baseUrl/stripe/payout/${Get.find<AuthController>().currentUser.value?.accountNumber}"),
          body: {
            "amount": amount,
          });

      Map<String, dynamic> result = jsonDecode(response.body);
      return result;
    } catch (e) {
      return null;
    }
  }

  stripeAccountTransactionsToBank() async {
    try {
      transactionsList.clear();
      loadingTransactions.value = true;

      var response = await client.get(
        Uri.parse(
            "$baseUrl/stripe/transactions/${Get.find<AuthController>().currentUser.value?.accountNumber}"),
      );

      Map<String, dynamic> result = jsonDecode(response.body);


        List responseData = result["response"]["data"];
        List<TransactionsModel> jsonData =
            responseData.map((e) => TransactionsModel.fromJson(e)).toList();
        transactionsList.assignAll(jsonData);

      loadingTransactions.value = false;
    } catch (e) {
      loadingTransactions.value = false;
    }
  }

  createTransaction(
      {required int amount,
      required String userId,
      required String type,
      required workId}) async {
    var docId = _firestore.doc().id;
    TransactionsModel transactionsModel = TransactionsModel(
      created: DateTime.now(),
      amount: amount,
      status: "pending",
      user: userId,
      type: type,
      workId: workId,
      docId: docId,
    );
    await _firestore.doc(docId).set(transactionsModel.toJson());
  }

  getTransactionsByUserId() async {
    try {
      transactionsList.clear();
      loadingTransactions.value = true;
      QuerySnapshot query = await _firestore
          .where("user",
              isEqualTo: Get.find<AuthController>().currentUser.value!.id!)
          .orderBy('created', descending: true)
          .get();

      if (query.docs.isNotEmpty) {
        for (var element in query.docs) {
          TransactionsModel transactionsModel = TransactionsModel.fromJson(
              element.data() as Map<String, dynamic>);

          transactionsList.add(transactionsModel);
        }
      } else {
        transactionsList.value = [];
      }
      loadingTransactions.value = false;
    } catch (e) {
      loadingTransactions.value = false;
    }
  }

  updateTransactionByWorkId({required String workId}) async {
    await _firestore.where("workId", isEqualTo: workId).get().then((value) {
      for (var i = 0; i <= value.docs.length; i++) {
        var id = value.docs[0].id;

        _firestore.doc(id).update({"status": "completed"});
      }
    });
  }
}
