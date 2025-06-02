import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/post.dart';
import '../../models/todo.dart';
import '../../repositories/user_repository.dart';
import 'user_detail_event.dart';
import 'user_detail_state.dart';
import '../../models/user.dart'; // Ensure this import is present

class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  final UserRepository userRepository;
  // The user object is passed to the BLoC's constructor as it's already available
  // from the UserListScreen when navigating to UserDetailScreen.
  final User user;

  UserDetailBloc({required this.userRepository, required this.user}) : super(UserDetailInitial()) {
    on<FetchUserDetail>(_onFetchUserDetail);
  }

  Future<void> _onFetchUserDetail(FetchUserDetail event, Emitter<UserDetailState> emit) async {
    emit(UserDetailLoading());
    try {
      // Fetch posts and todos concurrently for the specific user's ID
      final results = await Future.wait([
        userRepository.getUserPosts(user.id),
        userRepository.getUserTodos(user.id),
      ]);

      final List<Post> posts = results[0] as List<Post>;
      final List<Todo> todos = results[1] as List<Todo>;

      // Emit the UserDetailLoaded state with the user object received by the BLoC,
      // and the fetched posts and todos.
      emit(UserDetailLoaded(
        user: user,
        posts: posts,
        todos: todos,
      ));
    } catch (e) {
      emit(UserDetailError(e.toString()));
    }
  }
}