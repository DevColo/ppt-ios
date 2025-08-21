import 'package:dio/dio.dart';

class SermonsApi {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://ppt-app.net'));
  //final Dio _dio = Dio(BaseOptions(baseUrl: 'http://ppt.site'));

  // Get Pastors
  Future<dynamic> getPastorsAPI({required String language}) async {
    try {
      final response = await _dio.get('/api/$language/get-pastors');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load pastors: $e');
    }
  }

  // Get Sermons Playlist
  Future<dynamic> getSermonsPlayListAPI({required int pastorId}) async {
    try {
      final response = await _dio.get('/api/get-sermons-playlist/$pastorId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load sermons: $e');
    }
  }

  // Get Sermons Videos
  Future<dynamic> getSermonsVideosAPI({required int playListId}) async {
    try {
      final response = await _dio.get('/api/get-playlist-videos/$playListId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load videos: $e');
    }
  }

  // Get Home Youtube videos
  Future<dynamic> getYoutubeAPI({required String language}) async {
    try {
      final response = await _dio.get('/api/$language/home-videos');
      return response.data;
    } catch (e) {
      throw Exception('Failed to load home videos: $e');
    }
  }
}
