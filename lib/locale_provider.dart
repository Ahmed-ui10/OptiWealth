import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for managing app localization (language settings)
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // Default locale is English
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar'; // Helper to check if Arabic

  LocaleProvider() {
    _loadLocale(); // Load saved locale on initialization
  }

  // Load saved language preference from SharedPreferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code');
    if (langCode != null && langCode.isNotEmpty) {
      _locale = Locale(langCode); // Use saved language
    } else {
      _locale = const Locale('en'); // Default to English if no preference
    }
    notifyListeners();
  }

  // Change the app's language
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return; // No change needed
    _locale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode); // Persist preference
    notifyListeners(); // Notify all listeners to rebuild with new locale
  }

  // Get current language code (e.g., 'en', 'ar')
  String getCurrentLanguage() => _locale.languageCode;
}