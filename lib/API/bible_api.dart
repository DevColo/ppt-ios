import 'package:dio/dio.dart';

class BibleApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://ppt-app.net'));
  //final Dio _dio = Dio(BaseOptions(baseUrl: 'http://ppt.site'));

  // Get Pastors
  Future<dynamic> getTestamentsAPI({required String language}) async {
    try {
      final response = await _dio.get('/api/$language/get-testaments');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load testaments: $e');
    }
  }

  // Get Bible Books
  Future<dynamic> getBibleBooksAPI({required int testamentID}) async {
    try {
      final response = await _dio.get('/api/get-bible-books/$testamentID');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load Bible books: $e');
    }
  }

  // Get Book Audios Per Book ID
  Future<dynamic> getBibleBookAudiosAPI({required int bookId}) async {
    try {
      final response = await _dio.get('/api/$bookId/get-bible-book-audios');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load book audios: $e');
    }
  }
}
