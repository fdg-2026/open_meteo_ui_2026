import 'package:flutter/material.dart';
import 'location_data.dart';
import 'location_provider.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key, required this.locationProvider});

  final LocationProvider locationProvider;

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final List<LocationData> _testLocations = [
    LocationData(name: "Berlin", latitude: 10, longitude: 11),
    LocationData(name: "London", latitude: 20, longitude: 22),
    LocationData(name: "Madrid", latitude: 30, longitude: 33),
    LocationData(name: "Rome", latitude: 40, longitude: 44),
    LocationData(name: "Test01", latitude: 89, longitude: 1),
    LocationData(name: "Test02", latitude: 89, longitude: 2),
    LocationData(name: "Test03", latitude: 89, longitude: 3),
    LocationData(name: "Test04", latitude: 89, longitude: 4),
    LocationData(name: "Test05", latitude: 89, longitude: 5),
    LocationData(name: "Test06", latitude: 89, longitude: 6),
    LocationData(name: "Test07", latitude: 89, longitude: 7),
    LocationData(name: "Test08", latitude: 89, longitude: 8),
    LocationData(name: "Test09", latitude: 89, longitude: 9),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage your locations"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, thickness: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text("Add a new location:", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            RawAutocomplete<LocationData>(
              textEditingController: TextEditingController(),
              focusNode: FocusNode(),

              // 1️⃣ Filter logic
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<LocationData>.empty();
                }
                return _testLocations.where(
                  (location) => location.name.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },

              // 2️⃣ What happens when user selects an option
              onSelected: (LocationData selection) {
                widget.locationProvider.addLocation(selection);
                Navigator.pop(context);
              },

              // Next line is needed when you use your own type in RawAutocomplete instead of String.
              // It is used to display the selected item in the TextField.
              // Because we directly switch back to ForecastPage after an item was selected, it's not really needed in our case.
              displayStringForOption: (LocationData location) => location.name,

              // 3️⃣ The TextField itself
              fieldViewBuilder:
                  (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Search for new location',
                        border: OutlineInputBorder(),
                      ),
                    );
                  },

              // 4️⃣ CUSTOM suggestions widget
              optionsViewBuilder: (context, onSelected, options) {
                return Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(8),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      //padding: EdgeInsets.zero,
                      //shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return getAutocompleteTile(option, () {
                          onSelected(option);
                        });
                      },
                      // Gemini answering on _ and __ in netxt line:
                      // When you see (_, __), it's a way for a developer to tell the compiler
                      // — and other developers— that the function requires certain arguments to be passed in,
                      // but the code inside the function doesn't actually need to use them.
                      // You use two different symbols (_ and __) because Dart doesn't allow you
                      // to have two variables with the exact same name in the same scope.
                      separatorBuilder: (_, __) => const Divider(height: 1),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getAutocompleteTile(
    LocationData location,
    VoidCallback callbackOnTap,
  ) {
    // InkWell (dt.: Tintenfass) - it "spreads out" when tapped
    return InkWell(
      onTap: () {
        callbackOnTap();
      },
      child: ListTile(
        title: Text(
          location.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("lat:${location.latitude.toStringAsFixed(3)}"),
            Text("lon:${location.longitude.toStringAsFixed(3)}"),
          ],
        ),
      ),
    );
  }
}
