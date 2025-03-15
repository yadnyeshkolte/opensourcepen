// lib/views/onboarding_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
  late PageController _pageController;
  late AnimationController _animationController;
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void setCurrentIndex(int index, int _currentIndex) {
    _currentIndex = index;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingViewModel = Provider.of<OnboardingViewModel>(context);
    final appPreferences = Provider.of<AppPreferences>(context, listen: false);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated background gradient
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
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

          // Decorative elements
          Positioned(
            top: -size.height * 0.2,
            right: -size.width * 0.2,
            child: Opacity(
              opacity: 0.15,
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // App logo or brand
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Image.asset(
                    'assets/icon/icon.png', // Replace with your actual logo
                    height: 50,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.app_shortcut,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),

                // 3D Model or Lottie Animation
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: _build3DModel('assets/models/whitepen.glb'),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  flex: 3,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingViewModel.onboardingScreens.length,
                    onPageChanged: (index) {
                      // Let the onboarding view model handle the page change
                      if (index > onboardingViewModel.currentIndex) {
                        onboardingViewModel.next();
                      } else if (index < onboardingViewModel.currentIndex) {
                        onboardingViewModel.previous();
                      }
                    },
                    itemBuilder: (context, index) {
                      final screen = onboardingViewModel.onboardingScreens[index];
                      // Calculate opacity based on page position
                      final opacity = 1.0 - (_currentPage - index).abs();

                      return Opacity(
                        opacity: opacity.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - opacity.clamp(0.0, 1.0))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              children: [
                                Text(
                                  screen.title,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  screen.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Page indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: onboardingViewModel.onboardingScreens.length,
                    effect: ExpandingDotsEffect(
                      dotColor: Colors.white.withOpacity(0.4),
                      activeDotColor: Colors.white,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                    ),
                  ),
                ),

                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      TextButton(
                        onPressed: () async {
                          _handleSkip(context, onboardingViewModel, appPreferences);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Next/Finish button
                      ElevatedButton(
                        onPressed: () async {
                          if (onboardingViewModel.isLastScreen) {
                            _completeOnboarding(context, appPreferences);
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: onboardingViewModel.currentScreen.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 2,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DModel(String assetPath) {
    return ModelViewer(
      src: assetPath,
      alt: "A 3D model",
      ar: false,
      autoRotate: true,
      cameraControls: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _handleSkip(
      BuildContext context,
      OnboardingViewModel onboardingViewModel,
      AppPreferences appPreferences,
      ) async {
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
  }

  Future<void> _completeOnboarding(
      BuildContext context,
      AppPreferences appPreferences,
      ) async {
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
  }

  void notifyListeners() {}
}