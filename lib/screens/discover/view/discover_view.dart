import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/banner_ad/view/banner_ad_widget.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/bloc/native_ad_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad/view/native_ad_view.dart';
import 'package:lightroom_template/common/common_app_bar.dart';
import 'package:lightroom_template/common/common_bottom_sheet.dart';
import 'package:lightroom_template/common/common_loader.dart';
import 'package:lightroom_template/common/common_lottie_asset.dart';
import 'package:lightroom_template/common/common_sizedbox.dart';
import 'package:lightroom_template/common/common_text_widget.dart';
import 'package:lightroom_template/common/dialog/common_dialog.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_image_string.dart';
import 'package:lightroom_template/core/constant/app_lotties_string.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/app_text_style.dart';
import 'package:lightroom_template/data/helpers/ad_helper.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:lightroom_template/data/models/favourite_model.dart';
import 'package:lightroom_template/routes/app_route_string.dart';
import 'package:go_router/go_router.dart';
import 'package:lightroom_template/screens/home/view/home_view.dart';
import 'package:lightroom_template/screens/home/widgets/common_action_button.dart';
import '../bloc/discover_bloc.dart';
import '../widgets/discover_category_widget.dart';
import '../../../common/grid_item_widget.dart';

class DiscoverView extends StatefulWidget {
  const DiscoverView({super.key});

  @override
  State<DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  @override
  void initState() {
    context.read<DiscoverBloc>().add(FetchDiscoverCategories());
    // AdHelper.precacheInterstitialAd(adId: AppAdIdString.loadMoreInterstitialAd);
    super.initState();
  }

  bool shouldShowAd(int rowIndex) {
    return rowIndex % 5 == 1 || rowIndex % 5 == 3;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CommonAppBar(
          title: AppStrings.txtDiscover,
          actions: [
            // CommonLottieAsset(assetName: AppLottiesString.pro),
            // SBW2(),
            CommonActionButton(
              assetPath: AppImagesString.imgDino,
              onTap: () {
                final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
                if (totalCoin < 5) {
                  CommonBottomSheet.showCommonBottomSheet(
                    adId: AppAdIdString.discoverBottomNativeAd,
                    context: context,
                    firstButtonText: AppStrings.txtWatchAd,
                    title: AppStrings.txtNotEnoughCoinsWatchAnAdToPlay,
                    firstButtonOnTap: () {
                      Navigator.of(context).pop();
                      context.read<DiscoverBloc>().add(DiscoverLoadRewardAD());
                      AdHelper.showRewardedAd(
                        adUnitId: AppAdIdString.playDinoRewardedAd,
                        onRewardEarned: () {
                          context.read<DiscoverBloc>().add(DiscoverLoadedRewardAD());
                          context.read<DiscoverBloc>().add(DiscoverStoreCoinEvent());
                        },
                        onComplete: () {
                          context.push(AppRoutesString.dinoView);
                        },
                        onAdFailed: () {
                          context.read<DiscoverBloc>().add(DiscoverLoadedRewardAD());
                        },
                      );
                    },
                  );
                } else {
                  CommonBottomSheet.showCommonBottomSheet(
                    adId: AppAdIdString.discoverBottomNativeAd,
                    context: context,
                    firstButtonText: "🔓 ${AppStrings.txtFiveLetter} ${AppStrings.txtCoins}",
                    secondButtonText: AppStrings.txtWatchAd,
                    title: AppStrings.txtPlayGameReward,
                    secondButtonOnTap: () {
                      Navigator.of(context).pop();
                      context.read<DiscoverBloc>().add(DiscoverLoadRewardAD());
                      AdHelper.showRewardedAd(
                        adUnitId: AppAdIdString.playDinoRewardedAd,
                        onRewardEarned: () {
                          context.read<DiscoverBloc>().add(DiscoverLoadedRewardAD());
                          context.read<DiscoverBloc>().add(DiscoverStoreCoinEvent());
                        },
                        onComplete: () {
                          context.push(AppRoutesString.dinoView);
                        },
                        onAdFailed: () {
                          context.read<DiscoverBloc>().add(DiscoverLoadedRewardAD());
                        },
                      );
                    },
      
                    firstButtonOnTap: () {
                      context.pop();
                      context.read<DiscoverBloc>().add(DiscoverPlayDinoGame());
                    },
                  );
                }
              },
              imageSize: 45,
              removeDecoration: true,
              fit: BoxFit.fill,
            ),
          ],
        ),
        body: BlocListener<DiscoverBloc, DiscoverState>(
          listener: (context, state) {
            if (state.status == DiscoverStatus.rewardAdLoading ||
                state.status == DiscoverStatus.interstitialAdLoading) {
              CommonDialog.loaderDialog(context: context);
            } else if (state.status == DiscoverStatus.rewardAdLoaded ||
                state.status == DiscoverStatus.interstitialAdLoaded) {
              CommonDialog.closeDialog(context: context);
            } else if (state.status == DiscoverStatus.navigateToDinoGame) {
              context.push(AppRoutesString.dinoView);
            }
          },
          child: BlocBuilder<DiscoverBloc, DiscoverState>(
            builder: (context, state) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: AppColors.backgroundColor,
                    child: SizedBox(
                      height: 35,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: state.categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final cat = state.categories[index];
                          return DiscoverCategoryWidget(
                            label: cat.name,
                            isSelected: state.selectedCategory == cat.name,
                            onTap: () {
                              int tapCount = AppPreferences().getInt(AppPreferences.categoryTap) ?? 0;
                              tapCount++;
                              AppPreferences().setInt(AppPreferences.categoryTap, tapCount);
      
                              context.read<DiscoverBloc>().add(ChangeDiscoverCategory(cat.name, index));
      
                              final showAd = tapCount % 3 == 0;
                              if (showAd) {
                                if (!AdHelper.isCategoryAdLoadingOrShowing) {
                                  AdHelper.isCategoryAdLoadingOrShowing = true;
                                  AdHelper.showInterstitialAd(
                                    adUnitId: AppAdIdString.categoryOnTapInterstitialAd,
                                    onComplete: () {
                                      AdHelper.isCategoryAdLoadingOrShowing = false;
                                    },
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  BannerAdWidget(adId: AppAdIdString.discoverBannerAd),
                  SBH2(),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(child: SBH10()),
      
                        if (state.status == DiscoverStatus.loading && state.entries.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CommonLoader(size: 24, strokeWidth: 2.5)),
                          )
                        else if (state.status == DiscoverStatus.FailureModel && state.entries.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CommonTextWidget(
                                text: "${AppStrings.txtError} ${state.errorMessage}",
                                textStyle: size14TextStyle(textColor: AppColors.whiteColor),
                              ),
                            ),
                          )
                        else ...[
                          // Dynamic Masonry Grid
                          SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            sliver: state.entries.isEmpty
                                ? SliverToBoxAdapter(
                                    child: SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.6,
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CommonTextWidget(
                                              text: AppStrings.txtNoTemplatesFound,
                                              textStyle: size16TextStyle(
                                                textColor: AppColors.onSurfaceVariant,
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
                                    ),
                                  )
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate((context, row) {
                                      final firstIndex = row * 2;
      
                                      if (firstIndex >= state.entries.length) {
                                        return const SizedBox.shrink();
                                      }
      
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              /// First Item
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    AdHelper.cancelLoadMoreAd = true;
                                                    final bool? result = await context.push<bool>(
                                                      AppRoutesString.templateDetailView,
                                                      extra: state.entries[firstIndex],
                                                    );
      
                                                    if (result == true) {
                                                      if ((AppPreferences().getInt(
                                                                AppPreferences.onBackPress,
                                                              ) ??
                                                              0) >
                                                          1) {
                                                        AppPreferences().setInt(
                                                          AppPreferences.onBackPress,
                                                          0,
                                                        );
                                                        if (!AdHelper.isBackButtonAdLoadingOrShowing) {
                                                          AdHelper.isBackButtonAdLoadingOrShowing = true;
                                                          AdHelper.showInterstitialAd(
                                                            adUnitId: AppAdIdString.backButtonInterstitialAd,
                                                            onComplete: () {
                                                              AdHelper.isBackButtonAdLoadingOrShowing = false;
                                                            },
                                                          );
                                                        }
                                                      }
                                                    }
                                                  },
                                                  child: GridItemWidget(
                                                    entry: state.entries[firstIndex],
                                                    onFavourite: () {
                                                      if (state.entries[firstIndex].isFavourite == true) {
                                                        context.read<DiscoverBloc>().add(
                                                          DiscoverRemoveLikeEvent(
                                                            index: firstIndex,
                                                            presentId: state.entries[firstIndex].id,
                                                          ),
                                                        );
                                                      } else {
                                                        context.read<DiscoverBloc>().add(
                                                          DiscoverLikeReelEvent(
                                                            index: firstIndex,
                                                            favouriteModel: FavouriteModel(
                                                              title: state.entries[firstIndex].title.toString(),
                                                              image: state.entries[firstIndex].image.toString(),
                                                              presentId: state.entries[firstIndex].id
                                                                  .toString(),
                                                              coin: state.entries[firstIndex].coin.toString(),
                                                              category:
                                                                  (state.entries[firstIndex].categories
                                                                          as List<dynamic>)
                                                                      .join(', '),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
      
                                              SBW15(),
      
                                              /// Second Item
                                              if (firstIndex + 1 < state.entries.length)
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      AdHelper.cancelLoadMoreAd = true;
                                                      final bool? result = await context.push<bool>(
                                                        AppRoutesString.templateDetailView,
                                                        extra: state.entries[firstIndex + 1],
                                                      );
      
                                                      if (result == true) {
                                                        if ((AppPreferences().getInt(AppPreferences.onBackPress) ?? 0) > 1) {
                                                          AppPreferences().setInt(AppPreferences.onBackPress, 0);
                                                          if (!AdHelper.isBackButtonAdLoadingOrShowing) {
                                                            AdHelper.isBackButtonAdLoadingOrShowing = true;
                                                            AdHelper.showInterstitialAd(
                                                              adUnitId: AppAdIdString.backButtonInterstitialAd,
                                                              onComplete: () {
                                                                AdHelper.isBackButtonAdLoadingOrShowing = false;
                                                              },
                                                            );
                                                          }
                                                        }
                                                      }
                                                    },
                                                    child: GridItemWidget(
                                                      entry: state.entries[firstIndex + 1],
                                                      onFavourite: () {
                                                        if (state.entries[firstIndex + 1].isFavourite == true) {
                                                          context.read<DiscoverBloc>().add(
                                                            DiscoverRemoveLikeEvent(
                                                              index: firstIndex + 1,
                                                              presentId: state.entries[firstIndex + 1].id,
                                                            ),
                                                          );
                                                        } else {
                                                          context.read<DiscoverBloc>().add(
                                                            DiscoverLikeReelEvent(
                                                              index: firstIndex + 1,
                                                              favouriteModel: FavouriteModel(
                                                                title: state.entries[firstIndex + 1].title
                                                                    .toString(),
                                                                image: state.entries[firstIndex + 1].image
                                                                    .toString(),
                                                                presentId: state.entries[firstIndex + 1].id
                                                                    .toString(),
                                                                coin: state.entries[firstIndex + 1].coin
                                                                    .toString(),
                                                                category:
                                                                    (state.entries[firstIndex + 1].categories
                                                                            as List<dynamic>)
                                                                        .join(', '),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                )
                                              else
                                                const Expanded(child: SizedBox()),
                                            ],
                                          ),
      
                                          SBH15(),
      
                                          /// Show Ad
                                          if (shouldShowAd(row))
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 16),
                                              child: BlocProvider(
                                                create: (context) => NativeAdBloc(),
                                                child: NativeAdView(adId: AppAdIdString.discoverNativeAd),
                                              ),
                                            ),
                                        ],
                                      );
                                    }, childCount: (state.entries.length / 2).ceil()),
                                  ),
                          ),
      
                          // Load More Button
                          if (state.hasMore == true)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32),
                                child: Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      int loadMoreCount = AppPreferences().getInt(AppPreferences.loadMore) ?? 0;
                                      loadMoreCount++;
                                      AppPreferences().setInt(AppPreferences.loadMore, loadMoreCount);
      
                                      final category = state.selectedCategoryIndex == 0
                                          ? ''
                                          : state.selectedCategory;
      
                                      context.read<DiscoverBloc>().add(
                                        LoadMoreDiscoverData(category: category),
                                      );
      
                                      final showAd = loadMoreCount % 2 == 0;
                                      if (showAd) {
                                        if (!AdHelper.isLoadMoreAdLoadingOrShowing) {
                                          AdHelper.showLoadMoreInterstitialAd(
                                            adUnitId: AppAdIdString.loadMoreInterstitialAd,
                                          );
                                        }
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(100),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryContainer.withOpacity(0.3),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: state.status == DiscoverStatus.loadingMore
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: AppColors.whiteColor,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : CommonTextWidget(
                                              text: AppStrings.txtLoadMore,
                                              textStyle: size16TextStyle(
                                                textColor: AppColors.whiteColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
      
                          const SliverToBoxAdapter(child: SBH100()),
                        ],
                      ],
                    ),
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
