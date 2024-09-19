class TransactionsModel {
  int? amount;
  DateTime? created;
  String? status;
  String? type;
  String? user;
  String? docId;
  String? workId;

  TransactionsModel(
      {this.amount,
      this.status,
      this.created,
      this.type,
      this.user,
      this.docId,this.workId});

  factory TransactionsModel.fromJson(Map<String, dynamic> json) =>
      TransactionsModel(
        amount: json["amount"],
        status: json["status"],
        user: json["user"],
        type: json["type"],
        docId: json["docId"],
        workId: json["workId"],
        created: json["created"].toDate(),
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "status": status,
        "created": created,
        "type": type,
        "user": user,
        "docId": docId,
        "workId": workId,
      };
}
