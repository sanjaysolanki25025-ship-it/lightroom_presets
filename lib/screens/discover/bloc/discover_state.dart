part of 'discover_bloc.dart';

enum DiscoverStatus {
  initial,
  loading,
  success,
  FailureModel,
  loadingMore,
  selectedCategoryLoading,
  selectedCategoryLoaded,
  selectedCategoryError,
  loadMoreLoading,
  loadMoreLoaded,
  loadMoreError,
  rewardAdLoading,
  rewardAdLoaded,
  navigateToDinoGame,
  interstitialAdLoading,
  interstitialAdLoaded,
}

class DiscoverState {
  final DiscoverStatus status;
  final List<LrPresetModel> entries;
  final List<CategoryModel> categories;
  final String selectedCategory;
  final int currentPage;
  final bool hasReachedMax;
  final String? errorMessage;
  final int? selectedCategoryIndex;
  final bool? hasMore;
  final DocumentSnapshot? lastDoc;

  DiscoverState({
    this.status = DiscoverStatus.initial,
    this.entries = const [],
    this.categories = const [],
    this.selectedCategory = AppStrings.txtAll,
    this.currentPage = 0,
    this.hasReachedMax = false,
    this.errorMessage,
    this.selectedCategoryIndex,
    this.hasMore,
    this.lastDoc,
  });

  DiscoverState copyWith({
    DiscoverStatus? status,
    List<LrPresetModel>? entries,
    List<CategoryModel>? categories,
    String? selectedCategory,
    int? currentPage,
    bool? hasReachedMax,
    String? errorMessage,
    int? selectedCategoryIndex,
    bool? hasMore,
    DocumentSnapshot? lastDoc,
  }) {
    return DiscoverState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      hasMore: hasMore ?? this.hasMore,
      lastDoc: lastDoc ?? this.lastDoc,
    );
  }
}
