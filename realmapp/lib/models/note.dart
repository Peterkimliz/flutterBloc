import 'package:realm/realm.dart';

part 'note.g.dart';

@RealmModel()
class _Note {
  @PrimaryKey()
  @MapTo("_id")
  late ObjectId id;
  late String title;
  late String message;
  late DateTime date;
  late _Categories? category;
  late _UserModel? user;
}

@RealmModel()
class _UserModel {
  @PrimaryKey()
  @MapTo("_id")
  late ObjectId id;
  late String email;
  @Ignored()
  late String password;
  late String fullname;
  late String phone;
}

@RealmModel()
class _Categories {
  @PrimaryKey()
  @MapTo("_id")
  late ObjectId id;
  late String type;
  late String color;
}
