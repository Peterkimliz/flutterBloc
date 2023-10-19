import 'package:bloc/bloc.dart';
import 'package:flutterbloc/data/models/posts.dart';
import 'package:flutterbloc/data/repository/post_repository.dart';
import 'package:meta/meta.dart';

part 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  final PostRepository postRepository;

  PostsCubit({required this.postRepository}) : super(PostsInitial());

  void fetchPosts() async {
    emit(PostsLoading());
    postRepository.fetchPosts().then((posts) {
      emit(PostsLoaded(posts: posts));
    });
  }


}
