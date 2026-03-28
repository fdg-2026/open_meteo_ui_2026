import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../location/location_provider.dart';
import 'weather_data.dart';

class ForecastProvider {
  ForecastProvider(this._locationProvider, {http.Client? client})
    : _client = client ?? http.Client();

  final LocationProvider _locationProvider;
  final http.Client _client; // Use this instead of the static http.get
  List<WeatherData> hourlyForecast = [];
  bool _initialized = false;

  void _initialize() {
    tz.initializeTimeZones();
  }

  Future<bool> fetchHourlyForecast() async {
    if (!_initialized) {
      _initialize();
      _initialized = true;
    }

    hourlyForecast.clear();
    var lat = _locationProvider.selectedLocation.latitude;
    var lon = _locationProvider.selectedLocation.longitude;

    // 'https://api.open-meteo.com/v1/forecast?latitude=49.97606&longitude=9.14163&hourly=temperature_2m,precipitation,cloud_cover&forecast_days=1';
    final url =
        "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&hourly=temperature_2m,precipitation,cloud_cover,weather_code"
        "&forecast_days=3";

    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      // don't use "print" in production code (ToDo: implement better logging)
      developer.log(
        "statusCode in response from open-meteo api was ${response.statusCode}",
      );
      return (false);
    }

    final data = jsonDecode(response.body);

    List<String> times = [];
    List<double?> temps = [];
    List<double?> precipAmounts = [];
    List<int?> cloudCovers = [];
    List<int?> weatherCodes = [];

    times = List<String>.from(data['hourly']['time']);
    temps = List<double?>.from(data['hourly']['temperature_2m']);
    precipAmounts = List<double?>.from(data['hourly']['precipitation']);
    cloudCovers = List<int?>.from(data['hourly']['cloud_cover']);
    weatherCodes = List<int?>.from(data['hourly']['weather_code']);

    var timezoneName = latLngToTimezoneString(lat, lon);
    final tzLocation = tz.getLocation(timezoneName);
    final nowInUtc = DateTime.now().toUtc();

    for (int i = 0; i < times.length; i++) {
      final timeInUtc = DateTime.parse("${times[i]}Z");
      if (timeInUtc.isAfter(nowInUtc)) {
        final localTime = tz.TZDateTime.from(timeInUtc, tzLocation);
        var data = WeatherData(localTime);
        data.temp = temps[i];
        data.precipAmount = precipAmounts[i];
        data.cloudCover = cloudCovers[i];
        data.weatherCode = weatherCodes[i];
        hourlyForecast.add(data);
      }
    }
    return true;
  }
}
