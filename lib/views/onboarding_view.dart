// lib/views/onboarding_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/onboarding_view_model.dart';
import '../services/app_preferences.dart';
import 'product_view.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingViewModel = Provider.of<OnboardingViewModel>(context);
    final appPreferences = Provider.of<AppPreferences>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          // Color background
          Container(
            color: onboardingViewModel.currentScreen.color,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    onboardingViewModel.currentScreen.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    onboardingViewModel.currentScreen.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${onboardingViewModel.currentIndex + 1}/${onboardingViewModel.onboardingScreens.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom navigation buttons
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      // Mark first launch as complete
                      await appPreferences.setFirstLaunchComplete();

                      // Navigate directly to product screen when Skip is pressed
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const ProductView()),
                        );
                      }
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (onboardingViewModel.isLastScreen) {
                        // Mark first launch as complete
                        await appPreferences.setFirstLaunchComplete();

                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const ProductView()),
                          );
                        }
                      } else {
                        onboardingViewModel.next();
                      }
                    },
                    child: Text(
                      onboardingViewModel.isLastScreen ? 'Finish' : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}