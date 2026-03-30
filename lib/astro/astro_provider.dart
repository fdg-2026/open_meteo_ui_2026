import 'dart:convert';
import '../location/location_provider.dart';
import 'package:http/http.dart' as http;

class AstroProvider {
  AstroProvider(this._locationProvider);

  final LocationProvider _locationProvider;

  String _sunrise = "?";
  String _sunset = "?";
  String _moonrise = "?";
  String _moonset = "?";

  String get sunrise => _sunrise;
  String get sunset => _sunset;
  String get moonrise => _moonrise;
  String get moonset => _moonset;

  Future<void> updateTimes() async {
    double lat = _locationProvider.selectedLocation.latitude;
    double lon = _locationProvider.selectedLocation.longitude;

    final String apiKey = "7593a58fc8a94324a758b00cf46e6eb5";
    final url =
        'https://api.ipgeolocation.io/v2/astronomy?apiKey=$apiKey&lat=$lat&long=$lon&elevation=0';

    //https://api.ipgeolocation.io/v2/astronomy?apiKey=7593a58fc8a94324a758b00cf46e6eb5&lat=49.97704&long=9.15214&elevation=0

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        final astronomy = data["astronomy"];
        if (astronomy is Map<String, dynamic>) {
          if (astronomy["sunrise"] is String) {
            _sunrise = astronomy["sunrise"];
          }
          if (astronomy["sunset"] is String) {
            _sunset = astronomy["sunset"];
          }
          if (astronomy["moonrise"] is String) {
            _moonrise = astronomy["moonrise"];
          }
          if (astronomy["moonset"] is String) {
            _moonset = astronomy["moonset"];
          }
        }
      }
    }
  }
}
