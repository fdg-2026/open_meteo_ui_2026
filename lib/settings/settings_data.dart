import 'package:flutter/material.dart';

class SettingsData {
  SettingsData();

  bool isDirty = false;

  bool? _useDarkTheme;
  bool? get useDarkTheme => _useDarkTheme;
  set useDarkTheme(bool? value) {
    if (value != _useDarkTheme) {
      _useDarkTheme = value;
      isDirty = true;
    }
  }

  ThemeMode get themeMode {
    var result = ThemeMode.system;
    if (useDarkTheme != null) {
      result = useDarkTheme! ? ThemeMode.dark : ThemeMode.light;
    }
    return result;
  }

  String? _localeAsString;
  String? get localeAsString => _localeAsString;
  set localeAsString(String? value) {
    if (value != _localeAsString) {
      _localeAsString = value;
      isDirty = true;
    }
  }

  Locale? get locale {
    Locale? result;
    if (localeAsString != null) {
      result = Locale(localeAsString!);
    }
    return result;
  }

  // Object -> Map
  Map<String, dynamic> toJson() {
    return {"useDarkTheme": useDarkTheme, "localeAsString": localeAsString};
  }

  // Map -> Object
  factory SettingsData.fromJson(Map<String, dynamic> json) {
    var result = SettingsData();
    if (json["useDarkTheme"] != null && json["useDarkTheme"] is bool) {
      result._useDarkTheme = json["useDarkTheme"];
    }
    if (json["localeAsString"] != null) {
      result._localeAsString = json["localeAsString"];
    }
    return result;
  }
}
