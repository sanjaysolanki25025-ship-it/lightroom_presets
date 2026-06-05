part of 'favourite_bloc.dart';

abstract class FavouriteEvent {}

class LoadRewardADEvent extends FavouriteEvent {}

class LoadedRewardADEvent extends FavouriteEvent {}

class FavouriteStoreCoinEvent extends FavouriteEvent {}

class FavouritePlayDinoGame extends FavouriteEvent {}

class FetchFavouriteEvent extends FavouriteEvent {}

class ChangeFavouriteCategoryEvent extends FavouriteEvent {
  final int index;
  ChangeFavouriteCategoryEvent({required this.index});
}

class RemoveFavouriteEvent extends FavouriteEvent {
  final int index;
  final String presentId;
  RemoveFavouriteEvent({required this.index, required this.presentId});
}

class FavouriteMarkTemplateNotFavouriteEvent extends FavouriteEvent {
  final String templateId;
  final bool isLiked;

  FavouriteMarkTemplateNotFavouriteEvent(this.templateId, this.isLiked);
}

