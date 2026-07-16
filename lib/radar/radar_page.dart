import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart';
import 'package:latlong2/latlong.dart';
import 'package:timezone/timezone.dart' as tz;
import '../location/location_provider.dart';

class RadarPage extends StatefulWidget {
  const RadarPage({super.key, required this.locationProvider});

  final LocationProvider locationProvider;

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> {
  List<String> tileUrls = [];
  List<String> tileTimes = [];
  int currentTileIndex = -1;
  Timer? _timer;
  bool isTimerActive = false;
  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    fetchTileUrls();
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
      if (isTimerActive && tileUrls.isNotEmpty) {
        setState(() {
          if (currentTileIndex >= tileUrls.length - 1) {
            isTimerActive = false;
          } else {
            currentTileIndex++;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchTileUrls() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.rainviewer.com/public/weather-maps.json'),
      );
      if (response.statusCode != 200) {
        debugPrint("statusCode from rainviewer api was ${response.statusCode}");
        return;
      }
      final data = json.decode(response.body);
      decodeData(data);
    } catch (e) {
      debugPrint("exception in fetchTileUrls: $e");
    }
    // Set the current frame to the most recent one
    if (tileUrls.isNotEmpty) {
      currentTileIndex = tileUrls.length - 1;
    }
    setState(() {});
  }

  void decodeData(data) {
    final String host = data['host'];
    final List<dynamic> pastEntries = data['radar']['past'];

    // an entry under "past" looks like that:  {"time":1759170000,"path":"/v2/radar/1759170000"}
    // Construct the full tile URLs (host is "https://tilecache.rainviewer.com")
    tileUrls.clear();
    for (var entry in pastEntries) {
      tileUrls.add(host + entry['path']);
    }

    var location = widget.locationProvider.selectedLocation;
    var timeZoneName = latLngToTimezoneString(
      location.latitude,
      location.longitude,
    );
    var tzLocation = tz.getLocation(timeZoneName);

    tileTimes.clear();

    // "time" in the response is in "Unix timestamp format", that is the number of non-leap seconds
    // since 00:00:00 UTC on 1 January 1970, the Unix epoch.
    for (var frame in pastEntries) {
      var timestamp = frame["time"];
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(
        timestamp * 1000, // from seconds to milliseconds
        isUtc: true,
      );
      // Convert UTC to local time
      DateTime localDate = tz.TZDateTime.from(dt, tzLocation);
      tileTimes.add(DateFormat("HH:mm").format(localDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng currentSelectedLatLng = LatLng(
      widget.locationProvider.selectedLocation.latitude,
      widget.locationProvider.selectedLocation.longitude,
    );

    final greyBackground = Theme.of(context).brightness == Brightness.dark
        ? Colors.black54
        : Colors.grey.withAlpha(150);

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentSelectedLatLng,
        initialZoom: 7.0,
      ),
      children: [
        // Base Map Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'de.julig.open_meteo_ui_2026',
        ),

        // Radar Overlay Layer (only if TileUrl is available)
        if (currentTileIndex >= 0)
          Opacity(
            opacity: 0.5,
            child: TileLayer(
              // The URL template includes placeholders for zoom (z), x, and y coordinates
              urlTemplate:
                  '${tileUrls[currentTileIndex]}/512/{z}/{x}/{y}/2/1_1.png',
              errorTileCallback: (tile, error, stackTrace) =>
                  debugPrint("error rain tile: $error"),
            ),
          ),
        // Marker layer
        MarkerLayer(
          markers: [
            Marker(
              point: currentSelectedLatLng,
              width: 60,
              height: 60,
              child: Icon(Icons.location_pin, color: Colors.red, size: 40),
            ),
          ],
        ),
        //
        // According to https://operations.osmfoundation.org/policies/tiles/ and
        // https://docs.fleaflet.dev/tile-servers/using-openstreetmap-direct you should add
        // some attribution to OpenStreetMap when using its Tile server.
        // SimpleAttributionWidget is provied by FlutterMap, but I implemented an own one:
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            decoration: BoxDecoration(
              color: greyBackground,
              borderRadius: BorderRadius.circular(6), // Rounded corners
            ),

            child: Text(
              "© OpenStreetMap contributors",
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),

        // some buttons to center the map or rotate it to north
        Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: greyBackground,
            borderRadius: BorderRadius.circular(6), // Rounded corners
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.center_focus_strong),
                tooltip: "center to selected location",
                onPressed: () {
                  setState(() {
                    mapController.move(
                      currentSelectedLatLng,
                      mapController.camera.zoom,
                    );
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.navigation),
                tooltip: "rotate so that north is on top",
                onPressed: () {
                  setState(() {
                    mapController.rotate(0);
                  });
                },
              ),
            ],
          ),
        ),
        if (tileTimes.isNotEmpty) getSliderWidget(greyBackground),
      ],
    );
  }

  Widget getSliderWidget(Color greyBackground) {
    return Align(
      alignment: AlignmentGeometry.bottomCenter,
      child: Container(
        margin: EdgeInsets.all(8),
        height: 40,
        width: 240,
        decoration: BoxDecoration(
          color: greyBackground,
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tileTimes[currentTileIndex]),
            SizedBox(
              width: 140,
              child: Slider(
                max: tileUrls.length - 1,
                value: currentTileIndex.toDouble(),
                onChanged: (value) {
                  setState(() {
                    isTimerActive = false;
                    currentTileIndex = value.toInt();
                  });
                },
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  isTimerActive = !isTimerActive;
                  if (isTimerActive &&
                      currentTileIndex == tileUrls.length - 1) {
                    currentTileIndex = 0;
                  }
                });
              },
              icon: isTimerActive ? Icon(Icons.stop) : Icon(Icons.play_circle),
            ),
          ],
        ),
      ),
    );
  }
}
