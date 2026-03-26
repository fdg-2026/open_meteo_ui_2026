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
}
