part of 'template_detail_bloc.dart';

abstract class TemplateDetailEvent {}

class TemplateDetailLoadRewardAD extends TemplateDetailEvent {}

class TemplateDetailLoadedRewardAD extends TemplateDetailEvent {}

class TemplateDetailStoreCoinEvent extends TemplateDetailEvent {}

class TemplateDetailPlayDinoGame extends TemplateDetailEvent {}

class TemplateDetailDownloadImage extends TemplateDetailEvent {
  final String url;
  final String fileName;

  TemplateDetailDownloadImage({required this.url, required this.fileName});
}

class TemplateDetailUsedCoin extends TemplateDetailEvent {
  final int coin;

  TemplateDetailUsedCoin({required this.coin});
}

class TemplateDetailCheckLightroomInstallation extends TemplateDetailEvent {
  final LrPresetModel entry;

  TemplateDetailCheckLightroomInstallation({required this.entry});
}

class ResetStatus extends TemplateDetailEvent {}

class OpenInLightroomEvent extends TemplateDetailEvent {
  final String url;
  final String fileName;

  OpenInLightroomEvent({required this.url, required this.fileName});
}

class CountOnBackPressEvent extends TemplateDetailEvent {}


