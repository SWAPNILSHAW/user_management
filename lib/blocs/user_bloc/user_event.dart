import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class FetchUsers extends UserEvent {
  final String? searchQuery; // Optional search query

  const FetchUsers({this.searchQuery});

  @override
  List<Object> get props => [searchQuery ?? ''];
}

class LoadMoreUsers extends UserEvent {
  const LoadMoreUsers();
}

class SearchUsers extends UserEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object> get props => [query];
}

class RefreshUsers extends UserEvent {
  const RefreshUsers();
}