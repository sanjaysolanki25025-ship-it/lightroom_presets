import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';

class BannerAdManager {
  static final BannerAdManager _instance = BannerAdManager._internal();

  factory BannerAdManager() => _instance;

  BannerAdManager._internal();

  static final List<String> _adIds = [
    AppAdIdString.discoverBannerAd,
    AppAdIdString.favouriteBannerAd,
    AppAdIdString.presetDetailBannerAd,
    AppAdIdString.settingBannerAd,
    AppAdIdString.otherAppBannerAd,
  ];

  final Map<String, List<_CachedAdInfo>> _cachedAds = {};
  final Map<String, bool> _isLoading = {};

  // -------------------------------------------------------
  // INIT
  // -------------------------------------------------------
  void init() {
    final isSubscribed = AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;
    if (isSubscribed) {
      log('SKIP BANNER PRE-CACHE | User is subscribed.');
      return;
    }

    for (final adId in _adIds) {
      final cache = _cachedAds[adId] ?? [];
      final loading = _isLoading[adId] ?? false;

      if (cache.isEmpty && !loading) {
        preCacheAd(adId);
      }
    }
  }

  // -------------------------------------------------------
  // PRE CACHE AD
  // -------------------------------------------------------
  Future<void> preCacheAd(String adId) async {
    final isSubscribed = AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;
    if (isSubscribed) return;

    if (_isLoading[adId] == true) return;

    final cache = _cachedAds.putIfAbsent(adId, () => []);
    if (cache.isNotEmpty) return;

    _isLoading[adId] = true;

    // Get screen width in physical pixels divided by device pixel ratio to get logical pixels
    final views = PlatformDispatcher.instance.views;
    final view = views.isNotEmpty ? views.first : null;
    final width = view?.physicalSize.width ?? 0;
    final pixelRatio = view?.devicePixelRatio ?? 1.0;
    final screenWidth = (width > 0) ? (width / pixelRatio).truncate() : 320;

    log('BANNER PRE CACHE START | $adId | ScreenWidth: $screenWidth');

    final AdSize adaptiveSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(screenWidth) ?? AdSize.banner;

    BannerAd(
      adUnitId: adId,
      request: const AdRequest(),
      size: adaptiveSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          cache.add(_CachedAdInfo(ad as BannerAd, DateTime.now()));
          _isLoading[adId] = false;
          log('BANNER PRE CACHE SUCCESS | $adId');
        },
        onAdFailedToLoad: (ad, error) {
          log('BANNER PRE CACHE FAILED | $adId | Error: ${error.message}');
          ad.dispose();
          _isLoading[adId] = false;

          // Retry pre-caching after FailureModel
          Future.delayed(const Duration(seconds: 5), () {
            if (_cachedAds[adId]?.isEmpty ?? true) {
              log('BANNER RETRY PRE-CACHE | $adId | Retrying after FailureModel...');
              preCacheAd(adId);
            }
          });
        },
      ),
    ).load();
  }

  // -------------------------------------------------------
  // GET BANNER AD
  // -------------------------------------------------------
  BannerAd? getBannerAd(String adId) {
    final isSubscribed = AppPreferences().getBool(AppPreferences.subscriptionPlan) ?? false;
    if (isSubscribed) return null;

    final cache = _cachedAds[adId] ?? [];

    // Clean up stale ads (older than 45 seconds) to prevent native AdMob from invalidating them
    final now = DateTime.now();
    while (cache.isNotEmpty) {
      final first = cache.first;
      if (now.difference(first.loadedTime).inSeconds > 45) {
        log('BANNER EXPIRED | $adId | Disposing stale cached ad');
        first.ad.dispose();
        cache.removeAt(0);
      } else {
        break;
      }
    }

    if (cache.isEmpty) {
      log('BANNER NO CACHE | $adId | No Cached Banner Ads Available');
      if (!(_isLoading[adId] ?? false)) {
        preCacheAd(adId);
      }
      return null;
    }

    final adInfo = cache.removeAt(0);
    log('BANNER SERVE AD | $adId | Serving cached ad');

    // Trigger pre-cache for the next one immediately
    preCacheAd(adId);

    return adInfo.ad;
  }

  // -------------------------------------------------------
  // DISPOSE
  // -------------------------------------------------------
  void dispose() {
    for (final cache in _cachedAds.values) {
      for (final adInfo in cache) {
        adInfo.ad.dispose();
      }
      cache.clear();
    }
    _cachedAds.clear();
    _isLoading.clear();
  }
}

class _CachedAdInfo {
  final BannerAd ad;
  final DateTime loadedTime;

  _CachedAdInfo(this.ad, this.loadedTime);
}
