import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:news_app_task/Utils/Localization/AppLocalizationDelgate.dart';
import 'package:news_app_task/Utils/preference.dart';
import 'package:news_app_task/constrant/colors.dart';
import 'package:news_app_task/ui/screens/home_screen.dart';

import 'Utils/Localization/LanguageHelper.dart';

void main() async {
  await Preferences.initSharedPref();
  runApp(const StartApp());
}

class StartApp extends StatefulWidget {
  const StartApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    var state = context.findAncestorStateOfType<_StartAppState>();
    state!.setLocale(newLocale);
  }

  @override
  _StartAppState createState() => _StartAppState();
}

class _StartAppState extends State<StartApp> {
  Locale? _locale;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          systemStatusBarContrastEnforced: true,
          statusBarColor: AppColors.primaryColor,
          statusBarIconBrightness:
              Platform.isAndroid ? Brightness.light : Brightness.dark,
          statusBarBrightness:
              Platform.isAndroid ? Brightness.light : Brightness.dark),
      child: MaterialApp(
        theme: ThemeData(
          backgroundColor: AppColors.backgroundColor,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: AppColors.primaryColor,
            selectionColor: AppColors.primaryColor.withOpacity(0.5),
            selectionHandleColor: AppColors.primaryColor.withAlpha(90),
          ),
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(secondary: AppColors.primaryColor),
        ).copyWith(
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
            },
          ),
          splashFactory: NoSplash.splashFactory,
        ),
        debugShowCheckedModeBanner: false,
        // home: Preferences().getUserInfo() != null && Preferences().getUserInfo().data.isRemember ? MainScreen() : WelcomeScreen() ,
        home: HomeScreen(),
        locale: _locale,
        supportedLocales: supportedLocales,
        localizationsDelegates: localizationsDelegates,
        localeResolutionCallback: localeResolutionCallback,
      ),
    );
  }

  @override
  void didChangeDependencies() async {
    LanguageHelper.getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }
}

extension Localization on _StartAppState {
  Iterable<Locale> get supportedLocales => [
        const Locale('en', ''),
        const Locale('ar', ''),
      ];

  Iterable<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  LocaleResolutionCallback get localeResolutionCallback =>
      (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode &&
              supportedLocale.countryCode == locale?.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      };
}
