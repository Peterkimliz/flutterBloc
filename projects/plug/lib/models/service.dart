class ServiceModel {
  String? name;
  String? subCategory;
  String? id;
  String? icon;
  bool? expand;
  bool? isSubcategory;
  List<String>?subcategory;


  ServiceModel({this.name, this.id, this.icon,this.subcategory,this.expand,this.subCategory,this.isSubcategory});

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        name: json["name"],
        id: json["id"],
        icon: json["icon"],
        subCategory: "",
        expand:false,
        isSubcategory: false,
        subcategory: json["subcategory"]==null?[]:List<String>.from(json["subcategory"].map((e)=>e))
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        "icon": icon,
        "subCategory":subCategory
      };
}
