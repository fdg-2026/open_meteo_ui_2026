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

    var screenWidth = MediaQuery.of(context).size.width;

    double localTimeWidth = 75;
    double weatherIconWidth = 45;
    double tempWidth = 50;
    double cloudCoverWidth = 57;
    double windWidth = 73;
    double pressureWidth = 70;
    double precipProbWidth = 60;
    double precipAmountWidth = 58;

    double horizontalMargin = 6;

    var basicWidth =
        2 * horizontalMargin +
        localTimeWidth +
        weatherIconWidth +
        tempWidth +
        cloudCoverWidth +
        precipProbWidth;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 2),
      child: Row(
        children: [
          Container(
            width: localTimeWidth,
            alignment: Alignment.centerRight,
            child: Text(
              weekDayFormatter.format(weather.localTime),
              style: TextStyle(fontSize: normalFontSize),
            ),
          ),
          Container(
            width: weatherIconWidth,
            alignment: Alignment.centerRight,
            child: Icon(weather.weatherIcon, size: 30),
          ),
          // Text(
          //   "code:${weather.weatherCode}",
          //   style: TextStyle(fontSize: normalFontSize),
          // ),
          Container(
            width: tempWidth,
            alignment: Alignment.centerRight,
            child: (weather.temp != null)
                ? Text(
                    "${weather.temp!.toStringAsFixed(1)}°C",
                    style: TextStyle(fontSize: normalFontSize),
                  )
                : null,
          ),

          Container(
            width: cloudCoverWidth,
            alignment: Alignment.centerRight,
            child: (weather.cloudCover != null)
                ? Text(
                    "⛅ ${weather.cloudCover!.toStringAsFixed(0)}%",
                    style: TextStyle(fontSize: normalFontSize),
                  )
                : null,
          ),

          if (screenWidth > basicWidth + precipAmountWidth + windWidth)
            Container(
              width: windWidth,
              alignment: Alignment.centerRight,
              child:
                  (weather.windDirection != null && weather.windSpeed != null)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          " ${weather.windSpeed!.toStringAsFixed(0)}",
                          style: TextStyle(fontSize: normalFontSize),
                        ),
                        Text(
                          "km/h",
                          style: TextStyle(fontSize: normalFontSize - 1),
                        ),
                        weather.windDirectionIcon,
                      ],
                    )
                  : null,
            ),

          if (screenWidth >
              basicWidth + precipAmountWidth + windWidth + pressureWidth)
            Container(
              width: pressureWidth,
              alignment: Alignment.centerRight,
              child: (weather.pressure != null)
                  ? Text(
                      " ${weather.pressure!.toStringAsFixed(0)} hPa",
                      style: TextStyle(fontSize: normalFontSize),
                    )
                  : null,
            ),

          Container(
            width: precipProbWidth,
            alignment: Alignment.centerRight,
            child: (weather.precipProb != null)
                ? Text(
                    "💧 ${weather.precipProb!}%",
                    style: TextStyle(fontSize: normalFontSize),
                  )
                : null,
          ),

          if (weather.precipAmount != null &&
              weather.precipAmount! > 0 &&
              screenWidth > basicWidth + precipAmountWidth)
            Container(
              width: precipAmountWidth,
              alignment: Alignment.centerLeft,

              child: Text(
                " (${weather.precipAmount!.toStringAsFixed(1)}mm)",
                style: TextStyle(fontSize: normalFontSize),
              ),
            ),
        ],
      ),
    );
  }
}
