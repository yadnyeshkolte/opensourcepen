import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _errorMessage = '';

  bool get isLoggedIn => _isLoggedIn;
  String get errorMessage => _errorMessage;

  void login(String username, String password) {
    // Simple hardcoded authentication
    if (username == 'admin' && password == 'password') {
      _isLoggedIn = true;
      _errorMessage = '';
    } else {
      _errorMessage = 'Invalid username or password';
    }
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
