import 'package:flutter/material.dart';

import '../location/location_provider.dart';
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
    loading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var forecastExists = widget.forecastProvider.hourlyForecast.isNotEmpty;
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
          if (!loading && forecastExists)
            Text(
              "forecast for ${widget.forecastProvider.hourlyForecast[0].localTime}",
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
}
