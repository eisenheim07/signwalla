part of 'signup_bloc.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object?> get props => [];
}

class GetSignupEvent extends SignupEvent {
  final String firstName;
  final String lastName;
  final String phoneNo;
  final String email;
  final String password;

  const GetSignupEvent(
      this.firstName, this.lastName, this.phoneNo, this.email, this.password);
}
