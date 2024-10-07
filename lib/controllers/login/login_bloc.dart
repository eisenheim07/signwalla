import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:signwalla/common/constants.dart';
import 'package:signwalla/common/preffs_manager.dart';

import '../../repos/app_repo.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AppRepo appRepo;
  final PreferenceManager preffs;

  LoginBloc(this.appRepo, this.preffs) : super(LoginInitial()) {
    on<GetLoginEvent>((event, emit) async {
      try {
        emit(LoginLoading());
        var response = await appRepo.signin(event.email, event.password);
        if (response != null) {
          preffs.putString(Constants.LOGIN_TOKEN, response.uid);
          emit(LoginResult(response));
        } else {
          emit(const LoginError("Login Error, Something Went Wrong"));
        }
      } catch (e) {
        emit(LoginError(e.toString()));
      }
    });

    on<GetLogoutEvent>((event, emit) async {
      try {
        emit(LoginLoading());
        await appRepo.logout();
        var response = await preffs.clear();
        emit(LogoutResult(response));
      } catch (e) {
        emit(LoginError(e.toString()));
      }
    });
  }
}
