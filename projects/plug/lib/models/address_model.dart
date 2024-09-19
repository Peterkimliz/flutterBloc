class Address {
  Address({
    this.addressComponents,
    this.formattedAddress,
    this.formattedPhoneNumber,
    this.geometry,
    this.icon,
    this.name,
    this.placeId,
  });

  List<AddressComponent>? addressComponents;
  String? formattedAddress;
  String? formattedPhoneNumber;
  Geometry? geometry;
  String? icon;
  String? name;
  String? placeId;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    addressComponents: List<AddressComponent>.from(
        json["address_components"]
            .map((x) => AddressComponent.fromJson(x))),
    formattedAddress: json["formatted_address"],
    formattedPhoneNumber: json["formatted_phone_number"],
    geometry: Geometry.fromJson(json["geometry"]),
    icon: json["icon"],
    name: json["name"],
    placeId: json["place_id"],
  );


  Map<String,dynamic>toJson()=>{
    "addressComponents": addressComponents!.map((e) => e.toJson()).toList(),
    "formattedAddress": formattedAddress,
    "icon": icon,
    "formattedPhoneNumber": formattedPhoneNumber,
    "geometry": geometry!.toJson(),
    "name": name,
    "placeId": placeId,

  };
}

class AddressComponent {
  AddressComponent({
    this.longName,
    this.shortName,
    this.types,
  });

  String? longName;
  String? shortName;
  List<String>? types;

  factory AddressComponent.fromJson(Map<String, dynamic> json) =>
      AddressComponent(
        longName: json["long_name"],
        shortName: json["short_name"],
        types: List<String>.from(json["types"].map((x) => x)),
      );



  Map<String,dynamic>toJson()=>{
    "longName": longName,
    "shortName": shortName,
    "types": types,

  };



}

class Geometry {
  Geometry({
    this.location,
  });

  Location? location;

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    location: Location.fromJson(json["location"]),
  );

  Map<String,dynamic>toJson()=>{
    "location": location!.toJson(),

  };

}

class Location {
  Location({
    this.lat,
    this.lng,
  });

  double? lat;
  double? lng;

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    lat: json["lat"].toDouble(),
    lng: json["lng"].toDouble(),
  );

  Map<String,dynamic>toJson()=>{
    "lat": lat,
    "lng": lng
  };

}
