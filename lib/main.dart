import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_meteo_ui_2026/forecast/forecast_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'astro/astro_provider.dart';
import 'dart:ui' as ui;
import 'home_page.dart';
import 'l10n/app_localizations.dart';
import 'location/location_provider.dart';
import 'settings/settings_provider.dart';

void main() async {
  // without next line you get on Android the error "FlutterError (Binding has not yet been initialized ...)"
  WidgetsFlutterBinding.ensureInitialized();
  var sharedPrefsInstance = await SharedPreferences.getInstance();
  GetIt.instance.registerSingleton<SharedPreferences>(sharedPrefsInstance);

  _locationProvider = LocationProvider();
  _locationProvider.initialize();
  _forecastProvider = ForecastProvider(_locationProvider);
  await _forecastProvider.fetchHourlyForecast();
  var astroProvider = AstroProvider(_locationProvider);
  await astroProvider.updateTimes();
  GetIt.instance.registerSingleton<AstroProvider>(astroProvider);

  runApp(const MyApp());
}

late LocationProvider _locationProvider;
late ForecastProvider _forecastProvider;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = SettingsProvider(callbackOnSettingsChange: refresh);
    GetIt.instance.registerSingleton<SettingsProvider>(settingsProvider);

    super.initState();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // I wondered what happens when in Android the system language is e.g. Italian. We have no arb file for Italian!
    // But modern Android systems keep a list of preferred languages. This is logged with the next for-loop.
    // When "it" is on first position and e.g. "en" is on second, Android takes "en" as locale of the app.
    // When "de" is on second position, he takes "de". When the list has only one member and this is "it",
    // system looks at AppLocalizations.supportedLocales and takes the first from there (it is ordered alphabetically, so "de" is first).
    // I learned all that from https://chatgpt.com/share/6a6ceb75-56d4-83ed-befc-432314c8fb76
    debugPrint("preferred languages:");
    for (final locale in ui.PlatformDispatcher.instance.locales) {
      debugPrint(locale.toString());
    }

    return MaterialApp(
      // title from next line is displayed in Chrome tab
      title: 'Open Meteo UI 2026',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: AppBarTheme(centerTitle: true),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(centerTitle: true),
      ),
      themeMode: settingsProvider.settings.themeMode,
      // Configure localization delegates and supported locales
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // when you do not set locale here, the system's locale is used.
      //locale: Locale("de"),
      //locale: Locale("en"),
      locale: settingsProvider.settings.locale,
      home: HomePage(
        locationProvider: _locationProvider,
        forecastProvider: _forecastProvider,
      ),
    );
  }
}
