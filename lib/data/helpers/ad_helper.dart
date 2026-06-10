import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';


class AdHelper {
  // =================== SINGLE SOURCE OF TRUTH ===================
  static bool get _isUserSubscribed {
    return AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;
  }

  static InterstitialAd? _interstitialAd;
  static bool _interstitialAdLoaded = false;
  static bool _isAdShowing = false;
  static bool isCategoryAdLoadingOrShowing = false;
  static bool isLoadMoreAdLoadingOrShowing = false;
  static bool cancelLoadMoreAd = false;
  static bool isBackButtonAdLoadingOrShowing = false;

  // Public getter to know if an interstitial ad is ready to be shown
  static bool get isInterstitialReady => _interstitialAdLoaded && _interstitialAd != null && !_isAdShowing;

  static InterstitialAd? _landscapeInterstitialAd;
  static bool _landscapeInterstitialAdLoaded = false;
  static bool _isLandscapeAdShowing = false;

  // Public getter to know if a landscape interstitial ad is ready to be shown
  static bool get isLandscapeInterstitialReady => _landscapeInterstitialAdLoaded && _landscapeInterstitialAd != null && !_isLandscapeAdShowing;


  //*****************Interstitial Ad******************
  static void showInterstitialAd({
    required String adUnitId,
    required VoidCallback onComplete,
  }) {
    debugPrint("=== Interstitial Requested ===");
    debugPrint("Ad Unit Id: $adUnitId");

    if (_isUserSubscribed) {
      debugPrint("User subscribed, skipping ad");
      onComplete();
      return;
    }

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint("Interstitial Loaded");
          debugPrint("Ad Unit Id: $adUnitId");
          debugPrint("Response Info: ${ad.responseInfo}");

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint("Interstitial Dismissed");
              ad.dispose();
              onComplete();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint(
                "Interstitial Failed To Show: ${error.code} ${error.message}",
              );
              ad.dispose();
              onComplete();
            },
            onAdShowedFullScreenContent: (ad) {
              debugPrint("Interstitial Shown");
            },
            onAdImpression: (ad) {
              debugPrint("Interstitial Impression");
            },
            onAdClicked: (ad) {
              debugPrint("Interstitial Clicked");
            },
          );

          debugPrint("Calling ad.show()");
          ad.show();
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            "Interstitial Failed To Load: ${error.code} ${error.message}",
          );
          debugPrint("Ad Unit Id: $adUnitId");

          onComplete();
        },
      ),
    );
  }

  static void showLoadMoreInterstitialAd({
    required String adUnitId,
  }) {
    if (_isUserSubscribed) return;

    cancelLoadMoreAd = false;
    isLoadMoreAdLoadingOrShowing = true;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (cancelLoadMoreAd) {
            ad.dispose();
            isLoadMoreAdLoadingOrShowing = false;
            return;
          }
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isLoadMoreAdLoadingOrShowing = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              isLoadMoreAdLoadingOrShowing = false;
            },
          );

          ad.show();
        },
        onAdFailedToLoad: (error) {
          isLoadMoreAdLoadingOrShowing = false;
        },
      ),
    );
  }
  // static void precacheInterstitialAd({required String adId}) {
  //   log('Precache Interstitial Ad - Id: $adId');
  //   if (_isUserSubscribed) return;
  //   if (_interstitialAdLoaded || _isAdShowing) return;
  //
  //   InterstitialAd.load(
  //     adUnitId: adId,
  //     request: AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         // ✅ FIXED: NO callback here - let showInterstitialAd handle it
  //         _interstitialAd = ad;
  //         _interstitialAdLoaded = true;
  //         log('Interstitial ad precached');
  //       },
  //       onAdFailedToLoad: (err) {
  //         resetInterstitialAd();
  //         log('Failed to load interstitial: ${err.message}');
  //       },
  //     ),
  //   );
  // }
  //
  // static void showInterstitialAd({VoidCallback? onAdClosed, required String adId}) {
  //   if (_isUserSubscribed) {
  //     onAdClosed?.call();
  //     return;
  //   }
  //
  //   if (_interstitialAd == null || !_interstitialAdLoaded) {
  //     log('No interstitial ad ready');
  //     onAdClosed?.call();
  //     precacheInterstitialAd(adId: adId);
  //     return;
  //   }
  //
  //   // ✅ FIXED: Single source of truth for callbacks
  //   _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
  //     onAdShowedFullScreenContent: (ad) {
  //       log('Interstitial ad showed');
  //       _isAdShowing = true;
  //     },
  //     onAdDismissedFullScreenContent: (ad) {
  //       log('✅ User closed ad - calling onAdClosed');
  //       _isAdShowing = false;
  //       ad.dispose();
  //       _interstitialAd = null;
  //       _interstitialAdLoaded = false;
  //       onAdClosed?.call();
  //       precacheInterstitialAd(adId: adId);
  //     },
  //     onAdFailedToShowFullScreenContent: (ad, error) {
  //       log('Ad failed: ${error.message}');
  //       _isAdShowing = false;
  //       ad.dispose();
  //       _interstitialAd = null;
  //       _interstitialAdLoaded = false;
  //       onAdClosed?.call();
  //       precacheInterstitialAd(adId: adId);
  //     },
  //   );
  //
  //   _interstitialAd!.show();
  // }
  //
  // static void resetInterstitialAd() {
  //   _isAdShowing = false;
  //   _interstitialAdLoaded = false;
  //   _interstitialAd?.dispose();
  //   _interstitialAd = null;
  // }

  //*****************Landscape Interstitial Ad******************
  static void precacheLandscapeInterstitialAd({required String adId}) {
    log('Precache Landscape Interstitial Ad - Id: $adId');
    if (_isUserSubscribed) return;
    if (_landscapeInterstitialAdLoaded || _isLandscapeAdShowing) return;

    InterstitialAd.load(
      adUnitId: adId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _landscapeInterstitialAd = ad;
          _landscapeInterstitialAdLoaded = true;
          log('Landscape Interstitial ad precached');
        },
        onAdFailedToLoad: (err) {
          resetLandscapeInterstitialAd();
          log('Failed to load landscape interstitial: ${err.message}');
        },
      ),
    );
  }

  static void showLandscapeInterstitialAd({VoidCallback? onAdClosed, required String adId}) {
    if (_isUserSubscribed) {
      onAdClosed?.call();
      return;
    }

    if (_landscapeInterstitialAd == null || !_landscapeInterstitialAdLoaded) {
      log('No landscape interstitial ad ready');
      onAdClosed?.call();
      precacheLandscapeInterstitialAd(adId: adId);
      return;
    }

    _landscapeInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        log('Landscape Interstitial ad showed');
        _isLandscapeAdShowing = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        log('✅ User closed landscape ad - calling onAdClosed');
        _isLandscapeAdShowing = false;
        ad.dispose();
        _landscapeInterstitialAd = null;
        _landscapeInterstitialAdLoaded = false;
        onAdClosed?.call();
        precacheLandscapeInterstitialAd(adId: adId);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('Landscape Ad failed: ${error.message}');
        _isLandscapeAdShowing = false;
        ad.dispose();
        _landscapeInterstitialAd = null;
        _landscapeInterstitialAdLoaded = false;
        onAdClosed?.call();
        precacheLandscapeInterstitialAd(adId: adId);
      },
    );

    _landscapeInterstitialAd!.show();
  }

  static void resetLandscapeInterstitialAd() {
    _isLandscapeAdShowing = false;
    _landscapeInterstitialAdLoaded = false;
    _landscapeInterstitialAd?.dispose();
    _landscapeInterstitialAd = null;
  }

  //*****************Rewarded Ad******************
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;

  static bool get isRewardedAdLoaded => _rewardedAd != null;

  // PRELOAD REWARDED AD
  static void loadRewardedAd(String adUnitId) {
    if (_isLoading || _rewardedAd != null) return;

    _isLoading = true;

    log('Loading Rewarded Ad...');

    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          log('Rewarded Ad Loaded');

          _rewardedAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          log('Rewarded Ad Failed: ${error.message}');

          _rewardedAd = null;
          _isLoading = false;
        },
      ),
    );
  }

  // SHOW REWARDED AD
  static void showRewardedAd({
    required String adUnitId,
    required VoidCallback onRewardEarned,
    required VoidCallback onAdFailed,
    required VoidCallback onComplete,
  }) {
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              onComplete();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onAdFailed();
            },
          );

          ad.show(
            onUserEarnedReward: (ad, reward) {
              onRewardEarned();
            },
          );
        },
        onAdFailedToLoad: (error) {
          onAdFailed();
        },
      ),
    );
  }
  // DISPOSE
  static void disposeRewardedAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isLoading = false;
  }
  // static void precacheRewardedAd({required String adId}) {
  //   if (_isUserSubscribed) return;
  //   if (_rewardedAdLoaded || _isRewardedShowing) return;
  //
  //   log('Precache Rewarded Ad - Id: $adId');
  //   RewardedAd.load(
  //     adUnitId: adId,
  //     request: const AdRequest(),
  //     rewardedAdLoadCallback: RewardedAdLoadCallback(
  //       onAdLoaded: (RewardedAd ad) {
  //         log('RewardedAd loaded (cached).');
  //         ad.fullScreenContentCallback = FullScreenContentCallback(
  //           onAdShowedFullScreenContent: (ad) => _isRewardedShowing = true,
  //           onAdDismissedFullScreenContent: (ad) {
  //             log('RewardedAd dismissed (cached).');
  //             resetRewardedAd();
  //           },
  //           onAdFailedToShowFullScreenContent: (ad, error) {
  //             log('RewardedAd failed to show: ${error.message}');
  //             resetRewardedAd();
  //           },
  //         );
  //         _rewardedAd = ad;
  //         _rewardedAdLoaded = true;
  //       },
  //       onAdFailedToLoad: (LoadAdError error) {
  //         log('Failed to load rewarded ad: ${error.message}');
  //         resetRewardedAd();
  //         // Retry pre-caching after FailureModel
  //         Future.delayed(const Duration(seconds: 5), () {
  //           precacheRewardedAd(adId: adId);
  //         });
  //       },
  //     ),
  //   );
  // }
  //
  // /// Waits for the rewarded ad to be ready (up to [timeoutSeconds]),
  // /// then shows it. Falls back to [onComplete] if it never loads.
  // static void showRewardedAdWhenReady({
  //   required VoidCallback onComplete,
  //   required VoidCallback onRewardEarned,
  //   required String adId,
  //   int timeoutSeconds = 10,
  // }) {
  //   // Already loaded — show immediately
  //   if (_rewardedAdLoaded && _rewardedAd != null) {
  //     showRewardedAd(
  //       onComplete: onComplete,
  //       onRewardEarned: onRewardEarned,
  //       adId: adId,
  //     );
  //     return;
  //   }
  //
  //   // Not loaded yet — start loading if not already in progress
  //   precacheRewardedAd(adId: adId);
  //
  //   log('⏳ Waiting for rewarded ad to load...');
  //
  //   final stopwatch = Stopwatch()..start();
  //   const checkInterval = Duration(milliseconds: 300);
  //
  //   void checkLoop() {
  //     if (_rewardedAdLoaded && _rewardedAd != null) {
  //       log('✅ Rewarded ad ready after ${stopwatch.elapsedMilliseconds}ms');
  //       showRewardedAd(
  //         onComplete: onComplete,
  //         onRewardEarned: onRewardEarned,
  //         adId: adId,
  //       );
  //       return;
  //     }
  //
  //     if (stopwatch.elapsed.inSeconds >= timeoutSeconds) {
  //       log('⚠️ Rewarded ad timed out — skipping');
  //       onComplete();
  //       return;
  //     }
  //
  //     Future.delayed(checkInterval, checkLoop);
  //   }
  //
  //   checkLoop();
  // }
  //
  // static String checkRewardedAdStatus() {
  //   if (_rewardedAdLoaded && _rewardedAd != null) {
  //     return AppStrings.txtAvailable;
  //   } else {
  //     return AppStrings.txtNoAdAvailable;
  //   }
  // }
  //
  // static void resetRewardedAd() {
  //   _isRewardedShowing = false;
  //   _rewardedAdLoaded = false;
  //   _rewardedAd?.dispose();
  //   _rewardedAd = null;
  // }
  //
  // static void showRewardedAd({
  //   required VoidCallback onComplete,
  //   required VoidCallback onRewardEarned,
  //   required String adId,
  // }) {
  //   log('Show Rewarded Ad - Id: $adId');
  //   if (_isUserSubscribed) {
  //     onComplete();
  //     return;
  //   }
  //
  //   if (_rewardedAdLoaded && _rewardedAd != null) {
  //     final ad = _rewardedAd!;
  //     ad.fullScreenContentCallback = FullScreenContentCallback(
  //       onAdShowedFullScreenContent: (ad) => _isRewardedShowing = true,
  //       onAdDismissedFullScreenContent: (ad) {
  //         log('Rewarded video dismissed (cached).');
  //         onComplete();
  //         resetRewardedAd();
  //       },
  //       onAdFailedToShowFullScreenContent: (ad, error) {
  //         log('Failed to show rewarded video: ${error.message}');
  //         onComplete();
  //         resetRewardedAd();
  //       },
  //     );
  //
  //     ad.show(
  //       onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
  //         log('User earned reward: ${reward.amount}');
  //         onRewardEarned();
  //       },
  //     );
  //
  //     return;
  //   }
  //
  //   RewardedAd.load(
  //     adUnitId: adId,
  //     request: const AdRequest(),
  //     rewardedAdLoadCallback: RewardedAdLoadCallback(
  //       onAdLoaded: (RewardedAd ad) {
  //         log('Rewarded Video loaded (instant).');
  //         ad.fullScreenContentCallback = FullScreenContentCallback(
  //           onAdShowedFullScreenContent: (ad) => _isRewardedShowing = true,
  //           onAdDismissedFullScreenContent: (ad) {
  //             log('Rewarded video dismissed (instant).');
  //             onComplete();
  //             ad.dispose();
  //           },
  //           onAdFailedToShowFullScreenContent: (ad, error) {
  //             log('Failed to show rewarded video: ${error.message}');
  //             onComplete();
  //             ad.dispose();
  //           },
  //         );
  //
  //         ad.show(
  //           onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
  //             log('User earned reward: ${reward.amount}');
  //             onRewardEarned();
  //           },
  //         );
  //       },
  //       onAdFailedToLoad: (LoadAdError error) {
  //         log('Failed to load rewarded video: ${error.message}');
  //         onComplete();
  //       },
  //     ),
  //   );
  // }
  //
  // static void disposeAds() {
  //   if (_interstitialAd != null) {
  //     _interstitialAd?.dispose();
  //     _interstitialAd = null;
  //   }
  //   _interstitialAdLoaded = false;
  //   _isAdShowing = false;
  //
  //   resetLandscapeInterstitialAd();
  //   resetRewardedAd();
  // }

  //*****************App Open Ad******************
  static AppOpenAd? _appOpenAd;

  static bool _isShowing = false;
  /// =========================
  /// LOAD APP OPEN AD
  /// =========================
  static void precacheAppOpenAd() {
    /// already loaded
    if (_appOpenAd != null) {
      log('✅ App Open Ad Already Cached');
      return;
    }

    log('🚀 Loading App Open Ad');

    AppOpenAd.load(
      adUnitId: AppAdIdString.appOpen,
      request: const AdRequest(),
      // orientation: AppOpenAd.orientationPortrait,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          log('✅ App Open Ad Loaded');

          _appOpenAd = ad;

          _setFullScreenCallback();
        },
        onAdFailedToLoad: (error) {
          log('❌ Failed To Load App Open Ad : $error');

          _appOpenAd = null;
        },
      ),
    );
  }

  // SHOW APP OPEN AD
  static Future<void> showAppOpenAd({
    required Function onComplete,
  }) async {
    /// if ad not loaded -> move next screen
    if (_appOpenAd == null) {
      log('⚠️ App Open Ad Not Available');

      onComplete();

      /// preload for next time
      precacheAppOpenAd();

      return;
    }

    /// prevent multiple show
    if (_isShowing) {
      return;
    }

    _isShowing = true;

    await _appOpenAd?.show();

    onComplete();
  }

  // FULL SCREEN CALLBACK
  static void _setFullScreenCallback() {
    _appOpenAd?.fullScreenContentCallback =
        FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            log('🗑️ App Open Ad Dismissed');

            _disposeAd();

            /// preload next ad
            precacheAppOpenAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            log('❌ Failed To Show App Open Ad : $error');

            _disposeAd();

            /// preload next ad
            precacheAppOpenAd();
          },
        );
  }

  // DISPOSE
  static void _disposeAd() {
    _appOpenAd?.dispose();

    _appOpenAd = null;

    _isShowing = false;
  }
  // static AppOpenAd? _appOpenAd;
  // static bool _appOpenAdLoaded = false;
  // static bool _appOpenAdLoading = false;
  // static VoidCallback? _onAppOpenAdLoaded;
  //
  // static bool get isAppOpenAdLoaded => _appOpenAdLoaded;
  // static bool get isAppOpenAdLoading => _appOpenAdLoading;
  //
  // static void precacheAppOpenAd() {
  //   log('Precache AppOpen Ad - Id: ${AppAdIdString.appOpen}');
  //   if (_isUserSubscribed) return;
  //   if (_appOpenAdLoaded || _appOpenAdLoading) return;
  //
  //   _appOpenAdLoading = true;
  //   AppOpenAd.load(
  //     adUnitId: AppAdIdString.appOpen,
  //     request: const AdRequest(),
  //     adLoadCallback: AppOpenAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         _appOpenAd = ad;
  //         _appOpenAdLoaded = true;
  //         _appOpenAdLoading = false;
  //         log('AppOpenAd loaded.');
  //         if (_onAppOpenAdLoaded != null) {
  //           _onAppOpenAdLoaded!();
  //           _onAppOpenAdLoaded = null;
  //         }
  //       },
  //       onAdFailedToLoad: (err) {
  //         _appOpenAdLoading = false;
  //         _resetAppOpenAd();
  //         log('AppOpenAd failed to load: ${err.message}');
  //         if (_onAppOpenAdLoaded != null) {
  //           _onAppOpenAdLoaded!();
  //           _onAppOpenAdLoaded = null;
  //         }
  //       },
  //     ),
  //   );
  // }
  //
  // static void showAppOpenAd({required VoidCallback onComplete, VoidCallback? onAdShowed}) {
  //   log('Show AppOpen Ad - Id: ${AppAdIdString.appOpen}');
  //   if (_isUserSubscribed) {
  //     onComplete();
  //     return;
  //   }
  //
  //   if (_appOpenAdLoaded && _appOpenAd != null) {
  //     _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
  //       onAdShowedFullScreenContent: (ad) {
  //         onAdShowed?.call();
  //       },
  //       onAdDismissedFullScreenContent: (ad) {
  //         _resetAppOpenAd();
  //         precacheAppOpenAd();
  //         onComplete();
  //       },
  //       onAdFailedToShowFullScreenContent: (ad, error) {
  //         _resetAppOpenAd();
  //         precacheAppOpenAd();
  //         onComplete();
  //       },
  //     );
  //
  //     _appOpenAd!.show();
  //     return;
  //   }
  //
  //   // If an app open ad is currently loading, wait for it.
  //   if (_appOpenAdLoading) {
  //     log('AppOpen ad is currently loading; waiting.');
  //     _onAppOpenAdLoaded = () => showAppOpenAd(onComplete: onComplete, onAdShowed: onAdShowed);
  //     return;
  //   }
  //
  //   // Not loaded nor loading: load and show instantly when loaded.
  //   _appOpenAdLoading = true;
  //   AppOpenAd.load(
  //     adUnitId: AppAdIdString.appOpen,
  //     request: const AdRequest(),
  //     adLoadCallback: AppOpenAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         _appOpenAdLoading = false;
  //         ad.fullScreenContentCallback = FullScreenContentCallback(
  //           onAdShowedFullScreenContent: (ad) {
  //             onAdShowed?.call();
  //           },
  //           onAdDismissedFullScreenContent: (ad) {
  //             _resetAppOpenAd();
  //             precacheAppOpenAd();
  //             onComplete();
  //           },
  //           onAdFailedToShowFullScreenContent: (ad, error) {
  //             _resetAppOpenAd();
  //             precacheAppOpenAd();
  //             onComplete();
  //           },
  //         );
  //         ad.show();
  //       },
  //       onAdFailedToLoad: (err) {
  //         _appOpenAdLoading = false;
  //         log('Failed to load AppOpen ad: ${err.message}');
  //         onComplete();
  //       },
  //     ),
  //   );
  // }
  //
  // static void _resetAppOpenAd() {
  //   _appOpenAd?.dispose();
  //   _appOpenAd = null;
  //   _appOpenAdLoaded = false;
  //   _appOpenAdLoading = false;
  // }
}
