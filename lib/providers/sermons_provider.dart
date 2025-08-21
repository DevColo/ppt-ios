import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:precious/API/sermons_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SermonsProvider with ChangeNotifier {
  final SermonsApi _sermonsApi = SermonsApi();

  List<dynamic> _pastors = [];
  List<dynamic> get pastors => _pastors;

  List<dynamic> _sermons = [];
  List<dynamic> get sermons => _sermons;

  List<dynamic> _videos = [];
  List<dynamic> get videos => _videos;

  List<dynamic> _youtube = [];
  List<dynamic> get youtube => _youtube;

  // PASTORS
  Future<void> _savePastorsToPrefs(
      List<dynamic> newRelpastorseasedBooks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('pastors', jsonEncode(pastors));
  }

  void setPastors(List<dynamic> pastors) {
    _pastors = pastors;
    notifyListeners();
    _savePastorsToPrefs(pastors);
  }

  Future<void> getPastors() async {
    try {
      // Fetch the selected language from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedLanguage =
          prefs.getString('selectedLanguage') ?? 'Kinyarwanda';

      // Pass the selected language to the API call
      final pastors =
          await SermonsApi().getPastorsAPI(language: selectedLanguage);
      setPastors(pastors);
    } catch (e) {
      print('Error fetching pastors: $e');
    }
  }

  // SERMONS PLAYLIST
  Future<void> _saveSermonsToPrefs(List<dynamic> sermons) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sermons', jsonEncode(sermons));
  }

  void setSermons(List<dynamic> sermons) {
    _sermons = sermons;
    notifyListeners();
    _saveSermonsToPrefs(sermons);
  }

  Future<void> getSermons(BuildContext context, int pastorId) async {
    try {
      final sermons =
          await SermonsApi().getSermonsPlayListAPI(pastorId: pastorId);
      setSermons(sermons);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error fetching sermons: $e',
            style: const TextStyle(color: Colors.red),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 216, 203),
          elevation: 2.0,
        ),
      );
    }
  }

  // VIDEOS
  Future<void> _saveVideosToPrefs(List<dynamic> videos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('videos', jsonEncode(videos));
  }

  void setVideos(List<dynamic> videos) {
    _videos = videos;
    notifyListeners();
    _saveVideosToPrefs(videos);
  }

  Future<void> getVideos(BuildContext context, int playListId) async {
    try {
      final videos =
          await SermonsApi().getSermonsVideosAPI(playListId: playListId);
      setVideos(videos);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please check internet connection and try again.",
            style: const TextStyle(color: Colors.red),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 216, 203),
          elevation: 2.0,
        ),
      );
    }
  }

  // Youtube Video
  Future<void> _saveYoutubeToPrefs(List<dynamic> youtube) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('youtube', jsonEncode(youtube));
  }

  void setYoutube(List<dynamic> youtube) {
    _youtube = youtube;
    notifyListeners();
    _saveYoutubeToPrefs(youtube);
  }

  Future<void> getYoutube() async {
    try {
      // Fetch the selected language from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedLanguage =
          prefs.getString('selectedLanguage') ?? 'Kinyarwanda';

      // Pass the selected language to the API call
      final youtube =
          await _sermonsApi.getYoutubeAPI(language: selectedLanguage);
      setYoutube(youtube);
    } catch (e) {
      print('Error fetching youtube videos: $e');
    }
  }

  SermonsProvider() {
    // Fetch data from the API
    getPastors();
    getYoutube();
  }
}
