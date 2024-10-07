import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signwalla/common/constants.dart';
import 'package:signwalla/models/user_model.dart';

part 'user_selection_event.dart';
part 'user_selection_state.dart';

class UserSelectionBloc extends Bloc<UserSelectionEvent, UserSelectionState> {
  final FirebaseFirestore firestore;

  UserSelectionBloc(this.firestore) : super(UserSelectionLoading()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<ToggleUserSelectionEvent>(_onToggleUserSelection);
  }

  void _onLoadUsers(LoadUsersEvent event, Emitter<UserSelectionState> emit) async {
    try {
      final usersSnapshot = await firestore.collection(Constants.DB_NAME).get();
      final users = usersSnapshot.docs.map((doc) => UserModel.fromFirestore(doc.data())).toList();

      final currentUser = FirebaseAuth.instance.currentUser;
      List<int> selectedIndexes = [];
      List<UserModel> selectedUsers = [];

      if (currentUser != null) {
        final selectedUsersSnapshot = await firestore.collection(Constants.DB_SELECTED_USERS).doc(currentUser.uid).get();

        if (selectedUsersSnapshot.exists) {
          selectedUsers = List<UserModel>.from((selectedUsersSnapshot.data()?['users'] ?? []).map((data) => UserModel.fromFirestore(data)));

          for (var selectedUser in selectedUsers) {
            final index = users.indexWhere((user) => user.uuid == selectedUser.uuid);
            if (index != -1) {
              selectedIndexes.add(index);
            }
          }
        }
      }

      emit(UserSelectionLoaded(
        selectedIndexes: selectedIndexes,
        selectedUsers: selectedUsers,
        allUsers: users,
      ));
    } catch (e) {
      emit(UserSelectionError(e.toString()));
    }
  }

  void _onToggleUserSelection(ToggleUserSelectionEvent event, Emitter<UserSelectionState> emit) async {
    if (state is UserSelectionLoaded) {
      final currentState = state as UserSelectionLoaded;
      final selectedIndexes = List<int>.from(currentState.selectedIndexes);
      final selectedUsers = List<UserModel>.from(currentState.selectedUsers);

      if (selectedIndexes.contains(event.index)) {
        selectedIndexes.remove(event.index);
        selectedUsers.removeWhere((u) => u.uuid == event.user.uuid);
      } else {
        selectedIndexes.add(event.index);
        selectedUsers.add(event.user);
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        if (selectedUsers.isEmpty) {
          await firestore.collection(Constants.DB_SELECTED_USERS).doc(currentUser.uid).delete();
        } else {
          await firestore.collection(Constants.DB_SELECTED_USERS).doc(currentUser.uid).set({
            'users': selectedUsers.map((u) => u.toMap()).toList(),
          });
        }
      }

      emit(UserSelectionLoaded(
        selectedIndexes: selectedIndexes,
        selectedUsers: selectedUsers,
        allUsers: currentState.allUsers,
      ));
    }
  }
}
