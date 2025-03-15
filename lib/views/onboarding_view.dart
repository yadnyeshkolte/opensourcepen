// lib/views/onboarding_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'dart:math' as math;
import '../view_models/navigation_view_model.dart';
import '../view_models/onboarding_view_model.dart';
import '../services/app_preferences.dart';
import 'main_layout.dart';

class OnboardingView extends StatefulWidget {
  final bool isRestart;

  const OnboardingView({super.key, required this.isRestart});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Object? _object;
  late Scene _scene;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSceneCreated(Scene scene) {
    _scene = scene;
    _scene.camera.position.z = 0.9;
    _scene.light.position.setFrom(Vector3(0, 10, 10));
    _scene.light.setColor(Colors.white, 1.0, 1.0, 1.0);

    // Load your OBJ file
    _object = Object(
      fileName: 'assets/cube/cube.obj',
      lighting: true,
      isAsset: true,
    );
    _object!.rotation.setValues(0, 0, 0);
    _object!.updateTransform();
    _scene.world.add(_object!);

    // Start continuous rotation animation
    _startAnimation();

    // Notify view model that model is loaded
    final onboardingViewModel = Provider.of<OnboardingViewModel>(context, listen: false);
    onboardingViewModel.setModelLoaded(true);
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 16), () {
      if (_object != null && mounted) {
        setState(() {
          _object!.rotation.y += 0.01;
          _object!.updateTransform();
        });
        _startAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboardingViewModel = Provider.of<OnboardingViewModel>(context);
    final appPreferences = Provider.of<AppPreferences>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              // Gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      onboardingViewModel.currentScreen.primaryColor,
                      onboardingViewModel.currentScreen.secondaryColor,
                    ],
                  ),
                ),
              ),

              // Background patterns (circles)
              Positioned(
                top: -screenSize.height * 0.1,
                right: -screenSize.width * 0.2,
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    width: screenSize.width * 0.7,
                    height: screenSize.width * 0.7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: OnboardingViewModel.white,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: -screenSize.height * 0.1,
                left: -screenSize.width * 0.1,
                child: Opacity(
                  opacity: 0.08,
                  child: Container(
                    width: screenSize.width * 0.5,
                    height: screenSize.width * 0.5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: OnboardingViewModel.white,
                    ),
                  ),
                ),
              ),

              // Content
              Column(
                children: [
                  // 3D model view
                  SizedBox(
                    height: screenSize.height * 0.5,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - _animation.value)),
                      child: Opacity(
                        opacity: _animation.value,
                        child: Cube(onSceneCreated: _onSceneCreated),
                      ),
                    ),
                  ),

                  // Content area
                  Expanded(
                    child: Transform.translate(
                      offset: Offset(screenSize.width * 0.5 * (1 - _animation.value), 0),
                      child: Opacity(
                        opacity: _animation.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                onboardingViewModel.currentScreen.title,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: OnboardingViewModel.white,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                onboardingViewModel.currentScreen.description,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: OnboardingViewModel.white,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Page indicator
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingViewModel.onboardingScreens.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: onboardingViewModel.currentIndex == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: onboardingViewModel.currentIndex == index
                                ? OnboardingViewModel.white
                                : OnboardingViewModel.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom buttons
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 48.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () async {
                            if (widget.isRestart) {
                              await appPreferences.setDefaultScreen('products');
                              await appPreferences.setOnboardingCompleted(true);
                            } else {
                              await appPreferences.setDefaultScreen('products');
                              bool wasCompletedBefore = appPreferences.hasCompletedOnboarding();
                              if (!wasCompletedBefore) {
                                await appPreferences.setOnboardingCompleted(false);
                              }
                            }
                            await appPreferences.setFirstLaunchComplete();

                            Provider.of<NavigationViewModel>(context, listen: false)
                                .updateSoftwareAccess(widget.isRestart || appPreferences.hasCompletedOnboarding());

                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const MainLayout()),
                              );
                            }
                          },
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: OnboardingViewModel.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            // Previous button (visible if not on first screen)
                            if (onboardingViewModel.currentIndex > 0)
                              Container(
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: OnboardingViewModel.white.withOpacity(0.2),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back, color: OnboardingViewModel.white),
                                  onPressed: () {
                                    _animationController.reset();
                                    onboardingViewModel.previous();
                                    _animationController.forward();
                                  },
                                ),
                              ),
                            // Next/Get Started button
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (onboardingViewModel.isLastScreen) {
                                    await appPreferences.setDefaultScreen('home');
                                    await appPreferences.setFirstLaunchComplete();
                                    await appPreferences.setOnboardingCompleted(true);

                                    Provider.of<NavigationViewModel>(context, listen: false)
                                        .updateSoftwareAccess(true);

                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const MainLayout()),
                                      );
                                    }
                                  } else {
                                    // Animate transition
                                    _animationController.reset();
                                    onboardingViewModel.next();
                                    _animationController.forward();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: OnboardingViewModel.white,
                                  foregroundColor: onboardingViewModel.currentScreen.primaryColor,
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
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}