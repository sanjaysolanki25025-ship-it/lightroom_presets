import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:clarity_flutter/clarity_flutter.dart' as clarity;
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/native_ad_manager.dart';
import 'package:lightroom_template/core/utils/banner_ad_manager.dart';
import 'package:lightroom_template/data/helpers/ad_helper.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:lightroom_template/data/models/dino_game_models/player_data.dart';
import 'package:lightroom_template/data/models/dino_game_models/settings.dart';
import 'package:lightroom_template/data/services/meta_service.dart';
import 'package:lightroom_template/data/services/notification_services.dart';
import 'package:lightroom_template/routes/app_routes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:purchases_flutter/models/purchases_configuration.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as purchases;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = ClarityConfig(projectId: AppStrings.clarityKey, logLevel: clarity.LogLevel.None);

  /// Lock orientation & Firebase & App Preferences
  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]),
    Firebase.initializeApp(),
    AppPreferences().initialize(),
  ]);

  /// Meta (Facebook SDK)
  await MetaService.init();

  /// Crashlytics - Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  /// Firebase Remote Config
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 3),
      minimumFetchInterval: const Duration(days: 365),
    ),
  );
  await remoteConfig.fetchAndActivate();

  await NotificationService.init();

  unawaited(_warmUpServicesAfterLaunch());

  // await Purchases.setLogLevel(purchases.LogLevel.error);
  // PurchasesConfiguration configuration;
  // configuration = PurchasesConfiguration(
  //   Platform.isIOS ? AppStrings.applePurchaseKey : AppStrings.googlePurchaseKey,
  // );
  // await Purchases.configure(configuration);
  // PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20;
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     statusBarColor: Colors.transparent,
  //     statusBarIconBrightness: Brightness.light, // White Android icons
  //     statusBarBrightness: Brightness.dark, // White iOS icons
  //   ),
  // );
  await initHive();
  runApp(ClarityWidget(app: const MyApp(), clarityConfig: config));
}

/// Notifications &  Google Mobile Ads
Future<void> _warmUpServicesAfterLaunch() async {
  await Future.wait([MetaService.init(), MobileAds.instance.initialize()]);
  NativeAdManager().init();
  BannerAdManager().init();
  // NativeAdManager().initFullAds();
  AdHelper.precacheAppOpenAd();
}

/// for dino game
Future<void> initHive() async {
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  Hive.registerAdapter<PlayerData>(PlayerDataAdapter());
  Hive.registerAdapter<Settings>(SettingsAdapter());
}

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(370, 710),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        title: "Lightroom Presets - Lumio",
        debugShowCheckedModeBanner: false,
        routerConfig: AppRoutes.routes,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.backgroundColor,
          useMaterial3: true,
          // appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light),
          // appBarTheme: const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark),
          // appBarTheme: const AppBarTheme(
          //   systemOverlayStyle: SystemUiOverlayStyle(
          //     statusBarColor: Colors.transparent,
          //     statusBarIconBrightness: Brightness.light,
          //     statusBarBrightness: Brightness.dark,
          //   ),
          // ),
        ),
        // builder: (context, child) {
        //   return AnnotatedRegion<SystemUiOverlayStyle>(
        //     value: const SystemUiOverlayStyle(
        //       statusBarColor: Colors.black,
        //       statusBarIconBrightness: Brightness.light, // Android: white icons
        //       statusBarBrightness: Brightness.dark, // iOS: white icons
        //     ),
        //     child: child!,
        //   );
        // },
        // builder: (context, child) {
        //   // ✅ AnnotatedRegion here — closest to the actual UI
        //   return SafeArea(
        //     bottom: false,
        //     child: child ?? const SizedBox(),
        //   );
        // },
      ),
    );
  }
}
