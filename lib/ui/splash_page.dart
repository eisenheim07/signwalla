import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signwalla/common/constants.dart';
import 'package:signwalla/common/preffs_manager.dart';
import 'package:signwalla/ui/home_page.dart';
import 'package:signwalla/ui/login_page.dart';

class SplashScreen extends StatefulWidget {
  final PreferenceManager preffs;
  final FirebaseAuth auth;

  const SplashScreen({super.key, required this.preffs, required this.auth});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    checkSession();
    super.initState();
  }

  checkSession() async {
    await Future.delayed(const Duration(seconds: 3));
    if (widget.preffs.getString(Constants.LOGIN_TOKEN) != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomePage(uuid: widget.auth.currentUser!.uid)));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Image.asset(
        'assets/images/app_icon.png',
        height: 100,
        width: 100,
      ),
    ));
  }
}
