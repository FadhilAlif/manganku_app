import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:manganku_app/core/services/firebase_ml_service.dart';
import 'package:manganku_app/core/widgets/custom_buttons.dart';

class FirebaseStatusPage extends StatefulWidget {
  const FirebaseStatusPage({super.key});

  @override
  State<FirebaseStatusPage> createState() => _FirebaseStatusPageState();
}

class _FirebaseStatusPageState extends State<FirebaseStatusPage> {
  Map<String, dynamic> _firebaseStatus = {};
  Map<String, dynamic> _mlServiceStatus = {};
  bool _isLoading = false;
  String _testResult = '';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check Firebase Core status
      final apps = Firebase.apps;
      final isInitialized = apps.isNotEmpty;

      _firebaseStatus = {
        'isInitialized': isInitialized,
        'appName': isInitialized ? apps.first.name : 'None',
        'options': isInitialized ? apps.first.options.projectId : 'None',
        'appsCount': apps.length,
      };

      // Check Firebase ML Service status
      final firebaseMLService = FirebaseMLService();
      _mlServiceStatus = firebaseMLService.modelStatus;
    } catch (e) {
      _firebaseStatus = {'error': e.toString()};
      _mlServiceStatus = {'error': e.toString()};
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testMLService() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing Firebase ML Service...';
    });

    try {
      final firebaseMLService = FirebaseMLService();

      // Test initialization
      if (!_mlServiceStatus['isInitialized']) {
        await firebaseMLService.initialize();
        _testResult = 'Firebase ML Service initialized successfully';
      }

      // Test model download
      try {
        await firebaseMLService.downloadModel();
        _testResult += '\nModel downloaded successfully';
      } catch (e) {
        _testResult += '\nModel download failed: $e';
      }

      // Refresh status
      _mlServiceStatus = firebaseMLService.modelStatus;
    } catch (e) {
      _testResult = 'Test failed: $e';
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Status'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusSection('Firebase Core Status', _firebaseStatus),
                  const SizedBox(height: 24),
                  _buildStatusSection(
                    'Firebase ML Service Status',
                    _mlServiceStatus,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Test ML Service',
                    onPressed: _testMLService,
                    isLoading: _isLoading,
                  ),
                  if (_testResult.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Test Results:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(_testResult),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Refresh Status',
                    onPressed: _checkStatus,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusSection(String title, Map<String, dynamic> status) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            ...status.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${entry.key}:',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: TextStyle(
                          color: entry.key == 'error'
                              ? Colors.red
                              : entry.value == true
                              ? Colors.green
                              : entry.value == false
                              ? Colors.orange
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
