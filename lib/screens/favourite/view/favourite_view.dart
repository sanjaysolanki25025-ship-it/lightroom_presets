import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import 'package:lightroom_template/data/models/lr_preset_model.dart';
import 'package:lightroom_template/routes/app_route_string.dart';
import 'package:lightroom_template/screens/discover/widgets/discover_category_widget.dart';
import 'package:lightroom_template/common/grid_item_widget.dart';
import 'package:lightroom_template/screens/favourite/bloc/favourite_bloc.dart';
import 'package:lightroom_template/screens/home/widgets/common_action_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavouriteView extends StatefulWidget {
  const FavouriteView({super.key});

  @override
  State<FavouriteView> createState() => _FavouriteViewState();
}

class _FavouriteViewState extends State<FavouriteView> {
  @override
  void initState() {
    context.read<FavouriteBloc>().add(FetchFavouriteEvent());
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
          title: AppStrings.txtFavourite,
          actions: [
            // CommonLottieAsset(assetName: AppLottiesString.pro),
            // SBW2(),
            CommonActionButton(
              assetPath: AppImagesString.imgDino,
              onTap: () {
                final int totalCoin = AppPreferences().getInt(AppPreferences.coin) ?? 0;
                if (totalCoin < 5) {
                  CommonBottomSheet.showCommonBottomSheet(
                    adId: AppAdIdString.favouriteBottomNativeAd,
                    context: context,
                    firstButtonText: AppStrings.txtWatchAd,
                    title: AppStrings.txtNotEnoughCoinsWatchAnAdToPlay,
                    firstButtonOnTap: () {
                      Navigator.of(context).pop();
                      context.read<FavouriteBloc>().add(LoadRewardADEvent());
                      AdHelper.showRewardedAd(
                        adUnitId: AppAdIdString.playDinoRewardedAd,
                        onRewardEarned: () {
                          context.read<FavouriteBloc>().add(LoadedRewardADEvent());
                          context.read<FavouriteBloc>().add(FavouriteStoreCoinEvent());
                        },
                        onComplete: () {
                          context.push(AppRoutesString.dinoView);
                        },
                        onAdFailed: () {
                          context.read<FavouriteBloc>().add(LoadedRewardADEvent());
                        },
                      );
                    },
                  );
                } else {
                  CommonBottomSheet.showCommonBottomSheet(
                    adId: AppAdIdString.favouriteBottomNativeAd,
                    context: context,
                    firstButtonText: "🔓 ${AppStrings.txtFiveLetter} ${AppStrings.txtCoins}",
                    secondButtonText: AppStrings.txtWatchAd,
                    title: AppStrings.txtPlayGameReward,
                    secondButtonOnTap: () {
                      Navigator.of(context).pop();
                      context.read<FavouriteBloc>().add(LoadRewardADEvent());
                      AdHelper.showRewardedAd(
                        adUnitId: AppAdIdString.playDinoRewardedAd,
                        onRewardEarned: () {
                          context.read<FavouriteBloc>().add(LoadedRewardADEvent());
                          context.read<FavouriteBloc>().add(FavouriteStoreCoinEvent());
                        },
                        onComplete: () {
                          context.push(AppRoutesString.dinoView);
                        },
                        onAdFailed: () {
                          context.read<FavouriteBloc>().add(LoadedRewardADEvent());
                        },
                      );
                    },
      
                    firstButtonOnTap: () {
                      context.pop();
                      context.read<FavouriteBloc>().add(FavouritePlayDinoGame());
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
        body: BlocListener<FavouriteBloc, FavouriteState>(
          listener: (context, state) {
            if (state.status == FavouriteStatus.rewardAdLoading) {
              CommonDialog.loaderDialog(context: context);
            } else if (state.status == FavouriteStatus.rewardAdLoaded) {
              CommonDialog.closeDialog(context: context);
            } else if (state.status == FavouriteStatus.navigateToDinoGame) {
              context.push(AppRoutesString.dinoView);
            }
          },
          child: BlocBuilder<FavouriteBloc, FavouriteState>(
            builder: (context, state) {
              return Column(
                children: [
                  if (state.categories.isNotEmpty)
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
                              label: cat,
                              isSelected: state.selectedCategoryIndex == index,
                               onTap: () {
                                 int tapCount = AppPreferences().getInt(AppPreferences.categoryTap) ?? 0;
                                 tapCount++;
                                 AppPreferences().setInt(AppPreferences.categoryTap, tapCount);
      
                                 context.read<FavouriteBloc>().add(ChangeFavouriteCategoryEvent(index: index));
      
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
                  BannerAdWidget(adId: AppAdIdString.favouriteBannerAd),
                  SBH2(),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        const SliverToBoxAdapter(child: SBH10()),
      
                        if (state.status == FavouriteStatus.loading && state.presents.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(child: CommonLoader(size: 24, strokeWidth: 2.5)),
                          )
                        else if (state.status == FavouriteStatus.FailureModel && state.presents.isEmpty)
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
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: state.presents.isEmpty
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
                                      if (firstIndex >= state.presents.length) {
                                        return const SizedBox.shrink();
                                      }
      
                                      final fav1 = state.presents[firstIndex];
                                      final entry1 = LrPresetModel(
                                        categories: fav1.category.split(',').map((e) => e.trim()).toList(),
                                        coin: int.tryParse(fav1.coin) ?? 0,
                                        createdAt: Timestamp.now(),
                                        date: '',
                                        id: fav1.presentId,
                                        image: fav1.image,
                                        title: fav1.title,
                                        isFavourite: true,
                                      );
      
                                      LrPresetModel? entry2;
                                      if (firstIndex + 1 < state.presents.length) {
                                        final fav2 = state.presents[firstIndex + 1];
                                        entry2 = LrPresetModel(
                                          categories: fav2.category.split(',').map((e) => e.trim()).toList(),
                                          coin: int.tryParse(fav2.coin) ?? 0,
                                          createdAt: Timestamp.now(),
                                          date: '',
                                          id: fav2.presentId,
                                          image: fav2.image,
                                          title: fav2.title,
                                          isFavourite: true,
                                        );
                                      }
      
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    AdHelper.cancelLoadMoreAd = true;
                                                    final bool? result = await context.push<bool>(
                                                      AppRoutesString.templateDetailView,
                                                      extra: entry1,
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
                                                    entry: entry1,
                                                    onFavourite: () {
                                                      context.read<FavouriteBloc>().add(
                                                        RemoveFavouriteEvent(
                                                          index: firstIndex,
                                                          presentId: entry1.id,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
      
                                              SBW15(),
      
                                              if (entry2 != null)
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      AdHelper.cancelLoadMoreAd = true;
                                                      final bool? result = await context.push<bool>(
                                                        AppRoutesString.templateDetailView,
                                                        extra: entry2,
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
                                                      entry: entry2,
                                                      onFavourite: () {
                                                        context.read<FavouriteBloc>().add(
                                                          RemoveFavouriteEvent(
                                                            index: firstIndex + 1,
                                                            presentId: entry2!.id,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                )
                                              else
                                                const Expanded(child: SizedBox()),
                                            ],
                                          ),
      
                                          SBH15(),
      
                                          if (shouldShowAd(row))
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 16),
                                              child: BlocProvider(
                                                create: (context) => NativeAdBloc(),
                                                child: NativeAdView(adId: AppAdIdString.favouriteNativeAd),
                                              ),
                                            ),
                                        ],
                                      );
                                    }, childCount: (state.presents.length / 2).ceil()),
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
