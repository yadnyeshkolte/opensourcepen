# Flutter Prototype E-Commerce App

A cross-platform e-commerce application built with Flutter using the MVVM (Model-View-ViewModel) architecture pattern. This project demonstrates best practices for state management, navigation, data persistence, and interactive user experiences in Flutter.

## 📱 Project Overview

This application provides a complete e-commerce experience including:
- Interactive 3D onboarding experience
- User authentication with session management
- Product browsing and catalog management
- Shopping cart functionality with real-time updates
- Order management and history tracking

## 🏗️ Architecture

The project follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures representing core business logic
- **Views**: UI components that display data to the user
- **ViewModels**: Classes that handle business logic and state management

This separation ensures maintainable code organization, testability, and scalability.

## 📂 Project Structure

```
lib/
├── main.dart                # Entry point of the application
├── models/                  # Data models
│   ├── cart_model.dart      # Shopping cart item model
│   ├── onboarding_model.dart# Onboarding screen model
│   ├── order_model.dart     # Order data model
│   ├── product_model.dart   # Product data model
│   └── user_model.dart      # User data model
├── services/                # Service classes
│   └── app_preferences.dart # Handles app preferences and local storage
├── view_models/             # ViewModels (State management)
│   ├── auth_view_model.dart        # Authentication logic
│   ├── cart_view_model.dart        # Shopping cart management
│   ├── navigation_view_model.dart  # Navigation state management
│   ├── onboarding_view_model.dart  # Onboarding flow management
│   ├── order_view_model.dart       # Order management
│   └── product_view_model.dart     # Product data management
└── views/                   # UI components
    ├── cart_view.dart       # Shopping cart screen
    ├── home_view.dart       # Home screen
    ├── login_view.dart      # Authentication screen
    ├── main_layout.dart     # Main application layout
    ├── onboarding_view.dart # Onboarding screens
    ├── orders_view.dart     # Order history screen
    ├── product_view.dart    # Product details screen
    └── software_view.dart   # Additional features screen
```

## ✨ Key Features

### 🔐 Authentication
- User login with credential validation
- Session persistence using SharedPreferences
- Automatic login for returning users
- Secure logout functionality

### 🚀 Interactive 3D Onboarding
- Multi-step onboarding process with smooth transitions
- Interactive 3D model rendering using flutter_cube
- Custom animations for camera movement and object rotation
- Gradient background colors that transition between screens
- Skip functionality for returning users
- Progress tracking with animated indicators

**Technical Implementation:**
- Custom animation controllers for coordinated animations
- Vector3 interpolation for smooth camera movements
- Optimized rendering with RepaintBoundary
- Memory-efficient vector object reuse
- Asynchronous 3D model loading

### 📦 Product Management
- Product listing with images and details
- Mock API integration with simulated network requests
- Loading state management
- Error handling for failed network requests

### 🛒 Shopping Cart
- Add, remove, and update product quantities
- Real-time total calculation
- Item count tracking
- Empty state handling
- Persistent cart between sessions

### 📋 Order Management
- Order placement with cart validation
- Order history tracking
- Order status updates
- Mock API for demonstration purposes

### 🧭 Navigation
- Tab-based navigation with state preservation
- Conditional navigation based on user authentication status
- Deep linking support
- Navigation state management through Provider

## 🎨 UI/UX Features

### Theme and Styling
- Material Design 3 implementation
- Custom color schemes
- Consistent typography
- Responsive layouts for different screen sizes

### Animations
- Custom page transitions
- Loading animations
- Interactive UI elements
- 3D model rotations and camera movements

### Accessibility
- Semantic labels for screen readers
- Sufficient contrast ratios
- Touch target sizing

## 🔧 State Management

This project uses Provider for state management, demonstrating:
- ChangeNotifier implementation
- Provider scoping
- Consumer pattern
- MultiProvider for multiple data sources
- Efficient rebuilds with selective listeners

## 🧩 Dependencies

### Core Dependencies
- `flutter`: Core Flutter framework
- `provider`: State management solution
- `shared_preferences`: Local data persistence

### UI and Animation
- `flutter_cube`: 3D model rendering
- `animations`: Additional animation capabilities

### Utils
- `intl`: Internationalization and formatting

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (2.0.0 or higher)
- Dart SDK (2.12.0 or higher)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/flutter_ecommerce_app.git
```

2. Navigate to the project directory:
```bash
cd flutter_ecommerce_app
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## 📱 Usage

### Authentication
Use the following credentials to log in:
- Username: `admin`
- Password: `password`

### Onboarding
The onboarding flow showcases:
- 5 sequential screens with unique information
- Interactive 3D model that responds to transitions
- Different camera angles for each screen
- Smooth color transitions between screens
- Navigation controls (next, previous, skip)

The onboarding flow will be shown on first app launch. You can reset it from the settings menu.

### Development Notes
- The app uses mock data for products and orders
- Network requests are simulated with delays to demonstrate loading states
- Shared preferences are used to persist user session and app state

## 🧪 Testing

### Unit Tests
Run unit tests with:
```bash
flutter test
```

### Integration Tests
Run integration tests with:
```bash
flutter test integration_test
```

## 📚 Code Examples

### Implementing a ViewModel
```dart
class ProductViewModel extends ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // API call logic
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to fetch products: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}
```

### Using SharedPreferences
```dart
// Check if first launch
bool isFirstLaunch() {
  return _preferences.getBool(_isFirstLaunchKey) ?? true;
}

// Set first launch complete
Future<void> setFirstLaunchComplete() async {
  await _preferences.setBool(_isFirstLaunchKey, false);
}
```

## 🛣️ Roadmap

Future enhancements planned for this application:
- Firebase integration for backend services
- User profile management
- Product search and filtering
- Payment gateway integration
- Push notifications
- Theme customization
- Localization support
