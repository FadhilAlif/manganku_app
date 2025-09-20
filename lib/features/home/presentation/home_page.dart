import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manganku_app/core/widgets/custom_buttons.dart';
import 'package:manganku_app/core/widgets/custom_widgets.dart';
import 'package:manganku_app/core/utils/ui_utils.dart';
import 'package:manganku_app/core/services/image_service.dart';
import 'package:manganku_app/core/services/api_key_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _hasApiKey = false;

  Future<void> _requestPermissions() async {
    final hasPermissions = await ImageService.requestPermissions();
    if (!hasPermissions) {
      _showErrorSnackBar('Camera or photo permissions denied');
    }
  }

  Future<void> _navigateToSettings() async {
    print('HomePage: Navigating to settings...');
    try {
      await context.push('/settings');
      // Always refresh API key status after returning from settings
      print('HomePage: Returned from settings, refreshing API key status...');
      await _checkApiKeyStatus();
    } catch (e) {
      print('HomePage: Error navigating to settings: $e');
      // Still try to refresh in case something went wrong
      await _checkApiKeyStatus();
    }
  }

  Future<void> _checkApiKeyStatus() async {
    try {
      final hasApiKey = await ApiKeyService.instance.hasGeminiApiKey();
      if (mounted) {
        setState(() {
          _hasApiKey = hasApiKey;
        });
        print('HomePage: API Key status updated - hasApiKey: $hasApiKey');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasApiKey = false;
        });
        print('HomePage: Error checking API key status: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    SnackBarUtil.showError(context, message, onRetry: _requestPermissions);
  }

  void _showSuccessSnackBar(String message) {
    SnackBarUtil.showSuccess(context, message);
  }

  Future<void> _captureImage() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final imagePath = await ImageService.pickImageFromCamera();

      if (imagePath != null && mounted) {
        _showSuccessSnackBar('Image captured successfully!');
        context.push('/preview', extra: imagePath);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to capture image: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectFromGallery() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final imagePath = await ImageService.pickImageFromGallery();

      if (imagePath != null && mounted) {
        _showSuccessSnackBar('Image selected successfully!');
        context.push('/preview', extra: imagePath);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to select image: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissions();
    _checkApiKeyStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh API key status when app becomes active again
      _checkApiKeyStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ManganKu App'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: _navigateToSettings,
                tooltip: 'Settings',
              ),
              if (!_hasApiKey)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.restaurant, size: 100, color: Colors.indigo),
            const SizedBox(height: 12),
            Text(
              'Recognize Your Food',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Take a photo of your food to identify it with AI',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: _isLoading ? 'Capturing...' : 'Capture Image',
              icon: Icons.camera_alt,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _captureImage,
              width: double.infinity,
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              text: _isLoading ? 'Selecting...' : 'Select from Gallery',
              icon: Icons.photo_library,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _selectFromGallery,
              width: double.infinity,
            ),
            const SizedBox(height: 24),
            // API Key Guidance Card
            if (!_hasApiKey)
              Card(
                elevation: 2,
                margin: const EdgeInsets.all(8),
                clipBehavior: Clip.antiAlias,
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.key,
                        color: Theme.of(context).colorScheme.error,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Setup Required',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please add your Gemini API key in Settings to get nutrition information.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _navigateToSettings,
                        icon: const Icon(Icons.settings),
                        label: const Text('Go to Settings'),
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onError,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!_hasApiKey) const SizedBox(height: 24),
            CustomCard(
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tips for better results:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Ensure good lighting\n• Keep the image clear and focused\n• Avoid shadows and glare',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
