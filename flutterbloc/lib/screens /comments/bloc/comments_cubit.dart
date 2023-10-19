import 'package:bloc/bloc.dart';
import 'package:flutterbloc/data/models/comments.dart';
import 'package:flutterbloc/data/repository/post_repository.dart';
import 'package:meta/meta.dart';

part 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  final PostRepository postRepository;

  CommentsCubit({required this.postRepository}) : super(CommentsInitial());

  fetchComments({required int id}){
    emit(CommentsLoading());
    postRepository.fetchComments(id).then((comments) {
      emit(CommentsLoaded(comments: comments));
    });
  }
}
