// lib/views/onboarding_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'dart:math' as math;
import 'dart:async';
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
  late Timer _rotationTimer;
  bool _isModelLoaded = false;

  // Camera position variables for transitions
  final Vector3 _startCameraPosition = Vector3(0, 0, 0.9);
  final Vector3 _targetCameraPosition = Vector3(0, 0, 0.9);
  final Vector3 _startObjectRotation = Vector3(0, 0, 0);
  final Vector3 _targetObjectRotation = Vector3(0, 0, 0);
  bool _isCameraAnimating = false;

  // Reusable vector objects for interpolation to avoid allocations
  final Vector3 _cameraPositionCache = Vector3(0, 0, 0);
  final Vector3 _objectRotationCache = Vector3(0, 0, 0);

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
      'camera': Vector3(0, 1, 1),
      'rotation': Vector3(0, 0, 0),
      'zoom': 1.1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), //for debug make it 1000
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    // Add listener for camera animation updates
    _animationController.addListener(_updateCameraAndObjectPosition);

    // Initialize rotation timer (will effectively start when object is loaded)
    _rotationTimer = Timer.periodic(const Duration(milliseconds: 16), _updateRotation);

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
    _rotationTimer.cancel();
    _animationController.removeListener(_updateCameraAndObjectPosition);
    _animationController.dispose();
    super.dispose();
  }

  void _updateRotation(Timer timer) {
    if (_object != null && mounted && !_isCameraAnimating && _isModelLoaded) {
      setState(() {
        _object!.rotation.y += 0.005;
        _object!.updateTransform();
      });
    }
  }

  void _onSceneCreated(Scene scene) {
    _scene = scene;

    // Set initial camera position
    _scene.camera.position.setFrom(_modelViews[0]['camera']);
    _scene.light.position.setFrom(Vector3(0, 10, 10));
    _scene.light.setColor(Colors.white, 1.0, 1.0, 1.0);

    // Load object in a non-blocking way
    Future(() {
      if (!mounted) return;

      _object = Object(
        fileName: 'assets/cube/cube.obj',
        lighting: true,
        isAsset: true,
      );
      _object!.rotation.setFrom(_modelViews[0]['rotation']);
      _object!.updateTransform();

      if (mounted) {
        setState(() {
          _scene.world.add(_object!);
          _isModelLoaded = true;

          // Notify view model that model is loaded
          final onboardingViewModel = Provider.of<OnboardingViewModel>(context, listen: false);
          onboardingViewModel.setModelLoaded(true);
        });
      }
    });
  }

  void _updateCameraAndObjectPosition() {
    if (!_isCameraAnimating || _object == null || !mounted) return;

    // Get current animation progress
    double progress = _animationController.value;
    double easedProgress = Curves.easeInOutCubic.transform(progress);

    // Interpolate camera position using cached Vector3
    _lerpVector3(_startCameraPosition, _targetCameraPosition, easedProgress, _cameraPositionCache);
    _scene.camera.position.setFrom(_cameraPositionCache);

    // Interpolate object rotation using cached Vector3
    _lerpVector3(_startObjectRotation, _targetObjectRotation, easedProgress, _objectRotationCache);
    _object!.rotation.setFrom(_objectRotationCache);
    _object!.updateTransform();

    // Update scene
    _scene.update();
  }

  // Optimized method that uses an existing vector instead of creating a new one
  void _lerpVector3(Vector3 a, Vector3 b, double t, Vector3 result) {
    result.x = a.x + (b.x - a.x) * t;
    result.y = a.y + (b.y - a.y) * t;
    result.z = a.z + (b.z - a.z) * t;
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
    _startCameraPosition.setFrom(_scene.camera.position);
    _targetCameraPosition.setFrom(_modelViews[safeIndex]['camera']);

    _startObjectRotation.setFrom(Vector3(
      _object?.rotation.x ?? 0,
      _object?.rotation.y ?? 0,
      _object?.rotation.z ?? 0,
    ));
    _targetObjectRotation.setFrom(_modelViews[safeIndex]['rotation']);
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

  // Calculate content offset for animation
  Offset _calculateContentOffset(Size screenSize) {
    if (_isOutAnimation) {
      return Offset(
          screenSize.width * (_isForward ? (_animation.value - 1.0) : (1.0 - _animation.value)),
          0
      );
    } else {
      return Offset(
          screenSize.width * (_isForward ? (1.0 - _animation.value) : (_animation.value - 1.0)),
          0
      );
    }
  }

  // Build background patterns
  Widget _buildBackgroundPatterns(Size screenSize) {
    return Stack(
      children: [
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
      ],
    );
  }

  // Build content widget
  Widget _buildContentWidget(OnboardingViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            viewModel.currentScreen.title,
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
            viewModel.currentScreen.description,
            style: const TextStyle(
              fontSize: 18,
              color: OnboardingViewModel.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build page indicator
  Widget _buildPageIndicator(OnboardingViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          viewModel.onboardingScreens.length,
              (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: viewModel.currentIndex == index ? 24 : 8,
            decoration: BoxDecoration(
              color: viewModel.currentIndex == index
                  ? OnboardingViewModel.white
                  : OnboardingViewModel.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

// Build bottom buttons
  Widget _buildBottomButtons(OnboardingViewModel viewModel, AppPreferences appPreferences) {
    return Padding(
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
              if (viewModel.currentIndex > 0)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: OnboardingViewModel.white.withOpacity(0.2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: OnboardingViewModel.white),
                    onPressed: () => _goToPreviousScreen(viewModel),
                  ),
                ),
              // Next/Get Started button
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final primaryColor = _getInterpolatedColor(
                      _prevPrimaryColor,
                      _currentPrimaryColor,
                      _animation.value
                  );

                  return Container(
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
                      onPressed: () => _goToNextScreen(viewModel, appPreferences),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OnboardingViewModel.white,
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        viewModel.isLastScreen ? 'Get Started' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build 3D model with loading indicator
  Widget _build3DModel(Size screenSize) {
    return SizedBox(
      height: screenSize.height * 0.5,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Use RepaintBoundary to isolate complex rendering
          RepaintBoundary(
            child: Cube(onSceneCreated: _onSceneCreated),
          ),

          // Show loading indicator while model loads
          if (!_isModelLoaded)
            const Center(
              child: CircularProgressIndicator(
                color: OnboardingViewModel.white,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardingViewModel = Provider.of<OnboardingViewModel>(context);
    final appPreferences = Provider.of<AppPreferences>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background with animated colors
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final primaryColor = _getInterpolatedColor(
                  _prevPrimaryColor,
                  _currentPrimaryColor,
                  _animation.value
              );
              final secondaryColor = _getInterpolatedColor(
                  _prevSecondaryColor,
                  _currentSecondaryColor,
                  _animation.value
              );

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [primaryColor, secondaryColor],
                  ),
                ),
              );
            },
          ),

          // Background patterns (circles) - won't rebuild with animations
          _buildBackgroundPatterns(screenSize),

          // Content column with optimized rebuilds
          Column(
            children: [
              // 3D model view
              _build3DModel(screenSize),

              // Content with optimized animation
              Expanded(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) => Transform.translate(
                    offset: _calculateContentOffset(screenSize),
                    child: Opacity(
                      opacity: _animation.value,
                      child: child,
                    ),
                  ),
                  child: _buildContentWidget(onboardingViewModel),
                ),
              ),

              // Page indicator - doesn't need to rebuild with animation
              _buildPageIndicator(onboardingViewModel),

              // Bottom navigation buttons
              _buildBottomButtons(onboardingViewModel, appPreferences),
            ],
          ),
        ],
      ),
    );
  }
}