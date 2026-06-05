import 'package:facebook_app_events/facebook_app_events.dart';

class MetaService {
  static final FacebookAppEvents _events = FacebookAppEvents();

  static Future<void> init() async {
    await _events.setAdvertiserTracking(enabled: true);
  }
}
