part of 'template_detail_bloc.dart';

enum TemplateDetailStatus {
  initial,
  rewardAdLoading,
  rewardAdLoaded,
  navigateToDinoGame,
  downloading,
  downloadSuccess,
  downloadFailureModel,
  lightroomNotInstalled,
  lightroomInstalled,
  openingInLightroom,
  success,
}

class TemplateDetailState {
  final TemplateDetailStatus status;
  final String? errorMessage;
  final String? downloadMessage;
  final LrPresetModel? entry;

  TemplateDetailState({
    this.status = TemplateDetailStatus.initial,
    this.errorMessage,
    this.downloadMessage,
    this.entry,
  });

  TemplateDetailState copyWith({
    TemplateDetailStatus? status,
    String? errorMessage,
    String? downloadMessage,
    LrPresetModel? entry,
  }) {
    return TemplateDetailState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadMessage: downloadMessage ?? this.downloadMessage,
      entry: entry ?? this.entry,
    );
  }
}
