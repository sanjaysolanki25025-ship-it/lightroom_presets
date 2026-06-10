import 'dart:async';
import 'dart:developer';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';

class AdCacheConfig {
  final int cacheSize;
  final String factoryId;
  final String adName;

  AdCacheConfig({required this.cacheSize, required this.factoryId, required this.adName});
}

class AdStats {
  int loaded = 0;
  int served = 0;
  int failed = 0;

  int get pending => loaded - served;

  Map<String, dynamic> toJson() {
    return {'loaded': loaded, 'served': served, 'failed': failed, 'pending': pending};
  }
}

class NativeAdManager {
  static final NativeAdManager _instance = NativeAdManager._internal();

  factory NativeAdManager() => _instance;

  NativeAdManager._internal();

  static final Map<String, AdCacheConfig> _configs = {
    AppAdIdString.splashNativeAd: AdCacheConfig(
      adName: 'Splash Native Ad',
      cacheSize: 1,
      factoryId: 'row_native_ad',
    ),
    AppAdIdString.onBoardingNativeAd1: AdCacheConfig(
      adName: 'OnBoarding Native Ad 1',
      cacheSize: 1,
      factoryId: 'row_native_ad',
    ),
    AppAdIdString.onBoardingNativeAd2: AdCacheConfig(
      adName: 'OnBoarding Native Ad 2',
      cacheSize: 1,
      factoryId: 'row_native_ad',
    ),
    AppAdIdString.onBoardingNativeAd3: AdCacheConfig(
      adName: 'OnBoarding Native Ad 3',
      cacheSize: 1,
      factoryId: 'row_native_ad',
    ),
    AppAdIdString.onBoardingFullScreenAd: AdCacheConfig(
      adName: 'OnBoarding Full Screen Ad',
      cacheSize: 1,
      factoryId: 'full_screen_native_ad',
    ),
    AppAdIdString.homeReelsNativeAd: AdCacheConfig(
      adName: 'Home Reels Native Ad',
      cacheSize: 2,
      factoryId: 'full_screen_native_ad',
    ),
    AppAdIdString.homeBottomNativeAd: AdCacheConfig(
      adName: 'Home Bottom Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.discoverNativeAd: AdCacheConfig(
      adName: 'Discover Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.discoverBottomNativeAd: AdCacheConfig(
      adName: 'Discover Bottom Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),

    AppAdIdString.favouriteNativeAd: AdCacheConfig(
      adName: 'Favourite Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.favouriteBottomNativeAd: AdCacheConfig(
      adName: 'Favourite Bottom Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),

    AppAdIdString.presetDetailNativeAd: AdCacheConfig(
      adName: 'Preset Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.presetDetailBottomNativeAd: AdCacheConfig(
      adName: 'Preset Bottom Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),

    AppAdIdString.settingNativeAd: AdCacheConfig(
      adName: 'Setting Native Ad',
      cacheSize: 2,
      factoryId: 'medium_native_ad',
    ),
    AppAdIdString.settingBottomNativeAd: AdCacheConfig(
      adName: 'Setting Bottom Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),

    AppAdIdString.maintenanceNativeAd: AdCacheConfig(
      adName: 'Maintenance Native Ad',
      cacheSize: 1,
      factoryId: 'row_native_ad',
    ),

    AppAdIdString.exitAppNativeAd: AdCacheConfig(
      adName: 'Exit App Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),

    AppAdIdString.noDataFoundNativeAd: AdCacheConfig(
      adName: 'No Data Found Native Ad',
      cacheSize: 1,
      factoryId: 'medium_native_ad',
    ),

    AppAdIdString.socialMediaNativeAd: AdCacheConfig(
      adName: 'Social Media Native Ad',
      cacheSize: 1,
      factoryId: 'row_native_ad',
    ),

    AppAdIdString.rateUsNativeAd: AdCacheConfig(
      adName: 'Rate Us Native Ad',
      cacheSize: 1,
      factoryId: 'row_native_ad',
    ),
  };

  final Map<String, List<NativeAd>> _cachedAds = {};
  final Map<String, bool> _isLoading = {};
  final Map<String, AdStats> _adStats = {};
  final Map<String, bool> _preCacheSuccessful = {};

  AdStats _getStats(String adId) {
    return _adStats.putIfAbsent(adId, () => AdStats());
  }

  // -------------------------------------------------------
  // INIT
  // -------------------------------------------------------
  void init() {
    final onboarding = AppPreferences().getBool(AppPreferences.onboarding) ?? false;
    final isMaintenance = FirebaseRemoteConfig.instance.getBool("isMaintenance");
    for (final entry in _configs.entries) {
      final adId = entry.key;

      if (onboarding &&
          (adId == AppAdIdString.onBoardingNativeAd1 ||
              adId == AppAdIdString.onBoardingNativeAd2 ||
              adId == AppAdIdString.onBoardingNativeAd3 ||
              adId == AppAdIdString.onBoardingFullScreenAd)) {
        log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Onboarding already completed.');
        continue;
      }

      if (adId == AppAdIdString.maintenanceNativeAd && !isMaintenance) {
        log('SKIP INITIAL PRE-CACHE | ${entry.value.adName} | $adId | Not in maintenance mode.');
        continue;
      }

      final cache = _cachedAds[adId] ?? [];
      final loading = _isLoading[adId] ?? false;

      if (cache.isEmpty && !loading) {
        _loadBatchForAd(adId);
      }
    }
  }

  // -------------------------------------------------------
  // LOAD ADS
  // -------------------------------------------------------
  void _loadBatchForAd(String adId) async {
    final config = _configs[adId];
    if (config == null) return;

    if (_isLoading[adId] == true) return;

    final onboarding = AppPreferences().getBool(AppPreferences.onboarding) ?? false;
    if (onboarding &&
        (adId == AppAdIdString.onBoardingNativeAd1 ||
            adId == AppAdIdString.onBoardingNativeAd2 ||
            adId == AppAdIdString.onBoardingNativeAd3 ||
            adId == AppAdIdString.onBoardingFullScreenAd ||
            adId == AppAdIdString.maintenanceNativeAd)) {
      log('SKIP PRE-CACHE | ${config.adName} | $adId | Onboarding already completed.');
      return;
    }

    // If this ad has been successfully pre-cached once, don't try to pre-cache again (except for full screen reels ads, home bottom ads, and discover ads)
    if (adId != AppAdIdString.homeReelsNativeAd &&
        adId != AppAdIdString.homeBottomNativeAd &&
        adId != AppAdIdString.discoverNativeAd &&
        adId != AppAdIdString.discoverBottomNativeAd &&
        adId != AppAdIdString.favouriteBottomNativeAd &&
        adId != AppAdIdString.favouriteNativeAd &&
        adId != AppAdIdString.presetDetailNativeAd &&
        adId != AppAdIdString.presetDetailNativeAd &&
        adId != AppAdIdString.settingNativeAd &&
        adId != AppAdIdString.settingBottomNativeAd &&
        adId != AppAdIdString.exitAppNativeAd &&
        adId != AppAdIdString.noDataFoundNativeAd &&
        adId != AppAdIdString.socialMediaNativeAd &&
        adId != AppAdIdString.rateUsNativeAd &&
        _preCacheSuccessful[adId] == true) {
      log('SKIP PRE-CACHE | ${config.adName} | $adId | Already successfully pre-cached once.');
      return;
    }

    _isLoading[adId] = true;

    final cache = _cachedAds.putIfAbsent(adId, () => []);
    final currentCacheSize = cache.length;
    final needToLoad = config.cacheSize - currentCacheSize;

    if (needToLoad <= 0) {
      _isLoading[adId] = false;
      return;
    }

    final futures = <Future<void>>[];

    for (int i = 0; i < needToLoad; i++) {
      final completer = Completer<void>();

      // 📥 PRE CACHE START LOG
      log('PRE CACHE START | ${config.adName} | $adId | Ad ${i + 1}/$needToLoad');

      NativeAd(
        adUnitId: adId,
        factoryId: config.factoryId,
        request: const AdRequest(),
        nativeAdOptions: adId == AppAdIdString.homeReelsNativeAd
            ? NativeAdOptions(
                videoOptions: VideoOptions(startMuted: false),
                mediaAspectRatio: MediaAspectRatio.portrait,
              )
            : null,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            cache.add(ad as NativeAd);
            _getStats(adId).loaded++;
            _preCacheSuccessful[adId] = true;

            // ✅ PRE CACHE SUCCESS LOG
            log(
              'PRE CACHE SUCCESS | ${config.adName} | $adId | Total Pre Cache: ${cache.length}/${config.cacheSize}',
            );

            completer.complete();
          },
          onAdFailedToLoad: (ad, error) {
            _getStats(adId).failed++;

            // ❌ PRE CACHE FAILED LOG
            log('PRE CACHE FAILED | ${config.adName} | $adId | Error: ${error.message}');

            ad.dispose();
            completer.complete();

            // Retry pre-caching after FailureModel (except for splash native ad)
            if (adId != AppAdIdString.splashNativeAd) {
              Future.delayed(const Duration(seconds: 5), () {
                final currentCache = _cachedAds[adId] ?? [];
                bool shouldRetry = false;

                if (adId == AppAdIdString.homeReelsNativeAd ||
                    adId == AppAdIdString.homeBottomNativeAd ||
                    adId == AppAdIdString.discoverNativeAd ||
                    adId == AppAdIdString.discoverBottomNativeAd ||
                    adId == AppAdIdString.favouriteNativeAd ||
                    adId == AppAdIdString.favouriteBottomNativeAd ||
                    adId == AppAdIdString.presetDetailNativeAd ||
                    adId == AppAdIdString.presetDetailNativeAd ||
                    adId == AppAdIdString.settingNativeAd ||
                    adId == AppAdIdString.settingBottomNativeAd ||
                    adId == AppAdIdString.exitAppNativeAd ||
                    adId == AppAdIdString.noDataFoundNativeAd ||
                    adId == AppAdIdString.socialMediaNativeAd ||
                    adId == AppAdIdString.rateUsNativeAd
                ) {
                  shouldRetry = currentCache.length < config.cacheSize && !(_isLoading[adId] ?? false);
                } else {
                  shouldRetry =
                      currentCache.isEmpty &&
                      !(_isLoading[adId] ?? false) &&
                      _preCacheSuccessful[adId] != true;
                }

                if (shouldRetry) {
                  log('RETRY PRE-CACHE | ${config.adName} | $adId | Retrying after FailureModel...');
                  _loadBatchForAd(adId);
                }
              });
            }
          },
        ),
      ).load();

      futures.add(completer.future);
    }

    await Future.wait(futures);
    _isLoading[adId] = false;
  }

  // -------------------------------------------------------
  // GET AD (row_native_ad)
  // -------------------------------------------------------
  NativeAd? getAd(String adId) {
    final onboarding = AppPreferences().getBool(AppPreferences.onboarding) ?? false;
    if (onboarding &&
        (adId == AppAdIdString.onBoardingNativeAd1 ||
            adId == AppAdIdString.onBoardingNativeAd2 ||
            adId == AppAdIdString.onBoardingNativeAd3)) {
      log('SKIP GET AD | $adId | Onboarding already completed.');
      return null;
    }

    final config = _configs[adId];
    if (config != null && config.factoryId != 'row_native_ad') return null;
    return _serveAd(adId);
  }

  // -------------------------------------------------------
  // GET MEDIUM AD (medium_native_ad)
  // -------------------------------------------------------
  NativeAd? getMediumAd(String adId) {
    final config = _configs[adId];
    if (config != null && config.factoryId != 'medium_native_ad') return null;
    return _serveAd(adId);
  }

  // -------------------------------------------------------
  // GET FULL SCREEN AD
  // -------------------------------------------------------
  NativeAd? getFullScreenNativeAd({String? adId}) {
    final targetAdId = adId ?? AppAdIdString.homeReelsNativeAd;
    final config = _configs[targetAdId];

    if (config == null) return null;

    if (config.factoryId != 'full_screen_native_ad') {
      return null;
    }

    return _serveAd(targetAdId);
  }

  // -------------------------------------------------------
  // SERVE AD
  // -------------------------------------------------------
  NativeAd? _serveAd(String adId) {
    final config = _configs[adId];
    if (config == null) return null;

    final onboarding = AppPreferences().getBool(AppPreferences.onboarding) ?? false;
    if (onboarding &&
        (adId == AppAdIdString.onBoardingNativeAd1 ||
            adId == AppAdIdString.onBoardingNativeAd2 ||
            adId == AppAdIdString.onBoardingNativeAd3 ||
            adId == AppAdIdString.onBoardingFullScreenAd)) {
      log('SKIP SERVE AD | ${config.adName} | $adId | Onboarding already completed.');
      return null;
    }

    final cache = _cachedAds[adId] ?? [];

    if (cache.isEmpty) {
      log('NO CACHE | ${config.adName} | $adId | No Cached Ads Available');

      if (!(_isLoading[adId] ?? false)) {
        _loadBatchForAd(adId);
      }

      return null;
    }

    final ad = cache.removeAt(0);
    final stats = _getStats(adId);
    stats.served++;

    // 📤 SHOW AD LOG
    log(
      'SHOW AD | ${config.adName} | $adId | Total Pre Cache: ${cache.length}/${config.cacheSize} | Showed Ad: ${stats.served}',
    );

    if (cache.isEmpty) {
      _loadBatchForAd(adId);
    }

    return ad;
  }

  // -------------------------------------------------------
  // STATS
  // -------------------------------------------------------
  Map<String, dynamic> getAdStats(String adId) {
    final stats = _getStats(adId);
    return {
      'adId': adId,
      'loaded': stats.loaded,
      'served': stats.served,
      'failed': stats.failed,
      'pending': stats.pending,
      'cached': _cachedAds[adId]?.length ?? 0,
      'isLoading': _isLoading[adId] ?? false,
    };
  }

  void printAllStats() {
    for (final adId in _configs.keys) {
      final config = _configs[adId];
      final stats = getAdStats(adId);
      log(
        'STATS | ${config?.adName} | $adId | Loaded: ${stats['loaded']} | Served: ${stats['served']} | Failed: ${stats['failed']} | Cached: ${stats['cached']}',
      );
    }
  }

  // -------------------------------------------------------
  // DISPOSE
  // -------------------------------------------------------
  void dispose() {
    for (final cache in _cachedAds.values) {
      for (final ad in cache) {
        ad.dispose();
      }
      cache.clear();
    }
    _cachedAds.clear();
    _isLoading.clear();
    _adStats.clear();
    _preCacheSuccessful.clear();
  }
}
