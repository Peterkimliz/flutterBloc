class Subcategory {
  String? name;
  Subcategory({this.name});

  factory Subcategory.fromJson(Map<String, dynamic> json) => Subcategory(
    name: json["name"],
  );
  Map<String,dynamic>toJson()=>{
    "name": name,
  };
}