import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad_onboarding/view/native_ad_onboarding_widget.dart';
import 'package:lightroom_template/common/common_lottie_asset.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_image_string.dart';
import 'package:lightroom_template/core/constant/app_lotties_string.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/data/helpers/ad_helper.dart';
import 'package:lightroom_template/data/models/onboarding_model.dart';
import 'package:lightroom_template/routes/app_route_string.dart';
import 'package:lightroom_template/common/common_button.dart';
import 'package:lightroom_template/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();

  final List<OnboardingModel> _onboardingData = [
    OnboardingModel(
      title: AppStrings.txtOnboardingTitle1,
      subtitle: AppStrings.txtOnboardingSubtitle1,
      image: AppImagesString.imgOnboarding1,
    ),
    OnboardingModel(
      title: AppStrings.txtOnboardingTitle2,
      subtitle: AppStrings.txtOnboardingSubtitle2,
      image: AppImagesString.imgOnboarding2,
    ),
    OnboardingModel(
      title: AppStrings.txtOnboardingTitle3,
      subtitle: AppStrings.txtOnboardingSubtitle3,
      image: AppImagesString.imgOnboarding3,
    ),
  ];

  @override
  void initState() {
    context.read<OnboardingBloc>().add(StartButtonDelayEvent());
    AdHelper.precacheInterstitialAd(adId: AppAdIdString.onboarding1InterstitialAd);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocListener<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state.status == OnboardingStatus.loaded) {
              AdHelper.showAppOpenAd(
                onComplete: () {
                  context.go(AppRoutesString.dashboardView);
                },
              );
              // bool adLoaded = AdHelper.isAppOpenAdLoaded;
              // if (!adLoaded) {
              //   CommonDialog.loaderDialog(context: context);
              // }
              //
              // AdHelper.showAppOpenAd(
              //   onComplete: () {
              //     if (!adLoaded) {
              //       Navigator.of(context, rootNavigator: true).pop();
              //     }
              //   },
              //   onComplete: () {
              //     context.go(AppRoutesString.dashboardView);
              //   },
              // );
            }
          },
          child: BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, state) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        context.read<OnboardingBloc>().add(NextButtonOnTapEvent(index: index));
                      },
                      itemCount: _onboardingData.length,
                      itemBuilder: (context, index) {
                        return _buildPageContent(data: _onboardingData[index]);
                      },
                    ),
                  ),
                  state.showButtons ?? false
                      ? Positioned(
                          bottom: 16,
                          left: 20,
                          right: 20,
                          child: _buildControls(currentIndex: state.selectedIndex ?? 0),
                        )
                      : Positioned(
                          bottom: 16,
                          left: 20,
                          right: 20,
                          child: CommonLottieAsset(
                            assetName: AppLottiesString.loadingAnimation,
                            height: 55,
                            width: 55,
                          ),
                        ),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            return NativeAdOnboardingWidget(index: state.selectedIndex ?? 0);
          },
        ),
      ),
    );
  }

  Widget _buildPageContent({required OnboardingModel data}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 340;
        final bottomPadding = isCompact ? 70.0 : 80.0;

        return Stack(
          children: [
            /// Full screen image
            Positioned.fill(child: Image.asset(data.image, fit: BoxFit.cover)),

            /// Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.transparent, AppColors.surfaceContainerLowest],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.8],
                  ),
                ),
              ),
            ),

            /// Content
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CommonTextWidget(
                    text: data.title,
                    textStyle: isCompact
                        ? size24TextStyle(textColor: AppColors.onSurface, fontWeight: FontWeight.bold)
                        : size26TextStyle(textColor: AppColors.onSurface, fontWeight: FontWeight.bold),
                  ),
                  SBH10(),
                  CommonTextWidget(
                    text: data.subtitle,
                    textStyle: isCompact
                        ? size14TextStyle(textColor: AppColors.onSurface)
                        : size16TextStyle(textColor: AppColors.onSurface),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls({required int currentIndex}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: List.generate(
            _onboardingData.length,
            (index) => Container(
              margin: const EdgeInsets.only(right: 8),
              height: 4,
              width: currentIndex == index ? 24 : 12,
              decoration: BoxDecoration(
                color: currentIndex == index ? AppColors.primary : AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),

        // Next / Get Started Button
        CommonButton(
          text: currentIndex == 2 ? AppStrings.txtGetStarted : AppStrings.txtNext,
          onTap: () {
            if (currentIndex == 2) {
              context.read<OnboardingBloc>().add(SaveOnTapEvent());
            } else if (currentIndex == 0) {
              AdHelper.showInterstitialAd(
                adId: AppAdIdString.onboarding1InterstitialAd,
                reloadAfterClose: false,
                onAdClosed: () {
                  AdHelper.precacheInterstitialAd(adId: AppAdIdString.onbordingTwoInterstitialAd);
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              );
            } else if (currentIndex == 1) {
              AdHelper.showInterstitialAd(
                adId: AppAdIdString.onbordingTwoInterstitialAd,
                reloadAfterClose: false,
                onAdClosed: () {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
              );
            }
          },
          borderRadius: 100,
          icon: currentIndex != 2
              ? const Icon(Icons.arrow_forward_rounded, color: AppColors.whiteColor, size: 20)
              : null,
          textStyle: size16TextStyle(textColor: AppColors.whiteColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

