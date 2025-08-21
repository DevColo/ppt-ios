import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:precious/API/collections_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionsProvider with ChangeNotifier {
  final CollectionsApi _collectionsApi = CollectionsApi();

  List<dynamic> _collections = [];
  List<dynamic> get collections => _collections;

  String _selectedLanguage = '';
  String get selectedLanguage => _selectedLanguage;

  // Save collections to shared preferences
  Future<void> _saveCollectionsToPrefs(List<dynamic> collections) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('collections', jsonEncode(collections));
  }

  // Load collections from shared preferences
  Future<void> _loadCollectionsFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? collectionsString = prefs.getString('collections');
    if (collectionsString != null) {
      _collections = jsonDecode(collectionsString);
      notifyListeners();
    }
  }

  // Save selected language to shared preferences
  Future<void> _saveLanguageToPrefs(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
  }

  // Load selected language from shared preferences
  Future<void> _loadLanguageFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('selectedLanguage');
    if (language != null) {
      _selectedLanguage = language;
      notifyListeners();
    }
  }

  // Setter to update collections and save to shared preferences
  void setCollections(List<dynamic> newCollections) {
    _collections = newCollections;
    notifyListeners();
    _saveCollectionsToPrefs(newCollections);
  }

  // Fetch all collections from the API
  Future<void> getAllCollections() async {
    try {
      final collections = await _collectionsApi.getCollections();
      setCollections(collections);
    } catch (e) {
      print('Error fetching collections: $e');
    }
  }

  // Function to send selected language to the backend
  Future<void> selectLanguage(String language) async {
    try {
      // Save selected language locally
      _selectedLanguage = language;
      _saveLanguageToPrefs(language);

      // Notify listeners if any UI needs to update
      notifyListeners();
    } catch (e) {
      // Handle error
      print('Error selecting language: $e');
    }
  }

  // Constructor
  CollectionsProvider() {
    // Load data from shared preferences on initialization
    _loadCollectionsFromPrefs();
    _loadLanguageFromPrefs(); // Load the selected language from prefs

    // Fetch data from the API
    getAllCollections();
  }
}
