import 'dart:convert';

import 'package:http/http.dart' as http;

class DbBase {
  static const postRequest = "POST";
  static const getRequest = "GET";
  static const putRequest = "PUT";
  static const deleteRequest = "DELETE";

  static dataBaseRequest(String url, String method,
      {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    try {
      headers ??= {"Content-Type": "application/json"};
      var request = http.Request(method, Uri.parse(url));
      if (body != null) {
        var jsonBody = json.encode(body);
        request.body = jsonBody;
      }
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.stream.bytesToString();
    } catch (e) {
      print(e);
    }
  }
}
