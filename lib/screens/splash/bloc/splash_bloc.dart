import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'splash_event.dart';

part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashState.initial()) {
    on<SplashInitialEvent>(_splashInitialEvent);
  }


  /// splash initial event
  Future<void> _splashInitialEvent(SplashInitialEvent event, Emitter<SplashState> emit) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    // await _updateSubscriptionInBackground();

    bool? onboarding = AppPreferences().getBool(AppPreferences.onboarding);

    /// open app count
    int openAppCount = AppPreferences().getInt(AppPreferences.openAppCount) ?? 0;

    if (openAppCount >= 1) {
      AppPreferences().setInt(AppPreferences.openAppCount, 0);
    } else {
      AppPreferences().setInt(AppPreferences.openAppCount, openAppCount + 1);
    }
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(fetchTimeout: const Duration(seconds: 7), minimumFetchInterval: Duration.zero),
    );

    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      print("RemoteConfig: Error during fetch: $e");
    }

    bool isMaintenance = remoteConfig.getBool("under_maintenance");

    if (isMaintenance) {
      emit(state.copyWith(status: SplashStatus.maintenance));
      return;
    }
    await Future.delayed(const Duration(seconds: 3));

    emit(state.copyWith(status: SplashStatus.loaded, isOnboarding: onboarding));
  }

  Future<void> _updateSubscriptionInBackground() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();

      var premiumEntitlement = customerInfo.entitlements.all["premium"];
      bool isPremiumActive = premiumEntitlement?.isActive ?? false;

      String planName = isPremiumActive ? (premiumEntitlement?.productIdentifier ?? "") : "";

      await AppPreferences().setBool(AppPreferences.subscriptionPlan, isPremiumActive);
      await AppPreferences().setString(AppPreferences.planType, planName);
    } catch (e) {
      print("Error updating subscription: $e");
    }
  }
}
