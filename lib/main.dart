// lib/main.dart
import 'package:flutter/material.dart';
import 'package:opensourcepen/view_models/navigation_view_model.dart';
import 'package:opensourcepen/views/main_layout.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view_models/auth_view_model.dart';
import 'view_models/onboarding_view_model.dart';
import 'view_models/product_view_model.dart';
import 'views/login_view.dart';
import 'services/app_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        ChangeNotifierProvider(create: (_) => NavigationViewModel()),
        Provider.value(value: appPreferences),
      ],
      child: MaterialApp(
        title: 'MVVM Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // Change initial route based on login history
        home: appPreferences!.isLoggedInBefore()
            ? _getInitialScreen(appPreferences!)
            : const LoginView(),
      ),
    );
  }
  Widget _getInitialScreen(AppPreferences prefs) {
    return const MainLayout();
  }
}