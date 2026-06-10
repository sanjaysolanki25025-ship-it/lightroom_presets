import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:lightroom_template/common/common_button.dart';
import 'package:lightroom_template/common/common_loader.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/core/constant/app_image_string.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:go_router/go_router.dart';
import 'package:lightroom_template/routes/app_route_string.dart';

class CommonDialog {
  static Future<void> showDialogWidget({
    required BuildContext context,
    required String title,
    required Widget childWidget,
    bool barrierDismissible = true,
    required String adId,
  }) {
    return showDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              border: BoxBorder.all(color: AppColors.dialogBorderColor, width: 1),
              gradient: LinearGradient(colors: [AppColors.dialogBorderColor, AppColors.offBlackColor]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SBH10(),
                  Center(
                    child: CommonTextWidget(
                      text: title,
                      textAlign: TextAlign.center,
                      textStyle: size20TextStyle(
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.whiteColor,
                      ),
                    ),
                  ),
                  const SBH2(),
                  childWidget,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: BlocProvider(
                      create: (context) => NativeAdBloc(),
                      child: NativeAdView(isSmallAd: true, adId: adId),
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

  /// loader dialog
  static Future<void> loaderDialog({required BuildContext context, bool isSmall = false}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: isSmall
              ? Center(
                  child: Material(
                    color: AppColors.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    type: MaterialType.card,
                    child: SizedBox(
                      width: 250,
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CommonLoader(
                              size: 18,
                              strokeWidth: 2,
                            ),
                            const SizedBox(width: 12),
                            CommonTextWidget(
                              text: AppStrings.txtPleaseWait,
                              textStyle: size12TextStyle(textColor: AppColors.whiteColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Dialog(
                  backgroundColor: AppColors.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SBW5(),
                        const CommonLoader(
                          size: 30,
                          strokeWidth: 3,
                        ),
                        const SBW20(),
                        CommonTextWidget(
                          text: AppStrings.txtPleaseWait,
                          textStyle: size12TextStyle(textColor: AppColors.whiteColor),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  /// close dialog
  static void closeDialog({required BuildContext context}) {
    final navigator = Navigator.of(context, rootNavigator: true);

    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  /// Check if the Dino dialog should be shown today (once per day)
  static bool shouldShowDinoDialog() {
    final prefs = AppPreferences();
    final lastShown = prefs.getString("last_dino_dialog_show_date");
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastShown != today;
  }

  /// Mark that the Dino dialog was shown today
  static void markDinoDialogShown() {
    final prefs = AppPreferences();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    prefs.setString("last_dino_dialog_show_date", today);
  }

  /// Cartoon type Dino dialog
  static Future<void> showDinoDialog({required BuildContext context}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
            side: BorderSide(
              color: AppColors.primaryContainer.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Cartoon header icon - Dino
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    AppImagesString.imgDino,
                    height: 80.h,
                    width: 80.w,
                    fit: BoxFit.contain,
                  ),
                ),
                const SBH15(),
                // Title
                CommonTextWidget(
                  text: AppStrings.txtDinoRunChallenge,
                  textAlign: TextAlign.center,
                  textStyle: size18TextStyle(
                    fontWeight: FontWeight.bold,
                    textColor: AppColors.whiteColor,
                  ),
                ),
                const SBH10(),
                // Description
                CommonTextWidget(
                  text: AppStrings.txtRunWithTheDinoDodgeCactiAndEarnFreeCoinsToUnlockYourFavoritePremiumLightroomPresets,
                  textAlign: TextAlign.center,
                  textStyle: size12TextStyle(
                    textColor: AppColors.onSurfaceVariant,
                  ).copyWith(height: 1.4),
                ),
                const SBH20(),
                // Play Button
                SizedBox(
                  width: double.infinity,
                  child: CommonButton(
                    onTap: () {
                      Navigator.of(context).pop(); // close dialog
                      context.push(AppRoutesString.dinoView); // navigate to dino game
                    },
                    text: AppStrings.txtPlayGame,
                    textStyle: size14TextStyle(
                      textColor: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SBH10(),
                // Cancel
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: CommonTextWidget(
                      text: AppStrings.txtMaybeLater,
                      textStyle: size12TextStyle(
                        textColor: AppColors.greyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
