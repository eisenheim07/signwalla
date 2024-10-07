import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signwalla/common/colors.dart';
import 'package:signwalla/common/constants.dart';
import 'package:signwalla/controllers/users_selection/user_selection_bloc.dart';
import 'package:signwalla/widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    context.read<UserSelectionBloc>().add(LoadUsersEvent());
  }

  Stream<DocumentSnapshot> getUserStatusStream(String userId) {
    return _firestore.collection(Constants.DB_NAME).doc(userId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _firebaseAuth.currentUser;

    return Scaffold(
      body: BlocBuilder<UserSelectionBloc, UserSelectionState>(
        builder: (context, state) {
          if (state is UserSelectionLoading) {
            return const LoadingWidget();
          } else if (state is UserSelectionLoaded) {
            final users = state.allUsers;
            final selectedIndexes = state.selectedIndexes;

            return Padding(
              padding: EdgeInsets.all(8.sp),
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  if (user.uuid == currentUser?.uid) {
                    return Container();
                  }
                  final isSelected = selectedIndexes.contains(index);

                  return StreamBuilder<DocumentSnapshot>(
                    stream: getUserStatusStream(user.uuid),
                    builder: (context, snapshot) {
                      bool isOnline = false;

                      if (snapshot.connectionState == ConnectionState.active &&
                          snapshot.hasData &&
                          snapshot.data != null) {
                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        isOnline = userData['userStatus'] == 'online';
                      }

                      return Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: GestureDetector(
                          onTap: () {
                            context
                                .read<UserSelectionBloc>()
                                .add(ToggleUserSelectionEvent(index, user));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.greenColor : null,
                              border:
                                  Border.all(color: AppColors.primarymaincolor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: AppColors.primarymaincolor),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 24.h,
                                        backgroundColor: AppColors.greyColor,
                                        child: const Icon(Icons.person,
                                            color: AppColors.whiteColor),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${user.firstName} ${user.lastName}',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              user.email,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CircleAvatar(
                                        radius: 5.h,
                                        backgroundColor: isOnline
                                            ? AppColors.greenColor
                                            : AppColors.greyColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          } else if (state is UserSelectionError) {
            return Center(child: Text('Error: ${state.error}'));
          }
          return Container();
        },
      ),
    );
  }
}
