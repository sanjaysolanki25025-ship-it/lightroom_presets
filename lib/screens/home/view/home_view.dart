import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/data/models/favourite_model.dart';
import 'package:lightroom_template/common/ad_widgets/full_screen_native_ad/view/full_screen_native_ad_view.dart';
import 'package:lightroom_template/common/common_bottom_sheet.dart';
import 'package:lightroom_template/common/common_loader.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/common/common_toast.dart';
import 'package:lightroom_template/common/dialog/common_dialog.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/core/utils/common_functions.dart';
import 'package:lightroom_template/data/helpers/ad_helper.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:lightroom_template/data/models/lr_preset_model.dart';
import 'package:lightroom_template/routes/app_route_string.dart';
import 'package:lightroom_template/screens/home/bloc/home_bloc.dart';
import 'package:lightroom_template/screens/home/bloc/home_state.dart';
import 'package:lightroom_template/screens/home/widgets/home_category_list.dart';
import 'package:lightroom_template/screens/home/widgets/reel_item_widget.dart';
import 'package:lightroom_template/screens/dng_image_preview/bloc/dng_conversion_bloc.dart';
import 'package:lightroom_template/core/utils/in_app_update_manager.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _pageController = PageController();

  // How many pages to keep behind before evicting
  // e.g. if current is index 2, evict index 0 (2 - 2 = 0)
  static const int _evictOffset = 2;
  int _lastPrecachedIndex = -1;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    context.read<HomeBloc>().add(FetchHomeData());
    _pageController.addListener(_onScroll);
    InAppUpdateManager.checkForUpdate(context);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_pageController.hasClients) {
      final maxScroll = _pageController.position.maxScrollExtent;
      final currentScroll = _pageController.position.pixels;
      if (maxScroll - currentScroll <= 200) {
        context.read<HomeBloc>().add(LoadMoreHomeData());
      }
    }
  }

  void _handleDownload(LrPresetModel entry) {
    context.read<HomeBloc>().add(
      DownloadImage(url: "${AppStrings.imageUrl}${entry.image.trim()}", fileName: entry.title),
    );
  }

  // ─────────────────────────────────────────────
  // Get image URL for a content index
  // ─────────────────────────────────────────────

  String? _imageUrlForContentIndex(int contentIndex, List<LrPresetModel> entries) {
    if (contentIndex < 0 || contentIndex >= entries.length) return null;
    final image = entries[contentIndex].image.trim();
    if (image.isEmpty) return null;
    return "${AppStrings.imageUrl}$image";
  }

  // ─────────────────────────────────────────────
  // Convert page index → content index
  // (every 3rd page is an ad, so content index is offset)
  // ─────────────────────────────────────────────

  int _contentIndexFromPageIndex(int pageIndex) {
    return pageIndex - (pageIndex ~/ 3);
  }

  // ─────────────────────────────────────────────
  // PRECACHE: load next image into cache
  // ─────────────────────────────────────────────

  void _precacheContentIndex(int contentIndex, List<LrPresetModel> entries) {
    final url = _imageUrlForContentIndex(contentIndex, entries);
    if (url == null) return;

    // DNG image → use DngConversionBloc cache
    if (url.toLowerCase().contains('.dng')) {
      DngConversionBloc.precacheDng(url);
    } else {
      // Regular image → use Flutter's image cache
      precacheImage(NetworkImage(url), context);
    }
  }

  // ─────────────────────────────────────────────
  // EVICT: remove old image from cache
  // ─────────────────────────────────────────────

  void _evictContentIndex(int contentIndex, List<LrPresetModel> entries) {
    final url = _imageUrlForContentIndex(contentIndex, entries);
    if (url == null) return;

    if (url.toLowerCase().contains('.dng')) {
      DngConversionBloc.evictDng(url);
    } else {
      NetworkImage(url).evict();
    }
  }

  // ─────────────────────────────────────────────
  // Called on every page change
  // Precaches next page, evicts old page dynamically
  // ─────────────────────────────────────────────

  void _onPageChanged(int pageIndex, List<LrPresetModel> entries) {
    if (entries.isEmpty) return;

    final currentContentIndex = _contentIndexFromPageIndex(pageIndex);

    // ✅ Precache next content item
    _precacheContentIndex(currentContentIndex + 1, entries);

    // ✅ Evict content item 3 pages behind current to free memory
    // e.g. page 0→ evict nothing, page 3 → evict index 0, page 4 → evict index 1
    final evictContentIndex = currentContentIndex - _evictOffset;
    _evictContentIndex(evictContentIndex, entries);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BlocListener<HomeBloc, HomeState>(
          listenWhen: (previous, current) =>
              previous.status != current.status || previous.entries.length != current.entries.length,
          listener: (context, state) {
            if (state.status == HomeStatus.downloading ||
                state.status == HomeStatus.openingInLightroom ||
                state.status == HomeStatus.rewardAdLoading) {
              CommonDialog.loaderDialog(context: context);
            } else if (state.status == HomeStatus.downloadSuccess) {
              CommonDialog.closeDialog(context: context);
              if (state.downloadMessage != null) {
                CommonToast.show(context, state.downloadMessage!);
              }
            } else if (state.status == HomeStatus.downloadFailureModel) {
              CommonDialog.closeDialog(context: context);
              if (state.downloadMessage != null) {
                CommonToast.show(context, state.downloadMessage!);
              }
            } else if (state.status == HomeStatus.lightroomInstalled) {
              final userCoins = AppPreferences().getInt(AppPreferences.coin) ?? 0;
              final requiredCoins = state.entry?.coin ?? 0;
              final hasEnoughCoins = userCoins >= requiredCoins;

              CommonBottomSheet.showCommonBottomSheet(
                context: context,
                adId: AppAdIdString.homeBottomNativeAd,
                firstButtonText: (requiredCoins <= 0)
                    ? AppStrings.txtWatchAd
                    : hasEnoughCoins
                    ? "🔓 $requiredCoins ${AppStrings.txtCoins}"
                    : AppStrings.txtPlayGameEarnCoins,
                secondButtonText: AppStrings.txtCancel,
                title: (requiredCoins <= 0)
                    ? AppStrings.txtUnlockThisPresetEarnTwoCoins
                    : hasEnoughCoins
                    ? AppStrings.txtUnlockThisPreset
                    : AppStrings.txtNotEnoughCoins,
                secondButtonOnTap: () {
                  Navigator.of(context).pop();
                },
                firstButtonOnTap: () {
                  Navigator.of(context).pop();

                  final fileName = "${state.entry?.title.replaceAll(' ', '_')}_${state.entry?.id}.dng";

                  if (requiredCoins <= 0) {
                    context.read<HomeBloc>().add(LoadRewardAD());
                    AdHelper.showRewardedAd(
                      adUnitId: AppAdIdString.useLrRewardedAd,
                      onRewardEarned: () {
                        context.read<HomeBloc>().add(LoadedRewardAD());
                        context.read<HomeBloc>().add(StoreCoinEvent());
                      },
                      onComplete: () {
                        context.read<HomeBloc>().add(
                          OpenInLightroom(
                            url: "${AppStrings.imageUrl}${state.entry?.image.trim() ?? ''}",
                            fileName: fileName,
                          ),
                        );
                      },
                      onAdFailed: () {
                        context.read<HomeBloc>().add(LoadedRewardAD());
                      },
                    );
                  } else if (hasEnoughCoins) {
                    context.read<HomeBloc>().add(UsedCoin(coin: requiredCoins));
                    context.read<HomeBloc>().add(
                      OpenInLightroom(
                        url: "${AppStrings.imageUrl}${state.entry?.image.trim() ?? ''}",
                        fileName: fileName,
                      ),
                    );
                  } else {
                    context.read<HomeBloc>().add(LoadRewardAD());
                    AdHelper.showRewardedAd(
                      adUnitId: AppAdIdString.playDinoRewardedAd,
                      onRewardEarned: () {
                        context.read<HomeBloc>().add(LoadedRewardAD());
                        context.read<HomeBloc>().add(StoreCoinEvent());
                      },
                      onComplete: () {
                        context.push(AppRoutesString.dinoView);
                      },
                      onAdFailed: () {
                        context.read<HomeBloc>().add(LoadedRewardAD());
                      },
                    );
                  }
                },
              ).then((_) {
                context.read<HomeBloc>().add(ResetHomeStatus());
              });
            } else if (state.status == HomeStatus.lightroomNotInstalled) {
              CommonBottomSheet.showCommonBottomSheet(
                adId: AppAdIdString.homeBottomNativeAd,
                context: context,
                firstButtonText: AppStrings.txtDownload,
                secondButtonText: AppStrings.txtCancel,
                title: AppStrings.txtDownloadLightroomPresetInstantly,
                secondButtonOnTap: () {
                  Navigator.of(context).pop();
                },
                firstButtonOnTap: () {
                  Navigator.of(context).pop();
                  CommonFunction.openLightroomApp();
                },
              ).then((_) {
                context.read<HomeBloc>().add(ResetHomeStatus());
              });
            } else if (state.status == HomeStatus.success ||
                state.status == HomeStatus.initial ||
                state.status == HomeStatus.rewardAdLoaded) {
              if (state.status == HomeStatus.success || state.status == HomeStatus.rewardAdLoaded) {
                CommonDialog.closeDialog(context: context);
              }

              if (state.entries.isEmpty) {
                _lastPrecachedIndex = -1;
              } else {
                for (int i = _lastPrecachedIndex + 1; i < state.entries.length; i++) {
                  _precacheContentIndex(i, state.entries);
                  _lastPrecachedIndex = i;
                }

                // Show Dino dialog once per day when data is loaded successfully
                if (state.status == HomeStatus.success) {
                  if (CommonDialog.shouldShowDinoDialog()) {
                    CommonDialog.showDinoDialog(context: context);
                    CommonDialog.markDinoDialogShown();
                  }
                }
              }
            } else if (state.status == HomeStatus.navigateToDinoGame) {
              context.push(AppRoutesString.dinoView);
            }
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              final entries = state.entries;
              final totalContentCount = entries.length;
              final totalAdsCount = totalContentCount ~/ 2;
              final totalItems = totalContentCount + totalAdsCount;

              return Stack(
                children: [
                  /// MAIN VERTICAL PAGE VIEW
                  if (state.status == HomeStatus.loading && state.entries.isEmpty)
                    const Center(child: CommonLoader())
                  else if (state.status == HomeStatus.FailureModel && state.entries.isEmpty)
                    Center(
                      child: CommonTextWidget(
                        text: "${AppStrings.txtError} ${state.errorMessage}",
                        textStyle: size12TextStyle(textColor: AppColors.whiteColor),
                      ),
                    )
                  else if (entries.isEmpty && state.status == HomeStatus.success)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CommonTextWidget(
                              text: AppStrings.txtNoDataFound,
                              textStyle: size16TextStyle(
                                textColor: AppColors.whiteColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SBH5(),
                            BlocProvider(
                              create: (context) => NativeAdBloc(),
                              child: NativeAdView(
                                isSmallAd: false,
                                isSplash: false,
                                adId: AppAdIdString.noDataFoundNativeAd,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: totalItems,
                      onPageChanged: (pageIndex) {
                        final currentEntries = context.read<HomeBloc>().state.entries;
                        _onPageChanged(pageIndex, currentEntries);
                      },
                      itemBuilder: (context, index) {
                        // Trigger load more near end
                        // if (index >= state.entries.length - 2 && state.hasMore) {
                        //   context.read<HomeBloc>().add(LoadMoreHomeData());
                        // }

                        // Every 3rd page is an ad
                        if ((index + 1) % 3 == 0) {
                          return FullScreenNativeAdView(key: ValueKey('ad_$index'));
                        }

                        final contentIndex = index - (index ~/ 3);
                        if (contentIndex >= entries.length) return const SizedBox.shrink();

                        final entry = entries[contentIndex];

                        return ReelItemWidget(
                          entry: entry,
                          isFavourite: entries[contentIndex].isFavourite,
                          onFavouriteTap: () {
                            if (entries[contentIndex].isFavourite) {
                              context.read<HomeBloc>().add(
                                RemoveLikeEvent(
                                  index: contentIndex,
                                  presentId: entries[contentIndex].id ?? '',
                                ),
                              );
                            } else {
                              context.read<HomeBloc>().add(
                                LikeReelEvent(
                                  index: contentIndex,
                                  favouriteModel: FavouriteModel(
                                    title: entries[contentIndex].title.toString(),
                                    image: entries[contentIndex].image.toString(),
                                    presentId: entries[contentIndex].id.toString(),
                                    coin: entries[contentIndex].coin.toString(),
                                    category: (entries[contentIndex].categories as List<dynamic>).join(', '),
                                  ),
                                ),
                              );
                            }
                          },
                          onOpenDinoGame: () {
                            final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
                            if (totalCoin < 5) {
                              CommonBottomSheet.showCommonBottomSheet(
                                adId: AppAdIdString.homeBottomNativeAd,
                                context: context,
                                firstButtonText: AppStrings.txtWatchAd,
                                title: AppStrings.txtNotEnoughCoinsWatchAnAdToPlay,
                                firstButtonOnTap: () {
                                  Navigator.of(context).pop();
                                  context.read<HomeBloc>().add(LoadRewardAD());
                                  AdHelper.showRewardedAd(
                                    adUnitId: AppAdIdString.playDinoRewardedAd,
                                    onRewardEarned: () {
                                      context.read<HomeBloc>().add(LoadedRewardAD());
                                      context.read<HomeBloc>().add(StoreCoinEvent());
                                    },
                                    onComplete: () {
                                      context.push(AppRoutesString.dinoView);
                                    },
                                    onAdFailed: () {
                                      context.read<HomeBloc>().add(LoadedRewardAD());
                                    },
                                  );
                                },
                              );
                            } else {
                              CommonBottomSheet.showCommonBottomSheet(
                                adId: AppAdIdString.homeBottomNativeAd,
                                context: context,
                                firstButtonText: "🔓 ${AppStrings.txtFiveLetter} ${AppStrings.txtCoins}",
                                secondButtonText: AppStrings.txtWatchAd,
                                title: AppStrings.txtPlayGameReward,
                                secondButtonOnTap: () {
                                  Navigator.of(context).pop();
                                  context.read<HomeBloc>().add(LoadRewardAD());
                                  AdHelper.showRewardedAd(
                                    adUnitId: AppAdIdString.playDinoRewardedAd,
                                    onRewardEarned: () {
                                      context.read<HomeBloc>().add(LoadedRewardAD());
                                      context.read<HomeBloc>().add(StoreCoinEvent());
                                    },
                                    onComplete: () {
                                      context.push(AppRoutesString.dinoView);
                                    },
                                    onAdFailed: () {
                                      context.read<HomeBloc>().add(LoadedRewardAD());
                                    },
                                  );
                                },
                                firstButtonOnTap: () {
                                  context.pop();
                                  context.read<HomeBloc>().add(PlayDinoGame());
                                },
                              );
                            }
                          },
                          onDownloadTap: () {
                            final userCoins = AppPreferences().getInt(AppPreferences.coin) ?? 0;
                            final hasEnoughCoins = userCoins >= entry.coin;

                            CommonBottomSheet.showCommonBottomSheet(
                              adId: AppAdIdString.homeBottomNativeAd,
                              context: context,
                              firstButtonText: (entry.coin <= 0)
                                  ? AppStrings.txtWatchAd
                                  : hasEnoughCoins
                                  ? "🔓 ${entry.coin} ${AppStrings.txtCoins}"
                                  : AppStrings.txtPlayGameEarnCoins,
                              secondButtonText: AppStrings.txtCancel,
                              title: (entry.coin <= 0)
                                  ? AppStrings.txtUnlockThisPresetEarnTwoCoins
                                  : hasEnoughCoins
                                  ? AppStrings.txtUnlockThisPreset
                                  : AppStrings.txtNotEnoughCoins,
                              secondButtonOnTap: () {
                                Navigator.of(context).pop();
                              },
                              firstButtonOnTap: () {
                                Navigator.of(context).pop();
                                if (entry.coin <= 0) {
                                  context.read<HomeBloc>().add(LoadRewardAD());
                                  AdHelper.showRewardedAd(
                                    adUnitId: AppAdIdString.downloadImageRewardedAd,
                                    onRewardEarned: () {
                                      context.read<HomeBloc>().add(LoadedRewardAD());
                                      context.read<HomeBloc>().add(StoreCoinEvent());
                                      _handleDownload(entry);
                                    },
                                    onComplete: () {},
                                    onAdFailed: () {
                                      context.read<HomeBloc>().add(LoadedRewardAD());
                                      _handleDownload(entry);
                                    },
                                  );
                                } else if (hasEnoughCoins) {
                                  context.read<HomeBloc>().add(UsedCoin(coin: entry.coin));
                                  _handleDownload(entry);
                                } else {
                                  context.read<HomeBloc>().add(LoadRewardAD());
                                  AdHelper.showRewardedAd(
                                    adUnitId: AppAdIdString.playDinoRewardedAd,
                                    onRewardEarned: () {
                                      context.read<HomeBloc>().add(LoadedRewardAD());
                                      context.read<HomeBloc>().add(StoreCoinEvent());
                                    },
                                    onComplete: () {
                                      context.push(AppRoutesString.dinoView);
                                    },
                                    onAdFailed: () {
                                      context.read<HomeBloc>().add(LoadedRewardAD());
                                    },
                                  );
                                }
                              },
                            );
                          },
                          onOpenInLightroom: () {
                            context.read<HomeBloc>().add(CheckLightroomInstallation(entry: entry));
                          },
                        );
                      },
                    ),

                  /// TOP CATEGORY LIST (Sticky)
                  HomeCategoryList(
                    categories: state.categories,
                    selectedCategory: state.selectedCategory,
                    onCategorySelected: (categoryName) {
                      context.read<HomeBloc>().add(ChangeCategory(categoryName));
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
