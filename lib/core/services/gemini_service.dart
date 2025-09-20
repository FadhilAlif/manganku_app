import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:manganku_app/core/services/api_key_service.dart';
import 'package:manganku_app/core/models/nutrition.dart';

class GeminiService {
  GeminiService._();
  static final instance = GeminiService._();

  final _dio = Dio();
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-2.5-flash';

  static const String _staticApiKey = '';

  Future<String> get _apiKey async {
    // Try to get from SharedPreferences
    final apiKey = await ApiKeyService.instance.getGeminiApiKey();
    if (apiKey != null && apiKey.isNotEmpty) {
      return apiKey;
    }

    // Fallback to static key (not recommended for production)
    if (_staticApiKey.isNotEmpty) {
      return _staticApiKey;
    }

    throw Exception(
      'GEMINI_API_KEY not found. Please set it in the app settings.',
    );
  }

  Future<bool> get isEnabled async {
    try {
      await _apiKey;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getNutritionInfo(String foodName) async {
    try {
      final apiKey = await _apiKey; // This will throw if not available

      final response = await _dio.post(
        '$_baseUrl/$_model:generateContent',
        queryParameters: {'key': apiKey},
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {
                  'text':
                      'Provide nutrition information for the food "$foodName" in grams per 100 grams. Provide accurate and general data for this food.',
                },
              ],
            },
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'responseSchema': {
              'type': 'object',
              'properties': {
                'calories': {'type': 'integer'},
                'carbohydrate': {'type': 'integer'},
                'fat': {'type': 'integer'},
                'fiber': {'type': 'integer'},
                'protein': {'type': 'integer'},
              },
              'required': [
                'calories',
                'carbohydrate',
                'fat',
                'fiber',
                'protein',
              ],
              'propertyOrdering': [
                'calories',
                'carbohydrate',
                'fat',
                'fiber',
                'protein',
              ],
            },
          },
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content'];
          if (content['parts'] != null && content['parts'].isNotEmpty) {
            final jsonText = content['parts'][0]['text'];
            final result = jsonDecode(jsonText) as Map<String, dynamic>;
            debugPrint('Gemini API response: $result');
            return result;
          }
        }
      }

      throw Exception('Invalid response from Gemini API');
    } on DioException catch (e) {
      throw Exception('Failed to get nutrition info: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @Deprecated('Use getNutritionInfo instead')
  Future<Map<String, dynamic>> summarizeNutrition(String foodName) async {
    return getNutritionInfo(foodName);
  }
}
