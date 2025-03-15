// lib/view_models/onboarding_view_model.dart
import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';

class OnboardingViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isModelLoaded = false;

  // Your specified color palette
  static const Color white = Color(0xFFFFFFFF);
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color steelBlue = Color(0xFF4682B4);
  static const Color dodgerBlue = Color(0xFF1E90FF);
  static const Color deepSkyBlue = Color(0xFF00BFFF);
  static const Color cornflowerBlue = Color(0xFF6495ED);

  final List<OnboardingModel> _onboardingScreens = [
    OnboardingModel(
      index: 0,
      primaryColor: steelBlue,
      secondaryColor: skyBlue,
      title: 'Welcome to Our App',
      description: 'Discover a new way to explore and interact with our platform',
      assetPath: 'assets/animations/welcome.json',
    ),
    OnboardingModel(
      index: 1,
      primaryColor: dodgerBlue,
      secondaryColor: deepSkyBlue,
      title: 'Powerful Features',
      description: 'Access a wide range of tools designed to enhance your experience',
      assetPath: 'assets/animations/features.json',
    ),
    OnboardingModel(
      index: 2,
      primaryColor: cornflowerBlue,
      secondaryColor: skyBlue,
      title: 'Seamless Integration',
      description: 'Connect with your favorite services and apps effortlessly',
      assetPath: 'assets/animations/integration.json',
    ),
    OnboardingModel(
      index: 3,
      primaryColor: deepSkyBlue,
      secondaryColor: steelBlue,
      title: 'Personalized Experience',
      description: 'Customize your settings to match your preferences and workflow',
      assetPath: 'assets/animations/personalize.json',
    ),
    OnboardingModel(
      index: 4,
      primaryColor: dodgerBlue,
      secondaryColor: cornflowerBlue,
      title: 'Ready to Start',
      description: 'Your journey begins now. Let\'s get started!',
      assetPath: 'assets/animations/start.json',
    ),
  ];

  int get currentIndex => _currentIndex;
  List<OnboardingModel> get onboardingScreens => _onboardingScreens;
  OnboardingModel get currentScreen => _onboardingScreens[_currentIndex];
  bool get isLastScreen => _currentIndex == _onboardingScreens.length - 1;
  bool get isModelLoaded => _isModelLoaded;

  void setModelLoaded(bool loaded) {
    _isModelLoaded = loaded;
    notifyListeners();
  }

  void next() {
    if (_currentIndex < _onboardingScreens.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previous() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void skip() {
    _currentIndex = _onboardingScreens.length - 1;
    notifyListeners();
  }

  void resetOnboarding() {
    _currentIndex = 0;
    notifyListeners();
  }
}