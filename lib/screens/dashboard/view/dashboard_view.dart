import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/banner_ad/bloc/banner_ad_bloc.dart';
import 'package:lightroom_template/common/ad_widgets/full_screen_native_ad/bloc/full_screen_native_ad_bloc.dart';
import 'package:lightroom_template/common/common_bottom_sheet.dart';
import 'package:lightroom_template/common/dialog/common_dialog.dart';
import 'package:lightroom_template/core/constant/app_ad_id_string.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:lightroom_template/screens/favourite/bloc/favourite_bloc.dart';
import 'package:lightroom_template/screens/favourite/view/favourite_view.dart';
import 'package:lightroom_template/screens/home/bloc/home_bloc.dart';
import 'package:lightroom_template/screens/home/bloc/home_state.dart';
import 'package:lightroom_template/screens/home/view/home_view.dart';
import 'package:lightroom_template/screens/discover/bloc/discover_bloc.dart';
import 'package:lightroom_template/screens/discover/view/discover_view.dart';
import 'package:lightroom_template/screens/setting/bloc/setting_bloc.dart';
import 'package:lightroom_template/screens/setting/view/setting_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  static List<Widget> screens(BuildContext context) => [
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: BlocProvider.of<HomeBloc>(context)),
        BlocProvider(create: (context) => FullScreenNativeAdBloc()),
      ],
      child: const HomeView(),
    ),
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: BlocProvider.of<DiscoverBloc>(context)),
        BlocProvider(create: (context) => BannerAdBloc()),
      ],
      child: const DiscoverView(),
    ),
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: BlocProvider.of<FavouriteBloc>(context)),
        BlocProvider(create: (context) => BannerAdBloc()),
      ],
      child: const FavouriteView(),
    ),

    MultiBlocProvider(
      providers: [
        // BlocProvider.value(value: BlocProvider.of<FavouriteBloc>(context)),
        BlocProvider(create: (context) => BannerAdBloc()),
        BlocProvider(create: (context) => SettingBloc()),
      ],
      child: const SettingView(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeBloc()),
        BlocProvider(create: (context) => FavouriteBloc()),
        BlocProvider(
          create: (context) => DiscoverBloc(
            homeBloc: BlocProvider.of<HomeBloc>(context),
            favouriteBloc: BlocProvider.of<FavouriteBloc>(context),
          ),
        ),
      ],
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (didPop) return;
              if (state.tabHistory.length > 1) {
                context.read<DashboardBloc>().add(DashboardBackPressedEvent());
              } else {
                if (state.currentIndex == 0) {
                  CommonBottomSheet.showCommonBottomSheet(
                    adId: AppAdIdString.exitAppNativeAd,
                    context: context,
                    firstButtonText: AppStrings.txtYes,
                    secondButtonText: AppStrings.txtNo,
                    title: AppStrings.txtAreYouSureYouWantToExitThisApp,
                    secondButtonOnTap: () {
                      Navigator.of(context).pop();
                    },
                    firstButtonOnTap: () {
                      SystemNavigator.pop();
                    },
                  );
                } else {
                  context.read<DashboardBloc>().add(DashboardTabChangedEvent(0));
                }
              }
            },
            child: Scaffold(
              body: Stack(
                children: [
                  IndexedStack(index: state.currentIndex, children: screens(context)),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppColors.outlineVariant.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildNavItem(context, Icons.home_rounded, 0, state.currentIndex),
                            _buildNavItem(context, Icons.search_rounded, 1, state.currentIndex),
                            _buildNavItem(context, Icons.favorite_rounded, 2, state.currentIndex),
                            _buildNavItem(context, Icons.settings, 3, state.currentIndex),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index, int currentIndex) {
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        context.read<DashboardBloc>().add(DashboardTabChangedEvent(index));
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          size: isSelected ? 32 : 30,
          color: isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
