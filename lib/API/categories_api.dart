import 'package:dio/dio.dart';

class CategoriesApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://ppt-app.net'));
  //final Dio _dio = Dio(BaseOptions(baseUrl: 'http://ppt.site'));

  // Get Categories
  Future<dynamic> getCategories() async {
    try {
      final response = await _dio.get('/api/get-categories');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
