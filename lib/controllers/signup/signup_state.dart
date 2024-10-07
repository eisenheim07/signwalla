part of 'signup_bloc.dart';

abstract class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object> get props => [];
}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState{}

class SignupResult extends SignupState{
  final User user;
  const SignupResult(this.user);
}

class SignupError extends SignupState{
  final String error;
  const SignupError(this.error);
}
