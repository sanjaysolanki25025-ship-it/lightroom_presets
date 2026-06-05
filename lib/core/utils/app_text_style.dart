import 'dart:ui';
import 'package:flutter/src/painting/text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';

TextStyle size32TextStyle({Color? textColor, FontWeight? fontWeight}) {
  return GoogleFonts.manrope(
    textStyle: TextStyle(
      color: textColor ?? AppColors.backgroundColor,
      fontSize: 32.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
    ),
  );
}

TextStyle size26TextStyle({Color? textColor, FontWeight? fontWeight}) {
  return GoogleFonts.manrope(
    textStyle: TextStyle(
      color: textColor ?? AppColors.backgroundColor,
      fontSize: 26.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
    ),
  );
}

TextStyle size24TextStyle({Color? textColor, FontWeight? fontWeight}) {
  return GoogleFonts.manrope(
    textStyle: TextStyle(
      color: textColor ?? AppColors.backgroundColor,
      fontSize: 24.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
    ),
  );
}

TextStyle size22TextStyle({Color? textColor, FontWeight? fontWeight}) {
  return GoogleFonts.manrope(
    textStyle: TextStyle(
      color: textColor ?? AppColors.backgroundColor,
      fontSize: 22.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
    ),
  );
}

TextStyle size20TextStyle({Color? textColor, FontWeight? fontWeight}) {
  return GoogleFonts.manrope(
    textStyle: TextStyle(
      color: textColor ?? AppColors.backgroundColor,
      fontSize: 20.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
    ),
  );
}

TextStyle size18TextStyle({Color? textColor, FontWeight? fontWeight}) {
  return GoogleFonts.manrope(
    textStyle: TextStyle(
      color: textColor ?? AppColors.backgroundColor,
      fontSize: 18.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
    ),
  );
}

TextStyle size16TextStyle({Color? textColor, FontWeight? fontWeight}) {
  return GoogleFonts.manrope(
    textStyle: TextStyle(
      color: textColor ?? AppColors.backgroundColor,
      fontSize: 16.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
    ),
  );
}

TextStyle size14TextStyle({Color? textColor, FontWeight? fontWeight}) {
  return GoogleFonts.manrope(
    textStyle: TextStyle(
      color: textColor ?? AppColors.backgroundColor,
      fontSize: 14.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
    ),
  );
}

TextStyle size12TextStyle({Color? textColor, FontWeight? fontWeight, double? letterSpacing}) {
  return GoogleFonts.manrope(
    textStyle: TextStyle(
      color: textColor ?? AppColors.backgroundColor,
      fontSize: 12.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
      letterSpacing: letterSpacing,
    ),
  );
}

TextStyle size10TextStyle({Color? textColor, FontWeight? fontWeight}) {
  return GoogleFonts.manrope(
    textStyle: TextStyle(
      color: textColor ?? AppColors.backgroundColor,
      fontSize: 10.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
    ),
  );
}

TextStyle size8TextStyle({Color? textColor, FontWeight? fontWeight}) {
  return GoogleFonts.manrope(
    textStyle: TextStyle(
      color: textColor ?? AppColors.backgroundColor,
      fontSize: 8.sp,
      fontWeight: fontWeight ?? FontWeight.w400,
    ),
  );
}
