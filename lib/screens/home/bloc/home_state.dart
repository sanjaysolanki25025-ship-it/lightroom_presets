import 'package:lightroom_template/data/models/category_model.dart';
import 'package:lightroom_template/data/models/lr_preset_model.dart';

enum HomeStatus {
  initial,
  loading,
  success,
  FailureModel,
  loadingMore,
  downloading,
  downloadSuccess,
  downloadFailureModel,
  openingInLightroom,
  lightroomNotInstalled,
  lightroomInstalled,
  rewardAdLoading,
  rewardAdLoaded,

  navigateToDinoGame,
}

class HomeState {
  final HomeStatus status;
  final List<LrPresetModel> entries;
  final List<CategoryModel> categories;
  final int currentPage;
  final String selectedCategory;
  final String? downloadMessage;
  final String? errorMessage;
  final bool hasReachedMax;
  final LrPresetModel? entry;
  final bool hasMore;

  HomeState({
    this.status = HomeStatus.initial,
    this.entries = const [],
    this.categories = const [],
    this.currentPage = 0,
    this.selectedCategory = "All",
    this.downloadMessage,
    this.errorMessage,
    this.hasReachedMax = false,
    this.entry,
    this.hasMore = true,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<LrPresetModel>? entries,
    List<CategoryModel>? categories,
    int? currentPage,
    String? selectedCategory,
    String? downloadMessage,
    String? errorMessage,
    bool? hasReachedMax,
    LrPresetModel? entry,
    bool? hasMore,
  }) {
    return HomeState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      categories: categories ?? this.categories,
      currentPage: currentPage ?? this.currentPage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      downloadMessage: downloadMessage ?? this.downloadMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      entry: entry ?? this.entry,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
