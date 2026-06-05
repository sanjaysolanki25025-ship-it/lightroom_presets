part of 'setting_bloc.dart';

// enum SettingStatus {
//
// }
//
// class SettingState {
//   final SettingStatus status;
//   final int? selectedRateIndex;
//
//   SettingState({this.status = SettingStatus.initial, this.selectedRateIndex});
//
//   SettingState copyWith({SettingStatus? status, int? selectedRateIndex}) {
//     return SettingState(
//       status: status ?? this.status,
//       selectedRateIndex: selectedRateIndex ?? this.selectedRateIndex,
//     );
//   }
// }


enum SettingStatus {
  initial,
  loading,
  success,
  FailureModel,
  rewardAdLoading,
  rewardAdLoaded,
  navigateToDinoGame,
  onTapLading,
  onTapLoaded,
  onTapError, }

class SettingState {
  final SettingStatus status;
  final int? selectedRateIndex;


  SettingState({this.status = SettingStatus.initial, this.selectedRateIndex = 5});

  SettingState copyWith({SettingStatus? status, int? selectedRateIndex}) {
    return SettingState(
      status: status ?? this.status,
      selectedRateIndex: selectedRateIndex ?? this.selectedRateIndex,
    );
  }

  factory SettingState.initial() {
    return SettingState(
      status: SettingStatus.initial,
      selectedRateIndex: 5,
    );
  }
}
