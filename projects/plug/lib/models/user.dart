import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:plug/models/service.dart';

class UserModel {
  String? email;
  String? workProfile;
  String? firstname;
  String? lastname;
  String? profileUrl;
  String? address;
  GeoPoint? geoPoint;
  ServiceModel? service;
  List<UserModel>? followers;
  List<UserModel>? following;
  List<String>?blockedUsers;
  int? followersCount;
  int ?followingCount;
  int ?totalJobs;
  List ?rehire;
  String? id;
  String? bio;
  bool? isServiceProvider;
  bool? workFromHome;
  int? totalRatingCount;
  int? totalRating;
  int? pricePerHour;
  bool? seeBio;
  String? playerId;
  String? accountNumber;
  bool ?accountConnected;
  String? customerId;
  String? accountType;
  bool? isOnline;
  bool? isAccountVerified;
  bool? accountEnabled;
  double? pendingAmount;
  double? availableAmount;
  List<String>? availability;
  String? bankName;
  int? agorauuid;
  bool? featured;
  bool? showComments;
  DateTime? lastSeen;

  UserModel(
      {this.email,
      this.address,
      this.firstname,
      this.lastname,
      this.profileUrl,
      this.id,
      this.geoPoint,
      this.service,
      this.isServiceProvider,
      this.workFromHome,
      this.workProfile,
      this.seeBio,
      this.playerId,
      this.totalRating,
      this.bankName,
      this.totalRatingCount,
      this.pricePerHour,
      this.accountNumber,
      this.bio,
      this.customerId,
      this.isOnline,
      this.availableAmount,
      this.pendingAmount,
      this.availability,
      this.accountConnected,
      this.followers,
      this.following,
      this.totalJobs,
      this.rehire,
      this.followersCount,
      this.followingCount,
      this.isAccountVerified,
      this.accountEnabled,
      this.agorauuid,
      this.featured,
      this.lastSeen,
      this.blockedUsers,
      this.accountType,
      this.showComments});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("data $json");

    return UserModel(
      email: json["email"],
      showComments: json["showComments"],
      workProfile: json["workProfile"],
      firstname: json["profileUrl"] == null ? null : json["firstname"].toString().capitalize,
      accountType: json["accountType"],
      lastname: json["firstname"] == null ? null : json["lastname"].toString().capitalize,
      profileUrl: json["profileUrl"],
      seeBio: false,
      service: json["service"] == null
          ? null
          : ServiceModel.fromJson(Map<String, dynamic>.from(json["service"])),
      availability: json["availability"] == null
          ? []
          : List.from(json["availability"].map((e) => e)),
      address: json["address"],
      geoPoint: json["geoPoint"],
      bio: json["bio"],
      workFromHome: json["workFromHome"],
      isServiceProvider: json["isServiceProvider"],
      totalRating: json["totalRating"] ?? 0,
      totalRatingCount: json["totalRatingCount"] ?? 0,
      pricePerHour: json["pricePerHour"],
      playerId: json["playerId"],
      id: json["id"],
      accountNumber: json["accountNumber"],
      customerId: json["customerId"],
      isOnline: json["isOnline"] ?? false,
      pendingAmount: 0,
      accountConnected: json["accountConnected"],
      bankName: json["bankName"],
      followers: json["followers"] == null
          ? []
          : List<UserModel>.from(
              json["followers"].map((e) => UserModel.fromJson(e))),
      following: json["following"] == null
          ? []
          : List<UserModel>.from(
              json["following"].map((e) => UserModel.fromJson(e))),
      blockedUsers: json["blockedUsers"] == null
          ? []
          : List<String>.from(json["blockedUsers"].map((e) => e)),
      availableAmount: 0,
      followersCount: json["followersCount"],
      followingCount: json["followingCount"],
      totalJobs: json["totalJobs"],
      agorauuid: json["agorauuid"],
      featured: json["featured"],
      rehire: json["rehire"],
      isAccountVerified: json["isAccountVerified"],
      lastSeen:
          json["lastSeen"] == null ? DateTime.now() : json["lastSeen"].toDate(),
      accountEnabled: json["accountEnabled"] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        "totalRatingCount": 0,
        "totalRating": 0,
        "email": email,
        "firstname": firstname,
        "lastname": lastname,
        "profileUrl": profileUrl,
        "service": service == null ? null : service!.toJson(),
        "geoPoint": geoPoint,
        "address": address,
        "workProfile": workProfile ?? "",
        "bio": " ",
       "bankName":"",
        "pricePerHour":0,
       "accountType":accountType,
        "isServiceProvider": false,
        "workFromHome": false,
        "isOnline": false,
       "accountConnected":false,
       "isAccountVerified":false,
       "following":[],
       "followers":[],
       "followingCount":0,
       "followersCount":0,
       "totalJobs":0,
       "blockedUsers":blockedUsers,
        "rehire": [],
        "accountEnabled": accountEnabled,
        "id": id,
        "playerId": playerId,
        "accountNumber": accountNumber,
        "customerId": customerId,
        "availability": availability?.map((e) => e).toList(),
        "agorauuid": agorauuid,
        "featured": featured,
        "lastSeen": lastSeen,
        "showComments": true,
      };


     getTotalRehires(){
       num sum =0;
       if (rehire!.isEmpty) {
         return 0;
       }else{
       for(var i=0; i<rehire!.length;i++){
         sum+=(rehire![i]["value"]-1);
       }
       return sum;
       }
     }

}

