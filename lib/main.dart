import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:clarity_flutter/clarity_flutter.dart' as clarity;
import 'package:clarity_flutter/clarity_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:izooto_plugin/iZooto_flutter.dart';
import 'package:lightroom_template/core/constant/app_colors.dart';
import 'package:lightroom_template/core/constant/app_string.dart';
import 'package:lightroom_template/core/utils/native_ad_manager.dart';
import 'package:lightroom_template/core/utils/banner_ad_manager.dart';
import 'package:lightroom_template/data/helpers/ad_helper.dart';
import 'package:lightroom_template/data/helpers/notification_helper.dart';
import 'package:lightroom_template/data/helpers/preferences_helper.dart';
import 'package:lightroom_template/data/models/dino_game_models/player_data.dart';
import 'package:lightroom_template/data/models/dino_game_models/settings.dart';
import 'package:lightroom_template/data/services/meta_service.dart';
import 'package:lightroom_template/routes/app_routes.dart';
import 'package:path_provider/path_provider.dart';

const platform = MethodChannel("iZooto-flutter");
const landingURLPlateform = MethodChannel("iZooto-flutter_webview");

// iZooto initialisation
Future<void> _iZootoInitialise() async {
  try {
    if (Platform.isAndroid) {
      await iZooto.androidInit(false); // for Android
      // false will trigger WebView listener
      // true will trigger default WebView
      await iZooto.setNotificationChannelName("High Importance Notifications");
    } else if (Platform.isIOS) {
      await iZooto.iOSInit(appId: "89edf4067a4ef1194581ed66fee977ec6b848c28"); // for iOS
    }

    // DeepLink Android/iOS
    iZooto.shared.onNotificationOpened((data) {
      debugPrint('iZooto DeepLink Data : $data');
      if (data != null && data.isNotEmpty) {
        try {
          final Map<String, dynamic> parsed = json.decode(data);
          NotificationHelper.onNotificationTapped?.call(parsed);
        } catch (_) {
          NotificationHelper.onNotificationTapped?.call({'payload': data});
        }
      }
    });

    // LandingURLDelegate Android/iOS
    iZooto.shared.onWebView((landingUrl) {
      debugPrint('iZooto Landing URL : $landingUrl');
      if (landingUrl != null && landingUrl.isNotEmpty) {
        NotificationHelper.onNotificationTapped?.call({'landingUrl': landingUrl});
      }
    });

    // Received payload Android/iOS
    iZooto.shared.onNotificationReceived((payload) {
      debugPrint('iZooto Flutter Payload : $payload ');
      if (payload != null) {
        try {
          List<dynamic> list = json.decode(payload);
          debugPrint(list.toString());
          List<String> receivedpayload = List<String>.from(list.reversed);
          debugPrint(receivedpayload.toString());
        } catch (e) {
          debugPrint('Error decoding iZooto payload: $e');
        }
      }
    });

    // Device token Android/iOS
    iZooto.shared.onTokenReceived((token) {
      debugPrint('iZooto Flutter Token : $token ');
    });

    // iOS WebView Listener Killed State
    if (Platform.isIOS) {
      try {
        String? value = await landingURLPlateform.invokeMethod<String>(
          "handleLandingURL",
        );
        if (value != null) {
          debugPrint('iZooto Killed state ios data : $value ');
        }
      } catch (e) {
        debugPrint('Error in iOS WebView Listener Killed State: $e');
      }

      // iOS DeepLink Killed state code
      try {
        String? value = await platform.invokeMethod<String>("OpenNotification");
        if (value != null) {
          debugPrint('iZooto Killed state ios data : $value ');
        }
      } catch (e) {
        debugPrint('Error in iOS DeepLink Killed state: $e');
      }
    }
  } catch (e) {
    debugPrint('Deferred iZooto error: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = ClarityConfig(projectId: AppStrings.clarityKey, logLevel: clarity.LogLevel.None);

  /// Fast local initialization
  await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]),
    Firebase.initializeApp(),
    AppPreferences().initialize(),
    FlutterLocalization.instance.ensureInitialized(),
    initHive(),
  ]);

  FlutterLocalization.instance.init(
    initLanguageCode: AppPreferences().getString(AppPreferences.selectedLanguage) ?? 'en',
    source: LocalizationSource.jsonAsset,
    jsonLocales: const [
      JsonLocale('ar', 'assets/languages/ar.json'),
      JsonLocale('de', 'assets/languages/de.json'),
      JsonLocale('en', 'assets/languages/en.json'),
      JsonLocale('es', 'assets/languages/es.json'),
      JsonLocale('fr', 'assets/languages/fr.json'),
      JsonLocale('hi', 'assets/languages/hi.json'),
      JsonLocale('id', 'assets/languages/id.json'),
      JsonLocale('ko', 'assets/languages/ko.json'),
      JsonLocale('pt', 'assets/languages/pt.json'),
      JsonLocale('tr', 'assets/languages/tr.json'),
    ],
  );

  // Register FCM background message handler early
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  /// Crashlytics - Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Render the Flutter UI immediately so native splash dismisses at once
  runApp(ClarityWidget(app: const MyApp(), clarityConfig: config));

  // Initialize all remaining services concurrently after UI is drawn
  unawaited(_initAppServices());
}

Future<void> _initAppServices() async {
  // 1. Meta (Facebook SDK)
  try {
    await MetaService.init();
  } catch (e) {
    debugPrint('MetaService init error: $e');
  }

  // 2. Firebase Remote Config
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 3),
        minimumFetchInterval: const Duration(days: 365),
      ),
    );
    await remoteConfig.fetchAndActivate().timeout(
      const Duration(seconds: 3),
      onTimeout: () => false,
    );
  } catch (e) {
    debugPrint('RemoteConfig error: $e');
  }

  // 3. Mobile Ads SDK initialization & pre-caching
  try {
    await AdHelper.initializeMobileAds();
    NativeAdManager().init();
    BannerAdManager().init();
    AdHelper.precacheAppOpenAd();
  } catch (e) {
    debugPrint('Ad services init error: $e');
  }

  // 4. NotificationHelper (FCM + local notifications + topic "all")
  try {
    await NotificationHelper.initialize();
  } catch (e) {
    debugPrint('NotificationHelper init error: $e');
  }

  // 5. iZooto initialization
  try {
    await _iZootoInitialise();
  } catch (e) {
    debugPrint('Deferred iZooto error: $e');
  }
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
    final localization = FlutterLocalization.instance;

    return ListenableBuilder(
      listenable: localization,
      builder: (context, _) {
        return ScreenUtilInit(
          designSize: const Size(370, 710),
          minTextAdapt: true,
          splitScreenMode: true,
          child: MaterialApp.router(
            title: "Lightroom Presets - Lumio",
            debugShowCheckedModeBanner: false,
            routerConfig: AppRoutes.routes,
            locale: localization.currentLocale,
            supportedLocales: localization.supportedLocales,
            localizationsDelegates: localization.localizationsDelegates,
            theme: ThemeData(
              scaffoldBackgroundColor: AppColors.backgroundColor,
              useMaterial3: true,
            ),
          ),
        );
      },
    );
  }
}
