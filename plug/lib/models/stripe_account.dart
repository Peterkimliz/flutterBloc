class StripeAccount {
  StripeAccount({
    this.accountHolderName,
    this.accountHolderType,
    this.accountType,
    this.bankName,
    this.country,
    this.currency,
    this.last4,
  });
  String? accountHolderName;
  String? accountHolderType;
  dynamic accountType;
  String? bankName;
  String? country;
  String? currency;
  String? last4;

  factory StripeAccount.fromJson(Map<String, dynamic> json) => StripeAccount(
    accountHolderName: json["account_holder_name"],
    accountHolderType: json["account_holder_type"],
    accountType: json["account_type"],
    bankName: json["bank_name"],
    country: json["country"],
    currency: json["currency"],
    last4: json["last4"],
  );
}

class Metadata {
  Metadata();

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata();

  Map<String, dynamic> toJson() => {};
}