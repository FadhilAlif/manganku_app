# 📚 API Documentation - ManganKu App

This document provides comprehensive API documentation for all external services used in the ManganKu App.

## 📋 Table of Contents

- [Firebase ML API](#firebase-ml-api)
- [Google Gemini AI API](#google-gemini-ai-api)
- [MealDB API](#mealdb-api)
- [Error Handling](#error-handling)
- [Rate Limiting](#rate-limiting)
- [Best Practices](#best-practices)

---

## 🔥 Firebase ML API

### Overview

Firebase ML provides cloud-based machine learning model hosting and distribution for the food recognition model.

### Configuration

```dart
// Initialize Firebase ML
FirebaseModelDownloader modelDownloader = FirebaseModelDownloader.instance;
```

### Endpoints

#### Download Model

```dart
Future<FirebaseCustomModel> downloadModel() async {
  final model = await modelDownloader.getModel(
    'food-recognition',                           // Model name
    FirebaseModelDownloadType.latestModel,      // Download type
    FirebaseModelDownloadConditions(
      iosAllowsCellularAccess: true,
      iosAllowsBackgroundDownloading: false,
      androidChargingRequired: false,
      androidWifiRequired: false,
      androidDeviceIdleRequired: false,
    ),
  );
  return model;
}
```

**Parameters:**

- `modelName` (string): Name of the model in Firebase console
- `downloadType` (enum): `latestModel` or `localModel`
- `conditions` (object): Download conditions for different platforms

**Response:**

```dart
FirebaseCustomModel {
  name: 'food-recognition',
  file: File('/data/user/0/com.example.manganku_app/cache/ml_model_food-recognition'),
  downloadUrl: 'https://firebase-ml-models.googleapis.com/...',
  size: 23468432,  // Size in bytes
  hash: 'a1b2c3d4e5f6...'
}
```

#### Model Status

```dart
Future<Map<String, dynamic>> getModelInfo() async {
  try {
    final localModel = await modelDownloader.getModel(
      'food-recognition',
      FirebaseModelDownloadType.localModel,
    );

    return {
      'isDownloaded': true,
      'size': await File(localModel.file.path).length(),
      'lastUpdated': await File(localModel.file.path).lastModified(),
    };
  } catch (e) {
    return {'isDownloaded': false, 'error': e.toString()};
  }
}
```

### Error Codes

| Code                 | Description                             | Solution                              |
| -------------------- | --------------------------------------- | ------------------------------------- |
| `model-not-found`    | Model doesn't exist in Firebase console | Check model name and Firebase project |
| `download-failed`    | Network error during download           | Check internet connection             |
| `insufficient-space` | Not enough storage space                | Free up device storage                |

---

## 🤖 Google Gemini AI API

### Overview

Google Gemini AI provides natural language processing for generating nutrition information based on food names.

### Base URL

```
https://generativelanguage.googleapis.com/v1beta/models
```

### Authentication

```dart
final String apiKey = await ApiKeyService.instance.getGeminiApiKey();
final String requestUrl = '$baseUrl/$model:generateContent?key=$apiKey';
```

### Endpoints

#### Generate Nutrition Content

**Endpoint:** `POST /v1beta/models/gemini-2.5-flash:generateContent`

**Headers:**

```
Content-Type: application/json
```

**Request Body:**

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        {
          "text": "Provide nutrition information for the food \"Pizza\" in grams per 100 grams. Return only valid JSON with calories, carbohydrate, fat, fiber, protein, sugar as integers."
        }
      ]
    }
  ],
  "generationConfig": {
    "responseMimeType": "application/json",
    "responseSchema": {
      "type": "object",
      "properties": {
        "calories": { "type": "integer" },
        "carbohydrate": { "type": "integer" },
        "fat": { "type": "integer" },
        "fiber": { "type": "integer" },
        "protein": { "type": "integer" },
        "sugar": { "type": "integer" }
      },
      "required": [
        "calories",
        "carbohydrate",
        "fat",
        "fiber",
        "protein",
        "sugar"
      ]
    }
  }
}
```

**Response:**

```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "text": "{\"calories\":266,\"carbohydrate\":33,\"fat\":10,\"fiber\":2,\"protein\":11,\"sugar\":4}"
          }
        ],
        "role": "model"
      },
      "finishReason": "STOP",
      "index": 0,
      "safetyRatings": [
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "probability": "NEGLIGIBLE"
        }
      ]
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 45,
    "candidatesTokenCount": 22,
    "totalTokenCount": 67
  }
}
```

**Dart Implementation:**

```dart
Future<Map<String, dynamic>> getNutritionInfo(String foodName) async {
  final apiKey = await _apiKey;
  final requestData = {
    'contents': [
      {
        'role': 'user',
        'parts': [
          {
            'text': 'Provide nutrition information for the food "$foodName" in grams per 100 grams. Return only valid JSON with calories, carbohydrate, fat, fiber, protein, sugar as integers.',
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
          'sugar': {'type': 'integer'},
        },
        'required': ['calories', 'carbohydrate', 'fat', 'fiber', 'protein', 'sugar'],
      },
    },
  };

  final response = await _dio.post(
    '$_baseUrl/$_model:generateContent',
    queryParameters: {'key': apiKey},
    options: Options(headers: {'Content-Type': 'application/json'}),
    data: requestData,
  );

  if (response.statusCode == 200) {
    final responseData = response.data;
    final content = responseData['candidates'][0]['content']['parts'][0]['text'];
    return jsonDecode(content);
  } else {
    throw Exception('Failed to get nutrition info: ${response.statusMessage}');
  }
}
```

### Error Codes

| Code  | Description                             | Solution                           |
| ----- | --------------------------------------- | ---------------------------------- |
| `400` | Bad Request - Invalid input format      | Check request body format          |
| `401` | Unauthorized - Invalid API key          | Verify API key in Google AI Studio |
| `403` | Forbidden - Quota exceeded              | Check API quotas and billing       |
| `429` | Too Many Requests - Rate limit exceeded | Implement retry with backoff       |
| `500` | Internal Server Error                   | Retry the request                  |

### Rate Limits

- **Free Tier**: 60 requests per minute
- **Paid Tier**: Custom limits based on billing plan

---

## 🍽️ MealDB API

### Overview

The MealDB API provides access to a comprehensive database of meals with recipes, ingredients, and cooking instructions.

### Base URL

```
https://www.themealdb.com/api/json/v1/1
```

### Authentication

No authentication required - it's a free public API.

### Endpoints

#### Search Meals by Name

**Endpoint:** `GET /search.php?s={meal_name}`

**Parameters:**

- `s` (string): The meal name to search for

**Example Request:**

```
GET https://www.themealdb.com/api/json/v1/1/search.php?s=Pizza
```

**Response:**

```json
{
  "meals": [
    {
      "idMeal": "52771",
      "strMeal": "Spicy Arrabiata Penne",
      "strMealAlternate": null,
      "strCategory": "Vegetarian",
      "strArea": "Italian",
      "strInstructions": "Bring a large pot of water to a boil. Add kosher salt to the boiling water, then add the pasta...",
      "strMealThumb": "https://www.themealdb.com/images/media/meals/ustsqw1468250014.jpg",
      "strTags": "Pasta,Curry",
      "strYoutube": "https://www.youtube.com/watch?v=1IszT_guI08",
      "strIngredient1": "penne rigate",
      "strIngredient2": "olive oil",
      "strIngredient3": "garlic",
      "strIngredient4": "chopped tomatoes",
      "strIngredient5": "red chilli flakes",
      "strIngredient6": "italian seasoning",
      "strIngredient7": "basil",
      "strIngredient8": "Parmigiano-Reggiano",
      "strIngredient9": "",
      "strIngredient10": "",
      "strIngredient11": "",
      "strIngredient12": "",
      "strIngredient13": "",
      "strIngredient14": "",
      "strIngredient15": "",
      "strIngredient16": null,
      "strIngredient17": null,
      "strIngredient18": null,
      "strIngredient19": null,
      "strIngredient20": null,
      "strMeasure1": "1 pound",
      "strMeasure2": "1/4 cup",
      "strMeasure3": "3 cloves",
      "strMeasure4": "1 tin",
      "strMeasure5": "1/2 teaspoon",
      "strMeasure6": "1/2 teaspoon",
      "strMeasure7": "6 leaves",
      "strMeasure8": "sprinkling",
      "strMeasure9": "",
      "strMeasure10": "",
      "strMeasure11": "",
      "strMeasure12": "",
      "strMeasure13": "",
      "strMeasure14": "",
      "strMeasure15": "",
      "strMeasure16": null,
      "strMeasure17": null,
      "strMeasure18": null,
      "strMeasure19": null,
      "strMeasure20": null,
      "strSource": null,
      "strImageSource": null,
      "strCreativeCommonsConfirmed": null,
      "dateModified": null
    }
  ]
}
```

**Dart Implementation:**

```dart
Future<Map<String, dynamic>?> searchByName(String name) async {
  final response = await _dio.get(
    '/search.php',
    queryParameters: {'s': name},
  );

  final data = response.data;
  if (data is Map<String, dynamic>) {
    final meals = data['meals'];
    if (meals is List && meals.isNotEmpty) {
      return meals.first as Map<String, dynamic>;
    }
  }
  return null;
}
```

#### Parse Ingredients

Helper function to extract ingredients from the MealDB response:

```dart
List<Map<String, String>> parseIngredients(Map<String, dynamic> mealInfo) {
  final ingredients = <Map<String, String>>[];

  for (int i = 1; i <= 20; i++) {
    final ingredient = mealInfo['strIngredient$i'];
    final measure = mealInfo['strMeasure$i'];

    if (ingredient != null &&
        ingredient.toString().trim().isNotEmpty &&
        ingredient.toString() != "null") {
      ingredients.add({
        'ingredient': ingredient.toString().trim(),
        'measure': (measure?.toString().trim() ?? '').isEmpty
            ? 'To taste'
            : measure.toString().trim(),
      });
    }
  }

  return ingredients;
}
```

### Response Fields

| Field               | Type   | Description                        |
| ------------------- | ------ | ---------------------------------- |
| `idMeal`            | String | Unique meal identifier             |
| `strMeal`           | String | Meal name                          |
| `strCategory`       | String | Meal category (e.g., "Vegetarian") |
| `strArea`           | String | Cuisine area (e.g., "Italian")     |
| `strInstructions`   | String | Cooking instructions               |
| `strMealThumb`      | String | Meal thumbnail image URL           |
| `strTags`           | String | Comma-separated tags               |
| `strYoutube`        | String | YouTube video URL                  |
| `strIngredient1-20` | String | Ingredient names                   |
| `strMeasure1-20`    | String | Ingredient measurements            |

### Error Handling

```dart
Future<Map<String, dynamic>?> searchByName(String name) async {
  try {
    final response = await _dio.get('/search.php', queryParameters: {'s': name});

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic> && data['meals'] != null) {
        final meals = data['meals'] as List;
        if (meals.isNotEmpty) {
          return meals.first as Map<String, dynamic>;
        }
      }
    }
  } catch (e) {
    debugPrint('MealDB API error: $e');
  }
  return null;
}
```

---

## ⚠️ Error Handling

### General Error Handling Strategy

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? endpoint;

  ApiException(this.message, {this.statusCode, this.endpoint});

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${endpoint != null ? ' [Endpoint: $endpoint]' : ''}';
  }
}

// Usage in service
Future<T> makeApiCall<T>(Future<T> Function() apiCall, String endpoint) async {
  try {
    return await apiCall();
  } on DioException catch (e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data['message'] ?? e.message ?? 'Unknown error';

    throw ApiException(
      message,
      statusCode: statusCode,
      endpoint: endpoint,
    );
  } catch (e) {
    throw ApiException(
      'Unexpected error: ${e.toString()}',
      endpoint: endpoint,
    );
  }
}
```

### Service-Specific Error Handling

```dart
// Firebase ML Service
try {
  await downloadModel();
} on FirebaseException catch (e) {
  switch (e.code) {
    case 'model-not-found':
      throw Exception('Model not found in Firebase console');
    case 'download-failed':
      throw Exception('Failed to download model. Check internet connection.');
    default:
      throw Exception('Firebase ML error: ${e.message}');
  }
}

// Gemini AI Service
try {
  await getNutritionInfo(foodName);
} on DioException catch (e) {
  switch (e.response?.statusCode) {
    case 401:
      throw Exception('Invalid API key. Please check your Gemini AI API key.');
    case 429:
      throw Exception('Rate limit exceeded. Please try again later.');
    case 500:
      throw Exception('Gemini AI service is temporarily unavailable.');
    default:
      throw Exception('Failed to get nutrition info: ${e.message}');
  }
}

// MealDB Service
try {
  final result = await searchByName(foodName);
  if (result == null) {
    throw Exception('No recipes found for "$foodName"');
  }
} on DioException catch (e) {
  throw Exception('Failed to fetch recipe data: ${e.message}');
}
```

---

## 🎯 Rate Limiting

### Implementation Strategy

```dart
class RateLimiter {
  final int maxRequests;
  final Duration timeWindow;
  final Queue<DateTime> _requests = Queue<DateTime>();

  RateLimiter({required this.maxRequests, required this.timeWindow});

  Future<bool> canMakeRequest() async {
    final now = DateTime.now();

    // Remove old requests outside the time window
    while (_requests.isNotEmpty &&
           now.difference(_requests.first) > timeWindow) {
      _requests.removeFirst();
    }

    if (_requests.length < maxRequests) {
      _requests.add(now);
      return true;
    }

    return false;
  }

  Duration get waitTime {
    if (_requests.isEmpty) return Duration.zero;
    return timeWindow - DateTime.now().difference(_requests.first);
  }
}

// Usage in services
class GeminiService {
  final RateLimiter _rateLimiter = RateLimiter(
    maxRequests: 60,
    timeWindow: Duration(minutes: 1),
  );

  Future<Map<String, dynamic>> getNutritionInfo(String foodName) async {
    if (!await _rateLimiter.canMakeRequest()) {
      final waitTime = _rateLimiter.waitTime;
      throw Exception('Rate limit exceeded. Please wait ${waitTime.inSeconds} seconds.');
    }

    // Proceed with API call
    return await _makeApiCall(foodName);
  }
}
```

---

## 🏆 Best Practices

### 1. Caching Strategy

```dart
class CacheManager {
  final Map<String, CacheEntry> _cache = {};
  final Duration _defaultTtl = Duration(hours: 1);

  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.value as T?;
    }
    _cache.remove(key);
    return null;
  }

  void set<T>(String key, T value, {Duration? ttl}) {
    _cache[key] = CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? _defaultTtl),
    );
  }
}

class CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  CacheEntry({required this.value, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
```

### 2. Request Retry Logic

```dart
Future<T> retryRequest<T>(
  Future<T> Function() request,
  {int maxRetries = 3, Duration delay = const Duration(seconds: 1)}
) async {
  int attempts = 0;

  while (attempts < maxRetries) {
    try {
      return await request();
    } catch (e) {
      attempts++;
      if (attempts >= maxRetries) rethrow;

      // Exponential backoff
      await Future.delayed(delay * attempts);
    }
  }

  throw Exception('Max retries exceeded');
}

// Usage
final result = await retryRequest(() => geminiService.getNutritionInfo(foodName));
```

### 3. Request Timeout Configuration

```dart
final dio = Dio(BaseOptions(
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(seconds: 30),
  sendTimeout: Duration(seconds: 10),
));
```

### 4. Response Validation

```dart
bool isValidNutritionResponse(Map<String, dynamic> response) {
  final requiredFields = ['calories', 'carbohydrate', 'fat', 'fiber', 'protein', 'sugar'];

  return requiredFields.every((field) {
    final value = response[field];
    return value != null && value is int && value >= 0;
  });
}

Future<Nutrition> getNutritionInfo(String foodName) async {
  final response = await _makeApiCall(foodName);

  if (!isValidNutritionResponse(response)) {
    throw Exception('Invalid nutrition data received');
  }

  return Nutrition.fromJson(response);
}
```

### 5. Logging and Monitoring

```dart
class ApiLogger {
  static void logRequest(String method, String url, Map<String, dynamic>? data) {
    debugPrint('🔄 $method $url');
    if (data != null) {
      debugPrint('📤 Request: ${jsonEncode(data)}');
    }
  }

  static void logResponse(int statusCode, String url, dynamic data) {
    debugPrint('✅ $statusCode $url');
    debugPrint('📥 Response: ${jsonEncode(data)}');
  }

  static void logError(String url, Exception error) {
    debugPrint('❌ Error: $url - $error');
  }
}

// Dio interceptor for automatic logging
dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    ApiLogger.logRequest(options.method, options.path, options.data);
    handler.next(options);
  },
  onResponse: (response, handler) {
    ApiLogger.logResponse(response.statusCode!, response.requestOptions.path, response.data);
    handler.next(response);
  },
  onError: (error, handler) {
    ApiLogger.logError(error.requestOptions.path, Exception(error.message));
    handler.next(error);
  },
));
```

---

**Last Updated**: January 2025  
**API Version**: 1.0.0  
**Maintainer**: Fadhil Alif
