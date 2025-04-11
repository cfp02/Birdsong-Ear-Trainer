import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  final String defaultRegion;
  final bool showScientificNames;
  final bool autoPlayNext;

  Settings({
    required this.defaultRegion,
    this.showScientificNames = false,
    this.autoPlayNext = true,
  });

  Settings copyWith({
    String? defaultRegion,
    bool? showScientificNames,
    bool? autoPlayNext,
  }) {
    return Settings(
      defaultRegion: defaultRegion ?? this.defaultRegion,
      showScientificNames: showScientificNames ?? this.showScientificNames,
      autoPlayNext: autoPlayNext ?? this.autoPlayNext,
    );
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  static const String _defaultRegionKey = 'default_region';
  static const String _showScientificNamesKey = 'show_scientific_names';
  static const String _autoPlayNextKey = 'auto_play_next';

  SettingsNotifier() : super(Settings(defaultRegion: 'US-MA')) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = Settings(
      defaultRegion: prefs.getString(_defaultRegionKey) ?? 'US-MA',
      showScientificNames: prefs.getBool(_showScientificNamesKey) ?? false,
      autoPlayNext: prefs.getBool(_autoPlayNextKey) ?? true,
    );
  }

  Future<void> updateDefaultRegion(String region) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultRegionKey, region);
    state = state.copyWith(defaultRegion: region);
  }

  Future<void> updateShowScientificNames(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showScientificNamesKey, value);
    state = state.copyWith(showScientificNames: value);
  }

  Future<void> updateAutoPlayNext(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPlayNextKey, value);
    state = state.copyWith(autoPlayNext: value);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});
