import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_app_task/Utils/Localization/Language/Languages.dart';
import 'package:news_app_task/Utils/Localization/LanguageHelper.dart';
import 'package:news_app_task/Utils/preference.dart';
import 'package:news_app_task/bloc/news_bloc.dart';
import 'package:news_app_task/bloc/news_event.dart';
import 'package:news_app_task/bloc/news_state.dart';
import 'package:news_app_task/constrant/colors.dart';
import 'package:news_app_task/constrant/defaults.dart';
import 'package:news_app_task/model/country_model.dart';
import 'package:news_app_task/model/news_model.dart';
import 'package:news_app_task/repo/countries_repo.dart';
import 'package:news_app_task/repo/news_repo.dart';
import 'package:news_app_task/ui/widgets.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NewsBloc newsBloc;
  NewsModel newsModel = NewsModel(status: 'loading', articles: []);
  int currentOrderPage = 1;
  bool lastArticles = false;
  bool isLoading = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    newsBloc = NewsBloc()..add(GetNewsEvent(currentOrderPage.toString()));
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.offset >=
                _scrollController.position.maxScrollExtent &&
            !isLoading &&
            !lastArticles) {
          currentOrderPage++;
          newsBloc.add(GetNewsEvent(currentOrderPage.toString()));
        }
      });
  }

  Future<void> refreshNews() async {
    currentOrderPage = 1;
    lastArticles = false;
    dynamic response = await NewsRepo().getNews(currentOrderPage.toString());
    if (response.status == 'ok') {
      newsBloc.emit(NewsLoadedState(response));
    } else {
      newsBloc.emit(ErrorState(response.status));
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              Languages.of(context)!.topHeadlines,
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  fontSize: 18),
            ),
          ),
          actions: <Widget>[
            PopupMenuButton<PopupMenuButton>(
                tooltip: 'Options',
                offset: const Offset(0, 16),
                icon: const Icon(Icons.settings_rounded),
                position: PopupMenuPosition.under,
                color: AppColors.primaryColor,
                elevation: 0,
                shape: const TooltipShape(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            showDialog(
                              context: context,
                              barrierColor: Colors.black26,
                              builder: (_) => Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 200),
                                height: MediaQuery.of(context).size.height / 2,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Scaffold(
                                    body: FutureBuilder<List<CountryModel>>(
                                        future:
                                            CountriesRepo().getAllCountries(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.data
                                                  is List<CountryModel> &&
                                              snapshot.data != null) {
                                            List<CountryModel> countries =
                                                snapshot.data!;
                                            return ListView.builder(
                                                itemCount: countries.length,
                                                itemBuilder: (c, i) => ListTile(
                                                      onTap: () {
                                                        Navigator.pop(context,
                                                            countries[i]);
                                                      },
                                                      trailing: Text(
                                                        countries[i].emoji,
                                                        style:
                                                            GoogleFonts.cairo(
                                                                color: AppColors
                                                                    .txtColor,
                                                                fontSize: 16),
                                                      ),
                                                      title: Text(
                                                        countries[i].name,
                                                        style:
                                                            GoogleFonts.cairo(
                                                                color: AppColors
                                                                    .txtColor,
                                                                fontSize: 16),
                                                      ),
                                                    ));
                                          } else {
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        AppColors.primaryColor),
                                                strokeWidth: 1.4,
                                              ),
                                            );
                                          }
                                        }),
                                  ),
                                ),
                              ),
                            ).then((value) async {
                              if (value != null) {
                                Preferences().saveCountry(value);
                                await LanguageHelper.changeLanguage(
                                    context, Preferences().getCountry().lang);
                                refreshNews();
                              }
                            });
                          });
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              Languages.of(context)!.country,
                              style: GoogleFonts.cairo(
                                  color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              Preferences().getCountry().emoji,
                              style: GoogleFonts.cairo(
                                  color: Colors.white, fontSize: 16),
                            ),
                          ],
                        )),
                  ];
                }),
          ],
          backgroundColor: AppColors.primaryColor,
          elevation: 2,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.only(
                  bottomStart: Radius.circular(24))),
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.backgroundColor,
        body: RefreshIndicator(
          displacement: 24,
          edgeOffset: 50,
          color: AppColors.primaryColor,
          backgroundColor: Colors.white,
          onRefresh: refreshNews,
          child: BlocBuilder(
            bloc: newsBloc,
            builder: (context, snapshot) {
              if (snapshot is NewsLoadingState) {
                isLoading = true;
              } else if (snapshot is NetworkFailedState) {
                isLoading = false;
                Fluttertoast.showToast(msg: 'تأكد من اتصالك بالشبكة');
              } else if (snapshot is ErrorState) {
                isLoading = false;
                Fluttertoast.showToast(msg: snapshot.msg);
              } else if (snapshot is NewsLoadedState) {
                isLoading = false;
                lastArticles = snapshot.newsModel.articles.length <
                    int.parse(Defaults.requestsPerPage);
                if (currentOrderPage != 1) {
                  newsModel.articles.addAll(snapshot.newsModel.articles);
                } else {
                  newsModel = snapshot.newsModel;
                }
              }
              timeago.setLocaleMessages(
                  'en',
                  LanguageHelper.isEnglish
                      ? timeago.EnShortMessages()
                      : timeago.ArShortMessages());
              return isLoading && currentOrderPage == 1
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor),
                        strokeWidth: 1.4,
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16, top: 76),
                      itemCount: newsModel.articles.length + 1,
                      itemBuilder: (context, i) =>
                          i != newsModel.articles.length
                              ? _articleItem(newsModel.articles[i])
                              : SizedBox(
                                  height: !lastArticles ? 50.0 : 0.0,
                                  child: Visibility(
                                    visible: isLoading && currentOrderPage != 1,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppColors.primaryColor),
                                        strokeWidth: 1.4,
                                      ),
                                    ),
                                  ),
                                ),
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _articleItem(Article article) {
    return GestureDetector(
      onTap: () {
        _launchInBrowser(article.url ?? '');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: loadImage(article.urlToImage, fit: BoxFit.cover),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          article.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                              color: AppColors.txtColor,
                              fontSize: 13),
                          textAlign: TextAlign.start,
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          article.description ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.normal,
                              height: 1.4,
                              color: AppColors.txtColor.withOpacity(0.7),
                              fontSize: 13),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  article.source?.name ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.normal,
                                      height: 1.4,
                                      color: AppColors.primaryColor,
                                      fontSize: 11),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.access_time_rounded,
                                      color: AppColors.txtColor,
                                      size: 13,
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Text(
                                      timeago.format(
                                        article.publishedAt ?? DateTime.now(),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                          color: AppColors.txtColor,
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchInBrowser(String url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
}

class TooltipShape extends ShapeBorder {
  const TooltipShape();

  final BorderSide _side = BorderSide.none;
  final BorderRadiusGeometry _borderRadius = BorderRadius.zero;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(_side.width);

  @override
  Path getInnerPath(
    Rect rect, {
    TextDirection? textDirection,
  }) {
    final Path path = Path();

    path.addRRect(
      _borderRadius.resolve(textDirection).toRRect(rect).deflate(_side.width),
    );

    return path;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path();
    final RRect rrect = _borderRadius.resolve(textDirection).toRRect(rect);
    path.moveTo(0, 10);
    path.quadraticBezierTo(0, 0, 10, 0);
    path.lineTo(rrect.width - 30, 0);
    path.lineTo(rrect.width - 20, -10);
    path.lineTo(rrect.width - 10, 0);
    path.quadraticBezierTo(rrect.width, 0, rrect.width, 10);
    path.lineTo(rrect.width, rrect.height - 10);
    path.quadraticBezierTo(
        rrect.width, rrect.height, rrect.width - 10, rrect.height);
    path.lineTo(10, rrect.height);
    path.quadraticBezierTo(0, rrect.height, 0, rrect.height - 10);

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => RoundedRectangleBorder(
        side: _side.scale(t),
        borderRadius: _borderRadius * t,
      );
}
