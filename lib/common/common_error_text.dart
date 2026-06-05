import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';

class CommonErrorText extends StatelessWidget {
  final String errorMessage;

  const CommonErrorText({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return CommonTextWidget(
      textAlign: TextAlign.center,
      maxLine: 5,
      minFontSize: 16.sp,
      text: errorMessage,
      textStyle: size16TextStyle(
        fontWeight: FontWeight.w500,
        textColor: AppColors.whiteColor,
      ),
    );
  }
}
