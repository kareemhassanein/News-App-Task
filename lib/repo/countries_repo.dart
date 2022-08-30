import 'package:flutter/services.dart';
import 'package:news_app_task/model/country_model.dart';

class CountriesRepo {
  Future<List<CountryModel>> getAllCountries() async {
    return countriesModelFromJson(
        await rootBundle.loadString("assets/countries.json"));
  }
}
