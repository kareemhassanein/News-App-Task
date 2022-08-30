import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:news_app_task/constrant/defaults.dart';
import 'package:news_app_task/model/country_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences sharedPreferences;

  static initSharedPref() async {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white));
    sharedPreferences = await SharedPreferences.getInstance();
  }

  void saveCountry(CountryModel model) {
    sharedPreferences.setString('selected_country', jsonEncode(model));
  }

  CountryModel getCountry() {
    Map<String, dynamic> countryMap;
    final String? countryStr = sharedPreferences.getString('selected_country');
    if (countryStr != null && countryStr.isNotEmpty) {
      countryMap = jsonDecode(countryStr) as Map<String, dynamic>;
      return CountryModel.fromJson(countryMap);
    } else {
      return Defaults.getDefaultCountry();
    }
  }
}
