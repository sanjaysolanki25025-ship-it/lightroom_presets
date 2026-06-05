import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class NativeAdShimmer extends StatelessWidget {
  const NativeAdShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), color: AppColors.darkMoonColor),
      child: Row(
        children: [
          /// LEFT IMAGE
          Shimmer.fromColors(
            baseColor: AppColors.lightBlackColor,
            highlightColor: AppColors.offBlackColor,
            child: Container(
              width: 150.w,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),

          SBW10(),

          /// RIGHT CONTENT
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _shimmerLine(height: 28.h),
                SBH10(),
                _shimmerLine(height: 28.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerLine({required double height, double? width}) {
    return Shimmer.fromColors(
      baseColor: AppColors.lightBlackColor,
      highlightColor: AppColors.offBlackColor,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(color: AppColors.whiteColor, borderRadius: BorderRadius.circular(6.r)),
      ),
    );
  }
}
