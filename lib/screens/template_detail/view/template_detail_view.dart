import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lightroom_template/common/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:lightroom_template/common/common_app_bar.dart';
import 'package:lightroom_template/common/common_bottom_sheet.dart';
import 'package:lightroom_template/common/common_button.dart';
import 'package:lightroom_template/common/common_lottie_asset.dart';
import 'package:lightroom_template/common/common_network_image.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/common/common_toast.dart';
import 'package:lightroom_template/common/dialog/common_dialog.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_image_string.dart';
import 'package:lightroom_template/core/constant/app_lotties_string.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/core/utils/common_functions.dart';
import 'package:lightroom_template/data/helpers/ad_helper.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:lightroom_template/data/models/lr_preset_model.dart';
import 'package:lightroom_template/routes/app_route_string.dart';
import 'package:lightroom_template/screens/home/widgets/common_action_button.dart';
import 'package:lightroom_template/screens/template_detail/bloc/template_detail_bloc.dart';

class TemplateDetailView extends StatefulWidget {
  final LrPresetModel entry;

  const TemplateDetailView({super.key, required this.entry});

  @override
  State<TemplateDetailView> createState() => _TemplateDetailViewState();
}

class _TemplateDetailViewState extends State<TemplateDetailView> {
  void _handleDownload(LrPresetModel entry) {
    context.read<TemplateDetailBloc>().add(
      TemplateDetailDownloadImage(
        url: "${AppStrings.imageUrl}${widget.entry.image.trim()}.dng",
        fileName: widget.entry.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        context.pop(true);
        context.read<TemplateDetailBloc>().add(CountOnBackPressEvent());
      },
      child: SafeArea(
        child: Scaffold(
          appBar: CommonAppBar(
            title: widget.entry.title,
            actions: [
              // CommonLottieAsset(assetName: AppLottiesString.pro),
              // SBW2(),
              CommonActionButton(
                assetPath: AppImagesString.imgDino,
                onTap: () {
                  final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
                  if (totalCoin < 5) {
                    CommonBottomSheet.showCommonBottomSheet(
                      adId: AppAdIdString.presetDetailBottomNativeAd,
                      context: context,
                      firstButtonText: AppStrings.txtWatchAd,
                      title: AppStrings.txtNotEnoughCoinsWatchAnAdToPlay,
                      firstButtonOnTap: () {
                        Navigator.of(context).pop();
                        context.read<TemplateDetailBloc>().add(TemplateDetailLoadRewardAD());
                        AdHelper.showRewardedAd(
                          adUnitId: AppAdIdString.playDinoRewardedAd,
                          onRewardEarned: () {
                            context.read<TemplateDetailBloc>().add(TemplateDetailLoadedRewardAD());
                            ;
                            context.read<TemplateDetailBloc>().add(TemplateDetailStoreCoinEvent());
                          },
                          onComplete: () {
                            context.push(AppRoutesString.dinoView);
                          },
                          onAdFailed: () {
                            context.read<TemplateDetailBloc>().add(TemplateDetailLoadedRewardAD());
                          },
                        );
                      },
                    );
                  } else {
                    CommonBottomSheet.showCommonBottomSheet(
                      adId: AppAdIdString.presetDetailBottomNativeAd,
                      context: context,
                      firstButtonText: "🔓 ${AppStrings.txtFiveLetter} ${AppStrings.txtCoins}",
                      secondButtonText: AppStrings.txtWatchAd,
                      title: AppStrings.txtPlayGameReward,
                      secondButtonOnTap: () {
                        Navigator.of(context).pop();
                        context.read<TemplateDetailBloc>().add(TemplateDetailLoadRewardAD());
                        AdHelper.showRewardedAd(
                          adUnitId: AppAdIdString.playDinoRewardedAd,
                          onRewardEarned: () {
                            context.read<TemplateDetailBloc>().add(TemplateDetailLoadedRewardAD());
                            context.read<TemplateDetailBloc>().add(TemplateDetailStoreCoinEvent());
                          },
                          onComplete: () {
                            context.push(AppRoutesString.dinoView);
                          },
                          onAdFailed: () {
                            context.read<TemplateDetailBloc>().add(TemplateDetailLoadedRewardAD());
                          },
                        );
                      },

                      firstButtonOnTap: () {
                        context.pop();
                        context.read<TemplateDetailBloc>().add(TemplateDetailPlayDinoGame());
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
          body: BlocConsumer<TemplateDetailBloc, TemplateDetailState>(
            listener: (context, state) {
              if (state.status == TemplateDetailStatus.downloading ||
                  state.status == TemplateDetailStatus.openingInLightroom ||
                  state.status == TemplateDetailStatus.rewardAdLoading) {
                CommonDialog.loaderDialog(context: context);
              } else if (state.status == TemplateDetailStatus.downloadSuccess) {
                CommonDialog.closeDialog(context: context);
                if (state.downloadMessage != null) {
                  CommonToast.show(context, state.downloadMessage!);
                }
              } else if (state.status == TemplateDetailStatus.success ||
                  state.status == TemplateDetailStatus.rewardAdLoaded) {
                CommonDialog.closeDialog(context: context);
              } else if (state.status == TemplateDetailStatus.navigateToDinoGame) {
                context.push(AppRoutesString.dinoView);
              } else if (state.status == TemplateDetailStatus.downloadFailureModel) {
                CommonDialog.closeDialog(context: context);
                if (state.downloadMessage != null) {
                  CommonToast.show(context, state.downloadMessage!);
                }
              } else if (state.status == TemplateDetailStatus.lightroomNotInstalled) {
                CommonBottomSheet.showCommonBottomSheet(
                  adId: AppAdIdString.presetDetailBottomNativeAd,
                  context: context,
                  firstButtonText: AppStrings.txtDownload,
                  secondButtonText: AppStrings.txtCancel,
                  title: AppStrings.txtDownloadLightroomPresetInstantly,
                  secondButtonOnTap: () {
                    Navigator.of(context).pop();
                  },
                  firstButtonOnTap: () {
                    Navigator.of(context).pop();
                    CommonFunction.openLightroomApp();
                  },
                ).then((_) {
                  context.read<TemplateDetailBloc>().add(ResetStatus());
                });
              } else if (state.status == TemplateDetailStatus.lightroomInstalled) {
                final userCoins = AppPreferences().getInt(AppPreferences.coin) ?? 0;

                final requiredCoins = state.entry?.coin ?? 0;

                final hasEnoughCoins = userCoins >= requiredCoins;

                CommonBottomSheet.showCommonBottomSheet(
                  context: context,
                  adId: AppAdIdString.presetDetailBottomNativeAd,

                  firstButtonText: (requiredCoins <= 0)
                      ? AppStrings.txtWatchAd
                      : hasEnoughCoins
                      ? "🔓 $requiredCoins ${AppStrings.txtCoins}"
                      : AppStrings.txtPlayGameEarnCoins,

                  secondButtonText: AppStrings.txtCancel,

                  title: (requiredCoins <= 0)
                      ? AppStrings.txtUnlockThisPresetEarnTwoCoins
                      : hasEnoughCoins
                      ? AppStrings.txtUnlockThisPreset
                      : AppStrings.txtNotEnoughCoins,

                  secondButtonOnTap: (requiredCoins <= 0)
                      ? () {
                          Navigator.of(context).pop();
                        }
                      : hasEnoughCoins
                      ? () {
                          Navigator.of(context).pop();
                        }
                      : null,

                  firstButtonOnTap: () {
                    Navigator.of(context).pop();

                    final fileName = "${state.entry?.title.replaceAll(' ', '_')}_${state.entry?.id}.dng";

                    if (requiredCoins <= 0) {
                      context.read<TemplateDetailBloc>().add(TemplateDetailLoadRewardAD());
                      AdHelper.showRewardedAd(
                        adUnitId: AppAdIdString.useLrRewardedAd,
                        onRewardEarned: () {
                          context.read<TemplateDetailBloc>().add(TemplateDetailLoadedRewardAD());
                          context.read<TemplateDetailBloc>().add(TemplateDetailStoreCoinEvent());
                        },
                        onComplete: () {
                          context.read<TemplateDetailBloc>().add(
                            OpenInLightroomEvent(
                              url: "${AppStrings.imageUrl}${state.entry?.image.trim() ?? ''}.dng",
                              fileName: fileName,
                            ),
                          );
                        },
                        onAdFailed: () {
                          context.read<TemplateDetailBloc>().add(TemplateDetailLoadedRewardAD());
                        },
                      );
                    } else if (hasEnoughCoins) {
                      context.read<TemplateDetailBloc>().add(TemplateDetailUsedCoin(coin: requiredCoins));

                      context.read<TemplateDetailBloc>().add(
                        OpenInLightroomEvent(
                          url: "${AppStrings.imageUrl}${state.entry?.image.trim() ?? ''}.dng",
                          fileName: fileName,
                        ),
                      );
                    } else {
                      context.read<TemplateDetailBloc>().add(TemplateDetailLoadRewardAD());
                      AdHelper.showRewardedAd(
                        adUnitId: AppAdIdString.playDinoRewardedAd,
                        onRewardEarned: () {
                          context.read<TemplateDetailBloc>().add(TemplateDetailLoadedRewardAD());
                          context.read<TemplateDetailBloc>().add(TemplateDetailStoreCoinEvent());
                        },
                        onComplete: () {
                          context.push(AppRoutesString.dinoView);
                        },
                        onAdFailed: () {
                          context.read<TemplateDetailBloc>().add(TemplateDetailLoadedRewardAD());
                        },
                      );
                    }
                  },
                ).then((_) {
                  context.read<TemplateDetailBloc>().add(ResetStatus());
                });
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CommonNetworkImage(
                            imageUrl: "${AppStrings.imageUrl}${widget.entry.image.trim()}.png",
                            fit: BoxFit.cover,
                            height: 260,
                            width: 180,
                            isShimmer: true,
                          ),
                        ),
                      ),
                      SBH5(),
                      BlocProvider(
                        create: (context) => NativeAdBloc(),
                        child: NativeAdView(
                          isSmallAd: false,
                          isSplash: false,
                          adId: AppAdIdString.presetDetailNativeAd,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.r),
                child: Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        textStyle: size12TextStyle(
                          textColor: AppColors.whiteColor,
                          fontWeight: FontWeight.w700,
                        ),
                        onTap: () {
                          context.read<TemplateDetailBloc>().add(
                            TemplateDetailCheckLightroomInstallation(entry: widget.entry),
                          );
                        },
                        text: AppStrings.txtUseInLightroom,
                      ),
                    ),
                    SBW5(),
                    Expanded(
                      child: CommonButton(
                        width: 1.5,
                        onTap: () {
                          final userCoins = AppPreferences().getInt(AppPreferences.coin) ?? 0;

                          final hasEnoughCoins = userCoins >= widget.entry.coin;

                          CommonBottomSheet.showCommonBottomSheet(
                            adId: AppAdIdString.presetDetailBottomNativeAd,
                            context: context,

                            firstButtonText: (widget.entry.coin <= 0)
                                ? AppStrings.txtWatchAd
                                : hasEnoughCoins
                                ? "🔓 ${widget.entry.coin} ${AppStrings.txtCoins}"
                                : AppStrings.txtPlayGameEarnCoins,

                            secondButtonText: (widget.entry.coin <= 0)
                                ? AppStrings.txtCancel
                                : hasEnoughCoins
                                ? AppStrings.txtCancel
                                : AppStrings.txtCancel,

                            title: (widget.entry.coin <= 0)
                                ? AppStrings.txtUnlockThisPresetEarnTwoCoins
                                : hasEnoughCoins
                                ? AppStrings.txtUnlockThisPreset
                                : AppStrings.txtNotEnoughCoins,

                            secondButtonOnTap: (widget.entry.coin <= 0)
                                ? () {
                                    Navigator.of(context).pop();
                                  }
                                : hasEnoughCoins
                                ? () {
                                    Navigator.of(context).pop();
                                  }
                                : null,

                            firstButtonOnTap: () {
                              Navigator.of(context).pop();
                              if (widget.entry.coin <= 0) {
                                context.read<TemplateDetailBloc>().add(TemplateDetailLoadRewardAD());
                                AdHelper.showRewardedAd(
                                  adUnitId: AppAdIdString.downloadImageRewardedAd,
                                  onRewardEarned: () {
                                    context.read<TemplateDetailBloc>().add(TemplateDetailLoadedRewardAD());
                                    context.read<TemplateDetailBloc>().add(TemplateDetailStoreCoinEvent());
                                    _handleDownload(widget.entry);
                                  },
                                  onComplete: () {},
                                  onAdFailed: () {
                                    context.read<TemplateDetailBloc>().add(TemplateDetailLoadedRewardAD());
                                    _handleDownload(widget.entry);
                                  },
                                );
                              } else if (hasEnoughCoins) {
                                context.read<TemplateDetailBloc>().add(
                                  TemplateDetailUsedCoin(coin: widget.entry.coin),
                                );

                                _handleDownload(widget.entry);
                              } else {
                                context.read<TemplateDetailBloc>().add(TemplateDetailLoadRewardAD());
                                AdHelper.showRewardedAd(
                                  adUnitId: AppAdIdString.playDinoRewardedAd,
                                  onRewardEarned: () {
                                    context.read<TemplateDetailBloc>().add(TemplateDetailLoadedRewardAD());
                                    context.read<TemplateDetailBloc>().add(TemplateDetailStoreCoinEvent());
                                  },
                                  onComplete: () {
                                    context.push(AppRoutesString.dinoView);
                                  },
                                  onAdFailed: () {
                                    context.read<TemplateDetailBloc>().add(TemplateDetailLoadedRewardAD());
                                  },
                                );
                              }
                            },
                          );
                        },
                        text: AppStrings.txtDownload,
                        borderColor: AppColors.offBlackColor,
                        gradientColors: [AppColors.backgroundColor, AppColors.backgroundColor],
                      ),
                    ),
                  ],
                ),
              ),
              SBH5(),

              BlocProvider(
                create: (context) => BannerAdBloc(),
                child: BannerAdWidget(adId: AppAdIdString.presetDetailBannerAd),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
