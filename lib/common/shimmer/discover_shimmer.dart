import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class DiscoverShimmer extends StatelessWidget {
  final bool isDiscoverShimmer;

  const DiscoverShimmer({super.key, required this.isDiscoverShimmer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16.w, left: 16.w),
      child: Column(
        children: [
          SizedBox(
            height: 27.h,
            child: ListView.separated(
              separatorBuilder: (context, index) => SBW10(),
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: AppColors.lightBlackColor,
                  highlightColor: AppColors.offBlackColor,
                  child: Container(
                    width: 70.h,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                );
              },
            ),
          ),
          isDiscoverShimmer ? SBH10() : SizedBox.shrink(),

          isDiscoverShimmer
              ? SizedBox(
                  height: 25.h,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => SBW10(),
                    scrollDirection: Axis.horizontal,
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: AppColors.lightBlackColor,
                        highlightColor: AppColors.offBlackColor,
                        child: Container(
                          width: 60.h,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : SizedBox.shrink(),
          SBH10(),
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
      ),
    );
  }
}
