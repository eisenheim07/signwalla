part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class GetLoginEvent extends LoginEvent {
  final String email;
  final String password;

  const GetLoginEvent(this.email, this.password);
}

class GetLogoutEvent extends LoginEvent {}
