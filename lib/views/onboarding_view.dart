// lib/views/onboarding_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/navigation_view_model.dart';
import '../view_models/onboarding_view_model.dart';
import '../services/app_preferences.dart';
import 'main_layout.dart';

class OnboardingView extends StatelessWidget {
  final bool isRestart;

  const OnboardingView({super.key, required this.isRestart});

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
                      if (isRestart) {
                        // If restarting onboarding and skipping, maintain existing access
                        await appPreferences.setDefaultScreen('products');
                        // KEEP onboarding completion status as true since they're just skipping a restart
                        await appPreferences.setOnboardingCompleted(true);
                      } else {
                        // First-time onboarding and skipping
                        await appPreferences.setDefaultScreen('products');

                        // Check if onboarding was completed before
                        bool wasCompletedBefore = appPreferences.hasCompletedOnboarding();
                        // Only set to false if this is truly the first time
                        if (!wasCompletedBefore) {
                          await appPreferences.setOnboardingCompleted(false);
                        }
                      }
                      await appPreferences.setFirstLaunchComplete();

                      // Update Navigation ViewModel with correct software access
                      // This should be based on whether onboarding was completed before OR if this is a restart
                      Provider.of<NavigationViewModel>(context, listen: false)
                          .updateSoftwareAccess(isRestart || appPreferences.hasCompletedOnboarding());

                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MainLayout()),
                        );
                      }
                    },
                    child: const Text('Skip', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (onboardingViewModel.isLastScreen) {
                        // Completed onboarding, set Home as default
                        await appPreferences.setDefaultScreen('home');
                        await appPreferences.setFirstLaunchComplete();
                        await appPreferences.setOnboardingCompleted(true);

                        // Update software access
                        Provider.of<NavigationViewModel>(context, listen: false)
                            .updateSoftwareAccess(true);

                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainLayout()),
                          );
                        }
                      } else {
                        onboardingViewModel.next();
                      }
                    },
                    child: Text(onboardingViewModel.isLastScreen ? 'Finish' : 'Next'),
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