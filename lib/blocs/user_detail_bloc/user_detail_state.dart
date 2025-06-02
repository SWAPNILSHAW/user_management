import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../models/post.dart';
import '../../models/todo.dart';

abstract class UserDetailState extends Equatable {
  const UserDetailState();

  @override
  List<Object> get props => [];
}

class UserDetailInitial extends UserDetailState {}

class UserDetailLoading extends UserDetailState {}

class UserDetailLoaded extends UserDetailState {
  final User user;
  final List<Post> posts;
  final List<Todo> todos;

  const UserDetailLoaded({
    required this.user,
    required this.posts,
    required this.todos,
  });

  @override
  List<Object> get props => [user, posts, todos];
}

class UserDetailError extends UserDetailState {
  final String message;

  const UserDetailError(this.message);

  @override
  List<Object> get props => [message];
}