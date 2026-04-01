import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_data.dart';

class SettingsProvider {
  SettingsProvider({required this.callbackOnSettingsChange}) {
    sharedPrefsInstance = GetIt.instance<SharedPreferences>();
    loadSettings();
  }

  final Function() callbackOnSettingsChange;
  late SharedPreferences sharedPrefsInstance;

  late SettingsData _settings;
  SettingsData get settings => _settings;

  void loadSettings() {
    _settings = SettingsData();
    String? storedSettings = sharedPrefsInstance.getString("settings");
    if (storedSettings != null) {
      var json = jsonDecode(storedSettings);
      _settings = SettingsData.fromJson(json);
    }
  }

  void saveSettings() {
    if (_settings.isDirty) {
      sharedPrefsInstance.setString("settings", jsonEncode(_settings.toJson()));
      _settings.isDirty = false;
      callbackOnSettingsChange();
    }
  }
}
