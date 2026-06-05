import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/common_functions.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

part 'setting_event.dart';

part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(SettingState.initial()) {
    on<SettingLoadRewardAD>(_settingLoadRewardAD);
    on<SettingLoadedRewardAD>(_settingLoadedRewardAD);
    on<SettingStoreCoinEvent>(_settingStoreCoinEvent);
    on<SettingPlayDinoGame>(_settingPlayDinoGame);
    on<ChangeRateUsEvent>(_changeRateUsEvent);
    on<ShareAppEvent>(_shareAppEvent);
    on<RateUsEvent>(_rateUsEvent);
    on<OnInstagramTelegramFollowEvent>(_onInstagramTelegramFollowEvent);
  }

  final formKey = GlobalKey<FormState>();
  TextEditingController instagramUserIdController = TextEditingController();
  TextEditingController telegramUserIdController = TextEditingController();

  FutureOr<void> _settingLoadRewardAD(SettingLoadRewardAD event, Emitter<SettingState> emit) {
    emit(state.copyWith(status: SettingStatus.rewardAdLoading));
  }

  FutureOr<void> _settingLoadedRewardAD(SettingLoadedRewardAD event, Emitter<SettingState> emit) {
    emit(state.copyWith(status: SettingStatus.rewardAdLoaded));
  }

  FutureOr<void> _settingStoreCoinEvent(SettingStoreCoinEvent event, Emitter<SettingState> emit) {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    final newCoinTotal = totalCoin + 2;
    AppPreferences().setInt(AppPreferences.coin, newCoinTotal);
  }

  FutureOr<void> _settingPlayDinoGame(SettingPlayDinoGame event, Emitter<SettingState> emit) {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    final newCoinTotal = totalCoin - 5;
    AppPreferences().setInt(AppPreferences.coin, newCoinTotal);
    emit(state.copyWith(status: SettingStatus.navigateToDinoGame));
  }

  /// change rate us event
  FutureOr<void> _changeRateUsEvent(ChangeRateUsEvent event, Emitter<SettingState> emit) {
    emit(state.copyWith(selectedRateIndex: event.selectedRateIndex));
  }

  /// share app event
  Future<void> _shareAppEvent(ShareAppEvent event, Emitter<SettingState> emit) async {
    emit(state.copyWith(status: SettingStatus.onTapLading));
    await SharePlus.instance.share(ShareParams(text: AppStrings.txtShareMessage));

    emit(state.copyWith(status: SettingStatus.onTapLoaded));
  }

  Future<void> _rateUsEvent(RateUsEvent event, Emitter<SettingState> emit) async {
    emit(state.copyWith(status: SettingStatus.onTapLading));
    final url = Uri.parse(AppStrings.txtAppLink);
    if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    emit(state.copyWith(status: SettingStatus.onTapLoaded));
  }

  Future<void> _onInstagramTelegramFollowEvent(OnInstagramTelegramFollowEvent event, Emitter<SettingState> emit) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final String instaLink = remoteConfig.getString("instaLink");
    final String telegramLink = remoteConfig.getString("telegramLink");
    if (event.isInstagram == true) {
      final int userCoins = AppPreferences().getInt(AppPreferences.coin) ?? 0;
      await AppPreferences().setBool(AppPreferences.instagramFollow, true);
      await AppPreferences().setInt(AppPreferences.coin, userCoins + 50);
      await CommonFunction.launchUrlLink(instaLink);
    } else {
      final int userCoins = AppPreferences().getInt(AppPreferences.coin) ?? 0;
      await AppPreferences().setBool(AppPreferences.joinTelegram, true);
      await AppPreferences().setInt(AppPreferences.coin, userCoins + 50);
      await CommonFunction.launchUrlLink(telegramLink);
    }
    emit(
      state.copyWith(status: SettingStatus.initial),
    );
  }

}
