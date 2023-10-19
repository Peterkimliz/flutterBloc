import 'package:flutterbloc/data/models/comments.dart';
import 'package:flutterbloc/data/models/posts.dart';
import 'package:flutterbloc/services/posts.dart';

class PostRepository {
  Future<List<Posts>> fetchPosts() async {
    List posts = await PostService.getAllPosts();
    List<Posts> decodedPosts = posts.map((e) => Posts.fromJson(e)).toList();
    return decodedPosts;
  }
  Future<List<Comments>> fetchComments(int id) async {
    List comments = await PostService.getCommentsByPosts(postId: id);
    List<Comments> decodedPosts = comments.map((e) => Comments.fromJson(e)).toList();
    return decodedPosts;
  }
}
