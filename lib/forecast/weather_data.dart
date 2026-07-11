import 'dart:math';

import 'package:flutter/material.dart';

class WeatherData {
  DateTime localTime;
  double? temp;
  int? cloudCover;
  double? precipAmount;
  int? precipProb;
  int? weatherCode;
  double? windSpeed;
  int? windDirection;
  double? pressure;

  WeatherData(this.localTime);

  IconData get weatherIcon {
    if (weatherCode == null) {
      return const IconData(0xE900, fontFamily: 'EasyWeatherIcons');
    }
    // Hint: to find the weatherCode for an icon, open
    // easy_weather_icons/easy_weather_icons_font_(fonts)/demo.html
    // and search in the Browser for the weather type, e.g. for "foggy"

    // 0: clear sky   1, 2, 3	Mainly clear, partly cloudy, and overcast
    if (weatherCode == 0) {
      return const IconData(0xE96D, fontFamily: 'EasyWeatherIcons');
    }
    if (weatherCode == 1) {
      return const IconData(0xE96A, fontFamily: 'EasyWeatherIcons');
    }
    if (weatherCode == 2) {
      return const IconData(0xE961, fontFamily: 'EasyWeatherIcons');
    }
    if (weatherCode == 3) {
      return const IconData(0xE9DF, fontFamily: 'EasyWeatherIcons');
    }
    // 45 fog
    if (weatherCode == 45) {
      return const IconData(0xE94E, fontFamily: 'EasyWeatherIcons');
    }
    // 51,53,55  Drizzle (dt.:"Nieselregen"): Light, moderate, and dense intensity
    if (weatherCode == 51 || weatherCode == 53 || weatherCode == 55) {
      return const IconData(0xE921, fontFamily: 'EasyWeatherIcons');
    }
    // 56, 57 Freezing Drizzle: Light and dense intensity
    if (weatherCode == 56 || weatherCode == 57) {
      return const IconData(0xE91E, fontFamily: 'EasyWeatherIcons');
    }
    // 61, 63, 65 Rain: Slight, moderate and heavy intensity
    if (weatherCode == 61) {
      return const IconData(0xEA00, fontFamily: 'EasyWeatherIcons');
    }
    if (weatherCode == 63) {
      return const IconData(0xE92E, fontFamily: 'EasyWeatherIcons');
    }
    if (weatherCode == 65) {
      return const IconData(0xEA03, fontFamily: 'EasyWeatherIcons');
    }
    // 71, 73, 75 Snow fall:    Slight, moderate, and heavy intensity
    // 77 Snow grain (dt: "Griesel"): not found in easy_weather_icons
    // 81, 83, 85 Snow showers: Slight, moderate, and heavy intensity
    if (weatherCode == 71 || weatherCode == 77 || weatherCode == 81) {
      return const IconData(0xE937, fontFamily: 'EasyWeatherIcons');
    }
    if (weatherCode == 73 || weatherCode == 83) {
      return const IconData(0xE934, fontFamily: 'EasyWeatherIcons');
    }
    if (weatherCode == 75 || weatherCode == 85) {
      return const IconData(0xE940, fontFamily: 'EasyWeatherIcons');
    }
    // 80, 81, 82	Rain showers: Slight, moderate, and violent
    if (weatherCode == 80) {
      return const IconData(0xE928, fontFamily: 'EasyWeatherIcons');
    }
    if (weatherCode == 81) {
      return const IconData(
        0xE931,
        fontFamily: 'EasyWeatherIcons',
      ); // no moderate found !
    }
    if (weatherCode == 82) {
      return const IconData(0xE931, fontFamily: 'EasyWeatherIcons');
    }
    return const IconData(0xE900, fontFamily: 'EasyWeatherIcons');
  }

  Widget get windDirectionIcon {
    // OpenMeteo windDirection = 0 means wind from north (info from ChatGPT).
    // Because navigation_outlined icon shows upward, we have to add 180° which is pi in radians
    var angle = windDirection != null ? windDirection! * pi / 180 + pi : 0.0;

    return Transform.rotate(
      angle: angle,
      child: Icon(Icons.navigation_outlined, size: 14),
    );
  }
}
