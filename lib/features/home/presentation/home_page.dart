import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manganku_app/core/widgets/custom_buttons.dart';
import 'package:manganku_app/core/widgets/custom_widgets.dart';
import 'package:manganku_app/core/utils/ui_utils.dart';
import 'package:manganku_app/core/services/image_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;

  Future<void> _requestPermissions() async {
    final hasPermissions = await ImageService.requestPermissions();
    if (!hasPermissions) {
      _showErrorSnackBar('Camera or photo permissions denied');
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
    _requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ManganKu'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.photo_camera_rounded,
              size: 100,
              color: Colors.indigo,
            ),
            const SizedBox(height: 12),
            Text(
              'Choose how to add your image',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Take a photo or select from your gallery',
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
            const SizedBox(height: 16),
            SecondaryButton(
              text: _isLoading ? 'Selecting...' : 'Select from Gallery',
              icon: Icons.photo_library,
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _selectFromGallery,
              width: double.infinity,
            ),
            const SizedBox(height: 32),
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
