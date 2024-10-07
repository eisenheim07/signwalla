part of 'user_selection_bloc.dart';

abstract class UserSelectionState extends Equatable {
  const UserSelectionState();

  @override
  List<Object> get props => [];
}

class UserSelectionLoading extends UserSelectionState {}

class UserSelectionLoaded extends UserSelectionState {
  final List<int> selectedIndexes;
  final List<UserModel> selectedUsers;
  final List<UserModel> allUsers;

  const UserSelectionLoaded({
    required this.selectedIndexes,
    required this.selectedUsers,
    required this.allUsers,
  });

  @override
  List<Object> get props => [selectedIndexes, selectedUsers, allUsers];
}

class UserSelectionError extends UserSelectionState {
  final String error;

  const UserSelectionError(this.error);

  @override
  List<Object> get props => [error];
}
