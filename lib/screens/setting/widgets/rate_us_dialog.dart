import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:lightroom_template/common/common_button.dart';
import 'package:lightroom_template/common/common_image_asset.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_image_string.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/routes/app_route_string.dart';
import 'package:lightroom_template/screens/setting/bloc/setting_bloc.dart';

class RateUsDialog {
  /// show qr code dialog
  static Future<void> showCreatingDialog({required BuildContext context}) {
    return showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Dialog(
                backgroundColor: AppColors.transparentColor,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: AppColors.dialogBorderColor, width: 1),
                    gradient: LinearGradient(
                      colors: [AppColors.dialogBorderColor, AppColors.backgroundColor],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: BlocProvider(
                    create: (context) => SettingBloc(),
                    child: BlocBuilder<SettingBloc, SettingState>(
                      builder: (context, state) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// Close Button
                            Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                onTap: () => context.pop(),
                                child: Icon(Icons.close, color: AppColors.whiteColor.withValues(alpha: 0.5)),
                              ),
                            ),
                            SBH2(),

                            /// change cartoon image based on rating
                            CommonImageAsset(
                              assetName: state.selectedRateIndex == 0
                                  ? AppImagesString.imgOneStar
                                  : state.selectedRateIndex == 1
                                  ? AppImagesString.imgOneStar
                                  : state.selectedRateIndex == 2
                                  ? AppImagesString.imgTwoStar
                                  : state.selectedRateIndex == 3
                                  ? AppImagesString.imgThreeStar
                                  : state.selectedRateIndex == 4
                                  ? AppImagesString.imgFourStar
                                  : AppImagesString.imgFiveStar,
                              width: 80,
                            ),
                            SBH5(),

                            /// title based on rating
                            CommonTextWidget(
                              text: state.selectedRateIndex == 0
                                  ? AppStrings.txtWeAreSorry
                                  : state.selectedRateIndex == 1
                                  ? AppStrings.txtWeAreSorry
                                  : state.selectedRateIndex == 2
                                  ? AppStrings.txtWeCanDoBetter
                                  : state.selectedRateIndex == 3
                                  ? AppStrings.txtItAGoodStart
                                  : state.selectedRateIndex == 4
                                  ? AppStrings.txtYouLoveIt
                                  : AppStrings.txtYouAreAmazing,
                              maxLine: 1,
                              minFontSize: 18,
                              overflow: TextOverflow.ellipsis,
                              textStyle: size18TextStyle(
                                textColor: AppColors.whiteColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SBH5(),

                            /// subtitle based on rating
                            CommonTextWidget(
                              text: state.selectedRateIndex == 0
                                  ? AppStrings.txtWeAreSorryToHearThatHowCanWeImprove
                                  : state.selectedRateIndex == 1
                                  ? AppStrings.txtWeAreSorryToHearThatHowCanWeImprove
                                  : state.selectedRateIndex == 2
                                  ? AppStrings.txtWeWillWorkHarderWhatCanWeDoBetter
                                  : state.selectedRateIndex == 3
                                  ? AppStrings.txtWeAreGladYouAreFindingSomeValueWhatCanWeDoBetter
                                  : state.selectedRateIndex == 4
                                  ? AppStrings.txtThanksForTheLoveShareWithYourFriends
                                  : AppStrings.txtThanksForTheLoveShareWithYourFriends,
                              maxLine: 2,
                              minFontSize: 14,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              textStyle: size14TextStyle(
                                textColor: AppColors.whiteColor.withValues(alpha: 0.5),
                              ),
                            ),
                            SBH5(),

                            /// rating bar
                            RatingBar.builder(
                              initialRating: 5,
                              minRating: 1,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemSize: 35,
                              unratedColor: AppColors.greyColor,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                              itemBuilder: (context, _) => Icon(Icons.star, color: AppColors.primary),
                              onRatingUpdate: (rating) {
                                context.read<SettingBloc>().add(
                                  ChangeRateUsEvent(selectedRateIndex: rating.toInt()),
                                );
                              },
                            ),
                            SBH10(),

                            /// rate us button
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: CommonButton(
                                onTap: () {
                                  if (state.selectedRateIndex != 5) {
                                    context.pop();
                                    context.push(AppRoutesString.feedbackView);
                                  } else {
                                    context.read<SettingBloc>().add(RateUsEvent());
                                  }
                                },

                                height: 42,
                                borderRadius: 30,
                                textStyle: size12TextStyle(
                                  fontWeight: FontWeight.w600,
                                  textColor: AppColors.whiteColor,
                                ),
                                text: state.selectedRateIndex == 5
                                    ? AppStrings.txtRateUsOnGoogle
                                    : AppStrings.txtRateUs,
                              ),
                            ),

                            SBH5(),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: BlocProvider(
                  create: (context) => NativeAdBloc(),
                  child: NativeAdView(adId: AppAdIdString.rateUsNativeAd),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
