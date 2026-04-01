import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_meteo_ui_2026/forecast/forecast_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'astro/astro_provider.dart';
import 'home_page.dart';
import 'location/location_provider.dart';
import 'settings/settings_provider.dart';

void main() async {
  _locationProvider = LocationProvider();
  //_locationProvider.selectLocation("invalid");
  _forecastProvider = ForecastProvider(_locationProvider);
  await _forecastProvider.fetchHourlyForecast();
  var astroProvider = AstroProvider(_locationProvider);
  await astroProvider.updateTimes();
  GetIt.instance.registerSingleton<AstroProvider>(astroProvider);

  // without next line you get on Android the error "FlutterError (Binding has not yet been initialized ...)"
  WidgetsFlutterBinding.ensureInitialized();
  var sharedPrefsInstance = await SharedPreferences.getInstance();
  GetIt.instance.registerSingleton<SharedPreferences>(sharedPrefsInstance);

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
      ),
      themeMode: settingsProvider.settings.themeMode,
      home: HomePage(
        locationProvider: _locationProvider,
        forecastProvider: _forecastProvider,
      ),
    );
  }
}
