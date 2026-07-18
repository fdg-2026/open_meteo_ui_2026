import 'dart:collection';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        saveLocations();
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

  bool nameExists(String name) {
    var result = false;
    for (var location in _locations) {
      if (location.name == name) {
        return true;
      }
    }
    return result;
  }

  void addLocation(LocationData location) {
    if (location.name.isNotEmpty && !nameExists(location.name)) {
      _locations.add(location);
      _selectedLocationName = location.name;
      saveLocations();
    } else {
      throw ("addLocation: name ${location.name} is already used or not allowed");
    }
  }

  void deleteLocation(String name) {
    LocationData? toBeDeletedLocation;
    for (var location in _locations) {
      if (location.name == name) {
        toBeDeletedLocation = location;
        break;
      }
    }
    if (toBeDeletedLocation != null) {
      _locations.remove(toBeDeletedLocation);
      saveLocations();
    }
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

    loadLocations();

    if (_locations.isEmpty) {
      _locations.add(defaultLocation);
      _selectedLocationName = defaultLocation.name;
    }
  }

  void loadLocations() {
    _locations.clear();
    var sharedPrefsInstance = GetIt.instance<SharedPreferences>();
    var storedLocations = sharedPrefsInstance.getString("locations");
    if (storedLocations != null) {
      var storedList = jsonDecode(storedLocations);
      if (storedList is List<dynamic>) {
        for (var data in storedList) {
          if (data is Map<String, dynamic> && LocationData.isValidMap(data)) {
            var location = LocationData.fromMap(data);
            if (!nameExists(location.name)) {
              _locations.add(LocationData.fromMap(data));
            }
          }
        }
      }
    }
    String? nameToTest = sharedPrefsInstance.getString("selectedLocationName");
    if (nameToTest != null && nameExists(nameToTest)) {
      _selectedLocationName = nameToTest;
    } else {
      // something is corrupt, start from scratch
      _selectedLocationName = "";
      _locations.clear();
    }
  }

  void saveLocations() {
    // next line only works when LocationData has a method called "toJson"
    //var encoded = jsonEncode(_locations);
    List<dynamic> mapList = [];
    for (var location in _locations) {
      mapList.add(location.toMap());
    }
    var encoded = jsonEncode(mapList);
    var sharedPrefsInstance = GetIt.instance<SharedPreferences>();
    sharedPrefsInstance.setString("locations", encoded);
    sharedPrefsInstance.setString(
      "selectedLocationName",
      _selectedLocationName,
    );
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
