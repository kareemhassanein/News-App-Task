import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_task/model/news_model.dart';

import '../Utils/internet_connection.dart';
import '../repo/news_repo.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  NewsBloc() : super(NewInitial());
  Stream<NewsState> mapEventToState(
    NewsEvent event,
  ) async* {
    if (event is GetNewsEvent) {
      bool isConnected = await InternetConnection.isConnected();
      if (isConnected) {
        yield NewsLoadingState();
        NewsModel response = await NewsRepo().getNews(event.page);
        if (response.status == 'ok') {
          yield NewsLoadedState(response);
        } else {
          yield ErrorState(response.status);
        }
      } else {
        yield NetworkFailedState();
      }
    } else if (event is ResetState) {
      yield NewInitial();
    }
  }

  NewsState get initialState => NewInitial();
}
