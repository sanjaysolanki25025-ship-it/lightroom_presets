part of 'onboarding_bloc.dart';

abstract class OnboardingEvent {}

class NextButtonOnTapEvent extends OnboardingEvent {
  final int index;

  NextButtonOnTapEvent({required this.index});
}

class SaveOnTapEvent extends OnboardingEvent {}

class StartButtonDelayEvent extends OnboardingEvent {}
