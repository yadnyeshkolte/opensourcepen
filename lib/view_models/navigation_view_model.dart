import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_preferences.dart';

class NavigationViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  bool _softwareEnabled = false;

  NavigationViewModel() {
    _initializeNavigation();
  }

  Future<void> _initializeNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final appPrefs = AppPreferences(prefs);

    // Set software access based on onboarding completion
    _softwareEnabled = appPrefs.hasCompletedOnboarding();

    // Set initial tab based on default screen preference
    String defaultScreen = appPrefs.getDefaultScreen();
    if (defaultScreen == 'home') {
      _currentIndex = 0;
    } else {
      _currentIndex = 2; // Products screen
    }

    notifyListeners();
  }

  int get currentIndex => _currentIndex;
  bool get softwareEnabled => _softwareEnabled;

  void updateSoftwareAccess(bool hasCompletedOnboarding) {
    _softwareEnabled = hasCompletedOnboarding;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}