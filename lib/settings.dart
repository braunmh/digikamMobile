import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  
  static const String _url = 'url';
  static const String _darkMode = 'darkMode';
  
  String url;
  bool darkMode;

  Settings({required this.url, bool? darkMode}) :
    darkMode = darkMode ?? false;

  Settings.fromJson(Map<String, dynamic> values) :
    url = values[_url] ?? '',
    darkMode = values[_darkMode] ?? false;

  Map<String, dynamic> toJson() => {
    _url : url,
    _darkMode : darkMode,
  };

  isValid() {
    return url.isNotEmpty;
  }
}

class SettingsRepository {

  static const _settings = 'settings';

  Future<Settings> getSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString(_settings) ?? '';
    Settings settings = (value.isEmpty)
        ? Settings(url: '', darkMode: false)
        : Settings.fromJson(jsonDecode(value));
    SettingsFactory().settings = settings;
    return settings;
  }

  Future<void> saveSettings(Settings settings) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settings, jsonEncode(settings));
    SettingsFactory().settings = settings;
  }
}

class SettingsFactory {
  static final SettingsFactory _factory = SettingsFactory._internal();

  late Settings settings;

  factory SettingsFactory() {
    return _factory;
  }

  SettingsFactory._internal() {
    settings = Settings(url: '');
  }
}