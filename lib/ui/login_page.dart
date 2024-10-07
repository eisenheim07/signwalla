import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signwalla/ui/home_page.dart';
import 'package:signwalla/ui/signup_page.dart';
import 'package:signwalla/common/flushbar.dart';
import 'package:signwalla/widgets/loading_widget.dart';

import '../common/colors.dart';
import '../controllers/login/login_bloc.dart';
import '../widgets/custom_buttons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formkey = GlobalKey<FormState>();
  var isFormValid = false;
  var isVisible = false;
  final emailfocusnode = FocusNode();
  final passwordfocusnode = FocusNode();

  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginResult) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(uuid: state.user.uid)));
        } else if (state is LoginError) {
          context.flushBarErrorMessage(message: state.error);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formkey,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text('Messenger',
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(height: 30.h),
                        const Text('Please Sign in to continue',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        TextFormField(
                          controller: emailController,
                          validator: (value) {
                            if (value!.isEmpty ||
                                !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Colors.black,
                            ),
                            hintText: 'Enter Email Address',
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextFormField(
                          controller: passwordController,
                          obscureText: !isVisible,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.password,
                              color: Colors.black,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              child: Icon(
                                isVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
                              ),
                            ),
                            hintText: 'Enter Password',
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: AppColors.greyColor),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.w,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.red,
                                width: 2.w,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 30.h),
                        SizedBox(
                          width: double.infinity,
                          child: enabledButton(
                            isEnable: true,
                            title: 'Login',
                            onPressed: () {
                              if (_formkey.currentState!.validate()) {
                                context.read<LoginBloc>().add(GetLoginEvent(
                                    emailController.text.trim(),
                                    passwordController.text.trim()));
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 32.h),
                        Center(
                          child: RichText(
                              text:TextSpan(text: "Don't Have Account? ",
                                  style:const TextStyle(fontWeight: FontWeight.bold,color: AppColors.blackColor,fontSize: 16) ,
                                  children: [
                                TextSpan(
                                    recognizer:TapGestureRecognizer()..onTap=()=>Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupPage())),
                                    text: 'SignUp',
                                    style: const TextStyle(fontWeight: FontWeight.bold,color: AppColors.blackColor,fontSize: 18)),
                              ],)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (state is LoginLoading) const LoadingWidget()
            ],
          ),
        );
      },
    );
  }
}
