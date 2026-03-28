import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'weather_data.dart';

class ForecastCard extends StatelessWidget {
  const ForecastCard({super.key, required this.weather});

  final WeatherData weather;

  @override
  Widget build(BuildContext context) {
    final weekDayFormatter = DateFormat('E. HH:00');
    double normalFontSize = 13;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 13),
          Text(
            weekDayFormatter.format(weather.localTime),
            style: TextStyle(fontSize: normalFontSize),
          ),
          Container(
            width: 45,
            alignment: Alignment.centerRight,
            child: Icon(weather.weatherIcon, size: 30),
          ),

          if (weather.temp != null)
            Container(
              width: 50,
              alignment: Alignment.centerRight,

              child: Text(
                "${weather.temp!.toStringAsFixed(1)}°C",
                style: TextStyle(fontSize: normalFontSize),
              ),
            ),

          if (weather.cloudCover != null)
            Container(
              width: 63,
              alignment: Alignment.centerRight,
              child: Text(
                "⛅ ${weather.cloudCover!.toStringAsFixed(0)}%",
                style: TextStyle(fontSize: normalFontSize),
              ),
            ),
          if (weather.precipAmount != null)
            Container(
              width: 60,
              alignment: Alignment.centerRight,

              child: Text(
                "💧 ${weather.precipAmount!}mm",
                style: TextStyle(fontSize: normalFontSize),
              ),
            ),
        ],
      ),
    );
  }
}
