part of 'posts_cubit.dart';

@immutable
abstract class PostsState {}

class PostsInitial extends PostsState {}
class PostsLoading extends PostsState {}

class PostsLoaded extends PostsState {
  final List<Posts> posts;

  PostsLoaded({required this.posts});
}
