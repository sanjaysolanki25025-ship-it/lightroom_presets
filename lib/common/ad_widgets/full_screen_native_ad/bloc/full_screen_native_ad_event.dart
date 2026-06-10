part of 'full_screen_native_ad_bloc.dart';

abstract class FullScreenNativeAdEvent {}

class LoadFullScreenNativeAdEvent extends FullScreenNativeAdEvent {
  final String? adId;
  LoadFullScreenNativeAdEvent({this.adId});
}

class _ManualAdLoadedEvent extends FullScreenNativeAdEvent {
  final NativeAd ad;
  _ManualAdLoadedEvent({required this.ad});
}

class _ManualAdFailedEvent extends FullScreenNativeAdEvent {}
