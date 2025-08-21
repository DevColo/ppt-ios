import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:precious/API/bible_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleProvider with ChangeNotifier {
  final BibleApi _bibleApi = BibleApi();

  List<dynamic> _testaments = [];
  List<dynamic> get testaments => _testaments;

  List<dynamic> _books = [];
  List<dynamic> get books => _books;

  List<dynamic> _audios = [];
  List<dynamic> get audios => _audios;

  Map<int, double> downloadProgress = {};
  Map<int, bool> downloadComplete = {};

  List<String> _downloadedFiles = [];

  List<String> get downloadedFiles => _downloadedFiles;

  // TESTAMENTS
  Future<void> _saveTestamentsToPrefs(List<dynamic> testaments) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('testaments', jsonEncode(testaments));
  }

  // Future<void> _loadTestamentsFromPrefs() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? _testamentsString = prefs.getString('_testaments');
  //   if (_testamentsString != null) {
  //     _testaments = jsonDecode(_testamentsString);
  //     notifyListeners();
  //   }
  // }

  void setTestaments(List<dynamic> testaments) {
    _testaments = testaments;
    notifyListeners();
    _saveTestamentsToPrefs(testaments);
  }

  Future<void> getTestaments() async {
    try {
      // Fetch the selected language from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedLanguage =
          prefs.getString('selectedLanguage') ?? 'Kinyarwanda';

      // Pass the selected language to the API call
      final testaments =
          await _bibleApi.getTestamentsAPI(language: selectedLanguage);
      setTestaments(testaments);
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Testaments: $e');
      }
    }
  }

  // BOOKS
  Future<void> _saveBooksToPrefs(List<dynamic> books) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('books', jsonEncode(books));
  }

  // Future<void> _loadBooksFromPrefs() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? _booksString = prefs.getString('_books');
  //   if (_booksString != null) {
  //     _books = jsonDecode(_booksString);
  //     notifyListeners();
  //   }
  // }

  void setBooks(List<dynamic> books) {
    _books = books;
    notifyListeners();
    _saveBooksToPrefs(books);
  }

  Future<void> getBibleBooks(BuildContext context, int testamentID) async {
    try {
      final books = await _bibleApi.getBibleBooksAPI(testamentID: testamentID);
      setBooks(books);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error fetching books: $e',
            style: const TextStyle(color: Colors.red),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 216, 203),
          elevation: 2.0,
        ),
      );
    }
  }

  // AUDIOS
  Future<void> _saveAudiosToPrefs(List<dynamic> audios) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('audios', jsonEncode(audios));
  }

  // Future<void> _loadAudiosFromPrefs() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? _audiosString = prefs.getString('_audios');
  //   if (_audiosString != null) {
  //     _audios = jsonDecode(_audiosString);
  //     notifyListeners();
  //   }
  // }

  void setAudios(List<dynamic> audios) {
    _audios = audios;
    notifyListeners();
    _saveAudiosToPrefs(audios);
  }

  Future<void> getBibleBookAudios(BuildContext context, int bookId) async {
    try {
      final audios = await _bibleApi.getBibleBookAudiosAPI(bookId: bookId);
      setAudios(audios);
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

  void updateDownloadProgress(int index, double progress) {
    downloadProgress[index] = progress;
    notifyListeners();
  }

  void markDownloadComplete(int index, String filePath) {
    downloadComplete[index] = true;
    downloadedFiles.add(filePath);
    notifyListeners();
  }

  bool isDownloadComplete(int index) {
    return downloadComplete[index] ?? false;
  }

  double getDownloadProgress(int index) {
    return downloadProgress[index] ?? 0.0;
  }

  Future<void> refreshDownloadedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      // List all files in the directory
      final dir = Directory(directory.path);
      if (dir.existsSync()) {
        final files = dir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.mp3')) // Filter for mp3 files
            .map((file) => file.path)
            .toList();

        _downloadedFiles = files;
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing downloaded files: $e');
      _downloadedFiles = [];
      notifyListeners();
    }
  }

  void removeDownloadedFile(String filePath) {
    _downloadedFiles.remove(filePath);
    notifyListeners();
  }

  // Add this method to check if a file is already downloaded
  bool isFileDownloaded(String bookTitle, String chapterName) {
    final expectedFileName = '${bookTitle}_${chapterName}.mp3';
    return _downloadedFiles.any((path) => path.contains(expectedFileName));
  }

  BibleProvider() {
    // Fetch data from the API
    getTestaments();
  }
}
