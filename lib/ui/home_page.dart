import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signwalla/common/colors.dart';
import 'package:signwalla/controllers/user_details/user_details_bloc.dart';
import 'package:signwalla/controllers/user_update/user_status/user_status_bloc.dart';
import 'package:signwalla/ui/chat_screen.dart';
import 'package:signwalla/ui/login_page.dart';
import 'package:signwalla/ui/profile.dart';
import 'package:signwalla/ui/user_page.dart';
import 'package:signwalla/common/flushbar.dart';
import 'package:signwalla/widgets/loading_widget.dart';
import '../controllers/login/login_bloc.dart';

class HomePage extends StatefulWidget {
  final String? uuid;

  const HomePage({super.key, required this.uuid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  Map<String, dynamic>? userMap;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var index = 0;
  late TabController _tabController;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    context.read<UserDetailsBloc>().add(GetUserDetailsEvent(widget.uuid!));
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        index = _tabController.index;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context
          .read<UserStatusBloc>()
          .add(GetUserStatusEvent(widget.uuid!, "online", "userStatus"));
    } else {
      context
          .read<UserStatusBloc>()
          .add(GetUserStatusEvent(widget.uuid!, "offline", "userStatus"));
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserDetailsBloc, UserDetailsState>(
      listener: (context, state) {
        if (state is UserDetailsResult) {
          userMap = state.data;
          context
              .read<UserStatusBloc>()
              .add(GetUserStatusEvent(widget.uuid!, "online", "userStatus"));
        } else if (state is UserDetailsError) {
          context.flushBarErrorMessage(message: state.error);
        }
      },
      builder: (context, state1) {
        return BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LogoutResult) {
              if (state.result) {
                context
                    .read<UserStatusBloc>()
                    .add(GetUserStatusEvent(widget.uuid!, "offline", "userStatus"));
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              } else {
                context.flushBarErrorMessage(message: 'Something Went Wrong.');
              }
            } else if (state is LoginError) {
              context.flushBarErrorMessage(message: 'Something Went Wrong.');
            }
          },
          builder: (context, state) {
            return Scaffold(
              key: _scaffoldKey,
              drawer: customDrawer(),
              appBar: AppBar(
                backgroundColor: AppColors.primarymaincolor,
                title: const Text('Home'),
                bottom: TabBar(
                  controller: _tabController,
                  onTap: (val) {
                    setState(() {
                      index = val;
                    });
                  },
                  tabs: const [Tab(text: 'Users'), Tab(text: 'Chats')],
                ),
              ),
              body: Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    children: [const UserPage(), ChatPage()],
                  ),
                  if (state is LoginLoading || state1 is UserDetailsLoading)
                    const LoadingWidget(),
                ],
              ),
              floatingActionButton: index == 1
                  ? FloatingActionButton(
                      child: const Icon(Icons.add, color: AppColors.whiteColor),
                      onPressed: () {
                        _tabController.animateTo(0);
                      })
                  : null,
            );
          },
        );
      },
    );
  }

  Widget customDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primarymaincolor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              userMap != null
                                  ? userMap!['email']
                                  : 'example123@gmail.com',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 22)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts_rounded),
            title: const Text('Profile'),
            onTap: () {
              toggleDrawer();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(userMap: userMap!),
                  ));
            },
          ),
          Column(
            children: [
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  context.read<LoginBloc>().add(GetLogoutEvent());
                },
              ),
              SizedBox(height: 10.h)
            ],
          ),
        ],
      ),
    );
  }

  toggleDrawer() async {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openEndDrawer();
    }
  }
}
