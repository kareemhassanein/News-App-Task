import 'dart:convert';

List<CountryModel> countriesModelFromJson(String str) =>
    List<CountryModel>.from(
        json.decode(str).map((x) => CountryModel.fromJson(x)));

String countriesModelToJson(List<CountryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CountryModel {
  CountryModel({
    required this.code,
    required this.emoji,
    required this.name,
    required this.lang,
  });

  String code;
  String emoji;
  String name;
  String lang;

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        code: json["code"],
        emoji: json["emoji"],
        name: json["name"],
        lang: json["lang"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "emoji": emoji,
        "name": name,
        "lang": lang,
      };
}
