import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';

part 'onboarding_event.dart';

part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(OnboardingState.initial()) {
    on<NextButtonOnTapEvent>(_nextButtonOnTapEvent);
    on<SaveOnTapEvent>(_saveOnTapEvent);
    on<StartButtonDelayEvent>(_startButtonDelayEvent);
  }


  /// change index event handler
  Future<void> _nextButtonOnTapEvent(NextButtonOnTapEvent event, Emitter<OnboardingState> emit) async {
    emit(state.copyWith(showButtons: false, selectedIndex: event.index));
    await Future.delayed(const Duration(milliseconds: 2000));
    emit(state.copyWith(showButtons: true));
  }

  /// save on tap event handler
  FutureOr<void> _saveOnTapEvent(SaveOnTapEvent event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(status: OnboardingStatus.loading));
    AppPreferences().setInt(AppPreferences.coin, 50);
    AppPreferences().setBool(AppPreferences.onboarding, true);
    emit(state.copyWith(status: OnboardingStatus.loaded));
  }

  /// start button delay event handler
  Future<void> _startButtonDelayEvent(StartButtonDelayEvent event, Emitter<OnboardingState> emit) async {
    await Future.delayed(const Duration(milliseconds: 2000));
    emit(state.copyWith(showButtons: true, status: OnboardingStatus.initial));
  }
}
