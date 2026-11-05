import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void log(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final String prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
      if (error != null) {
        debugPrint('$prefix Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('$prefix StackTrace: $stackTrace');
      }
    }
  }
}

