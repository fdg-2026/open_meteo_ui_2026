import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../location/location_provider.dart';

class RadarPage extends StatefulWidget {
  const RadarPage({super.key, required this.locationProvider});

  final LocationProvider locationProvider;

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> {
  final MapController mapController = MapController();
  String rainTileUrl = "";

  @override
  void initState() {
    super.initState();
    getRainTileUrl();
  }

  Future<void> getRainTileUrl() async {
    rainTileUrl = "";
    try {
      final response = await http.get(
        Uri.parse('https://api.rainviewer.com/public/weather-maps.json'),
      );
      if (response.statusCode != 200) {
        debugPrint("statusCode from rainviewer api was ${response.statusCode}");
        return;
      }
      final data = json.decode(response.body);
      // Get the most recent 'past' radar frame
      setState(() {
        final String host = data['host'];
        rainTileUrl = host + data['radar']['past'].last['path'];
        //debugPrint("rainTileUrl is $rainTileUrl");
      });
    } on Exception catch (e) {
      debugPrint("Exception in getRainTileUrl: $e");
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
        if (rainTileUrl.isNotEmpty)
          Opacity(
            opacity: 0.9,
            child: TileLayer(
              // The URL template includes placeholders for zoom (z), x, and y coordinates
              //urlTemplate: '$rainTileUrl/512/{z}/{x}/{y}/2/1_1.png',
              urlTemplate:
                  //'https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=7089b9e7a29803a85fdf9eeb78e35294',
                  //'https://tile.openweathermap.org/map/clouds_new/{z}/{x}/{y}.png?appid=7089b9e7a29803a85fdf9eeb78e35294',
                  'https://tile.openweathermap.org/map/temp_new/{z}/{x}/{y}.png?appid=7089b9e7a29803a85fdf9eeb78e35294',

              //'https://maps.openweathermap.org/maps/2.0/weather/1h/PARAIN/{z}/{x}/{y}?date=1618898990&appid=f858c296f501d405d29a6e49c3b94ed3 ',
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
          alignment: Alignment.bottomRight,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
            color: greyBackground,
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
      ],
    );
  }
}
