import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:lightroom_template/data/models/favourite_model.dart';
import 'package:lightroom_template/data/repository/app_repository.dart';

import 'package:lightroom_template/screens/discover/bloc/discover_bloc.dart';
import 'package:lightroom_template/screens/home/bloc/home_bloc.dart';

part 'favourite_event.dart';

part 'favourite_state.dart';

class FavouriteBloc extends Bloc<FavouriteEvent, FavouriteState> {
  DiscoverBloc? discoverBloc;
  HomeBloc? homeBloc;

  FavouriteBloc() : super(FavouriteState()) {
    on<LoadRewardADEvent>(_loadRewardADEvent);
    on<LoadedRewardADEvent>(_loadedRewardADEvent);
    on<FavouriteStoreCoinEvent>(_favouriteStoreCoinEvent);
    on<FavouritePlayDinoGame>(_favouritePlayDinoGame);
    on<FetchFavouriteEvent>(_fetchFavouriteEvent);
    on<ChangeFavouriteCategoryEvent>(_changeFavouriteCategoryEvent);
    on<RemoveFavouriteEvent>(_removeFavouriteEvent);
    on<FavouriteMarkTemplateNotFavouriteEvent>(_favouriteMarkTemplateNotFavouriteEvent);
  }

  final AppRepository appRepository = AppRepository();
  List<FavouriteModel> allFavouriteData = [];

  FutureOr<void> _loadRewardADEvent(LoadRewardADEvent event, Emitter<FavouriteState> emit) {
    emit(state.copyWith(status: FavouriteStatus.rewardAdLoading));
  }

  FutureOr<void> _loadedRewardADEvent(LoadedRewardADEvent event, Emitter<FavouriteState> emit) {
    emit(state.copyWith(status: FavouriteStatus.rewardAdLoaded));
  }

  FutureOr<void> _favouriteStoreCoinEvent(FavouriteStoreCoinEvent event, Emitter<FavouriteState> emit) {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    final newCoinTotal = totalCoin + 2;
    AppPreferences().setInt(AppPreferences.coin, newCoinTotal);
  }

  FutureOr<void> _favouritePlayDinoGame(FavouritePlayDinoGame event, Emitter<FavouriteState> emit) {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    final newCoinTotal = totalCoin - 5;
    AppPreferences().setInt(AppPreferences.coin, newCoinTotal);
    emit(state.copyWith(status: FavouriteStatus.navigateToDinoGame));
  }

  Future<void> _fetchFavouriteEvent(FetchFavouriteEvent event, Emitter<FavouriteState> emit) async {
    emit(state.copyWith(status: FavouriteStatus.loading));

    final result = await appRepository.fetchFavouritePresents();

    result.fold(
      (FailureModel) {
        emit(state.copyWith(status: FavouriteStatus.FailureModel, errorMessage: FailureModel.message));
      },
      (favourites) {
        allFavouriteData = favourites;
        final categoryList =
            _buildOrderedCategoryListFromFavourites(favourites) ??
            (favourites.isNotEmpty ? const ['All'] : const []);

        emit(
          state.copyWith(
            status: FavouriteStatus.success,
            presents: favourites,
            categories: categoryList,
            selectedCategoryIndex: 0,
          ),
        );
      },
    );
  }

  List<String>? _buildOrderedCategoryListFromFavourites(List<FavouriteModel> favourites) {
    final Set<String> found = {};

    for (var fav in favourites) {
      if (fav.category.trim().isEmpty) continue;

      final list = fav.category
          .split(',')
          .map((e) => e.trim())
          .where((s) => s.isNotEmpty && s.toLowerCase() != 'null' && s.toLowerCase() != 'undefined')
          .toList();

      if (list.isNotEmpty) {
        found.addAll(list);
      }
    }

    if (found.isEmpty) return null;

    final bool hasPremium = found.contains('Premium');
    final bool hasTrending = found.contains('Trending');

    final List<String> ordered = ['All'];

    if (hasPremium) ordered.add('Premium');
    if (hasTrending) ordered.add('Trending');

    final others = found.where((c) => c != 'All' && c != 'Premium' && c != 'Trending').toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    ordered.addAll(others);

    return ordered.length == 1 ? null : ordered;
  }

  FutureOr<void> _changeFavouriteCategoryEvent(
    ChangeFavouriteCategoryEvent event,
    Emitter<FavouriteState> emit,
  ) {
    if (event.index >= 0 && event.index < state.categories.length) {
      final selectedCategory = state.categories[event.index];
      List<FavouriteModel> filteredPresents;
      if (selectedCategory == 'All') {
        filteredPresents = allFavouriteData;
      } else {
        filteredPresents = allFavouriteData.where((fav) {
          final list = fav.category.split(',').map((e) => e.trim().toLowerCase()).toList();
          return list.contains(selectedCategory.toLowerCase());
        }).toList();
      }
      emit(state.copyWith(selectedCategoryIndex: event.index, presents: filteredPresents));
    }
  }

  Future<void> _removeFavouriteEvent(RemoveFavouriteEvent event, Emitter<FavouriteState> emit) async {
    final result = await appRepository.removeFavourite(presentId: event.presentId);
    result.match((FailureModel) => emit(state.copyWith(errorMessage: FailureModel.message)), (success) {
      allFavouriteData.removeWhere((item) => item.presentId == event.presentId);
      
      homeBloc?.add(MarkTemplateNotFavouriteEvent(event.presentId, false));
      discoverBloc?.add(DiscoverMarkTemplateNotFavouriteEvent(event.presentId, false));

      final categoryList =
          _buildOrderedCategoryListFromFavourites(allFavouriteData) ??
          (allFavouriteData.isNotEmpty ? const ['All'] : const []);

      int newIndex = state.selectedCategoryIndex;
      if (newIndex >= categoryList.length) {
        newIndex = 0;
      }

      final String selectedCategory = categoryList.isNotEmpty ? categoryList[newIndex] : 'All';
      List<FavouriteModel> filteredPresents;
      if (selectedCategory == 'All') {
        filteredPresents = allFavouriteData;
      } else {
        filteredPresents = allFavouriteData.where((fav) {
          final list = fav.category.split(',').map((e) => e.trim().toLowerCase()).toList();
          return list.contains(selectedCategory.toLowerCase());
        }).toList();
      }

      emit(
        state.copyWith(presents: filteredPresents, categories: categoryList, selectedCategoryIndex: newIndex),
      );
    });
  }

  FutureOr<void> _favouriteMarkTemplateNotFavouriteEvent(
    FavouriteMarkTemplateNotFavouriteEvent event,
    Emitter<FavouriteState> emit,
  ) {
    add(FetchFavouriteEvent());
  }
}
