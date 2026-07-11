import 'package:flutter/material.dart';

import 'forecast/forecast_page.dart';
import 'forecast/forecast_provider.dart';
import 'location/location_provider.dart';
import 'radar/radar_page.dart';
import 'settings/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.locationProvider,
    required this.forecastProvider,
  });

  final LocationProvider locationProvider;
  final ForecastProvider forecastProvider;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 1;

  @override
  Widget build(BuildContext context) {
    var screens = [
      ForecastPage(
        locationProvider: widget.locationProvider,
        forecastProvider: widget.forecastProvider,
      ),
      RadarPage(locationProvider: widget.locationProvider),
    ];

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Open Meteo UI 2026"),
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Image.asset('assets/images/flutter_logo.png'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, thickness: 1),
        ),
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
