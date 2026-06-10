import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad_onboarding/bloc/native_ad_onboarding_bloc.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/common/shimmer/native_ad_shimmer.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/core/utils/native_ad_manager.dart';

class NativeAdOnboardingWidget extends StatefulWidget {
  final int index;

  const NativeAdOnboardingWidget({super.key, this.index = 0});

  @override
  State<NativeAdOnboardingWidget> createState() => _NativeAdOnboardingWidgetState();
}

class _NativeAdOnboardingWidgetState extends State<NativeAdOnboardingWidget> {
  NativeAd? _nativeAd;

  @override
  void initState() {
    super.initState();
    if (widget.index != 2) {
      _loadAd();
    }
  }

  static final List<String> onboardingNativeAds = [
    AppAdIdString.onBoardingNativeAd1,
    AppAdIdString.onBoardingNativeAd2,
    AppAdIdString.onBoardingNativeAd3,
  ];

  @override
  void didUpdateWidget(covariant NativeAdOnboardingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _nativeAd?.dispose();
      _nativeAd = null;
      context.read<NativeAdOnboardingBloc>().add(ShowNativeAdOnboardingEvent(isShowNative: false));
      if (widget.index != 2) {
        _loadAd();
      }
    }
  }

  void _loadAd() {
    int adIndex = widget.index;
    if (widget.index == 3) {
      adIndex = 2;
    }
    if (adIndex >= onboardingNativeAds.length) return;

    final adId = onboardingNativeAds[adIndex];
    log('🔍 NativeAdOnboardingWidget [index: ${widget.index}, adIndex: $adIndex]: Requesting ad... (adId: $adId)');
    _nativeAd = NativeAdManager().getAd(adId);

    if (_nativeAd != null) {
      log('✅ NativeAdOnboardingWidget [index: ${widget.index}]: Ad received from manager.');
      // Use a small delay to ensure the widget is ready to render the pre-loaded ad
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<NativeAdOnboardingBloc>().add(ShowNativeAdOnboardingEvent(isShowNative: true));
        }
      });
    } else {
      log('🔄 NativeAdOnboardingWidget [index: ${widget.index}]: No ad in manager. Loading manually...');
      _nativeAd = NativeAd(
        adUnitId: adId,
        request: const AdRequest(),
        factoryId: 'row_native_ad',
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('✅ NativeAdOnboardingWidget [index: ${widget.index}]: Manual ad loaded.');
            if (mounted) {
              context.read<NativeAdOnboardingBloc>().add(ShowNativeAdOnboardingEvent(isShowNative: true));
            }
          },
          onAdFailedToLoad: (ad, error) {
            log('❌ NativeAdOnboardingWidget [index: ${widget.index}]: Manual ad failed: ${error.message}');
            ad.dispose();
          },
        ),
      )..load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index == 2) {
      return const SizedBox.shrink();
    }
    return BlocBuilder<NativeAdOnboardingBloc, NativeAdOnboardingState>(
      builder: (context, state) {
        if (!state.isShowNative || _nativeAd == null) {
          return SizedBox(height: 140, child: Center(child: NativeAdShimmer()));
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Sponsored + Remove Ads Row (Hide in splash)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Platform.isIOS ? 10.w : 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.info, size: 18, color: AppColors.greyColor),
                  Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: CommonTextWidget(
                        text: AppStrings.txtSponsored,
                        textStyle: size12TextStyle(
                          textColor: AppColors.greyColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 140,
              width: double.infinity,
              child: AdWidget(ad: _nativeAd!),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}
