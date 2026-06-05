import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class GridShimmer extends StatelessWidget {
  const GridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SBH5(),
        for (int i = 0; i < 6; i += 2) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Shimmer.fromColors(
                  baseColor: AppColors.lightBlackColor,
                  highlightColor: AppColors.offBlackColor,
                  child: Container(
                    height: 300.h,
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
              SBW10(),
              if (i + 1 < 6)
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: AppColors.lightBlackColor,
                    highlightColor: AppColors.offBlackColor,
                    child: Container(
                      height: 300.h,
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
          SBH10(),
        ],
      ],
    );
  }
}
