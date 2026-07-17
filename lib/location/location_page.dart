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
  final List<String> _options = const [
    "Berlin",
    "London",
    "Madrid",
    "Rome",
    "Test01",
    "Test02",
    "Test03",
    "Test04",
    "Test05",
    "Test06",
    "Test07",
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
            RawAutocomplete<String>(
              textEditingController: TextEditingController(),
              focusNode: FocusNode(),

              // 1️⃣ Filter logic
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _options.where(
                  (option) => option.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },

              // 2️⃣ What happens when user selects an option
              onSelected: (String selection) {
                widget.locationProvider.addLocation(
                  LocationData(name: selection, latitude: 89, longitude: 0),
                );
                Navigator.pop(context);
              },

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
                    child: ListView.builder(
                      //padding: EdgeInsets.zero,
                      //shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return getAutocompleteTile(
                          options.elementAt(index),
                          () {
                            onSelected(option);
                          },
                        );
                      },
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

  Widget getAutocompleteTile(String text, VoidCallback callbackOnTap) {
    // InkWell (dt.: Tintenfass) - it "spreads out" when tapped
    return InkWell(
      onTap: () {
        callbackOnTap();
      },
      child: ListTile(
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
