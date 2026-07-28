import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../version_info.dart';
import 'settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final textStyle = const TextStyle(fontSize: 16);
  final headerPadding = EdgeInsets.fromLTRB(25, 20, 10, 10);
  final settingsProvider = GetIt.instance<SettingsProvider>();

  @override
  Widget build(BuildContext context) {
    final versionDateFormatter = DateFormat(
      'dd-MMM-yyyy',
      Localizations.localeOf(context).toString(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, thickness: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: headerPadding,
              child: Text(
                "Use light or dark mode for this app?",
                style: textStyle,
              ),
            ),
            RadioGroup<bool?>(
              groupValue: settingsProvider.settings.useDarkTheme,
              onChanged: (bool? value) {
                setState(() {
                  settingsProvider.settings.useDarkTheme = value;
                  settingsProvider.saveSettings();
                });
              },
              child: Column(
                children: [
                  RadioListTile<bool?>(
                    title: Text("same as defined in System", style: textStyle),
                    value: null,
                  ),
                  RadioListTile<bool?>(
                    title: Text("always light", style: textStyle),
                    value: false,
                  ),
                  RadioListTile<bool?>(
                    title: Text("always dark", style: textStyle),
                    value: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: headerPadding,
              child: Text(
                "Which language to use in this app?",
                style: textStyle,
              ),
            ),
            RadioGroup<String?>(
              groupValue:
                  settingsProvider.settings.localeAsString, // Zentral gesteuert
              onChanged: (String? value) {
                setState(() {
                  settingsProvider.settings.localeAsString = value;
                  settingsProvider.saveSettings();
                });
              },
              child: Column(
                children: [
                  RadioListTile<String?>(
                    title: Text("same as defined in System", style: textStyle),
                    value: null,
                  ),
                  RadioListTile<String?>(
                    // for a discussion how to display flags see https://gemini.google.com/share/7ba4786e1e32
                    // there might be an issue with Windows, but we only target Web and Android.
                    title: Text("🇬🇧 always English", style: textStyle),
                    value: "en",
                  ),
                  RadioListTile<String?>(
                    title: Text("🇩🇪 always German", style: textStyle),
                    value: "de",
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(),
            Padding(
              padding: headerPadding,
              child: Text(
                "This is version $versionTag from ${versionDateFormatter.format(versionDate)}.",
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
