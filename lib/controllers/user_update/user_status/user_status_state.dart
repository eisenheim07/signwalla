part of 'user_status_bloc.dart';

abstract class UserStatusState extends Equatable {
  const UserStatusState();

  @override
  List<Object> get props => [];
}

final class UserStatusInitial extends UserStatusState {}

class UserStatusLoading extends UserStatusState {}

class UserStatusResult extends UserStatusState {}

class UserStatusError extends UserStatusState {
  final String error;

  const UserStatusError(this.error);
}
