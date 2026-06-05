import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/core/utils/native_ad_manager.dart';

part 'full_screen_native_ad_event.dart';
part 'full_screen_native_ad_state.dart';

class FullScreenNativeAdBloc extends Bloc<FullScreenNativeAdEvent, FullScreenNativeAdState> {
  FullScreenNativeAdBloc() : super(FullScreenNativeAdState.initial()) {
    on<LoadFullScreenNativeAdEvent>(_onLoadFullScreenNativeAd);
    on<_ManualAdLoadedEvent>(_onManualAdLoaded);
    on<_ManualAdFailedEvent>(_onManualAdFailed);
  }

  void _onLoadFullScreenNativeAd(LoadFullScreenNativeAdEvent event, Emitter<FullScreenNativeAdState> emit) {
    log('FullScreenNativeAdBloc: LoadFullScreenNativeAdEvent received');
    if (state.nativeAd != null || state.isLoading) return;

    final cachedAd = NativeAdManager().getFullScreenNativeAd();
    if (cachedAd != null) {
      log('✅ FullScreenNativeAdBloc: Using cached ad.');
      emit(state.copyWith(
        nativeAd: cachedAd,
        isShowNative: true,
      ));
      return;
    }

    log('⚠️ FullScreenNativeAdBloc: No cached ad found. Loading manually...');
    emit(state.copyWith(isLoading: true));

    NativeAd(
      adUnitId: AppAdIdString.homeReelsNativeAd,
      factoryId: 'full_screen_native_ad',
      request: const AdRequest(),
      nativeAdOptions: NativeAdOptions(
        videoOptions: VideoOptions(startMuted: false),
        mediaAspectRatio: MediaAspectRatio.portrait,
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          log('✅ FullScreenNativeAdBloc: Manual ad loaded callback.');
          if (!isClosed) {
            add(_ManualAdLoadedEvent(ad: ad as NativeAd));
          }
        },
        onAdFailedToLoad: (ad, error) {
          log('❌ FullScreenNativeAdBloc: Ad failed to load callback: ${error.message}');
          ad.dispose();
          if (!isClosed) {
            add(_ManualAdFailedEvent());
          }
        },
      ),
    ).load();
  }

  void _onManualAdLoaded(_ManualAdLoadedEvent event, Emitter<FullScreenNativeAdState> emit) {
    emit(state.copyWith(
      nativeAd: event.ad,
      isShowNative: true,
      isLoading: false,
    ));
  }

  void _onManualAdFailed(_ManualAdFailedEvent event, Emitter<FullScreenNativeAdState> emit) {
    emit(state.copyWith(
      isLoading: false,
    ));

    // Force pre-caching to retry in NativeAdManager
    NativeAdManager().init();

    // Fire another load request after 3 seconds to try to load it again
    Future.delayed(const Duration(seconds: 3), () {
      if (!isClosed) {
        add(LoadFullScreenNativeAdEvent());
      }
    });
  }

  @override
  Future<void> close() {
    state.nativeAd?.dispose();
    return super.close();
  }
}
