import 'package:equatable/equatable.dart';
import '../../models/post.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object?> get props => [];
}

class AddPost extends PostEvent {
  final Post post;
  const AddPost(this.post);

  @override
  List<Object?> get props => [post];
}

class LoadPosts extends PostEvent {
  const LoadPosts();
}
