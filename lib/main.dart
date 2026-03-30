import 'package:flutter/material.dart';
import 'package:open_meteo_ui_2026/forecast/forecast_provider.dart';

import 'astro/astro_provider.dart';
import 'home_page.dart';
import 'location/location_provider.dart';

void main() async {
  _locationProvider = LocationProvider();
  //_locationProvider.selectLocation("invalid");
  _forecastProvider = ForecastProvider(_locationProvider);
  await _forecastProvider.fetchHourlyForecast();
  globalAstroProvider = AstroProvider(_locationProvider);
  await globalAstroProvider.updateTimes();
  runApp(const MyApp());
}

late LocationProvider _locationProvider;
late ForecastProvider _forecastProvider;
late AstroProvider globalAstroProvider;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title from next line is displayed in Chrome tab
      title: 'Open Meteo UI 2026',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: AppBarTheme(centerTitle: true),
      ),
      home: HomePage(
        locationProvider: _locationProvider,
        forecastProvider: _forecastProvider,
      ),
    );
  }
}
