import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;

  final Map<String, Map<String, String>> _cache = {};
  Map<String, String> _localizedStrings = {};
  String? _loadedLanguageCode;

  LocalizationService._internal();

  /// Loads translations for [languageCode] from assets.
  /// Uses a cache to avoid redundant loads.
  Future<void> loadLanguage(String languageCode) async {
    if (_loadedLanguageCode == languageCode) return;
    if (_cache.containsKey(languageCode)) {
      _localizedStrings = _cache[languageCode]!;
      _loadedLanguageCode = languageCode;
      return;
    }

    String jsonString =
        await rootBundle.loadString('assets/lang/$languageCode.json');
    Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));

    _cache[languageCode] = _localizedStrings;
    _loadedLanguageCode = languageCode;
  }

  /// Returns the translation for the provided [key].
  /// If not found, returns [key].
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}
