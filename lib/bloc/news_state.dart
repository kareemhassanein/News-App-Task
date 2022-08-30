import '../model/news_model.dart';

abstract class NewsState {}

class NewInitial extends NewsState {}

class NewsLoadingState extends NewsState {}

class NewsLoadedState extends NewsState {
  NewsModel newsModel;
  NewsLoadedState(this.newsModel);
}

class NetworkFailedState extends NewsState {}

class ErrorState extends NewsState {
  late String msg;
  ErrorState(this.msg);
}
