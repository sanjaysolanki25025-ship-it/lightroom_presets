import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:lightroom_template/common/common_button.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/core/utils/common_functions.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';

class CommonBottomSheet {
  /// Common Bottom Sheet
  static Future<void> showCommonBottomSheet({
    required BuildContext context,
    required String title,
    required String firstButtonText,
    required VoidCallback firstButtonOnTap,
    required String adId,

    /// Optional Second Button
    String? secondButtonText,
    VoidCallback? secondButtonOnTap,
  }) {
    final remoteConfig = FirebaseRemoteConfig.instance;
    late final String howToUseLink = remoteConfig.getString("howToUseLink");
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 12.h,
                bottom: 20.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),

                  BlocProvider(
                    create: (context) => NativeAdBloc(),
                    child: NativeAdView(isSmallAd: false, isSplash: false, adId: adId),
                  ),

                  const SBH10(),

                  CommonTextWidget(
                    text: title,
                    textStyle: size18TextStyle(textColor: AppColors.onSurface, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),

                  const SBH5(),

                  CommonTextWidget(
                    text:
                        "${AppStrings.txtYouHave} 🟡 ${AppPreferences().getInt(AppPreferences.coin)} ${AppStrings.txtCoins}",
                    textStyle: size14TextStyle(textColor: AppColors.onSurface, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),

                  if (howToUseLink.isNotEmpty) ...[
                    const SBH5(),
                    GestureDetector(
                      onTap: () async {
                        await CommonFunction.launchUrlLink(howToUseLink);
                      },
                      child: CommonTextWidget(
                        text: AppStrings.txtHowToUse,
                        isUnderline: true,
                        textStyle: size12TextStyle(textColor: AppColors.primaryContainer),
                        underlineColor: AppColors.primaryContainer,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  const SBH15(),

                  if (secondButtonText != null && secondButtonOnTap != null)
                    Row(
                      children: [
                        Expanded(
                          child: CommonButton(
                            text: firstButtonText,
                            onTap: firstButtonOnTap,
                            style: CommonButtonStyle.gradient,
                          ),
                        ),

                        const SBW15(),

                        Expanded(
                          child: CommonButton(
                            text: secondButtonText,
                            onTap: secondButtonOnTap,
                            style: CommonButtonStyle.outlined,
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: CommonButton(
                        text: firstButtonText,
                        onTap: firstButtonOnTap,
                        style: CommonButtonStyle.gradient,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
