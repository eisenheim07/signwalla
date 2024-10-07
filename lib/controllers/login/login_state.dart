part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginResult extends LoginState {
  final User user;

  const LoginResult(this.user);
}

class LoginError extends LoginState {
  final String error;

  const LoginError(this.error);
}

class LogoutResult extends LoginState{
  final bool result;
  const LogoutResult(this.result);
}
