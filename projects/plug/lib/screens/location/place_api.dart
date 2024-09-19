import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plug/screens/location/location_screen.dart';

import '../../utils/constants.dart';

class PlaceApiProvider {
  PlaceApiProvider(this.sessionToken);

  final String sessionToken;

  http.Request createGetRequest(String url) =>
      http.Request('GET', Uri.parse(url));

  Future<List<Suggestion>> fetchSuggestions(String input) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$mapKey&sessiontoken=$sessionToken';
    var request = createGetRequest(url);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final result = json.decode(data);
      print("result is $result");
      if (result['status'] == 'OK') {
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description'],
                p['structured_formatting']['main_text']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<PlaceDetail> getPlaceDetailFromId(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_address,name,geometry/location&key=$mapKey&sessiontoken=$sessionToken';
    var request = createGetRequest(url);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      final result = json.decode(data);
      print(result);

      if (result['status'] == 'OK') {
        // build result
        final place = PlaceDetail();
        place.address = result['result']['formatted_address'];
        place.latitude = result['result']['geometry']['location']['lat'];
        place.longitude = result['result']['geometry']['location']['lng'];
        place.name = result['result']['geometry']['name'];
        return place;
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }
}
