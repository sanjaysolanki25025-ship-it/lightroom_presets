part of 'discover_bloc.dart';

abstract class DiscoverEvent {}

class FetchDiscoverData extends DiscoverEvent {
  final String category;

  FetchDiscoverData({required this.category});
}

class LoadMoreDiscoverData extends DiscoverEvent {
  final String? category;
  final bool? hasMore;

  LoadMoreDiscoverData({this.category, this.hasMore});
}

class FetchDiscoverCategories extends DiscoverEvent {}

class ChangeDiscoverCategory extends DiscoverEvent {
  final String category;
  final int index;

  ChangeDiscoverCategory(this.category, this.index);
}

class DiscoverLikeReelEvent extends DiscoverEvent {
  final int index;
  final FavouriteModel favouriteModel;

  DiscoverLikeReelEvent({required this.index, required this.favouriteModel});
}

class DiscoverRemoveLikeEvent extends DiscoverEvent {
  final int index;
  final String presentId;

  DiscoverRemoveLikeEvent({required this.index, required this.presentId});
}

class DiscoverLoadRewardAD extends DiscoverEvent {}

class DiscoverLoadedRewardAD extends DiscoverEvent {}

class DiscoverStoreCoinEvent extends DiscoverEvent {}

class DiscoverPlayDinoGame extends DiscoverEvent {}

class DiscoverMarkTemplateNotFavouriteEvent extends DiscoverEvent {
  final String templateId;
  final bool isLiked;

  DiscoverMarkTemplateNotFavouriteEvent(this.templateId, this.isLiked);
}

class LoadInterstitialAD extends DiscoverEvent {}

class LoadedInterstitialRewardAD extends DiscoverEvent {}
