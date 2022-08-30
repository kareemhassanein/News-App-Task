import '../model/country_model.dart';

class Defaults {
  static CountryModel getDefaultCountry() => CountryModel(
      code: 'US', emoji: '🇺🇸', name: 'United States', lang: 'en');

  static const String requestsPerPage = '15';
}
