import 'package:dio/dio.dart';

class MealDbService {
  MealDbService._();
  static final instance = MealDbService._();

  // Dio instance with base URL
  final _dio = Dio(
    BaseOptions(baseUrl: 'https://www.themealdb.com/api/json/v1/1'),
  );

  // Search meal by name in TheMealDB
  Future<Map<String, dynamic>?> searchByName(String name) async {
    final res = await _dio.get('/search.php', queryParameters: {'s': name});
    final data = res.data;
    if (data is Map<String, dynamic>) {
      final meals = data['meals'];
      if (meals is List && meals.isNotEmpty) {
        return meals.first as Map<String, dynamic>;
      }
    }
    return null;
  }
}
