import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
      ],
    );
  }
}
