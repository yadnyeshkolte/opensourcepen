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
          // Animated background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  onboardingViewModel.currentScreen.color,
                  onboardingViewModel.currentScreen.color.withOpacity(0.7),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),
                    // Add an icon here
                    Icon(
                      _getIconForScreen(onboardingViewModel.currentIndex),
                      size: 100,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      onboardingViewModel.currentScreen.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      onboardingViewModel.currentScreen.description,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(flex: 2),

                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingViewModel.onboardingScreens.length,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: onboardingViewModel.currentIndex == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: onboardingViewModel.currentIndex == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),

          // Bottom navigation buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
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
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(fontSize: 16),
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
                    style: ElevatedButton.styleFrom(
                      foregroundColor: onboardingViewModel.currentScreen.color,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      onboardingViewModel.isLastScreen ? 'Get Started' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  // Helper method to get appropriate icons for each onboarding screen
  IconData _getIconForScreen(int index) {
    // You can customize these icons based on your onboarding content
    final List<IconData> icons = [
      Icons.start,
      Icons.explore,
      Icons.shopping_cart,
      Icons.check_circle_outline,
    ];

    // Return the icon if index is valid, otherwise return a default icon
    return index < icons.length ? icons[index] : Icons.info_outline;
  }
}