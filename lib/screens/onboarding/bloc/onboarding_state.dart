part of 'onboarding_bloc.dart';

enum OnboardingStatus { initial, loading, loaded, error }

class OnboardingState {
  final OnboardingStatus? status;
  final int? selectedIndex;
  final bool? showButtons;

  OnboardingState({this.status, this.selectedIndex, this.showButtons});

  OnboardingState copyWith({
    OnboardingStatus? status,
    int? selectedIndex,
    bool? showButtons,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      showButtons: showButtons ?? this.showButtons,
    );
  }

  factory OnboardingState.initial() {
    return OnboardingState(
      status: OnboardingStatus.initial,
      selectedIndex: 0,
      showButtons: false,
    );
  }
}

