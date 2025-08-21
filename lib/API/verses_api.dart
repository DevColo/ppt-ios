import 'package:dio/dio.dart';

class VersesApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://ppt-app.net'));
  //final Dio _dio = Dio(BaseOptions(baseUrl: 'http://ppt.site'));

  // Get Bible Verses
  Future<dynamic> getVersesAPI({required String language}) async {
    try {
      final response = await _dio.get('/api/$language/bible-verses');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load verses: $e');
    }
  }

  // Get Bible Sermon
  Future<dynamic> getSermonsAPI({required String language}) async {
    try {
      final response = await _dio.get('/api/$language/bible-sermons');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load sermons: $e');
    }
  }

  // Get Bible Verse Videos
  Future<dynamic> getBibleVerseAPI({required int videoID}) async {
    try {
      final response = await _dio.get('/api/bible-verse/$videoID');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load videos: $e');
    }
  }
}
