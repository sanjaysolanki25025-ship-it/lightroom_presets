import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  // Singleton instance
  static final AppPreferences _instance = AppPreferences._internal();

  // Factory constructor
  factory AppPreferences() {
    return _instance;
  }

  // Private constructor
  AppPreferences._internal();

  // SharedPreferences instance
  SharedPreferences? _preferences;

  // Keys for shared preferences
  static const String onboarding = "onboarding";
  static const String fcm = "fcm";
  static const String coin = "coin";
  static const String premiumTemplate = "premium_template";
  static const String countrySelection = "country_selection";
  static const String loadMore = "load_more";
  static const String onBackPress = "on_back_press";
  static const String slotMachineShowcase = "slot_machine_showcase";
  static const String swipeUp = "swipe_up";
  static const String selectCountry = "country";
  static const String instagramFollow = "instagram_follow";
  static const String joinTelegram = "join_telegram";
  static const String subscriptionPlan = "subscription_plan";
  static const String planType = "plan_type";
  static const String categoryTap = "category_tap";
  static const String openAppCount = "open_app_count";

  // Initialize SharedPreferences
  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Save a string value
  Future<void> setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  // // Get a string value
  String? getString(String key) {
    return _preferences?.getString(key);
  }

  // // Get a int value
  int? getInt(String key) {
    return _preferences?.getInt(key);
  }

  // Save a boolean value
  Future<void> setBool(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  // Save a int value
  Future<void> setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  // Get a boolean value
  bool? getBool(String key) {
    return _preferences?.getBool(key);
  }

  // Save a boolean value
  Future<void> setDouble(String key, double value) async {
    await _preferences?.setDouble(key, value);
  }

  // Get a boolean value
  double? getDouble(String key) {
    return _preferences?.getDouble(key);
  }

  // Save a list of strings
  Future<void> setStringList(String key, List<String> value) async {
    await _preferences?.setStringList(key, value);
  }

  // Get a list of strings
  List<String>? getStringList(String key) {
    return _preferences?.getStringList(key);
  }
}
