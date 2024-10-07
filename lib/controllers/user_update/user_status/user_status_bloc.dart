import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../repos/app_repo.dart';

part 'user_status_event.dart';

part 'user_status_state.dart';

class UserStatusBloc extends Bloc<UserStatusEvent, UserStatusState> {
  final AppRepo appRepo;

  UserStatusBloc(this.appRepo) : super(UserStatusInitial()) {
    on<GetUserStatusEvent>((event, emit) async {
      try {
        await appRepo.getUpdateStatus(event.uuid, event.status, event.key);
      } catch (e) {
        emit(UserStatusError(e.toString()));
      }
    });
  }
}
