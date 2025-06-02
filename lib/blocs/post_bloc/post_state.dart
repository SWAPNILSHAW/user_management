import 'package:equatable/equatable.dart';
import '../../models/post.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;
  const PostLoaded(this.posts);

  @override
  List<Object?> get props => [posts];
}
