import 'dart:convert';

import 'package:flutterbloc/services/api_urls.dart';
import 'package:flutterbloc/services/client.dart';

class PostService {
  static getAllPosts() async {
    var response =
        await DbBase.dataBaseRequest("${BASE_URL}/posts", DbBase.getRequest);
    return jsonDecode(response);
  }
  static getCommentsByPosts({required int postId}) async {
    var response =
        await DbBase.dataBaseRequest("${BASE_URL}/posts/$postId}/comments", DbBase.getRequest);
    return jsonDecode(response);
  }
}
