// lib/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_view_model.dart';
import '../services/app_preferences.dart';
import 'onboarding_view.dart';
import 'product_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const LoginForm(),
    );
  }
}

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final appPreferences = Provider.of<AppPreferences>(context, listen: false);
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    // Navigate to onboarding or product view if already logged in
    if (authViewModel.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (appPreferences.isFirstLaunch()) {
          // Navigate to onboarding on first launch
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OnboardingView(isRestart: false)),
          );
        } else {
          // Skip to product view on subsequent launches
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProductView()),
          );
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          if (authViewModel.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                authViewModel.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              final username = usernameController.text;
              final password = passwordController.text;
              authViewModel.login(username, password, appPreferences);

              // Navigate based on first launch
              if (authViewModel.isLoggedIn) {
                if (appPreferences.isFirstLaunch()) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const OnboardingView(isRestart: false)),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductView()),
                  );
                }
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text('Login'),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Default: username = admin, password = password',
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}