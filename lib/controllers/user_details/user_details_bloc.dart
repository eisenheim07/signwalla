import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repos/app_repo.dart';

part 'user_details_event.dart';

part 'user_details_state.dart';

class UserDetailsBloc extends Bloc<UserDetailsEvent, UserDetailsState> {
  final AppRepo appRepo;

  UserDetailsBloc(this.appRepo) : super(UserDetailsInitial()) {
    on<GetUserDetailsEvent>((event, emit) async {
      try {
        emit(UserDetailsLoading());
        var response = await appRepo.getUserDetails(event.uuid);
        if (response.docs[0].data().isNotEmpty) {
          emit(UserDetailsResult(response.docs[0].data()));
        } else {
          emit(const UserDetailsError("Fetch Error, Something Went Wrong."));
        }
      } catch (e) {
        emit(UserDetailsError(e.toString()));
      }
    });
  }
}
