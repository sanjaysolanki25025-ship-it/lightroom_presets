import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:lightroom_template/data/models/category_model.dart';
import 'package:lightroom_template/data/models/favourite_model.dart';
import 'package:lightroom_template/data/models/lr_preset_model.dart';
import 'package:lightroom_template/data/repository/app_repository.dart';
import 'package:lightroom_template/screens/discover/repository/discover_repository.dart';
import 'package:lightroom_template/screens/favourite/bloc/favourite_bloc.dart';
import 'package:lightroom_template/screens/home/bloc/home_bloc.dart';

part 'discover_event.dart';

part 'discover_state.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final HomeBloc homeBloc;
  final FavouriteBloc favouriteBloc;
  DiscoverBloc({required this.homeBloc, required this.favouriteBloc}) : super(DiscoverState()) {
    homeBloc.discoverBloc = this;
    homeBloc.favouriteBloc = favouriteBloc;
    favouriteBloc.discoverBloc = this;
    favouriteBloc.homeBloc = homeBloc;

    on<FetchDiscoverData>(_onFetchDiscoverData);
    on<LoadMoreDiscoverData>(_onLoadMoreDiscoverData);
    on<FetchDiscoverCategories>(_onFetchCategories);
    on<ChangeDiscoverCategory>(_onChangeCategory);
    on<DiscoverLikeReelEvent>(_discoverLikeReelEvent);
    on<DiscoverRemoveLikeEvent>(_discoverRemoveLikeEvent);
    on<DiscoverLoadRewardAD>(_discoverLoadRewardAD);
    on<DiscoverLoadedRewardAD>(_discoverLoadedRewardAD);
    on<DiscoverStoreCoinEvent>(_discoverStoreCoinEvent);
    on<DiscoverPlayDinoGame>(_discoverPlayDinoGame);
    on<DiscoverMarkTemplateNotFavouriteEvent>(_discoverMarkTemplateNotFavouriteEvent);
    on<LoadInterstitialAD>(_loadInterstitialAD);
    on<LoadedInterstitialRewardAD>(_loadedInterstitialRewardAD);
  }

  final AppRepository appRepository = AppRepository();
  final DiscoverRepository discoverRepository = DiscoverRepository();
  static const int _pageSize = 6;
  final randomStart = Random().nextDouble();
  final List<CategoryModel> categoryListData = [
    CategoryModel(name: 'All'),
    CategoryModel(name: 'Premium'),
    CategoryModel(name: 'Trending'),
  ];

  Future<void> _onFetchDiscoverData(FetchDiscoverData event, Emitter<DiscoverState> emit) async {
    emit(state.copyWith(status: DiscoverStatus.selectedCategoryLoading));

    final result = await discoverRepository.fetchPresentsDiscover(category: event.category, limit: _pageSize);
    await result.match(
      (f) {
        emit(state.copyWith(status: DiscoverStatus.selectedCategoryError, errorMessage: f.message));
      },
      (paged) async {
        /// favourite presents
        final favoriteIdsResult = await appRepository.fetchFavouritePresents();

        List<String> favIds = [];
        favoriteIdsResult.match((FailureModel) => null, (favModels) {
          favIds = favModels.map((fav) => fav.presentId.toString()).toList();
        });

        /// map favourite state
        List<LrPresetModel> list = paged.presents.map((presents) {
          final isLiked = favIds.contains(presents.id.toString());
          return presents.copyWith(isFavourite: isLiked);
        }).toList();
        list.shuffle();
        emit(
          state.copyWith(
            status: DiscoverStatus.selectedCategoryLoaded,
            entries: list,
            lastDoc: paged.lastDoc,
            hasMore: paged.hasMore,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreDiscoverData(LoadMoreDiscoverData event, Emitter<DiscoverState> emit) async {
    if (state.hasMore == false) return;
    emit(state.copyWith(status: DiscoverStatus.loadMoreLoading));

    final result = await discoverRepository.fetchPresentsDiscover(
      category: event.category,
      lastDoc: state.lastDoc,
      limit: _pageSize,
    );
    await result.match(
      (f) async {
        emit(state.copyWith(status: DiscoverStatus.loadMoreError, errorMessage: f.message));
      },
      (paged) async {
        final favoriteIdsResult = await appRepository.fetchFavouritePresents();

        List<String> favIds = [];
        favoriteIdsResult.match((FailureModel) => null, (favModels) {
          favIds = favModels.map((fav) => fav.presentId.toString()).toList();
        });

        /// map favourite state
        List<LrPresetModel> list = paged.presents.map((presents) {
          final isLiked = favIds.contains(presents.id);
          return presents.copyWith(isFavourite: isLiked);
        }).toList();

        list.shuffle();

        emit(
          state.copyWith(
            status: DiscoverStatus.loadMoreLoaded,
            entries: [...state.entries, ...list],
            lastDoc: paged.lastDoc ?? state.lastDoc,
            hasMore: paged.hasMore,
          ),
        );
      },
    );
  }

  Future<void> _onFetchCategories(FetchDiscoverCategories event, Emitter<DiscoverState> emit) async {
    emit(state.copyWith(status: DiscoverStatus.loading));
    final categoryResult = await appRepository.fetchCategory();
    final presentsResult = await discoverRepository.fetchPresentsDiscover(
      limit: _pageSize,
      randomStart: randomStart,
    );

    final favoriteIdsResult = await appRepository.fetchFavouritePresents();
    List<String> favIds = [];

    favoriteIdsResult.match((FailureModel) => null, (favModels) {
      favIds = favModels.map((fav) => fav.presentId.toString()).toList();
    });

    await categoryResult.fold(
      (FailureModel) async {
        if (emit.isDone) return;
        emit(state.copyWith(status: DiscoverStatus.FailureModel, errorMessage: FailureModel.message));
      },
      (categoryList) async {
        await presentsResult.fold(
          (FailureModel) async {
            if (emit.isDone) return;
            emit(state.copyWith(status: DiscoverStatus.FailureModel, errorMessage: FailureModel.message));
          },
          (paged) async {
            List<LrPresetModel> updatedPresents = paged.presents.map((presents) {
              final isLiked = favIds.contains(presents.id);
              return presents.copyWith(isFavourite: isLiked);
            }).toList();
            updatedPresents.shuffle();

            final existingNames = categoryListData.map((c) => c.name).toSet();
            for (final cat in categoryList) {
              if (!existingNames.contains(cat.name)) {
                categoryListData.add(cat);
                existingNames.add(cat.name);
              }
            }
            if (emit.isDone) return;

            emit(
              state.copyWith(
                status: DiscoverStatus.success,
                categories: categoryListData,
                entries: updatedPresents,
                lastDoc: paged.lastDoc,
                hasMore: paged.hasMore,
                selectedCategoryIndex: 0,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onChangeCategory(ChangeDiscoverCategory event, Emitter<DiscoverState> emit) async {
    final selectedIndex = event.index;
    final categories = state.categories;
    final categoryName = (selectedIndex >= 0 && selectedIndex < categories.length)
        ? categories[selectedIndex].name
        : categories[0].name;
    if (event.index == 0) {
      add(FetchDiscoverData(category: ''));
    } else if (event.index == 1) {
      add(FetchDiscoverData(category: 'Premium'));
    } else if (event.index == 2) {
      add(FetchDiscoverData(category: 'Trending'));
    } else {
      add(FetchDiscoverData(category: categoryName));
    }
    emit(state.copyWith(selectedCategoryIndex: event.index, selectedCategory: event.category));
  }

  Future<void> _discoverLikeReelEvent(DiscoverLikeReelEvent event, Emitter<DiscoverState> emit) async {
    final result = await appRepository.addFavourite(fav: event.favouriteModel);

    result.match(
      (f) {
        emit(state.copyWith(errorMessage: f.message));
      },
      (l) {
        homeBloc.add(MarkTemplateNotFavouriteEvent(event.favouriteModel.presentId, true));
        favouriteBloc.add(FavouriteMarkTemplateNotFavouriteEvent(event.favouriteModel.presentId, true));
        final idx = event.index;

        if (idx >= 0 && state.entries != null && idx < state.entries.length) {
          final updated = List<LrPresetModel>.from(state.entries);

          updated[idx] = updated[idx].copyWith(isFavourite: true);

          emit(state.copyWith(entries: updated));
        }
      },
    );
  }

  Future<void> _discoverRemoveLikeEvent(DiscoverRemoveLikeEvent event, Emitter<DiscoverState> emit) async {
    final removeResult = await appRepository.removeFavourite(presentId: event.presentId);

    removeResult.match(
      (f) {
        emit(state.copyWith(errorMessage: f.message));
      },
      (l) {
        homeBloc.add(MarkTemplateNotFavouriteEvent(event.presentId, false));
        favouriteBloc.add(FavouriteMarkTemplateNotFavouriteEvent(event.presentId, false));
        final idx = event.index;

        if (idx >= 0 && state.entries != null && idx < state.entries.length) {
          final updated = List<LrPresetModel>.from(state.entries);

          updated[idx] = updated[idx].copyWith(isFavourite: false);

          emit(state.copyWith(entries: updated));
        }
      },
    );
  }

  FutureOr<void> _discoverLoadRewardAD(DiscoverLoadRewardAD event, Emitter<DiscoverState> emit) {
    emit(state.copyWith(status: DiscoverStatus.rewardAdLoading));
  }

  FutureOr<void> _discoverLoadedRewardAD(DiscoverLoadedRewardAD event, Emitter<DiscoverState> emit) {
    emit(state.copyWith(status: DiscoverStatus.rewardAdLoaded));
  }

  FutureOr<void> _discoverStoreCoinEvent(DiscoverStoreCoinEvent event, Emitter<DiscoverState> emit) {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    final newCoinTotal = totalCoin + 2;
    AppPreferences().setInt(AppPreferences.coin, newCoinTotal);
  }

  FutureOr<void> _discoverPlayDinoGame(DiscoverPlayDinoGame event, Emitter<DiscoverState> emit) {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    final newCoinTotal = totalCoin - 5;
    AppPreferences().setInt(AppPreferences.coin, newCoinTotal);
    emit(state.copyWith(status: DiscoverStatus.navigateToDinoGame));
  }

  FutureOr<void> _discoverMarkTemplateNotFavouriteEvent(
    DiscoverMarkTemplateNotFavouriteEvent event,
    Emitter<DiscoverState> emit,
  ) {
    final currentTemplates = state.entries;
    final updatedTemplates = currentTemplates.map((template) {
      if (template.id == event.templateId) {
        return template.copyWith(isFavourite: event.isLiked);
      }
      return template;
    }).toList();
    emit(state.copyWith(entries: updatedTemplates));
  }

  FutureOr<void> _loadInterstitialAD(LoadInterstitialAD event, Emitter<DiscoverState> emit) {
    emit(state.copyWith(status: DiscoverStatus.interstitialAdLoading));
  }

  FutureOr<void> _loadedInterstitialRewardAD(LoadedInterstitialRewardAD event, Emitter<DiscoverState> emit) {
    emit(state.copyWith(status: DiscoverStatus.interstitialAdLoaded));
  }
}
