import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lightroom_template/common/ad_widgets/full_screen_native_ad/bloc/full_screen_native_ad_bloc.dart';
import 'package:lightroom_template/data/models/lr_preset_model.dart';
import 'package:lightroom_template/routes/app_route_string.dart';
import 'package:lightroom_template/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:lightroom_template/screens/dashboard/view/dashboard_view.dart';
import 'package:lightroom_template/screens/dino_game/view/dino_view.dart';
import 'package:lightroom_template/screens/feedback/bloc/feedback_bloc.dart';
import 'package:lightroom_template/screens/feedback/view/feedback_view.dart';
import 'package:lightroom_template/screens/home/bloc/home_bloc.dart';
import 'package:lightroom_template/screens/home/view/home_view.dart';
import 'package:lightroom_template/screens/maintenance/view/maintenance_view.dart';
import 'package:lightroom_template/screens/onboarding/bloc/onboarding_bloc.dart';
import 'package:lightroom_template/screens/onboarding/view/onboarding_view.dart';
import 'package:lightroom_template/screens/other_apps_screen/bloc/other_apps_bloc.dart';
import 'package:lightroom_template/screens/other_apps_screen/view/other_apps_view.dart';
import 'package:lightroom_template/screens/splash/bloc/splash_bloc.dart';
import 'package:lightroom_template/screens/splash/view/splash_view.dart';
import 'package:lightroom_template/common/ad_widgets/native_ad_onboarding/bloc/native_ad_onboarding_bloc.dart';
import 'package:lightroom_template/screens/template_detail/bloc/template_detail_bloc.dart';
import 'package:lightroom_template/screens/template_detail/view/template_detail_view.dart';

import '../main.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static GoRouter routes = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutesString.splashView,
    observers: [routeObserver],
    routes: [
      /// splash view
      GoRoute(
        path: AppRoutesString.splashView,
        builder: (context, state) =>
            BlocProvider(create: (context) => SplashBloc(), child: const SplashView()),
      ),

      /// onboarding view
      GoRoute(
        path: AppRoutesString.onboardingView,
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<OnboardingBloc>(create: (context) => OnboardingBloc()),
              BlocProvider<NativeAdOnboardingBloc>(create: (context) => NativeAdOnboardingBloc()),
            ],
            child: const OnboardingView(),
          );
        },
      ),

      /// dashboard view
      GoRoute(
        path: AppRoutesString.dashboardView,
        builder: (context, state) =>
            BlocProvider(create: (context) => DashboardBloc(), child: const DashboardView()),
      ),

      /// home view
      GoRoute(
        path: AppRoutesString.homeView,
        builder: (context, state) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => HomeBloc()),
            BlocProvider(create: (context) => FullScreenNativeAdBloc()),
          ],
          child: const HomeView(),
        ),
      ),

      /// dino view
      GoRoute(path: AppRoutesString.dinoView, builder: (context, state) => const DinoView()),

      /// template detail
      GoRoute(
        path: AppRoutesString.templateDetailView,
        builder: (context, state) {
          final data = state.extra as LrPresetModel;

          return MultiBlocProvider(
            providers: [BlocProvider(create: (context) => TemplateDetailBloc())],
            child: TemplateDetailView(entry: data),
          );
        },
      ),

      /// feedback view
      GoRoute(
        path: AppRoutesString.feedbackView,
        builder: (context, state) => BlocProvider(create: (context) => FeedbackBloc(), child: FeedbackView()),
      ),

      /// other Apps View
      GoRoute(
        path: AppRoutesString.otherAppsView,
        builder: (context, state) {
          return BlocProvider(create: (context) => OtherAppsBloc(), child: OtherAppsView());
        },
      ),

      /// maintenance view
      GoRoute(path: AppRoutesString.maintenanceView, builder: (context, state) => MaintenanceView()),

      //
      // /// dashboard view
      // GoRoute(
      //   path: AppRoutesString.dashboardView,
      //   builder: (context, state) => MultiBlocProvider(
      //     providers: [
      //       // 1. Move HomeBloc to the top because others depend on it
      //       BlocProvider(create: (context) => HomeBloc()),
      //
      //       BlocProvider(create: (context) => DashboardBloc()),
      //
      //       BlocProvider(
      //         create: (context) => DiscoverBloc(
      //           // Now HomeBloc is available in the context here
      //           homeBloc: BlocProvider.of<HomeBloc>(context),
      //         ),
      //       ),
      //
      //       BlocProvider(create: (context) => SettingBloc()),
      //
      //       BlocProvider(
      //         create: (context) => FavouriteBloc(
      //           // HomeBloc is also available here
      //           homeBloc: BlocProvider.of<HomeBloc>(context),
      //         ),
      //       ),
      //     ],
      //     child: const DashboardView(),
      //   ),
      // ),
      //
      // /// home view
      // GoRoute(path: AppRoutesString.homeView, builder: (context, state) => const HomeView()),
      //
      // /// discover view
      // GoRoute(path: AppRoutesString.discoverView, builder: (context, state) => const DiscoverView()),
      //
      // /// slot view
      // GoRoute(
      //   path: AppRoutesString.slotView,
      //   builder: (context, state) => BlocProvider(create: (context) => SlotBloc(), child: const SlotView()),
      // ),
      //
      // /// language Selection view
      // GoRoute(
      //   path: AppRoutesString.countrySelectionView,
      //   builder: (context, state) =>
      //       BlocProvider(create: (context) => CountrySelectionBloc(), child: const CountrySelectionView()),
      // ),
      //
      // /// discover detail
      // GoRoute(
      //   path: AppRoutesString.templateDetailView,
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>;
      //     return BlocProvider(
      //       create: (context) => TemplateDetailBloc(),
      //       child: TemplateDetailView(
      //         clips: extra['clips'] as String,
      //         templateName: extra['templateName'] as String,
      //         description: extra['description'] as String,
      //         templateLink: extra['templateLink'] as String,
      //         isPremium: extra['isPremium'] as bool,
      //         templateCoin: extra['templateCoin'] as int,
      //         templateId: extra['templateId'] as String,
      //         isImage: extra['isImage'] as bool,
      //       ),
      //     );
      //   },
      // ),
      //

      //
      // /// edit language selection view
      // GoRoute(
      //   path: AppRoutesString.editCountrySelectionView,
      //   builder: (context, state) =>
      //       BlocProvider(create: (context) => EditCountrySelectionBloc(), child: EditCategorySelectionView()),
      // ),
      //
      // /// slot machine how to use view
      // GoRoute(
      //   path: AppRoutesString.slotMachineHowToUseView,
      //   builder: (context, state) => SlotMachineHowToUseView(),
      // ),
      //
      // /// rewards pool view
      // GoRoute(path: AppRoutesString.rewardsPoolView, builder: (context, state) => RewardsPoolView()),
      //
      // /// rewards rush guide view
      // GoRoute(path: AppRoutesString.rewardRushGuideView, builder: (context, state) => RewardRushGuideView()),
      //
      // /// how to use view
      // GoRoute(path: AppRoutesString.howToUseView, builder: (context, state) => HowToUseView()),
      //

      //
      // /// subscription view
      // GoRoute(
      //   path: AppRoutesString.subscriptionView,
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>?;
      //     final bool isSplashScreen = (extra != null && extra['isSplashScreen'] == true);
      //     return BlocProvider(
      //       create: (context) => SubscriptionBloc(),
      //       child: SubscriptionView(isSplashScreen: isSplashScreen),
      //     );
      //   },
      // ),
      //
      // /// coin zone view
      // GoRoute(
      //   path: AppRoutesString.coinZoneView,
      //   builder: (context, state) => BlocProvider(create: (context) => CoinZoneBloc(), child: CoinZoneView()),
      // ),
      //
      // /// coin zone receipt view
      // GoRoute(
      //   path: AppRoutesString.coinZoneReceiptView,
      //   builder: (context, state) {
      //     final extra = state.extra as Map<String, dynamic>;
      //     return CoinZoneReceiptView(isConform: extra['isConform'] as bool);
      //   },
      // ),
      //
    ],
  );
}
