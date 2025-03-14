// lib/services/app_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final SharedPreferences _preferences;
  static const String _isFirstLaunchKey = 'is_first_launch';

  AppPreferences(this._preferences);

  bool isFirstLaunch() {
    // If the key doesn't exist, it means it's the first launch
    return _preferences.getBool(_isFirstLaunchKey) ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    await _preferences.setBool(_isFirstLaunchKey, false);
  }

  Future<void> resetFirstLaunch() async {
    await _preferences.setBool(_isFirstLaunchKey, true);
  }

  static const String _isLoggedInBeforeKey = 'is_logged_in_before';

  bool isLoggedInBefore() {
    return _preferences.getBool(_isLoggedInBeforeKey) ?? false;
  }

  Future<void> setLoggedInBefore() async {
    await _preferences.setBool(_isLoggedInBeforeKey, true);
  }

  Future<void> resetLoggedInStatus() async {
    await _preferences.setBool(_isLoggedInBeforeKey, false);
  }

  static const String _completedOnboardingKey = 'completed_onboarding';
  static const String _defaultScreenKey = 'default_screen';

  bool hasCompletedOnboarding() {
    return _preferences.getBool(_completedOnboardingKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await _preferences.setBool(_completedOnboardingKey, completed);
  }

  String getDefaultScreen() {
    return _preferences.getString(_defaultScreenKey) ?? 'products';
  }

  Future<void> setDefaultScreen(String screen) async {
    await _preferences.setString(_defaultScreenKey, screen);
  }
}