import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signwalla/common/colors.dart';
import 'package:signwalla/common/flushbar.dart';
import 'package:signwalla/ui/home_page.dart';
import 'package:signwalla/widgets/custom_buttons.dart';

import '../controllers/user_update/user_status/user_status_bloc.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userMap;

  const ProfilePage({super.key, required this.userMap});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userMap;

  var textController = TextEditingController();

  @override
  void initState() {
    userMap = widget.userMap;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(uuid: userMap!['uuid'])));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage: AssetImage('assets/images/profile.png'),
                  ),
                ),
                SizedBox(height: 15.h),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      row("First Name", userMap!['firstName'] ?? '***', mapKey: "firstName"),
                      row("Last Name", userMap!['lastName'] ?? '***', mapKey: "lastName"),
                      row("Username", userMap!['username'] ?? '***', mapKey: "username"),
                      row("Email", userMap!['email']),
                      row("User ID", userMap!['uuid']),
                      row("Phone No.", userMap!['phoneNumber'] ?? '***', mapKey: "phoneNumber"),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Expanded(
                                child: Text("Verified",
                                    style: TextStyle(color: AppColors.blackColor, fontWeight: FontWeight.bold, fontSize: 16))),
                            Expanded(
                                flex: 2,
                                child: userMap!['isVerified']
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.verified, color: AppColors.primarymaincolor),
                                          SizedBox(
                                            width: 4.w,
                                          ),
                                          const Text('Verified', style: TextStyle(color: AppColors.blackColor, fontSize: 16)),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          const Icon(Icons.cancel, color: AppColors.primarymaincolor),
                                          SizedBox(
                                            width: 4.w,
                                          ),
                                          const Text('Not Verified', style: TextStyle(color: AppColors.blackColor, fontSize: 16))
                                        ],
                                      )),
                          ],
                        ),
                      ),
                      row("Account Creation", userMap!['createdAt']),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget row(String key, String value, {String mapKey = ""}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(key, style: const TextStyle(color: AppColors.blackColor, fontWeight: FontWeight.bold, fontSize: 16))),
          Expanded(
              flex: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(value.isNotEmpty ? value : '***', style: const TextStyle(color: AppColors.blackColor, fontSize: 16)),
                  ),
                  mapKey.isNotEmpty
                      ? InkWell(
                          onTap: () async {
                            textController.text = value;
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                    content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(key,
                                          style: const TextStyle(color: AppColors.blackColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                      SizedBox(height: 4.h),
                                      TextFormField(
                                        controller: textController,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Invalid $key';
                                          }
                                          return null;
                                        },
                                        keyboardType: mapKey == 'phoneNumber' ? TextInputType.phone : TextInputType.text,
                                        maxLength: mapKey == 'phoneNumber' ? 10 : null,
                                        decoration: InputDecoration(
                                          hintText: key,
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
                                      SizedBox(height: 10.h),
                                      SizedBox(
                                        width: double.infinity,
                                        child: enabledButton(
                                            title: 'UPDATE',
                                            onPressed: () async {
                                              context
                                                  .read<UserStatusBloc>()
                                                  .add(GetUserStatusEvent(userMap!['uuid'], textController.text.trim(), mapKey));
                                              Navigator.pop(context);
                                              context.flushBarSuccessMessage(message: "Updated");
                                              setState(() {
                                                userMap![mapKey] = textController.text;
                                              });
                                            }),
                                      )
                                    ],
                                  ),
                                ));
                              },
                            );
                          },
                          child: Column(
                            children: [SizedBox(width: 2.w), const Icon(Icons.edit)],
                          ),
                        )
                      : const SizedBox()
                ],
              )),
        ],
      ),
    );
  }
}
