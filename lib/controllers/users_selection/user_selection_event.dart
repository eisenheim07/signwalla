part of 'user_selection_bloc.dart';

abstract class UserSelectionEvent extends Equatable {
  const UserSelectionEvent();

  @override
  List<Object> get props => [];
}

class LoadUsersEvent extends UserSelectionEvent {}

class ToggleUserSelectionEvent extends UserSelectionEvent {
  final int index;
  final UserModel user;

  const ToggleUserSelectionEvent(this.index, this.user);

  @override
  List<Object> get props => [index, user];
}
