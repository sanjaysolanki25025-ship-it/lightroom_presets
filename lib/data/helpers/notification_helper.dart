import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:izooto_plugin/iZooto_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/utils/app_logger.dart';

/// Top-level background message handler for FCM.
/// Must be outside of any class and annotated with @pragma('vm:entry-point').
/// Handles notifications when the app is in the background or killed.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
  }

  AppLogger.log(
    'FCM Background message received: ${message.messageId} | data: ${message.data}',
    tag: 'NotificationHelper',
  );
}

class NotificationHelper {
  NotificationHelper._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Default topic requested for all users
  static const String topicAll = 'all';

  /// Android High Importance Notification Channel definition
  /// Mandatory for Android 8.0+ (API 26+) including Android 9, 10, 11, 12, 13, 14, 15+
  static const AndroidNotificationChannel _highImportanceChannel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // name
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  /// Callback to handle notification tap navigation or action
  static Function(Map<String, dynamic> data)? onNotificationTapped;

  /// Initializes FCM and Local Notifications for all Android & iOS versions
  static Future<void> initialize({Function(Map<String, dynamic> data)? onTapped}) async {
    onNotificationTapped = onTapped;

    try {
      // 1. Request permissions across all Android versions & iOS (non-blocking)
      unawaited(_requestPermissions());

      // 2. Initialize local notifications plugin (heads-up notifications in foreground)
      await _initializeLocalNotifications();

      // 3. Setup Android notification channel (Essential for Android 9, 10, 11, 12, 13+)
      await _createNotificationChannel();

      // 4. Configure foreground presentation options for iOS
      await _messaging.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

      // 5. Setup foreground & background message listeners
      _setupMessageListeners();

      // 6. Check if app was opened from terminated state by a notification
      await _checkInitialNotification();

      // 7. Subscribe to default topic "all" (non-blocking in background)
      unawaited(subscribeToTopic(topicAll));

      // 8. Listen to token refresh and re-subscribe to topic "all"
      _listenTokenRefresh();

      // 9. Fetch and log device FCM token for debugging/testing (non-blocking)
      unawaited(getDeviceToken());

      AppLogger.log('NotificationHelper initialized successfully', tag: 'NotificationHelper');
    } catch (e, stack) {
      AppLogger.log(
        'Error during NotificationHelper initialization: $e',
        tag: 'NotificationHelper',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Request Notification Permissions
  /// Covers all Android versions (9, 10, 11, 12, 13, 14, 15, 16+) and iOS,
  /// syncing iZooto subscriptions when allowed.
  static Future<void> _requestPermissions() async {
    // 1. Android Permission & iZooto subscription
    if (Platform.isAndroid) {
      try {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          final res = await Permission.notification.request();
          if (res.isGranted) {
            debugPrint('iZooto.setSubscription(true); (permission granted sync)');
            iZooto.setSubscription(true);
          }
        }

        await _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();

        // Android 13+ native permission prompt as per iZooto docs (non-blocking)
        try {
          iZooto.promptForPushNotifications();
        } catch (e) {
          debugPrint('iZooto.promptForPushNotifications error: $e');
        }

        // REQUIRED: Keep iZooto.setSubscription(true) and print as requested
        debugPrint('iZooto.setSubscription(true);');
        iZooto.setSubscription(true);

        // Delayed retry to ensure iZooto async senderId config has finished loading
        Future.delayed(const Duration(seconds: 3), () {
          debugPrint('iZooto.setSubscription(true); (delayed sync)');
          iZooto.setSubscription(true);
        });

        Future.delayed(const Duration(seconds: 6), () {
          debugPrint('iZooto.setSubscription(true); (fallback sync)');
          iZooto.setSubscription(true);
        });
      } catch (e) {
        debugPrint('Error requesting Android notification permission: $e');
      }
    }

    // 2. iOS Permission & iZooto subscription
    if (Platform.isIOS) {
      try {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          final res = await Permission.notification.request();
          if (res.isGranted) {
            debugPrint('iZooto.setSubscription(true); (iOS permission granted sync)');
            iZooto.setSubscription(true);
          }
        }

        // FCM permission request for iOS
        final NotificationSettings settings = await _messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        AppLogger.log('iOS notification permission status: ${settings.authorizationStatus}', tag: 'NotificationHelper');

        if (settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional) {
          debugPrint('iZooto.setSubscription(true); (iOS FCM permission granted sync)');
          iZooto.setSubscription(true);
        }

        // Local notifications request for iOS
        final iosPlatform = _localNotifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        if (iosPlatform != null) {
          await iosPlatform.requestPermissions(alert: true, badge: true, sound: true);
        }

        // Set iZooto subscription on iOS
        debugPrint('iZooto.setSubscription(true); (iOS)');
        iZooto.setSubscription(true);

        Future.delayed(const Duration(seconds: 3), () {
          debugPrint('iZooto.setSubscription(true); (iOS delayed sync)');
          iZooto.setSubscription(true);
        });

        Future.delayed(const Duration(seconds: 6), () {
          debugPrint('iZooto.setSubscription(true); (iOS fallback sync)');
          iZooto.setSubscription(true);
        });
      } catch (e) {
        debugPrint('Error requesting iOS notification permission: $e');
      }
    }
  }

  /// Initialize Local Notifications Plugin
  static Future<void> _initializeLocalNotifications() async {
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(android: androidInitSettings, iOS: darwinInitSettings);

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        AppLogger.log('Foreground notification clicked: payload=${response.payload}', tag: 'NotificationHelper');
        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(response.payload!);
            onNotificationTapped?.call(data);
          } catch (_) {
            onNotificationTapped?.call({'payload': response.payload});
          }
        }
      },
    );
  }

  /// Creates notification channel for Android 8.0+ (required for Android 9, 10, 11, 12, 13+)
  static Future<void> _createNotificationChannel() async {
    final androidPlatform = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlatform != null) {
      await androidPlatform.createNotificationChannel(_highImportanceChannel);
      AppLogger.log('Created Android Notification Channel: ${_highImportanceChannel.id}', tag: 'NotificationHelper');
    }
  }

  /// Listen to foreground and background notification interactions
  static void _setupMessageListeners() {
    // 1. Foreground message listener:
    // Shows heads-up notification popup when app is open across all Android versions
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.log('Foreground FCM message received: ${message.messageId}', tag: 'NotificationHelper');
      showLocalNotification(message);
    });

    // 2. Notification clicked when app was in background (not killed)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.log(
        'Notification tapped from background state: ${message.messageId} | data: ${message.data}',
        tag: 'NotificationHelper',
      );
      onNotificationTapped?.call(message.data);
    });
  }

  /// Check if the app was opened from terminated state by clicking a notification
  static Future<void> _checkInitialNotification() async {
    try {
      final RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.log(
          'App opened from terminated state via notification: ${initialMessage.messageId}',
          tag: 'NotificationHelper',
        );
        onNotificationTapped?.call(initialMessage.data);
      }
    } catch (e) {
      AppLogger.log('Error checking initial notification: $e', tag: 'NotificationHelper');
    }
  }

  /// Show heads-up notification in foreground or for data-only messages
  static Future<void> showLocalNotification(RemoteMessage message) async {
    try {
      final RemoteNotification? notification = message.notification;
      final Map<String, dynamic> data = message.data;

      // Extract title and body from notification payload or fallback to data payload
      final String? title = notification?.title ?? data['title']?.toString();
      final String? body = notification?.body ?? data['body']?.toString();

      // Don't show empty notification
      if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
        return;
      }

      final int notificationId = message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

      final androidDetails = AndroidNotificationDetails(
        _highImportanceChannel.id,
        _highImportanceChannel.name,
        channelDescription: _highImportanceChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        styleInformation: body != null && body.isNotEmpty
            ? BigTextStyleInformation(body, contentTitle: title, htmlFormatBigText: true, htmlFormatContentTitle: true)
            : null,
      );

      const darwinDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _localNotifications.show(
        id: notificationId,
        title: title ?? 'Grid Photo Splitter',
        body: body ?? '',
        notificationDetails: platformChannelSpecifics,
        payload: jsonEncode(data),
      );
    } catch (e, stack) {
      AppLogger.log('Error displaying local notification: $e', tag: 'NotificationHelper', error: e, stackTrace: stack);
    }
  }

  /// Subscribe to a specific FCM topic (e.g. "all")
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      AppLogger.log('Successfully subscribed to topic: "$topic"', tag: 'NotificationHelper');
    } catch (e, stack) {
      AppLogger.log(
        'Failed to subscribe to topic "$topic": $e',
        tag: 'NotificationHelper',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Unsubscribe from a specific FCM topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      AppLogger.log('Successfully unsubscribed from topic: "$topic"', tag: 'NotificationHelper');
    } catch (e, stack) {
      AppLogger.log(
        'Failed to unsubscribe from topic "$topic": $e',
        tag: 'NotificationHelper',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Listen for FCM token refresh and re-subscribe to "all"
  static void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((newToken) async {
      AppLogger.log('FCM Token refreshed: $newToken', tag: 'NotificationHelper');
      // Re-subscribe to topic "all" whenever token is refreshed
      await subscribeToTopic(topicAll);
    });
  }

  /// Get current FCM Device Token
  static Future<String?> getDeviceToken() async {
    try {
      final String? token = await _messaging.getToken();
      if (token != null) {
        AppLogger.log('FCM Device Registration Token: $token', tag: 'NotificationHelper');
        if (kDebugMode) {
          debugPrint('====================================');
          debugPrint('FCM DEVICE TOKEN: $token');
          debugPrint('====================================');
        }
      }
      return token;
    } catch (e) {
      AppLogger.log('Error getting FCM device token: $e', tag: 'NotificationHelper');
      return null;
    }
  }
}
