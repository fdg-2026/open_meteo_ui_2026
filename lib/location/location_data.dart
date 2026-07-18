class LocationData {
  LocationData({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  // an alternative would be a c-tor with positional parameters:
  //LocationData.pos(this.name, this.latidude, this.longitude);

  final String name;
  final double latitude;
  final double longitude;
  String? country;
  String? admin1; // Bundesland
  String? admin3; // Kreis
  // For a list of all featureCodes see https://www.geonames.org/export/codes.html
  // E.g. when searching for Hanau, there is one result with featureCode AIRF = "a place on land where aircraft land and take off".
  // In our autocompletion list, we take at the moment all results from geocoding-api where featureCode starts with "P".
  // ToDo: shall we only take those results starting with "PPL" (populated place) ?
  String? featureCode;
  String timezone = "";

  String get details {
    var result = "";
    if (country != null) {
      result += country!;
    }
    if (admin1 != null) {
      result += " - ${admin1!}";
    }
    if (admin3 != null) {
      result += " - ${admin3!}";
    }
    return result;
  }

  static bool isValidMap(Map<String, dynamic> data) {
    var result = false;
    var name = data["name"] as String?;
    var featureCode = data["feature_code"] as String?;
    var timezone = data["timezone"] as String?;
    if (name != null &&
        featureCode != null &&
        timezone != null &&
        data["latitude"] is double &&
        data["longitude"] is double) {
      result =
          name.length > 1 && timezone.isNotEmpty && featureCode.startsWith("P");
    }
    return result;
  }

  factory LocationData.fromMap(Map<String, dynamic> data) {
    var result = LocationData(name: "unknown", latitude: 0, longitude: 0);
    if (isValidMap(data)) {
      result = LocationData(
        name: data["name"],
        latitude: data["latitude"],
        longitude: data["longitude"],
      );
      result.country = data["country"];
      result.admin1 = data["admin1"];
      result.admin3 = data["admin3"];
      result.featureCode = data["feature_code"];
      result.timezone = data["timezone"];
    }
    return result;
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'country': country,
    'admin1': admin1,
    'admin3': admin3,
    'feature_code': featureCode,
    'timezone': timezone,
  };
}
