class Continents {
  String? name;
  List<Countries> ?countries;

  Continents({this.name,this.countries});
  factory Continents.fromJson(Map<String,dynamic>json)=>Continents(
      name: json["name"],
    countries: List.from(json["countries"].map((element)=>Countries.fromJson(element)))
  );

}

class Countries {
  String? name;
  String? code;
  String? emoji;

  Countries({this.name,this.code,this.emoji});
  factory Countries.fromJson(Map<String,dynamic>json)=>Countries(
    name: json["name"],
    code: json["phone"],
    emoji: json["emoji"]
  );
}
