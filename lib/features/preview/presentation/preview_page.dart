import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manganku_app/core/widgets/custom_buttons.dart';
import 'package:manganku_app/core/widgets/custom_widgets.dart';
import 'package:manganku_app/core/widgets/common_widgets.dart';
import 'package:manganku_app/core/utils/ui_utils.dart';
import 'package:manganku_app/core/services/image_service.dart';

class PreviewPage extends StatefulWidget {
  final String? imagePath;

  const PreviewPage({super.key, required this.imagePath});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  String? _currentImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath;
  }

  void _showErrorSnackBar(String message) {
    SnackBarUtil.showError(context, message);
  }

  void _showSuccessSnackBar(String message) {
    SnackBarUtil.showSuccess(context, message);
  }

  Future<void> _cropImage() async {
    if (_currentImagePath == null || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final croppedPath = await ImageService.cropImage(
        _currentImagePath!,
        context,
      );

      if (!mounted) return; // Check if widget is still mounted

      if (croppedPath != null) {
        setState(() {
          _currentImagePath = croppedPath;
        });
        _showSuccessSnackBar('Image cropped successfully!');
      } else {
        _showSuccessSnackBar('Crop cancelled');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to crop image: ${e.toString()}');
      }
      print('Crop error: $e'); // For debugging
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _retakePhoto() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentImagePath == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Preview'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        body: const EmptyStateWidget(
          title: 'No image selected',
          subtitle: 'Please go back and select an image',
          icon: Icons.image_not_supported,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: _retakePhoto,
            icon: const Icon(Icons.refresh),
            tooltip: 'Retake photo',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: CustomCard(
                padding: EdgeInsets.zero,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: _isLoading
                      ? const LoadingWidget(message: 'Processing image...')
                      : CustomImageWidget(
                          imagePath: _currentImagePath,
                          fit: BoxFit.contain,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                          errorMessage: 'Failed to load image',
                        ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                PrimaryButton(
                  text: _isLoading ? 'Cropping...' : 'Crop Image',
                  icon: Icons.crop,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _cropImage,
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  text: 'Retake Photo',
                  icon: Icons.camera_alt,
                  onPressed: _isLoading ? null : _retakePhoto,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
