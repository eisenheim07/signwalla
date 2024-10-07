import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../repos/app_repo.dart';

part 'signup_event.dart';

part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AppRepo appRepo;

  SignupBloc(this.appRepo) : super(SignupInitial()) {
    on<GetSignupEvent>((event, emit) async {
      try {
        emit(SignupLoading());
        var response = await appRepo.signup(event.firstName, event.lastName,
            event.phoneNo, event.email, event.password);
        if (response.user != null) {
          emit(SignupResult(response.user!));
        } else {
          emit(const SignupError("Signup Error, Something Went Wrong."));
        }
      } catch (e) {
        emit(SignupError(e.toString()));
      }
    });
  }
}
