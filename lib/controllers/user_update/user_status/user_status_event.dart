part of 'user_status_bloc.dart';

abstract class UserStatusEvent extends Equatable {
  const UserStatusEvent();

  @override
  List<Object?> get props => [];
}

class GetUserStatusEvent extends UserStatusEvent {
  final String uuid;
  final String status;
  final String key;

  const GetUserStatusEvent(this.uuid, this.status, this.key);
}
