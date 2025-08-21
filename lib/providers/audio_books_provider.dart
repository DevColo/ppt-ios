import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:precious/API/audio_books_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioBooksProvider with ChangeNotifier {
  List<dynamic> _audioBooks = [];
  List<dynamic> get audioBooks => _audioBooks;

  List<dynamic> _books = [];
  List<dynamic> get books => _books;

  List<dynamic> _categoryBooks = [];
  List<dynamic> get categoryBooks => _categoryBooks;

  Map<int, double> downloadProgress = {};
  Map<int, bool> downloadComplete = {};

  List<String> _downloadedFiles = [];

  List<String> get downloadedFiles => _downloadedFiles;

  // Audio Books
  Future<void> _saveAudioBooksToPrefs(List<dynamic> audioBooks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('audioBooks', jsonEncode(audioBooks));
  }

  void setAudioBooks(List<dynamic> audioBooks) {
    _audioBooks = audioBooks;
    notifyListeners();
    _saveAudioBooksToPrefs(audioBooks);
  }

  Future<void> getAudioBooks() async {
    try {
      // Fetch the selected language from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedLanguage =
          prefs.getString('selectedLanguage') ?? 'Kinyarwanda';

      // Pass the selected language to the API call
      final audioBooks =
          await AudioBooksApi().getAudioBooksAPI(language: selectedLanguage);
      setAudioBooks(audioBooks);
    } catch (e) {
      print('Error fetching audio books: $e');
    }
  }

  // BOOKS
  Future<void> _saveBooksToPrefs(List<dynamic> books) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('books', jsonEncode(books));
  }

  void setBooks(List<dynamic> books) {
    _books = books;
    notifyListeners();
    _saveBooksToPrefs(books);
  }

  Future<void> getBooks(BuildContext context, int bookId) async {
    try {
      final books = await AudioBooksApi().getBookAPI(bookId: bookId);
      setBooks(books);
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

  // CATEGORY BOOKS
  Future<void> _saveCategoryBooksToPrefs(List<dynamic> categoryBooks) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('categoryBooks', jsonEncode(categoryBooks));
  }

  void setCategoryBooks(List<dynamic> categoryBooks) {
    _categoryBooks = categoryBooks;
    notifyListeners();
    _saveCategoryBooksToPrefs(categoryBooks);
  }

  Future<void> getCategoryBooks(BuildContext context, int categoryId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedLanguage =
          prefs.getString('selectedLanguage') ?? 'Kinyarwanda';
      final books = await AudioBooksApi().getCategoryBooksAPI(
          language: selectedLanguage, categoryId: categoryId);
      setCategoryBooks(books);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please check internet connection and try again.",
            style: TextStyle(color: Colors.red),
          ),
          backgroundColor: Color.fromARGB(255, 255, 216, 203),
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

  AudioBooksProvider() {
    // Fetch data from the API
    getAudioBooks();
  }
}
