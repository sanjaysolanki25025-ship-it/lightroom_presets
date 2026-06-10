part of 'full_screen_native_ad_bloc.dart';

class FullScreenNativeAdState {
  final bool isShowNative;
  final NativeAd? nativeAd;
  final bool isLoading;
  final String adId;

  FullScreenNativeAdState({
    required this.isShowNative,
    this.nativeAd,
    required this.isLoading,
    required this.adId,
  });

  factory FullScreenNativeAdState.initial() => FullScreenNativeAdState(
        isShowNative: false,
        nativeAd: null,
        isLoading: false,
        adId: '',
      );

  FullScreenNativeAdState copyWith({
    bool? isShowNative,
    NativeAd? nativeAd,
    bool? isLoading,
    String? adId,
  }) {
    return FullScreenNativeAdState(
      isShowNative: isShowNative ?? this.isShowNative,
      nativeAd: nativeAd ?? this.nativeAd,
      isLoading: isLoading ?? this.isLoading,
      adId: adId ?? this.adId,
    );
  }
}
