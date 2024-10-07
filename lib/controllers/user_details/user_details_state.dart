part of 'user_details_bloc.dart';

abstract class UserDetailsState extends Equatable {
  const UserDetailsState();

  @override
  List<Object> get props => [];
}

final class UserDetailsInitial extends UserDetailsState {}

class UserDetailsLoading extends UserDetailsState {}

class UserDetailsResult extends UserDetailsState {
  final Map<String, dynamic> data;
  const UserDetailsResult(this.data);
}

class UserDetailsError extends UserDetailsState {
  final String error;

  const UserDetailsError(this.error);
}
