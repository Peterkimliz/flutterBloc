
class BankDetails {
  String? frontImage;
  String? backImage;
  String? firstName;
  String? lastName;
  String? country;
  String? city;
  String? state;
  String? userId;

  BankDetails(
      {this.userId,
      this.firstName,
      this.backImage,
      this.city,
      this.country,
      this.frontImage,
      this.lastName,
      this.state,

   });

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
        frontImage: json["frontImage"],
        backImage: json["backImage"],
        firstName: json["firstName"],
        lastName: json["LastName"],
        country: json["country"],
        city: json["city"],
        state: json["state"],
        userId: json["userId"],

      );
}
