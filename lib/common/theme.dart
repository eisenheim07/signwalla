import 'package:flutter/material.dart';
import 'package:signwalla/common/colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: AppColors.primarymaincolor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primarymaincolor,
      foregroundColor: AppColors.whiteColor,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.whiteColor,
    ),
    tabBarTheme: const TabBarTheme(
        indicatorColor: AppColors.whiteColor,
        labelColor: AppColors.whiteColor,
        unselectedLabelColor: AppColors.greyColor),
    useMaterial3: true,
  );
}
