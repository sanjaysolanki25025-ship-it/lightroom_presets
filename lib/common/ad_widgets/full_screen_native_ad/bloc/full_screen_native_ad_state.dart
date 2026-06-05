part of 'full_screen_native_ad_bloc.dart';

class FullScreenNativeAdState {
  final bool isShowNative;
  final NativeAd? nativeAd;
  final bool isLoading;

  FullScreenNativeAdState({
    required this.isShowNative,
    this.nativeAd,
    required this.isLoading,
  });

  factory FullScreenNativeAdState.initial() => FullScreenNativeAdState(
        isShowNative: false,
        nativeAd: null,
        isLoading: false,
      );

  FullScreenNativeAdState copyWith({
    bool? isShowNative,
    NativeAd? nativeAd,
    bool? isLoading,
  }) {
    return FullScreenNativeAdState(
      isShowNative: isShowNative ?? this.isShowNative,
      nativeAd: nativeAd ?? this.nativeAd,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
