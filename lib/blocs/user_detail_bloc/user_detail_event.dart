import 'package:equatable/equatable.dart';
// No need for userId in event if the User object is passed directly to BLoC constructor
// as the BLoC already has the user.id.
// This event is primarily to trigger the data fetching.

abstract class UserDetailEvent extends Equatable {
  const UserDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchUserDetail extends UserDetailEvent {
  // No need for userId here, as the BLoC already has the user.id from its constructor.
  // This event just signals to the BLoC to start fetching associated data.
  const FetchUserDetail();

  @override
  List<Object> get props => [];
}