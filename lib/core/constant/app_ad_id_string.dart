import 'dart:io';

class AppAdIdString {
  static bool get _isAndroid {
    return Platform.isAndroid ? true : false;
  }

  /// -------------------- Test Ad Id ------------------------
  // /// ======= app open ad ==========
  // static final String appOpen = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/9257395921'
  //     : 'ca-app-pub-3940256099942544/5575463023';
  //
  // /// ========== interstitial ad ==========
  //
  // // back button interstitial ad
  // static final String backButtonInterstitialAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/1033173712'
  //     : 'ca-app-pub-3940256099942544/4411468910';
  //
  // // restart dino interstitial ad
  // static final String restartDinoInterstitialAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/1033173712'
  //     : 'ca-app-pub-3940256099942544/4411468910';
  //
  // // load more  interstitial ad
  // static final String loadMoreInterstitialAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/1033173712'
  //     : 'ca-app-pub-3940256099942544/4411468910';
  //
  // ///============ banner ad ===========
  //
  // // discover banner ad
  // static final String discoverBannerAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/6300978111'
  //     : 'ca-app-pub-3940256099942544/2934735716';
  //
  // // favourite banner ad
  // static final String favouriteBannerAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/6300978111'
  //     : 'ca-app-pub-3940256099942544/2934735716';
  //
  // // preset detail banner ad
  // static final String presetDetailBannerAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/6300978111'
  //     : 'ca-app-pub-3940256099942544/2934735716';
  //
  // // setting banner ad
  // static final String settingBannerAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/6300978111'
  //     : 'ca-app-pub-3940256099942544/2934735716';
  //
  // // other app banner ad
  // static final String otherAppBannerAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/6300978111'
  //     : 'ca-app-pub-3940256099942544/2934735716';
  //
  // /// ========== Native ad ===========
  //
  // // discover bottom native ad
  // static final String discoverBottomNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // exit app native ad
  // static final String exitAppNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // discover native ad
  // static final String discoverNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // favourite bottom native ad
  // static final String favouriteBottomNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // favourite native ad
  // static final String favouriteNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // home bottom native ad
  // static final String homeBottomNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // home reels native ad
  // static final String homeReelsNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // maintenance native ad
  // static final String maintenanceNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // no data found native ad
  // static final String noDataFoundNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // onboarding Native ad 1
  // static final String onBoardingNativeAd1 = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // onboarding Native ad 2
  // static final String onBoardingNativeAd2 = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // onboarding Native ad 3
  // static final String onBoardingNativeAd3 = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // template detail native ad
  // static final String presetDetailBottomNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // preset detail native ad
  // static final String presetDetailNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // setting bottom native ad
  // static final String settingBottomNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // setting native ad
  // static final String settingNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // splash screen native Ad
  // static final String splashNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // social media native ad
  // static final String socialMediaNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // // rate us native ad
  // static final String rateUsNativeAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/2247696110'
  //     : 'ca-app-pub-3940256099942544/3986624511';
  //
  // /// =========== rewarded ad ===========
  // // download image rewarded ad
  // static final String downloadImageRewardedAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/5224354917'
  //     : 'ca-app-pub-3940256099942544/1712485313';
  //
  // // play dino rewarded ad
  // static final String playDinoRewardedAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/5224354917'
  //     : 'ca-app-pub-3940256099942544/1712485313';
  //
  // // use lr rewarded ad
  // static final String useLrRewardedAd = _isAndroid
  //     ? 'ca-app-pub-3940256099942544/5224354917'
  //     : 'ca-app-pub-3940256099942544/1712485313';

  /// -------------------- Real Ad Id ------------------------
  /// ======= app open ad ==========
  static final String appOpen = _isAndroid ? 'ca-app-pub-1234444627237787/6733209129' : '';

  /// ========== interstitial ad ==========
  // back button interstitial ad
  static final String backButtonInterstitialAd = _isAndroid ? 'ca-app-pub-1234444627237787/9658755368' : '';

  // restart dino interstitial ad
  // static final String restartDinoInterstitialAd = _isAndroid ? 'ca-app-pub-1234444627237787/1535202857' : '';

  // load more interstitial ad
  static final String loadMoreInterstitialAd = _isAndroid ? 'ca-app-pub-1234444627237787/2349058241' : '';

  // load more interstitial ad
  static final String categoryOnTapInterstitialAd = _isAndroid
      ? 'ca-app-pub-1234444627237787/2349588472'
      : '';

  ///============ banner ad ===========
  // discover banner ad
  static final String discoverBannerAd = _isAndroid ? 'ca-app-pub-1234444627237787/9399506156' : '';

  // favourite banner ad
  static final String favouriteBannerAd = _isAndroid ? 'ca-app-pub-1234444627237787/2371063372' : '';

  // preset detail banner ad
  static final String presetDetailBannerAd = _isAndroid ? 'ca-app-pub-1234444627237787/8174054398' : '';

  // setting banner ad
  static final String settingBannerAd = _isAndroid ? 'ca-app-pub-1234444627237787/6390729661' : '';

  // other app banner ad
  static final String otherAppBannerAd = _isAndroid ? 'ca-app-pub-1234444627237787/6386330007' : '';

  /// ========== Native ad ===========
  // discover bottom native ad
  static final String discoverBottomNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/1009578924' : '';

  // exit app native ad
  static final String exitAppNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/2376978406' : '';

  // discover native ad
  static final String discoverNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/2788574770' : '';

  // favourite bottom native ad
  static final String favouriteBottomNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/5787262884' : '';

  // favourite native ad
  static final String favouriteNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/5223166420' : '';

  //home bottom native ad
  static final String homeBottomNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/4186406608' : '';

  //home reels native ad
  static final String homeReelsNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/7306404285' : '';

  // maintenance native ad
  static final String maintenanceNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/1287790844' : '';

  // no data found native ad
  static final String noDataFoundNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/4338751166' : '';

  // onboarding Native ad 1
  static final String onBoardingNativeAd1 = _isAndroid ? 'ca-app-pub-1234444627237787/7854719103' : '';

  // onboarding Native ad 2
  static final String onBoardingNativeAd2 = _isAndroid ? 'ca-app-pub-1234444627237787/4680240947' : '';

  // onboarding Native ad 3
  static final String onBoardingNativeAd3 = _isAndroid ? 'ca-app-pub-1234444627237787/6703769059' : '';

  // onboarding full screen ad
  static final String onBoardingFullScreenAd = _isAndroid ? 'ca-app-pub-1234444627237787/6993748362' : '';

  // template detail native ad
  static final String presetDetailBottomNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/2777956167' : '';

  // preset detail native ad
  static final String presetDetailNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/5595691192' : '';

  // setting bottom native ad
  static final String settingBottomNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/3967444983' : '';

  // setting native ad
  static final String settingNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/6540117528' : '';

  // splash screen native Ad
  static final String splashNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/1201150617' : '';

  // rate us native ad
  static final String rateUsNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/4534192287' : '';

  // social media native ad
  static final String socialMediaNativeAd = _isAndroid ? 'ca-app-pub-1234444627237787/7587731037' : '';

  /// =========== rewarded ad ===========
  // download image rewarded ad
  static final String downloadImageRewardedAd = _isAndroid ? 'ca-app-pub-1234444627237787/7195713329' : '';

  // play dino rewarded ad
  static final String playDinoRewardedAd = _isAndroid ? 'ca-app-pub-1234444627237787/4569549982' : '';

  // use lr rewarded ad
  static final String useLrRewardedAd = _isAndroid ? 'ca-app-pub-1234444627237787/1943386646' : '';

  // dino game restart rewarded ad
  static final String dinoGameRestart = _isAndroid ? 'ca-app-pub-1234444627237787/1518060404' : '';
}
