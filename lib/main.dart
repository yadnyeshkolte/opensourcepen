// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/onboarding_view_model.dart';
import 'view_models/product_view_model.dart';
import 'views/login_view.dart';
import 'services/app_preferences.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  final appPreferences = AppPreferences(prefs);

  runApp(MyApp(appPreferences: appPreferences));
}

class MyApp extends StatelessWidget {
  final AppPreferences? appPreferences;
  const MyApp({super.key, this.appPreferences});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => OnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        // Provide app preferences to the widget tree
        Provider.value(value: appPreferences),
      ],
      child: MaterialApp(
        title: 'MVVM Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const LoginView(),
      ),
    );
  }
}