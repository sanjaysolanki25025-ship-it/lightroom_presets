import 'dart:io';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/common/shimmer/native_ad_shimmer.dart';
import 'package:lightroom_template/common/shimmer/native_medium_ad_shimmer.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/core/utils/native_ad_manager.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';

class NativeAdView extends StatefulWidget {
  final String adId;
  final bool isSplash;
  final bool isSmallAd;

  const NativeAdView({super.key, this.isSplash = false, this.isSmallAd = false, required this.adId});

  @override
  State<NativeAdView> createState() => _NativeAdViewState();
}

class _NativeAdViewState extends State<NativeAdView> {
  static bool get _isUserSubscribed {
    return AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;
  }

  /// Logic to decide whether ad should show or not
  bool get _shouldShowAd {
    if (widget.isSplash) return true;
    return !_isUserSubscribed;
  }

  NativeAd? _nativeAd;

  @override
  void initState() {
    super.initState();

    if (_shouldShowAd) {
      loadNativeAd();
    }
  }

  void loadNativeAd() {
    log(
      '🔍 NativeAdView: Requesting ad... '
          '(isSmallAd: ${widget.isSmallAd}, adId: ${widget.adId})',
    );

    _nativeAd = widget.isSmallAd
        ? NativeAdManager().getAd(widget.adId)
        : NativeAdManager().getMediumAd(widget.adId);

    if (_nativeAd != null) {
      log('✅ NativeAdView: Ad received from manager.');

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<NativeAdBloc>().add(
            ShowNativeAdEvent(isShowNative: true),
          );
        }
      });
    } else {
      log('🔄 NativeAdView: No cached ad. Loading manually...');
      _loadNormalManualAd();
    }
  }


  void _loadNormalManualAd() {
    _nativeAd = NativeAd(
      request: const AdRequest(),
      factoryId: widget.isSmallAd ? "row_native_ad" : "medium_native_ad",
      adUnitId: widget.adId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          log('✅ NativeAdView: Manual ad loaded.');
          if (mounted) {
            context.read<NativeAdBloc>().add(ShowNativeAdEvent(isShowNative: true));
          }
        },
        onAdFailedToLoad: (ad, error) {
          log('❌ NativeAdView: Manual ad failed: ${error.message}');
          ad.dispose();
        },
      ),
    );
    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// If ad should not show
    if (!_shouldShowAd) {
      return const SizedBox();
    }

    return BlocBuilder<NativeAdBloc, NativeAdState>(
      builder: (context, state) {
        if (!state.isShowNative || _nativeAd == null) {
          return SizedBox(
            height: widget.isSmallAd
                ? 140
                : Platform.isIOS
                ? 340
                : 370,
            child: Center(child: widget.isSmallAd ? const NativeAdShimmer() : const NativeMediumAdShimmer()),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SBH5(),

            /// Sponsored + Remove Ads Row (Hide in splash)
            widget.isSplash
                ? const SizedBox()
                : Padding(
              padding: EdgeInsets.symmetric(horizontal: Platform.isIOS ? 10.w : 16.w),
              child: Row(
                children: [
                  const Icon(Icons.info, size: 18, color: AppColors.greyColor),
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

                  const Spacer(),

                  // GestureDetector(
                  //   onTap: () {
                  //     // context.push(AppRoutesString.subscriptionView);
                  //   },
                  //   child: CommonTextWidget(
                  //     text: AppStrings.txtRemoveAds,
                  //     isUnderline: true,
                  //     underlineColor: AppColors.greyColor,
                  //     textStyle: size12TextStyle(
                  //       textColor: AppColors.greyColor,
                  //       fontWeight: FontWeight.w700,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),

            SizedBox(
              height: widget.isSmallAd
                  ? 140
                  : Platform.isIOS
                  ? 360
                  : 370,
              width: double.infinity,
              child: AdWidget(ad: _nativeAd!),
            ),
          ],
        );
      },
    );
  }
}
