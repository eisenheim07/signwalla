import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signwalla/common/colors.dart';
import 'package:signwalla/common/preffs_manager.dart';
import 'package:signwalla/common/theme.dart';
import 'package:signwalla/controllers/users_selection/user_selection_bloc.dart';
import 'package:signwalla/controllers/signup/signup_bloc.dart';
import 'package:signwalla/controllers/user_details/user_details_bloc.dart';
import 'package:signwalla/repos/app_repo.dart';
import 'package:signwalla/ui/splash_page.dart';
import 'controllers/login/login_bloc.dart';
import 'controllers/user_update/user_status/user_status_bloc.dart';

class ChatApp extends StatefulWidget {
  final SharedPreferences preffs;

  const ChatApp({super.key, required this.preffs});

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firebaseStore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.primarymaincolor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final appRepo = AppRepo(_firebaseAuth, _firebaseStore);
        final preffs = PreferenceManager(widget.preffs);
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => SignupBloc(appRepo)),
            BlocProvider(create: (context) => LoginBloc(appRepo, preffs)),
            BlocProvider(create: (context) => UserDetailsBloc(appRepo)),
            BlocProvider(create: (context) => UserStatusBloc(appRepo)),
            BlocProvider(
                create: (context) => UserSelectionBloc(_firebaseStore)),
          ],
          child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: AppTheme.lightTheme,
              home: SplashScreen(preffs: preffs, auth: _firebaseAuth)),
        );
      },
    );
  }
}
