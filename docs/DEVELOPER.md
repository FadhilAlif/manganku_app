# 🛠️ ManganKu App - Developer Documentation

This document provides detailed technical information for developers working on the ManganKu App project.

## 📋 Table of Contents

- [Development Environment](#-development-environment)
- [Project Structure](#-project-structure)
- [Core Services](#-core-services)
- [State Management](#-state-management)
- [Testing Strategy](#-testing-strategy)
- [Build & Deployment](#-build--deployment)
- [Performance Optimization](#-performance-optimization)
- [Code Style Guide](#-code-style-guide)

---

## 🔧 Development Environment

### Required Tools

```bash
# Flutter SDK
Flutter 3.9.2 • channel stable
Framework • revision 845304cf96 (4 months ago) • 2025-09-22 10:00:00 -0500
Engine • revision f51102b30c
Tools • Dart 3.9.2 • DevTools 2.31.1

# Android Development
Android Studio Giraffe | 2022.3.1
Android SDK Platform-Tools 34.0.4
Android Gradle Plugin 8.1.0

# iOS Development (Optional)
Xcode 15.0
CocoaPods 1.12.1
```

### IDE Extensions

**VS Code:**

- Flutter
- Dart
- Flutter Intl
- GitLens
- Error Lens

**Android Studio:**

- Flutter Plugin
- Dart Plugin

---

## 📁 Project Structure

### High-Level Architecture

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # App configuration
├── firebase_options.dart        # Firebase configuration
├── core/                        # Shared core functionality
│   ├── core.dart               # Core exports
│   ├── models/                 # Data models
│   │   └── nutrition.dart      # Nutrition data model
│   ├── services/               # Business logic services
│   │   ├── api_key_service.dart       # API key management
│   │   ├── firebase_ml_service.dart   # ML model service
│   │   ├── firebase_model_service.dart # Model management
│   │   ├── gemini_service.dart        # Gemini AI integration
│   │   ├── image_service.dart         # Image processing
│   │   └── mealdb_service.dart        # Recipe API service
│   ├── theme/                  # App theming
│   │   └── app_theme.dart      # Theme configuration
│   ├── utils/                  # Utility functions
│   │   └── ui_utils.dart       # UI helper functions
│   └── widgets/                # Reusable widgets
│       ├── common_widgets.dart  # Common UI components
│       ├── custom_buttons.dart  # Button components
│       └── custom_widgets.dart  # Custom widgets
├── features/                   # Feature modules
│   ├── debug/                  # Debug utilities
│   │   └── firebase_status_page.dart
│   ├── home/                   # Home feature
│   │   └── presentation/
│   │       └── home_page.dart
│   ├── preview/                # Image preview feature
│   │   └── presentation/
│   │       └── preview_page.dart
│   ├── result/                 # Result display feature
│   │   └── presentation/
│   │       └── result_page.dart
│   └── settings/               # Settings feature
│       └── presentation/
│           └── settings_page.dart
└── routes/                     # Navigation
    └── app_router.dart         # Route configuration
```

### Design Patterns Used

1. **Service Layer Pattern**: Business logic separation
2. **Repository Pattern**: Data access abstraction
3. **Singleton Pattern**: Service instance management
4. **Factory Pattern**: Model object creation
5. **Observer Pattern**: State management

---

## 🔧 Core Services

### Image Service (`lib/core/services/image_service.dart`)

Handles all image-related operations:

```dart
class ImageService {
  // Camera capture
  static Future<String?> pickImageFromCamera()

  // Gallery selection
  static Future<String?> pickImageFromGallery()

  // Image cropping
  static Future<String?> cropImage(String imagePath, BuildContext context)

  // Permission management
  static Future<bool> requestPermissions()
  static Future<bool> hasPermissions()
}
```

**Key Features:**

- Permission handling for camera and storage
- Image compression and optimization
- Cross-platform crop functionality
- Error handling and user feedback

### Firebase ML Service (`lib/core/services/firebase_ml_service.dart`)

Machine learning model management and inference:

```dart
class FirebaseMLService {
  // Model management
  Future<void> initialize()
  Future<FirebaseCustomModel?> downloadModel()
  Future<void> loadModel(FirebaseCustomModel model)

  // Inference
  Future<Map<String, dynamic>> analyzeImage(File imageFile)

  // Utilities
  bool get isModelReady
  Map<String, dynamic> get modelStatus
}
```

**Technical Details:**

- Uses TensorFlow Lite for on-device inference
- Firebase ML for cloud model distribution
- Image preprocessing pipeline (224x224 RGB)
- Confidence scoring and result ranking

### Gemini AI Service (`lib/core/services/gemini_service.dart`)

Integration with Google's Gemini AI for nutrition analysis:

```dart
class GeminiService {
  Future<Map<String, dynamic>> getNutritionInfo(String foodName)
  Future<bool> get isEnabled
}
```

**API Integration:**

- RESTful API calls to Gemini AI
- Structured JSON schema responses
- Error handling and rate limiting
- API key security management

### MealDB Service (`lib/core/services/mealdb_service.dart`)

Recipe database integration:

```dart
class MealDbService {
  Future<Map<String, dynamic>?> searchByName(String name)
}
```

**Features:**

- Recipe search functionality
- Ingredient parsing (strIngredient1-20)
- Instruction formatting
- Image and video link handling

---

## 📊 State Management

### Approach

The app uses **StatefulWidget** with **setState()** for local component state management. For more complex state, consider implementing:

1. **Provider Pattern** for app-wide state
2. **BLoC Pattern** for complex business logic
3. **Riverpod** for dependency injection

### Current State Patterns

```dart
// Local state example (ResultPage)
class _ResultPageState extends State<ResultPage> {
  bool _loadingNutrition = false;
  Nutrition? _nutrition;
  String? _nutritionError;

  @override
  void initState() {
    super.initState();
    _loadAdditionalInfo();
  }
}
```

### Future State Management

Consider implementing for v2.0:

```dart
// Provider example
class AppStateProvider extends ChangeNotifier {
  AppState _state = AppState.initial();

  AppState get state => _state;

  void updateState(AppState newState) {
    _state = newState;
    notifyListeners();
  }
}
```

---

## 🧪 Testing Strategy

### Test Structure

```
test/
├── unit/                       # Unit tests
│   ├── services/              # Service layer tests
│   └── models/                # Model tests
├── widget/                    # Widget tests
│   └── features/              # Feature widget tests
└── integration/               # Integration tests
    └── app_test.dart          # End-to-end tests
```

### Testing Patterns

**Unit Tests:**

```dart
group('ImageService', () {
  test('should request camera permissions', () async {
    final hasPermission = await ImageService.hasPermissions();
    expect(hasPermission, isA<bool>());
  });
});
```

**Widget Tests:**

```dart
testWidgets('HomePage should display camera button', (tester) async {
  await tester.pumpWidget(MaterialApp(home: HomePage()));
  expect(find.text('Take Photo'), findsOneWidget);
});
```

**Integration Tests:**

```dart
testWidgets('Full food recognition flow', (tester) async {
  // Test complete user journey
  // Camera -> Preview -> Crop -> Analysis -> Results
});
```

### Coverage Goals

- **Unit Tests**: >80% coverage
- **Widget Tests**: Critical UI components
- **Integration Tests**: Main user flows

---

## 🚀 Build & Deployment

### Build Configurations

**Debug Build:**

```bash
flutter build apk --debug --flavor dev
```

**Release Build:**

```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info/
flutter build appbundle --release --obfuscate --split-debug-info=./debug-info/
```

### Environment Configuration

```dart
// lib/config/environment.dart
class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.example.com',
  );

  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
}
```

### CI/CD Pipeline (GitHub Actions)

```yaml
name: Build and Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk --release
```

---

## ⚡ Performance Optimization

### Image Processing

```dart
// Optimize image before ML inference
Future<Uint8List> _optimizeImage(File imageFile) async {
  final image = img.decodeImage(await imageFile.readAsBytes());
  final resized = img.copyResize(image!, width: 224, height: 224);
  return Uint8List.fromList(img.encodeJpg(resized, quality: 85));
}
```

### Memory Management

- Use `AutomaticKeepAliveClientMixin` for complex widgets
- Implement proper disposal in `dispose()` methods
- Cache frequently accessed data
- Use `ListView.builder()` for long lists

### Network Optimization

- Implement request caching
- Use connection pooling
- Add timeout configurations
- Implement retry mechanisms

---

## 📝 Code Style Guide

### Naming Conventions

```dart
// Classes: PascalCase
class ImageService {}

// Variables and functions: camelCase
String imagePath = '';
Future<void> analyzeImage() async {}

// Constants: SCREAMING_SNAKE_CASE
static const String API_BASE_URL = '';

// Private members: underscore prefix
String _privateVariable = '';
void _privateMethod() {}
```

### Code Organization

```dart
// Import order
import 'dart:async';                    // Dart imports
import 'package:flutter/material.dart'; // Flutter imports
import 'package:dio/dio.dart';          // Package imports
import '../models/nutrition.dart';      // Relative imports

class ExampleClass {
  // 1. Constants
  static const String constantValue = '';

  // 2. Static variables
  static final instance = ExampleClass._();

  // 3. Instance variables
  final String publicVariable;
  String? _privateVariable;

  // 4. Constructor
  ExampleClass({required this.publicVariable});

  // 5. Public methods
  void publicMethod() {}

  // 6. Private methods
  void _privateMethod() {}
}
```

### Documentation

```dart
/// Service class for handling image operations.
///
/// This class provides methods for:
/// - Capturing images from camera
/// - Selecting images from gallery
/// - Cropping and processing images
class ImageService {
  /// Captures an image from the device camera.
  ///
  /// Returns the file path of the captured image, or null if
  /// the user cancelled or an error occurred.
  ///
  /// Throws [Exception] if camera permissions are denied.
  static Future<String?> pickImageFromCamera() async {
    // Implementation
  }
}
```

### Error Handling

```dart
// Comprehensive error handling
Future<String> processImage(String imagePath) async {
  try {
    // Validate input
    if (imagePath.isEmpty) {
      throw ArgumentError('Image path cannot be empty');
    }

    // Process image
    final result = await _processImageInternal(imagePath);
    return result;

  } on FormatException catch (e, stackTrace) {
    // Handle format errors
    _logger.error('Format error: $e', stackTrace);
    rethrow;
  } on FileSystemException catch (e, stackTrace) {
    // Handle file system errors
    _logger.error('File system error: $e', stackTrace);
    throw ProcessingException('Failed to read image file');
  } catch (e, stackTrace) {
    // Handle unexpected errors
    _logger.error('Unexpected error: $e', stackTrace);
    throw ProcessingException('An unexpected error occurred');
  }
}
```

---

## 🔐 Security Considerations

### API Key Management

```dart
// DON'T: Hardcode API keys
const String apiKey = 'your-api-key-here';

// DO: Use secure storage
class ApiKeyService {
  static Future<String?> getSecureApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('encrypted_api_key');
  }
}
```

### Data Sanitization

```dart
// Validate and sanitize user input
String sanitizeInput(String input) {
  return input
      .trim()
      .replaceAll(RegExp(r'[<>"\']'), '')
      .substring(0, math.min(input.length, 100));
}
```

### Network Security

```dart
// Use certificate pinning for production
final dio = Dio();
dio.interceptors.add(CertificatePinningInterceptor(
  allowedSHAFingerprints: ['YOUR_CERTIFICATE_SHA256_HASH'],
));
```

---

## 📈 Monitoring & Analytics

### Crash Reporting

```dart
// Firebase Crashlytics integration
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runZonedGuarded(
    () => runApp(MyApp()),
    FirebaseCrashlytics.instance.recordError,
  );
}
```

### Performance Monitoring

```dart
// Track performance metrics
Future<void> trackImageProcessingTime() async {
  final stopwatch = Stopwatch()..start();

  try {
    await processImage();
  } finally {
    stopwatch.stop();
    _analytics.logEvent('image_processing_time', {
      'duration_ms': stopwatch.elapsedMilliseconds,
    });
  }
}
```

---

## 🔄 Version Management

### Versioning Strategy

- **Major.Minor.Patch** (Semantic Versioning)
- **Build Number**: Auto-incremented
- **Version Code**: For Play Store

```yaml
# pubspec.yaml
version: 1.0.0+1
```

### Changelog Format

```markdown
## [1.1.0] - 2025-01-15

### Added

- iOS version support
- Offline mode for basic functionality
- Recipe favorites feature

### Changed

- Improved ML model accuracy
- Updated UI design

### Fixed

- Camera permission issue on Android 14
- Memory leak in image processing

### Security

- Enhanced API key protection
- Updated security dependencies
```

---

## 🚨 Common Issues & Solutions

### Build Issues

**Problem**: `Execution failed for task ':app:mergeDebugResources'`

```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter build apk
```

**Problem**: Firebase configuration errors

```bash
# Solution: Verify Firebase setup
1. Check google-services.json placement
2. Verify Firebase project configuration
3. Ensure all services are enabled
```

### Runtime Issues

**Problem**: ML model not loading

```dart
// Solution: Add proper error handling
try {
  await FirebaseMLService().downloadModel();
} on FirebaseException catch (e) {
  print('Firebase error: ${e.message}');
  // Fallback to local model
}
```

---

## 📚 Additional Resources

### Documentation Links

- [Flutter Official Docs](https://docs.flutter.dev/)
- [Firebase Flutter Setup](https://firebase.flutter.dev/)
- [TensorFlow Lite Guide](https://www.tensorflow.org/lite/guide)
- [Material Design Guidelines](https://material.io/design)

### Learning Resources

- [Flutter Codelabs](https://codelabs.developers.google.com/codelabs?product=flutter)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Firebase ML Documentation](https://firebase.google.com/docs/ml)

### Community

- [Flutter Community](https://flutter.dev/community)
- [Firebase Community](https://firebase.google.com/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

---

**Last Updated**: January 2025  
**Version**: 1.0.0  
**Maintainer**: Fadhil Alif
