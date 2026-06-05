import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class NativeMediumAdShimmer extends StatelessWidget {
  const NativeMediumAdShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), color: AppColors.darkMoonColor),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.lightBlackColor,
            highlightColor: AppColors.offBlackColor,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SBH10(),
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: AppColors.lightBlackColor,
                highlightColor: AppColors.offBlackColor,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              SBW5(),
              Expanded(
                child: Column(
                  children: [
                    _shimmerLine(height: 20.h),
                    SBH5(),
                    _shimmerLine(height: 20.h),
                  ],
                ),
              ),
            ],
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
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(6.r),
        ),
      ),
    );
  }
}
