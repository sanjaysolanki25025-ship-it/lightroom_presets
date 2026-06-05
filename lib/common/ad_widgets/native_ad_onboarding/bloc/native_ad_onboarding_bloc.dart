import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'native_ad_onboarding_event.dart';

part 'native_ad_onboarding_state.dart';

class NativeAdOnboardingBloc
    extends Bloc<NativeAdOnboardingEvent, NativeAdOnboardingState> {
  NativeAdOnboardingBloc() : super(NativeAdOnboardingState.initial()) {
    on<ShowNativeAdOnboardingEvent>(_showNativeAdOnboardingEvent);
  }

  /// show native ad
  FutureOr<void> _showNativeAdOnboardingEvent(
    ShowNativeAdOnboardingEvent event,
    Emitter<NativeAdOnboardingState> emit,
  ) {
    log("NativeAdOnboardingBloc: Received event ShowNativeAdOnboardingEvent(${event.isShowNative})");
    emit(state.copyWith(isShowNative: event.isShowNative));
  }
}
