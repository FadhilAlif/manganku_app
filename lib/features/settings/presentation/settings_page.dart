import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:manganku_app/core/services/api_key_service.dart';
import 'package:manganku_app/core/services/gemini_service.dart';
import 'package:manganku_app/core/services/firebase_ml_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _apiKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _hasApiKey = false;
  String? _currentApiKey;
  Map<String, dynamic> _serviceStatus = {};

  // Firebase ML Model state
  bool _isModelLoading = false;
  Map<String, dynamic> _modelInfo = {};
  String _modelStatus = 'Checking...';

  @override
  void initState() {
    super.initState();
    _loadCurrentApiKey();
    _checkServicesStatus();
    _checkModelStatus();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentApiKey() async {
    try {
      final apiKey = await ApiKeyService.instance.getGeminiApiKey();
      setState(() {
        _hasApiKey = apiKey != null && apiKey.isNotEmpty;
        _currentApiKey = apiKey;
        if (_hasApiKey && apiKey != null) {
          _apiKeyController.text = apiKey;
        }
      });
    } catch (e) {
      setState(() {
        _hasApiKey = false;
      });
    }
  }

  Future<void> _checkServicesStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final geminiEnabled = await GeminiService.instance.isEnabled;
      final firebaseMLService = FirebaseMLService();
      final mlStatus = firebaseMLService.modelStatus;

      setState(() {
        _serviceStatus = {
          'gemini': {
            'enabled': geminiEnabled,
            'status': geminiEnabled ? 'Ready' : 'API Key Required',
          },
          'firebaseML': mlStatus,
        };
      });
    } catch (e) {
      setState(() {
        _serviceStatus = {'error': e.toString()};
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkModelStatus() async {
    try {
      final firebaseMLService = FirebaseMLService();
      await firebaseMLService.initialize();

      final modelInfo = await firebaseMLService.getModelInfo();
      setState(() {
        _modelInfo = modelInfo;
        _modelStatus = modelInfo['isDownloaded']
            ? 'Downloaded (${modelInfo['sizeFormatted'] ?? 'Unknown size'})'
            : 'Not Downloaded';
      });
    } catch (e) {
      setState(() {
        _modelInfo = {'error': e.toString()};
        _modelStatus = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _downloadModel() async {
    setState(() {
      _isModelLoading = true;
    });

    try {
      final firebaseMLService = FirebaseMLService();
      await firebaseMLService.initialize();

      final model = await firebaseMLService.downloadLatestModel();

      // Refresh status after download
      await _checkModelStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Model downloaded successfully! Size: ${_formatFileSize(model.size)}',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download model: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isModelLoading = false;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (bytes.bitLength - 1) ~/ 10;
    if (i >= suffixes.length) i = suffixes.length - 1;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<void> _saveApiKey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiKey = _apiKeyController.text.trim();
      await ApiKeyService.instance.saveGeminiApiKey(apiKey);

      setState(() {
        _hasApiKey = true;
        _currentApiKey = apiKey;
      });

      await _checkServicesStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API Key saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving API Key: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _removeApiKey() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ApiKeyService.instance.removeGeminiApiKey();
      _apiKeyController.clear();

      setState(() {
        _hasApiKey = false;
        _currentApiKey = null;
      });

      await _checkServicesStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API Key removed successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing API Key: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testApiKey() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await GeminiService.instance.getNutritionInfo('apple');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API Key test successful! Result: $result'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API Key test failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _launchApiKeyUrl() async {
    const url = 'https://aistudio.google.com/apikey';
    try {
      // Copy URL to clipboard
      await Clipboard.setData(const ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'API Key URL copied to clipboard! Open your browser and paste it.',
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not copy link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildApiKeySection(),
                    const SizedBox(height: 24),
                    _buildFirebaseMLSection(),
                    const SizedBox(height: 24),
                    _buildServiceStatusSection(),
                    const SizedBox(height: 24),
                    _buildHelpSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildApiKeySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.key, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Gemini API Key',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_hasApiKey) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'API Key is configured',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Current API Key: ${_currentApiKey?.substring(0, 8)}...****',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _apiKeyController.text = _currentApiKey ?? '';
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Key'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _testApiKey,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Test Key'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _removeApiKey,
                  icon: const Icon(Icons.delete),
                  label: const Text('Remove Key'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'API Key required for nutrition features',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'Enter your Gemini API Key',
                  hintText: 'AIzaSy...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                  suffixIcon: Icon(Icons.paste, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your API Key';
                  }
                  if (!value.startsWith('AIza')) {
                    return 'Invalid API Key format';
                  }
                  if (value.length < 35) {
                    return 'API Key seems too short';
                  }
                  return null;
                },
                onTap: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null && data!.text!.startsWith('AIza')) {
                    _apiKeyController.text = data.text!;
                  }
                },
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveApiKey,
                  icon: const Icon(Icons.save),
                  label: const Text('Save API Key'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFirebaseMLSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.smart_toy,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Firebase ML Model',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Model Status Row
            Row(
              children: [
                Icon(
                  _modelInfo['isDownloaded'] == true
                      ? Icons.check_circle
                      : Icons.download,
                  color: _modelInfo['isDownloaded'] == true
                      ? Colors.green
                      : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: $_modelStatus',
                        style: TextStyle(
                          color: _modelInfo['isDownloaded'] == true
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_modelInfo['isDownloaded'] == true &&
                          _modelInfo['sizeFormatted'] != null)
                        Text(
                          'Size: ${_modelInfo['sizeFormatted']}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'The Firebase ML model is used for food recognition. Download it now to avoid waiting during image analysis.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isModelLoading ? null : _downloadModel,
                    icon: _isModelLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Icon(
                            _modelInfo['isDownloaded'] == true
                                ? Icons.refresh
                                : Icons.download,
                          ),
                    label: Text(
                      _isModelLoading
                          ? 'Downloading...'
                          : _modelInfo['isDownloaded'] == true
                          ? 'Update Model'
                          : 'Download Model',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _isModelLoading ? null : _checkModelStatus,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check Status'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Service Status',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_serviceStatus.containsKey('error')) ...[
              ListTile(
                leading: const Icon(Icons.error, color: Colors.red),
                title: const Text('Services Error'),
                subtitle: Text(_serviceStatus['error']),
                tileColor: Colors.red.withAlpha(255 * 1),
              ),
            ] else ...[
              ListTile(
                leading: Icon(
                  _serviceStatus['gemini']?['enabled'] == true
                      ? Icons.check_circle
                      : Icons.warning,
                  color: _serviceStatus['gemini']?['enabled'] == true
                      ? Colors.green
                      : Colors.orange,
                ),
                title: const Text('Gemini API'),
                subtitle: Text(
                  _serviceStatus['gemini']?['status'] ?? 'Unknown',
                ),
              ),
              const Divider(),
              ListTile(
                leading: Icon(
                  _serviceStatus['firebaseML']?['isModelLoaded'] == true
                      ? Icons.check_circle
                      : Icons.warning,
                  color: _serviceStatus['firebaseML']?['isModelLoaded'] == true
                      ? Colors.green
                      : Colors.orange,
                ),
                title: const Text('Firebase ML'),
                subtitle: Text(
                  _serviceStatus['firebaseML']?['isModelLoaded'] == true
                      ? 'Model loaded and ready'
                      : 'Model not loaded',
                ),
              ),
            ],

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _checkServicesStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'How to get API Key',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'To use nutrition features, you need a Gemini API Key:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),

            const Text('1. Visit Google AI Studio'),
            const Text('2. Sign in with your Google account'),
            const Text('3. Create a new API key'),
            const Text('4. Copy and paste the key above'),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _launchApiKeyUrl,
                icon: const Icon(Icons.content_copy),
                label: const Text('Copy Google AI Studio URL'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(255 * 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your API key is stored locally and securely on your device.',
                      style: TextStyle(color: Colors.blue[700], fontSize: 13),
                    ),
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
