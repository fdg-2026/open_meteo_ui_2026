import 'dart:collection';
import 'dart:developer' as developer;
import 'dart:convert';
import 'location_data.dart';
import 'package:http/http.dart' as http;

class LocationProvider {
  final List<LocationData> _locations = [];
  List<LocationData> get locations => UnmodifiableListView(_locations);

  String _selectedLocationName = "Aschaffenburg";

  bool selectLocation(String name) {
    for (var location in _locations) {
      if (location.name == name) {
        _selectedLocationName = location.name;
        return true;
      }
    }
    // don't use "print" in production code (ToDo: implement better logging)
    developer.log("selectLocation: location $name not found");
    return false;
  }

  LocationData get selectedLocation {
    LocationData? result;
    // for (var location in _locations) {
    //   if (location.name == _selectedLocationName) {
    //     result = location;
    //   }
    // }
    // if (result == null) {
    //   throw ("getter selectedLocation: "
    //       "did not find $_selectedLocationName");
    // }

    result = _locations.firstWhere(
      (element) => element.name == _selectedLocationName,
    );

    return result;
  }

  List<String> getLocationNames() {
    // List<String> result = [];
    // for (var location in _locations) {
    //   result.add(location.name);
    // }
    // return result;

    return _locations.map((data) => data.name).toList();
  }

  void addLocation(LocationData location) {
    _locations.add(location);
    _selectedLocationName = location.name;
  }

  void initialize() {
    var defaultLocation = LocationData(
      name: "Aschaffenburg",
      // location of the center of Schloss Johannisburg:
      latitude: 49.97606,
      longitude: 9.14163,
      // // location of TH Aschaffenburg in Google Maps:
      // latidude: 49.97198,
      // longitude: 9.16138,
    );
    defaultLocation.country = "Deutschland";
    defaultLocation.admin1 = "Bayern";
    defaultLocation.admin3 = "Kreisfreie Stadt Aschaffenburg";
    defaultLocation.featureCode = "PPL"; // populated place
    defaultLocation.timezone = "Europe/Berlin";
    _locations.add(defaultLocation);
    _selectedLocationName = defaultLocation.name;
  }

  // BTW: the geocoding api of open-meteo is quite strict, e.g. it does not know Grossostheim, only Großostheim
  // I tried other apis like
  // https://nominatim.openstreetmap.org/search?q=Aschaffenburg&format=json&addressdetails=1&limit=10
  // They know Grossostheim at the end, but only when you have typed the full word,
  // you do not get suggestions before, same for "Aschaf" for example.

  Future<List<LocationData>> getLocationProposals(String text) async {
    List<LocationData> result = [];

    final url =
        'https://geocoding-api.open-meteo.com/v1/search?name=$text&count=10&language=de&feature_code=PPL,PPLA,PPLC&format=json';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['results'] is List<dynamic>) {
        for (var entry in data['results']) {
          if (entry is Map<String, dynamic> && LocationData.isValidMap(entry)) {
            result.add(LocationData.fromMap(entry));
          }
        }
      }
    }
    return result;
  }
}
