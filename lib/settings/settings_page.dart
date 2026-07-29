import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
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
  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    final versionDateFormatter = DateFormat(
      'dd-MMM-yyyy',
      Localizations.localeOf(context).toString(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sp_pageTitle),
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
              child: Text(l10n.sp_themeTitle, style: textStyle),
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
                    title: Text(l10n.sp_themeSystem, style: textStyle),
                    value: null,
                  ),
                  RadioListTile<bool?>(
                    title: Text(l10n.sp_themeLight, style: textStyle),
                    value: false,
                  ),
                  RadioListTile<bool?>(
                    title: Text(l10n.sp_themeDark, style: textStyle),
                    value: true,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: headerPadding,
              child: Text(l10n.sp_localeTitle, style: textStyle),
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
                    title: Text(l10n.sp_localeSystem, style: textStyle),
                    value: null,
                  ),
                  RadioListTile<String?>(
                    // for a discussion how to display flags see https://gemini.google.com/share/7ba4786e1e32
                    // there might be an issue with Windows, but we only target Web and Android.
                    title: Text(l10n.sp_localeEN, style: textStyle),
                    value: "en",
                  ),
                  RadioListTile<String?>(
                    title: Text(l10n.sp_localeDE, style: textStyle),
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
                l10n.sp_versionInfo(
                  versionTag,
                  versionDateFormatter.format(versionDate),
                ),
                style: textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
