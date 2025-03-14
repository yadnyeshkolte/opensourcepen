import 'package:flutter/material.dart';
import '../models/onboarding_model.dart';

class OnboardingViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  final List<OnboardingModel> _onboardingScreens = [
    OnboardingModel(
      index: 0,
      color: Colors.red,
      title: 'Red Screen',
      description: 'This is the first color screen',
    ),
    OnboardingModel(
      index: 1,
      color: Colors.blue,
      title: 'Blue Screen',
      description: 'This is the second color screen',
    ),
    OnboardingModel(
      index: 2,
      color: Colors.green,
      title: 'Green Screen',
      description: 'This is the third color screen',
    ),
    OnboardingModel(
      index: 3,
      color: Colors.yellow,
      title: 'Yellow Screen',
      description: 'This is the fourth color screen',
    ),
    OnboardingModel(
      index: 4,
      color: Colors.purple,
      title: 'Purple Screen',
      description: 'This is the fifth color screen',
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
