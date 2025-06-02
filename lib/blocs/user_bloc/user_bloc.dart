import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart'; // For debounce
import '../../repositories/user_repository.dart';
import '../../constants.dart';
import 'user_event.dart';
import 'user_state.dart';
import '../../models/user.dart'; // Ensure User model is imported

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  int _currentPage = 0;
  String _currentSearchQuery = '';
  bool _isFetching = false; // To prevent multiple simultaneous fetches

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<FetchUsers>(_onFetchUsers);
    on<LoadMoreUsers>(_onLoadMoreUsers);
    on<SearchUsers>(
      _onSearchUsers,
      transformer: (events, mapper) => events.debounceTime(const Duration(milliseconds: 500)).flatMap(mapper),
    );
    on<RefreshUsers>(_onRefreshUsers);
  }

  Future<void> _onFetchUsers(FetchUsers event, Emitter<UserState> emit) async {
    if (_isFetching) return;
    _isFetching = true;

    _currentPage = 0; // Reset page for new fetch or search
    _currentSearchQuery = event.searchQuery ?? '';

    // Emit UserLoading, passing existing users if any, to prevent full screen loading flicker
    List<User> existingUsers = [];
    if (state is UserLoaded) {
      existingUsers = (state as UserLoaded).users;
    } else if (state is UserError) {
      existingUsers = (state as UserError).users;
    }
    emit(UserLoading(users: existingUsers));

    try {
      final users = await userRepository.getUsers(
        limit: AppConstants.usersPerPage,
        skip: _currentPage * AppConstants.usersPerPage,
        query: _currentSearchQuery,
        forceRefresh: true, // Force refresh for initial fetch/search
      );
      _isFetching = false;
      emit(UserLoaded(
        users: users,
        hasReachedMax: users.length < AppConstants.usersPerPage,
        currentSearchQuery: _currentSearchQuery,
      ));
    } catch (e) {
      _isFetching = false;
      emit(UserError(e.toString(), users: existingUsers)); // Pass existing users on error too
    }
  }

  Future<void> _onLoadMoreUsers(LoadMoreUsers event, Emitter<UserState> emit) async {
    if (_isFetching) return;
    if (state is! UserLoaded) return;

    final currentState = state as UserLoaded;
    if (currentState.hasReachedMax) return;

    _isFetching = true;
    _currentPage++;

    // When loading more, keep the current state as UserLoaded (with existing users)
    // and let the UI handle the loading indicator at the bottom of the list.
    // No explicit UserLoading state emission here to avoid full-screen loader.

    try {
      final newUsers = await userRepository.getUsers(
        limit: AppConstants.usersPerPage,
        skip: _currentPage * AppConstants.usersPerPage,
        query: _currentSearchQuery,
      );
      _isFetching = false;
      emit(currentState.copyWith(
        users: currentState.users + newUsers,
        hasReachedMax: newUsers.length < AppConstants.usersPerPage,
      ));
    } catch (e) {
      _isFetching = false;
      // If load more fails, keep existing users and emit error
      emit(UserError(e.toString(), users: currentState.users));
    }
  }

  Future<void> _onSearchUsers(SearchUsers event, Emitter<UserState> emit) async {
    if (_isFetching) return;
    _isFetching = true;

    _currentPage = 0; // Reset page for search
    _currentSearchQuery = event.query;

    // Show loading state for search, passing existing users if any
    List<User> existingUsers = [];
    if (state is UserLoaded) {
      existingUsers = (state as UserLoaded).users;
    } else if (state is UserError) {
      existingUsers = (state as UserError).users;
    }
    emit(UserLoading(users: existingUsers));

    try {
      final users = await userRepository.getUsers(
        limit: AppConstants.usersPerPage,
        skip: _currentPage * AppConstants.usersPerPage,
        query: _currentSearchQuery,
        forceRefresh: true, // Always force refresh for search
      );
      _isFetching = false;
      emit(UserLoaded(
        users: users,
        hasReachedMax: users.length < AppConstants.usersPerPage,
        currentSearchQuery: _currentSearchQuery,
      ));
    } catch (e) {
      _isFetching = false;
      emit(UserError(e.toString(), users: existingUsers)); // Pass existing users on search error
    }
  }

  Future<void> _onRefreshUsers(RefreshUsers event, Emitter<UserState> emit) async {
    if (_isFetching) return;
    _isFetching = true;

    _currentPage = 0; // Reset page for refresh
    // Keep current search query if any, otherwise reset
    final currentSearch = (state is UserLoaded) ? (state as UserLoaded).currentSearchQuery : '';
    _currentSearchQuery = currentSearch ?? '';

    try {
      final users = await userRepository.getUsers(
        limit: AppConstants.usersPerPage,
        skip: _currentPage * AppConstants.usersPerPage,
        query: _currentSearchQuery,
        forceRefresh: true, // Always force refresh for pull-to-refresh
      );
      _isFetching = false;
      emit(UserLoaded(
        users: users,
        hasReachedMax: users.length < AppConstants.usersPerPage,
        currentSearchQuery: _currentSearchQuery,
      ));
    } catch (e) {
      _isFetching = false;
      // On refresh error, keep the last loaded successful state's users.
      // If it was already in an error state with users, keep those.
      List<User> usersOnError = [];
      if (state is UserLoaded) {
        usersOnError = (state as UserLoaded).users;
      } else if (state is UserError) {
        usersOnError = (state as UserError).users;
      }
      emit(UserError(e.toString(), users: usersOnError));
    }
  }
}