import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signwalla/common/colors.dart';

Widget enabledButton(
    {required String title,
    Color? color,
    required Function() onPressed,
    bool isEnable = true}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor:
          isEnable ? AppColors.primarymaincolor : AppColors.greyColor,
      foregroundColor: color ?? AppColors.whiteColor,
      padding: EdgeInsets.all(15.r),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Text(title),
  );
}
