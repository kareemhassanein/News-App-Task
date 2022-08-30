import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:news_app_task/Utils/preference.dart';
import 'package:news_app_task/constrant/apis.dart';
import 'package:news_app_task/constrant/defaults.dart';
import 'package:news_app_task/model/news_model.dart';

class NewsRepo {
  Future<NewsModel> getNews(String page) async {
    Map<String, dynamic> params = {
      "apiKey": Apis.apiKey,
      "country": Preferences().getCountry().code.toLowerCase(),
      "page": page,
      "pageSize": Defaults.requestsPerPage,
    };
    var response = await http.get(
      Uri.parse(Uri.encodeFull(Apis.baseUrl)).replace(queryParameters: params),
    );
    print(response.body.toString());
    var decodedResponse = json.decode(response.body);
    NewsModel modelResponse = NewsModel.fromJson(decodedResponse);
    return modelResponse;
  }
}
