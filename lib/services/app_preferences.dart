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
}