import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://ppt-app.net'));

  //final Dio _dio = Dio(BaseOptions(baseUrl: 'http://ppt.site'));

  // Get Most Read Books
  Future<dynamic> getMostReadBooksAPI({required String language}) async {
    try {
      final response = await _dio.get('/api/$language/most-read-books');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load most read books: $e');
    }
  }

  // Get New Released Books
  Future<dynamic> getNewReleasedBooksAPI({required String language}) async {
    try {
      final response = await _dio.get('/api/$language/new-released-books');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load new released books: $e');
    }
  }

  // Get Preachers
  Future<dynamic> getPreachersAPI({required String language}) async {
    try {
      final response = await _dio.get('/api/$language/preachers');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load preachers: $e');
    }
  }
}
