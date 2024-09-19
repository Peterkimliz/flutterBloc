class PlacePrediction {
  PlacePrediction({
    this.description,
    this.placeId,
    this.reference,
    this.structuredFormatting,
  });

  String ?description;
  String ?placeId;
  String ?reference;
  StructuredFormatting ?structuredFormatting;

  factory PlacePrediction.fromJson(json) => PlacePrediction(
    description: json["description"],
    placeId: json["place_id"],
    reference: json["reference"],
    structuredFormatting: StructuredFormatting.fromJson(json["structured_formatting"]),
  );

  Map<String,dynamic>toJson()=>{
    "description": description,
    "placeId": placeId,
    "reference": reference,
    "structuredFormatting": structuredFormatting!.toJson(),


  };


}

class StructuredFormatting {
  StructuredFormatting({
    this.mainText,
    this.secondaryText,
  });

  String? mainText;

  String? secondaryText;

  factory StructuredFormatting.fromJson(Map<String, dynamic> json) => StructuredFormatting(
    mainText: json["main_text"],
    secondaryText: json["secondary_text"],
  );

  Map<String,dynamic>toJson()=>{
    "mainText": mainText,
    "secondaryText": secondaryText
  };

}

