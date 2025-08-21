import 'package:dio/dio.dart';

class AudioBooksApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://ppt-app.net'));
  //final Dio _dio = Dio(BaseOptions(baseUrl: 'http://ppt.site'));

  // Get Audio Books Per Language
  Future<dynamic> getAudioBooksAPI({required String language}) async {
    try {
      final response = await _dio.get('/api/$language/get-audio-books');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load audio books: $e');
    }
  }

  // Get Audio Books Per Language Category
  Future<dynamic> getCategoryBooksAPI(
      {required String language, required int categoryId}) async {
    try {
      final response =
          await _dio.get('/api/get-category-books/$language/$categoryId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load books: $e');
    }
  }

  // Get Book Details Per ID
  Future<dynamic> getBookAPI({required int bookId}) async {
    try {
      final response = await _dio.get('/api/$bookId/get-book');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load book: $e');
    }
  }
}
