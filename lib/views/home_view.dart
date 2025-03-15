import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../services/app_preferences.dart';
import '../view_models/navigation_view_model.dart';
import 'onboarding_view.dart';
import 'login_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final appPreferences = Provider.of<AppPreferences>(context, listen: false);
    final navigationViewModel = Provider.of<NavigationViewModel>(context);
    final bool onboardingCompleted = appPreferences.hasCompletedOnboarding();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart Onboarding',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingView(isRestart: true)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authViewModel.logout(appPreferences);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
          ),
        ],
      ),
      body: onboardingCompleted
          ? const Center(child: Text('Welcome to the Home Screen'))
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Please complete onboarding to access all features'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OnboardingView(isRestart: false)),
                );
              },
              child: const Text('Start Onboarding'),
            ),
          ],
        ),
      ),
    );
  }
}