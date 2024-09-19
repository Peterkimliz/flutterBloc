import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:plug/models/chat.dart';
import 'package:plug/models/location_model.dart';
import '../screens/location/location_screen.dart';
import '../screens/location/place_api.dart';
import 'package:uuid/uuid.dart';
import '../utils/constants.dart';

class LocationController extends GetxController {
  RxSet<Marker> markers = RxSet<Marker>();
  RxBool loadingPolyLines=RxBool(false);

  RxSet<Polyline> polyline = RxSet<Polyline>({});

  final provider = PlaceApiProvider(const Uuid().v4());
  final controller = Completer<GoogleMapController>();

  RxBool loadingLocation = RxBool(false);
  RxList<Suggestion> suggestion = RxList([]);
  Rxn<PlaceDetail> fromPlace = Rxn(null);
  Rxn<PlaceDetail> toPlace = Rxn(null);

  void getMarkers(
      {required double startLat,
      required double startLong,
      required double endLat,
      required double endLong}) async {
    Marker marker1 = Marker(
      markerId: MarkerId(startLat.toString() + startLong.toString()),
      position: LatLng(startLat, startLong),
    );
    Marker marker2 = Marker(
      markerId: MarkerId(endLat.toString() + endLong.toString()),
      position: LatLng(endLat, endLong),
    );
    markers.add(marker1);
    markers.add(marker2);
    markers.refresh();
  }

  getDirections(
      {required double startLat,
      required double startLong,
      required double endLat,
      required double endLong}) async {
    try {
      loadingPolyLines.value=true;
      List<LatLng> polylineCoordinates = [];
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        mapKey,
        PointLatLng(startLat, startLong),
        PointLatLng(endLat, endLong),
        travelMode: TravelMode.driving,
      );
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {}
      Polyline pollinates = Polyline(
        color: Colors.deepPurpleAccent,
        points: polylineCoordinates,
        width: 8,
        polylineId: const PolylineId("poly"),
      );
      polyline.add(pollinates);
      // polyline.refresh();


      _updateMapBounds(polylineCoordinates);
      loadingPolyLines.value=false;

    } catch (e) {
      loadingPolyLines.value=false;

    }
  }


  void _updateMapBounds(List<LatLng> polylineCoordinates) async {
    final bounds = getBounds(polylineCoordinates);
    final GoogleMapController control =await controller.future;
    control.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    polyline.refresh();
  }

  LatLngBounds getBounds(List<LatLng> points) {
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }





  fetchPlacesByName(String name) async {
    try {
      suggestion.clear();
      loadingLocation.value = true;
      List<Suggestion> response = await provider.fetchSuggestions(name);
      loadingLocation.value = false;
      suggestion.assignAll(response);
      suggestion.refresh();
    } catch (e) {
      loadingLocation.value = false;
      print(e);
    }
  }

  fetchPlaceDetail({required String placeId, required type}) async {
    try {
      Get.dialog(
          barrierDismissible: false,
          Dialog(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: const Row(
                children: [
                  Text("Just a moment"),
                  SizedBox(
                    width: 10,
                  ),
                  CircularProgressIndicator()
                ],
              ),
            ),
          ));
      PlaceDetail response = await provider.getPlaceDetailFromId(placeId);
      Get.back();
      if (type == "from") {
        fromPlace.value = response;
      } else {
        toPlace.value = response;
      }
    } catch (e) {
      Get.back();
      loadingLocation.value = false;
      print(e);
    }
  }

  void drawRoute({required Chat chatData}) {
    try {
      LocationModel pickUp = LocationModel(
          name: chatData.pickUp?.name, geoPoint: chatData.pickUp?.geoPoint);
      LocationModel destination = LocationModel(
          name: chatData.destination?.name,
          geoPoint: chatData.destination?.geoPoint);

      getMarkers(
          startLat: pickUp.geoPoint!.latitude,
          startLong: pickUp.geoPoint!.longitude,
          endLat: destination.geoPoint!.latitude,
          endLong: destination.geoPoint!.longitude);

      getDirections(
          startLat: pickUp.geoPoint!.latitude,
          startLong: pickUp.geoPoint!.longitude,
          endLat: destination.geoPoint!.latitude,
          endLong: destination.geoPoint!.longitude);
    } catch (e) {
      print(e);
    }
  }

  void getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position currentLocation = await Geolocator.getCurrentPosition();
    print("placeDetails");
    final placeDetails = await getPlaceDetails(
        currentLocation.latitude, currentLocation.longitude);
    print(placeDetails);
  }

  getPlaceDetails(double latitude, double longitude) async {
    Get.dialog(
        barrierDismissible: false,
        Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Text("Just a moment"),
                SizedBox(
                  width: 10,
                ),
                CircularProgressIndicator()
              ],
            ),
          ),
        ));
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$mapKey';
    final response = await http.get(Uri.parse(url));
    Get.back();
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      PlaceDetail placeDetail = PlaceDetail(
        address: responseData["results"][0]["formatted_address"],
        latitude: responseData["results"][0]["geometry"]["location"]["lat"],
        longitude: responseData["results"][0]["geometry"]["location"]["lng"],
        name: responseData["results"][0]["formatted_address"],
      );
      fromPlace.value = placeDetail;
    } else {
      throw Exception('Failed to load place details');
    }
  }
}
