part of 'setting_bloc.dart';

abstract class SettingEvent {}

class SettingLoadRewardAD extends SettingEvent {}

class SettingLoadedRewardAD extends SettingEvent {}

class SettingStoreCoinEvent extends SettingEvent {}

class SettingPlayDinoGame extends SettingEvent {}

class ChangeRateUsEvent extends SettingEvent {
  final int selectedRateIndex;

  ChangeRateUsEvent({required this.selectedRateIndex});
}

class ShareAppEvent extends SettingEvent {}

class RateUsEvent extends SettingEvent {}

class OnInstagramTelegramFollowEvent extends SettingEvent {
  final bool isInstagram;

  OnInstagramTelegramFollowEvent({required this.isInstagram});
}