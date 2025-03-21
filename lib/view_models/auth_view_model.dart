import 'package:flutter/material.dart';
import '../services/app_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _errorMessage = '';

  bool get isLoggedIn => _isLoggedIn;
  String get errorMessage => _errorMessage;

  void login(String username, String password, AppPreferences appPreferences) {
    // Simple hardcoded authentication
    if (username == 'admin' && password == 'password') {
      _isLoggedIn = true;
      _errorMessage = '';
      // Mark as logged in before
      appPreferences.setLoggedInBefore();
    } else {
      _errorMessage = 'Invalid username or password';
    }
    notifyListeners();
  }

  void logout(AppPreferences appPreferences) async {
    _isLoggedIn = false;
    // Reset the logged in status in shared preferences
    await appPreferences.resetLoggedInStatus();
    notifyListeners();
  }
}
