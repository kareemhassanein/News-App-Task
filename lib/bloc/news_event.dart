abstract class NewsEvent {}

class GetNewsEvent extends NewsEvent {
  String page;
  GetNewsEvent(this.page);
}

class ResetState extends NewsEvent {}
