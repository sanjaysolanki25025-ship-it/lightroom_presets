part of 'splash_bloc.dart';

enum SplashStatus { initial, loading, loaded, error, maintenance }

class SplashState {
  final SplashStatus? status;
  final bool? onboarding;

  SplashState({this.status, this.onboarding});

  SplashState copyWith({
    SplashStatus? status,
    String? selectedFlowName,
    bool? isOnboarding,
  }) {
    return SplashState(
      status: status ?? this.status,
      onboarding: isOnboarding,
    );
  }

  factory SplashState.initial() {
    return SplashState(
      status: SplashStatus.initial,
      onboarding: false,
    );
  }
}
