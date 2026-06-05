part of 'favourite_bloc.dart';

enum FavouriteStatus {
  initial,
  loading,
  success,
  FailureModel,
  rewardAdLoading,
  rewardAdLoaded,
  navigateToDinoGame,
}

class FavouriteState {
  final FavouriteStatus status;
  final String? errorMessage;
  final List<FavouriteModel> presents;
  final List<String> categories;
  final int selectedCategoryIndex;

  FavouriteState({
    this.status = FavouriteStatus.initial,
    this.errorMessage,
    this.presents = const [],
    this.categories = const [],
    this.selectedCategoryIndex = 0,
  });

  FavouriteState copyWith({
    FavouriteStatus? status,
    String? errorMessage,
    List<FavouriteModel>? presents,
    List<String>? categories,
    int? selectedCategoryIndex,
  }) {
    return FavouriteState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      presents: presents ?? this.presents,
      categories: categories ?? this.categories,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
    );
  }
}
