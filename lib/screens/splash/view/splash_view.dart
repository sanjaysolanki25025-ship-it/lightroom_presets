import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:lightroom_template/common/common_image_asset.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/core/constant/app_image_string.dart';
import 'package:lightroom_template/data/helpers/ad_helper.dart';
import 'package:lightroom_template/common/dialog/common_dialog.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:lightroom_template/routes/app_route_string.dart';
import 'package:lightroom_template/screens/splash/bloc/splash_bloc.dart';
import 'package:lightroom_template/common/common_lottie_asset.dart';
import 'package:lightroom_template/core/constant/app_lotties_string.dart';
import 'package:lightroom_template/core/utils/native_ad_manager.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    context.read<SplashBloc>().add(SplashInitialEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          final remoteConfig = FirebaseRemoteConfig.instance;
          final bool isMaintenance = remoteConfig.getBool("isMaintenance");

          /// Maintenance Mode
          if (isMaintenance) {
            AdHelper.showAppOpenAd(
              onComplete: () {
                context.go(AppRoutesString.maintenanceView);
              },
            );
            return;
          }
          if (state.status == SplashStatus.loaded) {
            /// If onboarding already completed
            if (state.onboarding == true) {
              AdHelper.showAppOpenAd(
                onComplete: () {
                  context.go(AppRoutesString.dashboardView);
                },
              );
            } else {
              /// First time user → go onboarding directly
              context.go(AppRoutesString.onboardingView);
            }
          }
        },
        child: Stack(
          children: [
            /// Center logo
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Align(
                alignment: Alignment.center,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                  child: CommonImageAsset(
                    assetName: AppImagesString.imgAppLogo,
                    height: 200.sp,
                    width: 200.sp,
                  ),
                ),
              ),
            ),

            /// Bottom loader
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: CommonLottieAsset(assetName: AppLottiesString.loadingAnimation),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: BlocProvider(
                    create: (context) => NativeAdBloc(),
                    child: NativeAdView(
                      isSmallAd: true,
                      isSplash: true,
                      adId: AppAdIdString.splashNativeAd,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
