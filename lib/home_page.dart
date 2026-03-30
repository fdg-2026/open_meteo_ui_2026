import 'package:flutter/material.dart';
import 'astro/astro_provider.dart';
import 'forecast/forecast_page.dart';
import 'forecast/forecast_provider.dart';
import 'location/location_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.locationProvider,
    required this.forecastProvider,
    required this.astroProvider,
  });

  final LocationProvider locationProvider;
  final ForecastProvider forecastProvider;
  final AstroProvider astroProvider;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    var screens = [
      ForecastPage(
        locationProvider: widget.locationProvider,
        forecastProvider: widget.forecastProvider,
        astroProvider: widget.astroProvider,
      ),
      const Center(child: Text("radar page")),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Open Meteo UI 2026"),
      ),
      body: SafeArea(child: screens[_currentTab]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            label: "forecast",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.radar), label: "radar"),
        ],
      ),
    );
  }
}
