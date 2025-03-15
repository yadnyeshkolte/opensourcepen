// lib/models/onboarding_model.dart
import 'package:flutter/material.dart';

class OnboardingModel {
  final int index;
  final Color primaryColor;
  final Color secondaryColor;
  final String title;
  final String description;
  final String? assetPath; // For custom illustrations or icons

  OnboardingModel({
    required this.index,
    required this.primaryColor,
    required this.secondaryColor,
    required this.title,
    required this.description,
    this.assetPath,
  });
}