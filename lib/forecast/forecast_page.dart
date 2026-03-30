import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_meteo_ui_2026/astro/astro_widget.dart';

import '../location/location_provider.dart';
import '../main.dart';
import 'forecast_card.dart';
import 'forecast_provider.dart';

class ForecastPage extends StatefulWidget {
  const ForecastPage({
    super.key,
    required this.locationProvider,
    required this.forecastProvider,
  });

  final LocationProvider locationProvider;
  final ForecastProvider forecastProvider;

  @override
  State<ForecastPage> createState() => _ForecastPageState();
}

class _ForecastPageState extends State<ForecastPage> {
  bool loading = false;
  final leftPadding = 16.0;

  Future<void> refresh() async {
    loading = true;
    setState(() {});
    // uncomment next line to simulate long loading
    //await Future.delayed(const Duration(seconds: 2));
    await widget.forecastProvider.fetchHourlyForecast();
    await globalAstroProvider.updateTimes();
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var forecastExists = widget.forecastProvider.hourlyForecast.isNotEmpty;
    var screenHeight = MediaQuery.of(context).size.height;
    const minHeightForNextHourForecast = 420;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          getLocationSelection(),
          Divider(indent: leftPadding, endIndent: leftPadding),
          if (loading) const Center(child: CircularProgressIndicator()),
          if (!loading && !forecastExists)
            const Center(child: Text("No forecast available")),
          if (!loading &&
              forecastExists &&
              screenHeight > minHeightForNextHourForecast)
            Column(
              children: [
                getNextHourForecast(),
                Divider(indent: leftPadding, endIndent: leftPadding),
              ],
            ),
          if (!loading && forecastExists)
            // without Expanded user cannot scroll and gets an overflow at the bottom
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var e in widget.forecastProvider.hourlyForecast)
                      ForecastCard(weather: e),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Row getLocationSelection() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: leftPadding),
          child: Text("Weather in: ", style: TextStyle(fontSize: 18)),
        ),
        DropdownButton<String>(
          borderRadius: BorderRadius.circular(10),
          value: widget.locationProvider.selectedLocation.name,
          items: getLocationDropDownItems(),
          onChanged: (value) async {
            if (value != null) {
              widget.locationProvider.selectLocation(value);
              refresh();
            }
          },
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> getLocationDropDownItems() {
    List<DropdownMenuItem<String>> result = [];
    List<String> names = widget.locationProvider.getLocationNames();
    for (var name in names) {
      result.add(
        DropdownMenuItem<String>(
          value: name,
          child: Text(name, style: TextStyle(fontSize: 18)),
        ),
      );
    }
    return result;
  }

  Widget getNextHourForecast() {
    final weather = widget.forecastProvider.hourlyForecast.first;
    final fullDateFormatter = DateFormat(
      'E dd-MMM HH:mm',
      Localizations.localeOf(context).toString(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: leftPadding),
            Text(
              "Forecast for ${fullDateFormatter.format(weather.localTime)}",
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(" (local time)", style: const TextStyle(fontSize: 15)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(width: leftPadding + 4),
            Icon(weather.weatherIcon, size: 40),
            // a VerticalDivider is not displayed inside a Row unless it is wrapped in a Container
            // or SizedBox (see https://chatgpt.com/share/69c98599-d3bc-8331-85b8-c83de3a70b84)
            SizedBox(
              height: 70,
              child: VerticalDivider(width: 23, thickness: 1),
            ),
            getNextHourWeatherDetails(),
            SizedBox(
              height: 70,
              child: VerticalDivider(width: 23, thickness: 1),
            ),
            AstroWidget(),
          ],
        ),
      ],
    );
  }

  Widget getNextHourWeatherDetails() {
    final weather = widget.forecastProvider.hourlyForecast.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (weather.temp != null) Text("temp.: ${weather.temp}°C"),
        if (weather.cloudCover != null) Text("clouds: ${weather.cloudCover}%"),
        Row(
          children: [
            Text("wind:"),
            Text(
              weather.windSpeed != null
                  ? " ${weather.windSpeed!.toStringAsFixed(0)}km/h"
                  : "",
            ),
            weather.windDirectionIcon,
          ],
        ),
      ],
    );
  }
}
