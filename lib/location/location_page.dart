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
  void addLocation(LocationData location) {
    if (widget.locationProvider.nameExists(location.name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent.shade200,
          content: Text(
            'There is already a location with name ${location.name}.',
          ),
        ),
      );
    } else {
      widget.locationProvider.addLocation(location);
      Navigator.pop(context);
    }
  }

  void deleteLocation(LocationData location) {
    widget.locationProvider.deleteLocation(location.name);
    // refresh the UI so that the deleted location is no longer displayed in the list of locations to be selected or deleted
    setState(() {});
  }

  void selectLocation(LocationData location) {
    widget.locationProvider.selectLocation(location.name);
    Navigator.pop(context);
  }

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
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<LocationData>.empty();
                }
                var result = await widget.locationProvider.getLocationProposals(
                  textEditingValue.text,
                );
                return result;
              },

              // 2️⃣ What happens when user selects an option
              onSelected: (LocationData selection) {
                addLocation(selection);
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
                    constraints: const BoxConstraints(maxHeight: 350),
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

            const SizedBox(height: 20),
            Divider(),
            const SizedBox(height: 20),
            Text(
              "Select or delete an existing location:",
              style: TextStyle(fontSize: 20),
            ),

            Expanded(
              child: ListView(
                children: widget.locationProvider.locations
                    .map(
                      (LocationData location) =>
                          getSelectOrDeleteLocationTile(location),
                    )
                    .toList(),
                // same with a for loop:
                // children: [
                //   for (var location in widget.locationProvider.locations)
                //     getSelectOrDeleteLocationTile(location),
                // ],
              ),
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
        subtitle: Text(location.details),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("lat:${location.latitude.toStringAsFixed(3)}"),
            Text("lon:${location.longitude.toStringAsFixed(3)}"),
            Text(location.timezone),
          ],
        ),
      ),
    );
  }

  Widget getSelectOrDeleteLocationTile(LocationData location) {
    Widget trailing = SizedBox(width: 10);
    bool isSelectedLocation =
        location.name == widget.locationProvider.selectedLocation.name;
    if (!isSelectedLocation) {
      trailing = IconButton(
        onPressed: () {
          deleteLocation(location);
        },
        icon: Icon(Icons.delete),
      );
    }
    return Card(
      elevation: 4, // shadow depth
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        title: Text(
          location.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(location.details),
        leading: Checkbox(
          value: isSelectedLocation,
          onChanged: isSelectedLocation
              ? null
              : (value) {
                  selectLocation(location);
                },
        ),
        trailing: trailing,
        dense: true,
      ),
    );
  }
}
