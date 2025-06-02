import 'package:equatable/equatable.dart';
import '../../models/user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {
  // Add users property to UserLoading to enable displaying existing data
  // while new data is being loaded (e.g., for infinite scroll).
  final List<User> users;
  const UserLoading({this.users = const []});

  @override
  List<Object> get props => [users];
}

class UserLoaded extends UserState {
  final List<User> users;
  final bool hasReachedMax; // Indicates if all users have been loaded
  final String? currentSearchQuery; // To maintain search state

  const UserLoaded({
    required this.users,
    this.hasReachedMax = false,
    this.currentSearchQuery,
  });

  UserLoaded copyWith({
    List<User>? users,
    bool? hasReachedMax,
    String? currentSearchQuery,
  }) {
    return UserLoaded(
      users: users ?? this.users,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
    );
  }

  @override
  List<Object> get props => [users, hasReachedMax, currentSearchQuery ?? ''];
}

class UserError extends UserState {
  final String message;
  // Also keep users data on error if available, to show existing data with an error message
  final List<User> users;

  const UserError(this.message, {this.users = const []});

  @override
  List<Object> get props => [message, users];
}