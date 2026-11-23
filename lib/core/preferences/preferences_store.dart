import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences.dart';

/// Reads and writes [AppPreferences] through `shared_preferences`.
///
/// Every call degrades to in-memory defaults when the platform store is
/// unavailable (unit/widget tests), so callers never have to guard for it.
abstract final class PreferencesStore {
  static const String _themeKey = 'preferences.theme_mode';
  static const String _radiusKey = 'preferences.search_radius_km';
  static const String _openFirstKey = 'preferences.show_open_first';
  static const String _insuranceOnlyKey = 'preferences.insurance_only';
  static const String _alertsKey = 'preferences.duty_roster_alerts';
  static const String _preciseGpsKey = 'preferences.precise_gps';

  static Future<AppPreferences> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return AppPreferences(
        themeMode: _themeFrom(prefs.getString(_themeKey)),
        searchRadiusKm: _radiusFrom(prefs.getInt(_radiusKey)),
        showOpenFirst: prefs.getBool(_openFirstKey) ?? true,
        insuranceOnly: prefs.getBool(_insuranceOnlyKey) ?? true,
        dutyRosterAlerts: prefs.getBool(_alertsKey) ?? true,
        preciseGps: prefs.getBool(_preciseGpsKey) ?? true,
      );
    } catch (error) {
      debugPrint('Preferences load failed: $error');
      return AppPreferences.defaults;
    }
  }

  static Future<void> save(AppPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, preferences.themeMode.name);
      await prefs.setInt(_radiusKey, preferences.searchRadiusKm);
      await prefs.setBool(_openFirstKey, preferences.showOpenFirst);
      await prefs.setBool(_insuranceOnlyKey, preferences.insuranceOnly);
      await prefs.setBool(_alertsKey, preferences.dutyRosterAlerts);
      await prefs.setBool(_preciseGpsKey, preferences.preciseGps);
    } catch (error) {
      debugPrint('Preferences save failed: $error');
    }
  }

  static ThemeMode _themeFrom(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static int _radiusFrom(int? value) {
    if (value == null || !AppPreferences.radiusStops.contains(value)) {
      return AppPreferences.defaults.searchRadiusKm;
    }
    return value;
  }
}
