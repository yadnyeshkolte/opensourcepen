import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';

class OnboardingViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  final List<OnboardingModel> _onboardingScreens = [
    OnboardingModel(
      index: 0,
      color: const Color(0xFF00BFFF), // Deep Sky Blue
      title: 'Welcome',
      description: 'Discover our powerful and intuitive app designed to enhance your experience',
    ),
    OnboardingModel(
      index: 1,
      color: const Color(0xFF1E90FF), // Dodger Blue
      title: 'Simple & Intuitive',
      description: 'Navigate with ease through our clean and user-friendly interface',
    ),
    OnboardingModel(
      index: 2,
      color: const Color(0xFF4682B4), // Steel Blue
      title: 'Powerful Features',
      description: 'Access advanced tools and capabilities designed to boost your productivity',
    ),
    OnboardingModel(
      index: 3,
      color: const Color(0xFF6495ED), // Cornflower Blue
      title: 'Customizable',
      description: 'Personalize your experience to match your unique preferences and workflow',
    ),
    OnboardingModel(
      index: 4,
      color: const Color(0xFF87CEEB), // Sky Blue
      title: 'Ready to Start',
      description: 'Begin your journey and explore everything our app has to offer',
    ),
  ];

  int get currentIndex => _currentIndex;
  List<OnboardingModel> get onboardingScreens => _onboardingScreens;
  OnboardingModel get currentScreen => _onboardingScreens[_currentIndex];
  bool get isLastScreen => _currentIndex == _onboardingScreens.length - 1;

  void next() {
    if (_currentIndex < _onboardingScreens.length - 1) {
      _currentIndex++;
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