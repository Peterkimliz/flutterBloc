
class Rating {
  String? message;
  String? username;
  String? userid;
  String? reviewedId;
  String? profileImage;
  int? rating;

  Rating(
      {this.message,
      this.userid,
      this.username,
      this.rating,
      this.reviewedId,
      this.profileImage});

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
        message: json["message"],
        username: json["username"],
        userid: json["userid"],
        rating: json["rating"],
        profileImage:
            json["profileImage"],
        reviewedId: json["reviewedId"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "username": username,
        "userid": userid,
        "rating": rating,
        "reviewedId": reviewedId,

    "profileImage":profileImage
      };
}
