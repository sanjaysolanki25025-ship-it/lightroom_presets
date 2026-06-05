import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/dng_cache.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:lightroom_template/data/models/category_model.dart';
import 'package:lightroom_template/data/models/favourite_model.dart';
import 'package:lightroom_template/data/models/lr_preset_model.dart';
import 'package:lightroom_template/data/repository/app_repository.dart';
import 'package:lightroom_template/screens/home/bloc/home_state.dart';
import 'package:flutter/services.dart';
import 'package:lightroom_template/screens/home/repository/home_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:lightroom_template/screens/discover/bloc/discover_bloc.dart';
import 'package:lightroom_template/screens/favourite/bloc/favourite_bloc.dart';

part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  DiscoverBloc? discoverBloc;
  FavouriteBloc? favouriteBloc;

  final HomeRepository _repository = HomeRepository();
  static const _navigationChannel = MethodChannel('com.nebalcore.lightroom/navigation');

  HomeBloc() : super(HomeState()) {
    on<FetchHomeData>(_onFetchHomeData);
    on<LoadMoreHomeData>(_onLoadMoreHomeData);
    on<ChangeCategory>(_onChangeCategory);
    on<DownloadImage>(_onDownloadImage);
    on<OpenInLightroom>(_onOpenInLightroom);
    on<LoadRewardAD>(_loadRewardAD);
    on<LoadedRewardAD>(_loadedRewardAD);
    on<StoreCoinEvent>(_storeCoinEvent);
    on<PlayDinoGame>(_playDinoGame);
    on<ResetHomeStatus>(_onResetHomeStatus);
    on<CheckLightroomInstallation>(_checkLightroomInstallation);
    on<UsedCoin>(_usedCoin);
    on<LikeReelEvent>(_likeReelEvent);
    on<RemoveLikeEvent>(_removeLikeEvent);
    on<MarkTemplateNotFavouriteEvent>(_markTemplateNotFavouriteEvent);
  }

  DocumentSnapshot? _lastPresentDoc;
  bool _presentHasMore = true;
  bool _hasMore = true;
  double? _randomStart;
  final AppRepository appRepository = AppRepository();
  List<CategoryModel> categoryListData = [
    CategoryModel(name: 'All'),
    CategoryModel(name: 'Premium'),
    CategoryModel(name: 'Trending'),
  ];

  // ─────────────────────────────────────────────
  // RESET
  // ─────────────────────────────────────────────

  void _onResetHomeStatus(ResetHomeStatus event, Emitter<HomeState> emit) {
    emit(state.copyWith(status: HomeStatus.initial));
  }

  // ─────────────────────────────────────────────
  // FETCH HOME DATA
  // ─────────────────────────────────────────────

  Future<void> _onFetchHomeData(FetchHomeData event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading));

    if (_lastPresentDoc == null) {
      _randomStart = Random().nextDouble();
    }

    final result = await _repository.fetchPresentWithPagination(
      limit: 2,
      lastDoc: _lastPresentDoc,
      randomStart: _randomStart,
    );

    await result.match(
          (FailureModel) {
        emit(state.copyWith(status: HomeStatus.FailureModel, errorMessage: FailureModel.message));
      },
          (presents) async {
        _lastPresentDoc = presents.lastDoc;
        _presentHasMore = presents.hasMore;
        _hasMore = (presents.presents.length >= 2) || _presentHasMore;

        // ✅ Separate awaits — avoids List<dynamic> cast error from Future.wait
        final categoryResult = await appRepository.fetchCategory();
        final favoriteIdsResult = await appRepository.fetchFavouritePresents();

        categoryResult.match((_) {}, (categories) {
          final existingNames = categoryListData.map((c) => c.name).toSet();
          for (final cat in categories) {
            if (!existingNames.contains(cat.name)) {
              categoryListData.add(cat);
              existingNames.add(cat.name);
            }
          }
        });

        List<String> favIds = [];
        favoriteIdsResult.match((FailureModel) => null, (favModels) {
          favIds = favModels.map((fav) => fav.presentId.toString()).toList();
        });

        final List<LrPresetModel> updatePresents = presents.presents.map((p) {
          return p.copyWith(isFavourite: favIds.contains(p.id));
        }).toList();

        updatePresents.shuffle();
        _precacheImages(updatePresents);
        emit(
          state.copyWith(
            status: HomeStatus.success,
            entries: updatePresents,
            categories: categoryListData,
            selectedCategory: 'All',
            hasMore: _hasMore,
          ),
        );

        // ✅ Precache images after emitting state

      },
    );
  }

  // ─────────────────────────────────────────────
  // LOAD MORE
  // ─────────────────────────────────────────────

  Future<void> _onLoadMoreHomeData(LoadMoreHomeData event, Emitter<HomeState> emit) async {
    if (!_hasMore || state.status == HomeStatus.loadingMore || state.status == HomeStatus.loading) return;

    emit(state.copyWith(status: HomeStatus.loadingMore));

    final currentCategory = state.selectedCategory;
    final isAll = currentCategory == 'All';

    final result = await _repository.fetchPresentWithPagination(
      limit: 2,
      lastDoc: _lastPresentDoc,
      category: isAll ? null : currentCategory,
    );

    await result.match(
          (FailureModel) {
        emit(state.copyWith(status: HomeStatus.success));
      },
          (paged) async {
        _lastPresentDoc = paged.lastDoc;
        _presentHasMore = paged.hasMore;
        _hasMore = paged.hasMore;

        final favoriteIdsResult = await appRepository.fetchFavouritePresents();
        List<String> favIds = [];
        favoriteIdsResult.match((FailureModel) => null, (favModels) {
          favIds = favModels.map((fav) => fav.presentId.toString()).toList();
        });

        final List<LrPresetModel> newPresents = paged.presents.map((p) {
          return p.copyWith(isFavourite: favIds.contains(p.id));
        }).toList();

        final updatedList = [...state.entries, ...newPresents];
         _precacheImages(newPresents);

        emit(state.copyWith(status: HomeStatus.initial, entries: updatedList, hasMore: _hasMore));

        // ✅ Precache only newly added images

      },
    );
  }

  // ─────────────────────────────────────────────
  // CHANGE CATEGORY
  // ─────────────────────────────────────────────

  Future<void> _onChangeCategory(ChangeCategory event, Emitter<HomeState> emit) async {
    final isAll = event.category == 'All';
    final requestedCategory = isAll ? 'All' : event.category;

    _lastPresentDoc = null;
    _presentHasMore = true;
    _hasMore = true;

    emit(
      state.copyWith(
        status: HomeStatus.initial,
        entries: [],
        currentPage: 0,
        selectedCategory: requestedCategory,
        hasMore: true,
      ),
    );

    final result = await _repository.fetchPresentWithPagination(
      limit: 2,
      category: isAll ? null : event.category,
    );

    await result.match(
          (FailureModel) {
        if (state.selectedCategory != requestedCategory) return;
        emit(state.copyWith(status: HomeStatus.FailureModel, errorMessage: FailureModel.message));
      },
          (paged) async {
        if (state.selectedCategory != requestedCategory) return;

        _lastPresentDoc = paged.lastDoc;
        _presentHasMore = paged.hasMore;
        _hasMore = paged.hasMore;

        final favoriteIdsResult = await appRepository.fetchFavouritePresents();
        List<String> favIds = [];
        favoriteIdsResult.match((FailureModel) => null, (favModels) {
          favIds = favModels.map((fav) => fav.presentId.toString()).toList();
        });

        final List<LrPresetModel> updatePresents = paged.presents.map((p) {
          return p.copyWith(isFavourite: favIds.contains(p.id));
        }).toList();

        updatePresents.shuffle();
        _precacheImages(updatePresents);
        emit(
          state.copyWith(
            status: HomeStatus.success,
            entries: updatePresents,
            hasMore: _hasMore,
            currentPage: 0,
          ),
        );

        // ✅ Precache images after category change

      },
    );
  }

  // ─────────────────────────────────────────────
  // DOWNLOAD IMAGE
  // ─────────────────────────────────────────────

  // Future<void> _onDownloadImage(DownloadImage event, Emitter<HomeState> emit) async {
  //   emit(state.copyWith(status: HomeStatus.downloading));
  //
  //   File? tempFile;
  //   try {
  //     if (!await Gal.hasAccess()) {
  //       final granted = await Gal.requestAccess();
  //       if (!granted) {
  //         emit(
  //           state.copyWith(
  //             status: HomeStatus.downloadFailureModel,
  //             downloadMessage: AppStrings.txtStoragePermissionDenied,
  //           ),
  //         );
  //         return;
  //       }
  //     }
  //
  //     final response = await http.get(Uri.parse(event.url));
  //     if (response.statusCode != 200) throw Exception("Download failed");
  //     final bytes = response.bodyBytes;
  //
  //     final tempDir = await getTemporaryDirectory();
  //     final cleanFileName = event.fileName.split('.').first;
  //     tempFile = File('${tempDir.path}/$cleanFileName.dng');
  //     await tempFile.writeAsBytes(bytes);
  //
  //     await Gal.putImage(tempFile.path);
  //
  //     emit(
  //       state.copyWith(
  //         status: HomeStatus.downloadSuccess,
  //         downloadMessage: "${AppStrings.txtDownloadedTo} $cleanFileName.dng",
  //       ),
  //     );
  //   } catch (e) {
  //     emit(
  //       state.copyWith(
  //         status: HomeStatus.downloadFailureModel,
  //         downloadMessage: "${AppStrings.txtDownloadFailed} $e",
  //       ),
  //     );
  //   } finally {
  //     if (tempFile != null && await tempFile.exists()) {
  //       try {
  //         await tempFile.delete();
  //       } catch (_) {}
  //     }
  //   }
  // }


  Future<void> _onDownloadImage(
      DownloadImage event,
      Emitter<HomeState> emit,
      ) async {
    emit(state.copyWith(status: HomeStatus.downloading));

    try {
      final response = await http.get(Uri.parse(event.url));

      if (response.statusCode != 200) {
        throw Exception('Download failed');
      }

      final bytes = response.bodyBytes;

      Directory dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      if (!await dir.exists()) {
        dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      }

      final fileName = event.fileName.endsWith('.dng')
          ? event.fileName
          : '${event.fileName}.dng';

      final file = File('${dir.path}/$fileName');

      await file.writeAsBytes(bytes);

      emit(
        state.copyWith(
          status: HomeStatus.downloadSuccess,
          downloadMessage: Platform.isAndroid 
              ? "${AppStrings.txtDownloadedTo} Download/$fileName"
              : "${AppStrings.txtDownloadedTo} $fileName",
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.downloadFailureModel,
          downloadMessage: "${AppStrings.txtDownloadFailed} $e",
        ),
      );
    }
  }
  // ─────────────────────────────────────────────
  // OPEN IN LIGHTROOM
  // ─────────────────────────────────────────────

  Future<void> _onOpenInLightroom(OpenInLightroom event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.openingInLightroom));

    try {
      final dio = Dio();

      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (!await directory.exists()) {
        directory = await getExternalStorageDirectory();
      }

      if (directory == null) {
        emit(
          state.copyWith(
            status: HomeStatus.downloadFailureModel,
            downloadMessage: "Could not find storage directory",
          ),
        );
        return;
      }

      final fileName = "${event.fileName.split('.').first}.dng";
      final savePath = p.join(directory.path, fileName);
      final file = File(savePath);

      if (!await file.exists()) {
        await dio.download(event.url, savePath, options: Options(responseType: ResponseType.bytes));
      }

      if (Platform.isAndroid) {
        await _navigationChannel.invokeMethod('openInLightroom', {'filePath': savePath});
      } else if (Platform.isIOS) {
        await LaunchApp.openApp(iosUrlScheme: 'lightroom://', androidPackageName: 'com.adobe.lrmobile');
      }

      emit(state.copyWith(status: HomeStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.downloadFailureModel,
          downloadMessage: "Failed to open in Lightroom: $e",
        ),
      );
    }
  }

  // ─────────────────────────────────────────────
  // ADS
  // ─────────────────────────────────────────────

  FutureOr<void> _loadRewardAD(LoadRewardAD event, Emitter<HomeState> emit) {
    emit(state.copyWith(status: HomeStatus.rewardAdLoading));
  }

  FutureOr<void> _loadedRewardAD(LoadedRewardAD event, Emitter<HomeState> emit) {
    emit(state.copyWith(status: HomeStatus.rewardAdLoaded));
  }

  // ─────────────────────────────────────────────
  // COINS
  // ─────────────────────────────────────────────

  FutureOr<void> _storeCoinEvent(StoreCoinEvent event, Emitter<HomeState> emit) {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    AppPreferences().setInt(AppPreferences.coin, totalCoin + 2);
  }

  FutureOr<void> _usedCoin(UsedCoin event, Emitter<HomeState> emit) {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    AppPreferences().setInt(AppPreferences.coin, totalCoin - event.coin);
    emit(state.copyWith(status: HomeStatus.initial));
  }

  // ─────────────────────────────────────────────
  // DINO GAME
  // ─────────────────────────────────────────────

  FutureOr<void> _playDinoGame(PlayDinoGame event, Emitter<HomeState> emit) {
    final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
    AppPreferences().setInt(AppPreferences.coin, totalCoin - 5);
    emit(state.copyWith(status: HomeStatus.navigateToDinoGame));
  }

  // ─────────────────────────────────────────────
  // LIGHTROOM CHECK
  // ─────────────────────────────────────────────

  Future<void> _checkLightroomInstallation(CheckLightroomInstallation event, Emitter<HomeState> emit) async {
    final isInstalled = await LaunchApp.isAppInstalled(
      androidPackageName: 'com.adobe.lrmobile',
      iosUrlScheme: 'lightroom://',
    );

    if (!isInstalled) {
      emit(
        state.copyWith(
          status: HomeStatus.lightroomNotInstalled,
          downloadMessage: AppStrings.txtLightroomIsNotInstalled,
          entry: event.entry,
        ),
      );
      return;
    }

    emit(state.copyWith(status: HomeStatus.lightroomInstalled, entry: event.entry));
  }

  // ─────────────────────────────────────────────
  // FAVOURITES
  // ─────────────────────────────────────────────

  Future<void> _likeReelEvent(LikeReelEvent event, Emitter<HomeState> emit) async {
    final result = await appRepository.addFavourite(fav: event.favouriteModel);

    result.match(
          (f) {
        emit(state.copyWith(errorMessage: f.message));
      },
          (l) {
        discoverBloc?.add(DiscoverMarkTemplateNotFavouriteEvent(event.favouriteModel.presentId, true));
        favouriteBloc?.add(FavouriteMarkTemplateNotFavouriteEvent(event.favouriteModel.presentId, true));

        final idx = event.index;
        if (idx >= 0 && idx < state.entries.length) {
          final updated = List<LrPresetModel>.from(state.entries);
          updated[idx] = updated[idx].copyWith(isFavourite: true);
          emit(state.copyWith(entries: updated));
        }
      },
    );
  }

  Future<void> _removeLikeEvent(RemoveLikeEvent event, Emitter<HomeState> emit) async {
    final removeResult = await appRepository.removeFavourite(presentId: event.presentId);

    removeResult.match(
          (f) {
        emit(state.copyWith(errorMessage: f.message));
      },
          (l) {
        discoverBloc?.add(DiscoverMarkTemplateNotFavouriteEvent(event.presentId, false));
        favouriteBloc?.add(FavouriteMarkTemplateNotFavouriteEvent(event.presentId, false));

        final idx = event.index;
        if (idx >= 0 && idx < state.entries.length) {
          final updated = List<LrPresetModel>.from(state.entries);
          updated[idx] = updated[idx].copyWith(isFavourite: false);
          emit(state.copyWith(entries: updated));
        }
      },
    );
  }

  FutureOr<void> _markTemplateNotFavouriteEvent(
      MarkTemplateNotFavouriteEvent event,
      Emitter<HomeState> emit,
      ) {
    final updatedTemplates = state.entries.map((template) {
      if (template.id == event.templateId) {
        return template.copyWith(isFavourite: event.isLiked);
      }
      return template;
    }).toList();

    emit(state.copyWith(entries: updatedTemplates));
  }

  // // ─────────────────────────────────────────────
  // // PRECACHE IMAGES
  // // ─────────────────────────────────────────────
  Future<void> _precacheImages(List<LrPresetModel> presets) async {
    final cache = DngCache.instance;

    for (final preset in presets) {
      final url = "${AppStrings.imageUrl}${preset.image.trim()}";
      if (url.isEmpty) continue;
      if (cache.hasCache(url) || cache.isLoading(url)) continue;
      await cache.getOrStartLoad(url, () async {
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode != 200) {
            return null;
          }

          final converted = await compute(
            _decodeDngStatic,
            response.bodyBytes,
          );

          return converted.isNotEmpty ? converted : null;
        } catch (_) {
          return null;
        }
      });
    }
  }
}

// // ─────────────────────────────────────────────
// // TOP-LEVEL FUNCTION — required for compute()
// // Must be outside any class
// // ─────────────────────────────────────────────
//
Uint8List _decodeDngStatic(Uint8List rawBytes) {
  try {
    final img.Image? decodedImage = img.decodeImage(rawBytes);
    if (decodedImage != null) {
      return Uint8List.fromList(img.encodeJpg(decodedImage, quality: 85));
    }
  } catch (_) {}
  return Uint8List(0);
}