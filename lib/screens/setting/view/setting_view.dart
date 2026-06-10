import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lightroom_template/common/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:lightroom_template/common/common_app_bar.dart';
import 'package:lightroom_template/common/common_bottom_sheet.dart';
import 'package:lightroom_template/common/common_button.dart';
import 'package:lightroom_template/common/common_lottie_asset.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/common/common_text_field.dart';
import 'package:lightroom_template/common/dialog/common_dialog.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_icon_string.dart';
import 'package:lightroom_template/core/constant/app_image_string.dart';
import 'package:lightroom_template/core/constant/app_lotties_string.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_validations.dart';
import 'package:lightroom_template/core/utils/common_functions.dart';
import 'package:lightroom_template/data/helpers/ad_helper.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:lightroom_template/routes/app_route_string.dart';
import 'package:lightroom_template/screens/home/widgets/common_action_button.dart';
import 'package:lightroom_template/screens/setting/bloc/setting_bloc.dart';
import 'package:lightroom_template/screens/setting/widgets/rate_us_dialog.dart';
import 'package:lightroom_template/screens/setting/widgets/setting_item_widget.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  final remoteConfig = FirebaseRemoteConfig.instance;
  late final String instaLink = remoteConfig.getString("instaLink");
  late final String telegramLink = remoteConfig.getString("telegramLink");
  late final String howToUseLink = remoteConfig.getString("howToUseLink");

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CommonAppBar(
          title: AppStrings.txtSettings,
          actions: [
            // CommonLottieAsset(assetName: AppLottiesString.pro),
            // SBW2(),
            CommonActionButton(
              assetPath: AppImagesString.imgDino,
              onTap: () {
                final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
                if (totalCoin < 5) {
                  CommonBottomSheet.showCommonBottomSheet(
                    adId: AppAdIdString.settingBottomNativeAd,
                    context: context,
                    firstButtonText: AppStrings.txtWatchAd,
                    title: AppStrings.txtNotEnoughCoinsWatchAnAdToPlay,
                    firstButtonOnTap: () {
                      Navigator.of(context).pop();
                      context.read<SettingBloc>().add(SettingLoadRewardAD());
                      AdHelper.showRewardedAd(
                        adUnitId: AppAdIdString.playDinoRewardedAd,
                        onRewardEarned: () {
                          context.read<SettingBloc>().add(SettingLoadedRewardAD());
                          context.read<SettingBloc>().add(SettingStoreCoinEvent());
                        },
                        onComplete: () {
                          context.push(AppRoutesString.dinoView);
                        },
                        onAdFailed: () {
                          context.read<SettingBloc>().add(SettingLoadedRewardAD());
                        },
                      );
                    },
                  );
                } else {
                  CommonBottomSheet.showCommonBottomSheet(
                    adId: AppAdIdString.settingBottomNativeAd,
                    context: context,
                    firstButtonText: "🔓 ${AppStrings.txtFiveLetter} ${AppStrings.txtCoins}",
                    secondButtonText: AppStrings.txtWatchAd,
                    title: AppStrings.txtPlayGameReward,
                    secondButtonOnTap: () {
                      Navigator.of(context).pop();
                      context.read<SettingBloc>().add(SettingLoadRewardAD());
                      AdHelper.showRewardedAd(
                        adUnitId: AppAdIdString.playDinoRewardedAd,
                        onRewardEarned: () {
                          context.read<SettingBloc>().add(SettingLoadedRewardAD());
                          context.read<SettingBloc>().add(SettingStoreCoinEvent());
                        },
                        onComplete: () {
                          context.push(AppRoutesString.dinoView);
                        },
                        onAdFailed: () {
                          context.read<SettingBloc>().add(SettingLoadedRewardAD());
                        },
                      );
                    },
      
                    firstButtonOnTap: () {
                      context.pop();
                      context.read<SettingBloc>().add(SettingPlayDinoGame());
                    },
                  );
                }
              },
              imageSize: 45,
              removeDecoration: true,
              fit: BoxFit.fill,
            ),
          ],
        ),
        body: BlocListener<SettingBloc, SettingState>(
          listener: (context, state) {
            if (state.status == SettingStatus.onTapLading) {
              CommonDialog.loaderDialog(context: context);
            } else if (state.status == SettingStatus.onTapLoaded) {
              CommonDialog.closeDialog(context: context);
            } else if (state.status == SettingStatus.navigateToDinoGame) {
              context.push(AppRoutesString.dinoView);
            }
          },
          child: Column(
            children: [
              BannerAdWidget(adId: AppAdIdString.settingBannerAd),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        instaLink.isEmpty
                            ? SizedBox.shrink()
                            : SettingsItemWidget(
                                title: AppPreferences().getBool(AppPreferences.instagramFollow) == true
                                    ? AppStrings.txtJoinOnInstagram
                                    : AppStrings.txtFollowAndEarnCoins,
                                assetIcon: AppIconsString.icInstagram,
                                onTap: () async {
                                  if (AppPreferences().getBool(AppPreferences.instagramFollow) == true) {
                                    await CommonFunction.launchUrlLink(instaLink);
                                  } else {
                                    CommonDialog.showDialogWidget(
                                      adId: AppAdIdString.socialMediaNativeAd,
                                      context: context,
                                      title: AppStrings.txtJoinOnInstagram,
                                      childWidget: Form(
                                        key: context.read<SettingBloc>().formKey,
                                        child: Column(
                                          children: [
                                            CommonTextField(
                                              controller: context.read<SettingBloc>().instagramUserIdController,
                                              autoFocus: true,
                                              hintText: "e.g. username",
                                              validator: (value) {
                                                return AppValidations.validateNotEmpty(
                                                  errorMessage: AppStrings.txtPleaseEnterThisField,
                                                  inputValue: value ?? '',
                                                );
                                              },
                                            ),
                                            SBH5(),
                                            CommonButton(
                                              text: AppStrings.txtSubmitAndEarnFiftyCoin,
                                              onTap: () {
                                                if (context
                                                    .read<SettingBloc>()
                                                    .formKey
                                                    .currentState!
                                                    .validate()) {
                                                  context.pop();
                                                  context.read<SettingBloc>().add(
                                                    OnInstagramTelegramFollowEvent(isInstagram: true),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                        telegramLink.isEmpty
                            ? SizedBox.shrink()
                            : SettingsItemWidget(
                                title: AppPreferences().getBool(AppPreferences.joinTelegram) == true
                                    ? AppStrings.txtJoinOnTelegram
                                    : AppStrings.txtJoinAndEarnCoins,
                                assetIcon: AppIconsString.icTelegram,
                                onTap: () async {
                                  if (AppPreferences().getBool(AppPreferences.joinTelegram) == true) {
                                    await CommonFunction.launchUrlLink(telegramLink);
                                  } else {
                                    CommonDialog.showDialogWidget(
                                      adId: AppAdIdString.socialMediaNativeAd,
                                      context: context,
                                      title: AppStrings.txtJoinOnTelegram,
                                      childWidget: Form(
                                        key: context.read<SettingBloc>().formKey,
                                        child: Column(
                                          children: [
                                            CommonTextField(
                                              controller: context.read<SettingBloc>().telegramUserIdController,
                                              autoFocus: true,
                                              hintText: "e.g. username",
                                              validator: (value) {
                                                return AppValidations.validateNotEmpty(
                                                  errorMessage: AppStrings.txtPleaseEnterThisField,
                                                  inputValue: value ?? '',
                                                );
                                              },
                                            ),
                                            SBH5(),
                                            CommonButton(
                                              onTap: () {
                                                if (context
                                                    .read<SettingBloc>()
                                                    .formKey
                                                    .currentState!
                                                    .validate()) {
                                                  context.pop();
                                                  context.read<SettingBloc>().add(
                                                    OnInstagramTelegramFollowEvent(isInstagram: false),
                                                  );
                                                }
                                              },
                                              text: AppStrings.txtSubmitAndEarnFiftyCoin,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
      
                        SettingsItemWidget(
                          title: AppStrings.txtRateUs,
                          icon: Icons.star_border,
                          onTap: () {
                            RateUsDialog.showCreatingDialog(context: context);
                          },
                        ),
      
                        SBH5(),
      
                        BlocProvider(
                          create: (context) => NativeAdBloc(),
                          child: NativeAdView(adId: AppAdIdString.settingNativeAd),
                        ),
                        SBH5(),
      
                        howToUseLink.isEmpty
                            ? SizedBox()
                            : SettingsItemWidget(
                                title: AppStrings.txtHowToUse,
                                icon: Icons.question_mark_outlined,
                                onTap: () async {
                                  await CommonFunction.launchUrlLink(howToUseLink);
                                },
                              ),
      
                        SBH5(),
      
                        SettingsItemWidget(
                          title: AppStrings.txtShareApp,
                          icon: Icons.share,
                          onTap: () {
                            context.read<SettingBloc>().add(ShareAppEvent());
                          },
                        ),
      
                        SettingsItemWidget(
                          title: AppStrings.txtPrivacyPolicy,
                          icon: Icons.privacy_tip_outlined,
                          onTap: () {
                            CommonFunction.launchUrlLink(AppStrings.txtPrivacyPolicyLink);
                          },
                        ),
                        SBH5(),
      
                        BlocProvider(
                          create: (context) => NativeAdBloc(),
                          child: NativeAdView(adId: AppAdIdString.settingNativeAd),
                        ),
                        SBH5(),
                        SettingsItemWidget(
                          title: AppStrings.txtExploreOurOtherApps,
                          icon: Icons.more_horiz_outlined,
                          onTap: () {
                            context.push(AppRoutesString.otherAppsView);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
