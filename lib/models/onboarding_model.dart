import 'dart:ui';

class OnboardingModel {
  final int index;
  final Color primaryColor;
  final Color secondaryColor;
  final String title;
  final String description;
  final String assetPath;

  OnboardingModel({
    required this.index,
    required this.primaryColor,
    required this.secondaryColor,
    required this.title,
    required this.description,
    required this.assetPath,
  });
}