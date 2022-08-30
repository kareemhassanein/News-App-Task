import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class LanguageHelper {
  static bool _isEnglish = true;

  static bool get isEnglish => _isEnglish;
  static const String _prefSelectedLanguageCode = "SelectedLanguageCode";

  static Future<Locale> getLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString(_prefSelectedLanguageCode) ?? 'en';
    _isEnglish = languageCode == "en" ? true : false;
    return _locale(languageCode);
  }

  static Locale _locale(String languageCode) {
    return languageCode.isNotEmpty
        ? Locale(languageCode, '')
        : const Locale("en", '');
  }

  static Future changeLanguage(
      BuildContext context, String selectedLanguageCode) async {
    _isEnglish = selectedLanguageCode == "en" ? true : false;
    var locale = await _setLocale(selectedLanguageCode);
    StartApp.setLocale(context, locale);
  }

  static Future<Locale> _setLocale(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefSelectedLanguageCode, languageCode);
    return _locale(languageCode);
  }
}
