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
  int _previousIndex = 0;
  bool _isForward = true;
  bool _isOutAnimation = false;

  // Camera position variables for transitions
  late Vector3 _startCameraPosition;
  late Vector3 _targetCameraPosition;
  late Vector3 _startObjectRotation;
  late Vector3 _targetObjectRotation;
  bool _isCameraAnimating = false;

  // For smooth background color transitions
  Color _prevPrimaryColor = Colors.transparent;
  Color _prevSecondaryColor = Colors.transparent;
  Color _currentPrimaryColor = Colors.transparent;
  Color _currentSecondaryColor = Colors.transparent;

  // Define different views for each onboarding screen
  final List<Map<String, dynamic>> _modelViews = [
    {
      'camera': Vector3(1, 1, 0),
      'rotation': Vector3(0, 0, 0),
      'zoom': 1.8,
    },
    {
      'camera': Vector3(0.5, 0.3, 0.9),
      'rotation': Vector3(math.pi / 6, math.pi / 4, 0),
      'zoom': 1.2,
    },
    {
      'camera': Vector3(-0.3, -0.2, 0.9),
      'rotation': Vector3(-math.pi / 8, -math.pi / 3, math.pi / 10),
      'zoom': 0.9,
    },
    {
      'camera': Vector3(0.1, 0.5, 0.9),
      'rotation': Vector3(math.pi / 4, 0, math.pi / 6),
      'zoom': 1.1,
    },
    {
      'camera': Vector3(0, 1, 0),
      'rotation': Vector3(0, 0, 0),
      'zoom': 1.1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    // Initialize camera positions
    _startCameraPosition = Vector3(0, 0, 0.9);
    _targetCameraPosition = Vector3(0, 0, 0.9);
    _startObjectRotation = Vector3(0, 0, 0);
    _targetObjectRotation = Vector3(0, 0, 0);

    // Initialize colors after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onboardingViewModel = Provider.of<OnboardingViewModel>(context, listen: false);
      _previousIndex = onboardingViewModel.currentIndex;

      // Initialize background colors
      _currentPrimaryColor = onboardingViewModel.currentScreen.primaryColor;
      _currentSecondaryColor = onboardingViewModel.currentScreen.secondaryColor;
      _prevPrimaryColor = _currentPrimaryColor;
      _prevSecondaryColor = _currentSecondaryColor;

      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onSceneCreated(Scene scene) {
    _scene = scene;

    // Set initial camera position
    _scene.camera.position.setFrom(_modelViews[0]['camera']);

    _scene.light.position.setFrom(Vector3(0, 10, 10));
    _scene.light.setColor(Colors.white, 1.0, 1.0, 1.0);

    // Load your OBJ file
    _object = Object(
      fileName: 'assets/cube/cube.obj',
      lighting: true,
      isAsset: true,
    );
    _object!.rotation.setFrom(_modelViews[0]['rotation']);
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
          if (!_isCameraAnimating) {
            // Apply gentle continuous rotation when not transitioning between screens
            _object!.rotation.y += 0.005;
            _object!.updateTransform();
          } else {
            // Animate camera and object during screen transitions
            _animateCameraAndObject();
          }
        });
        _startAnimation();
      }
    });
  }

  void _animateCameraAndObject() {
    // Get current animation progress
    double progress = _animationController.value;

    Vector3 _lerpVector3(Vector3 a, Vector3 b, double t) {
      return Vector3(
        a.x + (b.x - a.x) * t,  // Interpolate x coordinate
        a.y + (b.y - a.y) * t,  // Interpolate y coordinate
        a.z + (b.z - a.z) * t,  // Interpolate z coordinate
      );
    }
    // Interpolate camera position
    Vector3 interpolatedCameraPosition = _lerpVector3(
        _startCameraPosition,
        _targetCameraPosition,
        Curves.easeInOutCubic.transform(progress)
    );
    _scene.camera.position.setFrom(interpolatedCameraPosition);

    // Interpolate object rotation
    Vector3 interpolatedRotation = _lerpVector3(
        _startObjectRotation,
        _targetObjectRotation,
        Curves.easeInOutCubic.transform(progress)
    );
    _object!.rotation.setFrom(interpolatedRotation);
    _object!.updateTransform();

    // Update scene
    _scene.update();
  }

  // Get interpolated colors based on animation value
  Color _getInterpolatedColor(Color color1, Color color2, double value) {
    return Color.lerp(color1, color2, value)!;
  }

  void _updateModelView(int screenIndex) {
    // Ensure we have a view for this index
    int safeIndex = math.min(screenIndex, _modelViews.length - 1);

    _isCameraAnimating = true;

    // Store current positions
    _startCameraPosition = Vector3(
        _scene.camera.position.x,
        _scene.camera.position.y,
        _scene.camera.position.z
    );
    _targetCameraPosition = _modelViews[safeIndex]['camera'];

    _startObjectRotation = Vector3(
        _object!.rotation.x,
        _object!.rotation.y,
        _object!.rotation.z
    );
    _targetObjectRotation = _modelViews[safeIndex]['rotation'];
  }

  Future<void> _goToNextScreen(OnboardingViewModel viewModel, AppPreferences appPreferences) async {
    if (viewModel.isLastScreen) {
      // Keep the original completion logic
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
      // Store current colors before transition
      _prevPrimaryColor = viewModel.currentScreen.primaryColor;
      _prevSecondaryColor = viewModel.currentScreen.secondaryColor;

      // Update direction flag and previous index
      _isForward = true;
      _previousIndex = viewModel.currentIndex;

      // Set that we're doing an out animation
      _isOutAnimation = true;

      // Animate current content out
      await _animationController.reverse();

      // Reset for in animation
      _isOutAnimation = false;

      // Change to next screen
      viewModel.next();

      // Update the 3D model view for the next screen
      _updateModelView(viewModel.currentIndex);

      // Update target colors for the transition
      _currentPrimaryColor = viewModel.currentScreen.primaryColor;
      _currentSecondaryColor = viewModel.currentScreen.secondaryColor;

      // Animate new content in
      _animationController.forward().then((_) {
        // Animation completed
        _isCameraAnimating = false;
      });
    }
  }

  Future<void> _goToPreviousScreen(OnboardingViewModel viewModel) async {
    // Store current colors before transition
    _prevPrimaryColor = viewModel.currentScreen.primaryColor;
    _prevSecondaryColor = viewModel.currentScreen.secondaryColor;

    // Update direction flag and previous index
    _isForward = false;
    _previousIndex = viewModel.currentIndex;

    // Set that we're doing an out animation
    _isOutAnimation = true;

    // Animate current content out
    await _animationController.reverse();

    // Reset for in animation
    _isOutAnimation = false;

    // Go to previous screen
    viewModel.previous();

    // Update the 3D model view for the previous screen
    _updateModelView(viewModel.currentIndex);

    // Update target colors for the transition
    _currentPrimaryColor = viewModel.currentScreen.primaryColor;
    _currentSecondaryColor = viewModel.currentScreen.secondaryColor;

    // Animate new content in
    _animationController.forward().then((_) {
      // Animation completed
      _isCameraAnimating = false;
    });
  }

  Future<void> _skipOnboarding(AppPreferences appPreferences) async {
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

  @override
  Widget build(BuildContext context) {
    final onboardingViewModel = Provider.of<OnboardingViewModel>(context);
    final appPreferences = Provider.of<AppPreferences>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Calculate interpolated colors for smooth transition
          final primaryColor = _getInterpolatedColor(_prevPrimaryColor, _currentPrimaryColor, _animation.value);
          final secondaryColor = _getInterpolatedColor(_prevSecondaryColor, _currentSecondaryColor, _animation.value);

          return Stack(
            children: [
              // Gradient background with animated colors
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor,
                      secondaryColor,
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
                    child: Cube(onSceneCreated: _onSceneCreated),
                  ),

                  Expanded(
                    child: Transform.translate(
                      // Animation starts from edge of screen based on navigation direction
                      offset: Offset(
                          screenSize.width * (
                              _isOutAnimation
                                  ? (_isForward
                                  ? (_animation.value - 1.0) // Going out to left when going forward
                                  : (1.0 - _animation.value)) // Going out to right when going backward
                                  : (_isForward
                                  ? (1.0 - _animation.value) // Coming in from right when going forward
                                  : (_animation.value - 1.0)) // Coming in from left when going backward
                          ),
                          0
                      ),
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
                          onPressed: () => _skipOnboarding(appPreferences),
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
                                  onPressed: () => _goToPreviousScreen(onboardingViewModel),
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
                                onPressed: () => _goToNextScreen(onboardingViewModel, appPreferences),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: OnboardingViewModel.white,
                                  foregroundColor: primaryColor, // Use interpolated color
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