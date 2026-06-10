part of 'home_bloc.dart';

abstract class HomeEvent {}

class FetchHomeData extends HomeEvent {}

class LoadMoreHomeData extends HomeEvent {}

class ChangeCategory extends HomeEvent {
  final String category;

  ChangeCategory(this.category);
}

class DownloadImage extends HomeEvent {
  final String url;
  final String fileName;

  DownloadImage({required this.url, required this.fileName});
}

class OpenInLightroom extends HomeEvent {
  final String url;
  final String fileName;

  OpenInLightroom({required this.url, required this.fileName});
}

class LoadRewardAD extends HomeEvent {}

class LoadedRewardAD extends HomeEvent {}

class StoreCoinEvent extends HomeEvent {}

class PlayDinoGame extends HomeEvent {}

class CheckLightroomInstallation extends HomeEvent {
  final LrPresetModel entry;

  CheckLightroomInstallation({required this.entry});
}

class UsedCoin extends HomeEvent {
  final int coin;

  UsedCoin({required this.coin});
}

class LikeReelEvent extends HomeEvent {
  final int index;
  final FavouriteModel favouriteModel;

  LikeReelEvent({required this.index, required this.favouriteModel});
}

class RemoveLikeEvent extends HomeEvent {
  final int index;
  final String presentId;

  RemoveLikeEvent({required this.index, required this.presentId});
}

class ResetHomeStatus extends HomeEvent {}

class MarkTemplateNotFavouriteEvent extends HomeEvent {
  final String templateId;
  final bool isLiked;

  MarkTemplateNotFavouriteEvent(this.templateId, this.isLiked);
}

class HomeViewIndexChanged extends HomeEvent {
  final int index;

  HomeViewIndexChanged({required this.index});
}

