import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:precious/API/categories_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoriesProvider with ChangeNotifier {
  final CategoriesApi _categoriesApi = CategoriesApi();

  List<dynamic> _categories = [];
  List<dynamic> get categories => _categories;

  String _selectedLanguage = '';
  String get selectedLanguage => _selectedLanguage;

  // Save categories to shared preferences
  Future<void> _saveCategoriesToPrefs(List<dynamic> categories) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('categories', jsonEncode(categories));
  }

  // Load categories from shared preferences
  Future<void> _loadCategoriesFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? categoriesString = prefs.getString('categories');
    if (categoriesString != null) {
      _categories = jsonDecode(categoriesString);
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

  // Setter to update categories and save to shared preferences
  void setCategories(List<dynamic> newCategories) {
    _categories = newCategories;
    notifyListeners();
    _saveCategoriesToPrefs(newCategories);
  }

  // Fetch all categories from the API
  Future<void> getAllCategories() async {
    try {
      final categories = await _categoriesApi.getCategories();
      setCategories(categories);
    } catch (e) {
      print('Error fetching categories: $e');
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
  CategoriesProvider() {
    // Load data from shared preferences on initialization
    _loadCategoriesFromPrefs();
    _loadLanguageFromPrefs();

    // Fetch data from the API
    getAllCategories();
  }
}
