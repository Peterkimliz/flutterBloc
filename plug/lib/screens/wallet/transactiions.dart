import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:plugme/models/transactions.dart';
import 'package:plugme/utils/style.dart';
import 'package:plugme/widgets/common_text.dart';

import '../../controllers/service_controller.dart';
import '../../controllers/wallet_controller.dart';

class TransactionsPage extends StatelessWidget {
  TransactionsPage({Key? key}) : super(key: key) {
    _walletController.getTransactionsByUserId();
  }

  final WalletController _walletController = Get.find<WalletController>();
  final ServiceController _serviceController = Get.find<ServiceController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: whiteColor,
          ),
        ),
        backgroundColor: blueColor,
        title: const CommonText(
          color: whiteColor,
          text: "Transactions",
          fontFamily: "RedHatMedium",
          fontWeight: FontWeight.bold,
          size: 18,
        ),
        elevation: 0.1,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            color: blueColor,
            height: 60,
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40),
                    topLeft: Radius.circular(40))),
            padding: const EdgeInsets.only(top: 30, right: 10, left: 10),
            child: Obx(() {
              return _walletController.loadingTransactions.isTrue
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: blackColor,
                    ))
                  : _walletController.transactionsList.isEmpty
                      ? Center(
                          child: Text(
                            "No transactions yet",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16.sp),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _walletController.transactionsList.length,
                          itemBuilder: (context, index) {
                            TransactionsModel transaction = _walletController
                                .transactionsList
                                .elementAt(index);
                            return InkWell(
                              onTap: () {
                                _serviceController.getWorkById(transaction.workId!);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(
                                    top: 10, left: 5, right: 5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: lightGrey,
                                    boxShadow: const [
                                      BoxShadow(
                                        offset: Offset(0.1, 0.1),
                                        blurRadius: 1,
                                        color: greyColor,
                                        // spreadRadius: 1,
                                      )
                                    ]),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              transaction.type!
                                                  .capitalize!,
                                              style: TextStyle(
                                                color: blackColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14.sp,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            " ${transaction.type!.toLowerCase() == "transfered" ? "-" : ""}\$${transaction.amount!}",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 16.sp),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 3,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat("dd-MM-yyyy hh:mm").format(transaction.created!),
                                            style: TextStyle(
                                                color: blackColor,
                                                fontSize: 10.sp),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                                color: transaction.status ==
                                                        "pending"
                                                    ? Colors.orangeAccent
                                                    : Colors.green,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Text(
                                              "${transaction.status}"
                                                  .capitalize!,
                                              style: TextStyle(
                                                  color: whiteColor,
                                                  fontSize: 10.sp),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
            }),
          ),
        ],
      ),
    );
  }
}
