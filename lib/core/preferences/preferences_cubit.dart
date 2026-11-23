import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_preferences.dart';
import 'preferences_store.dart';

/// App-wide preference state.
///
/// Emits immediately, then persists in the background so toggles stay
/// responsive even when the disk write is slow.
class PreferencesCubit extends Cubit<AppPreferences> {
  PreferencesCubit([super.initial = AppPreferences.defaults]);

  /// Loads the persisted snapshot; used by `main` before the first frame.
  static Future<AppPreferences> loadPersisted() => PreferencesStore.load();

  Future<void> setThemeMode(ThemeMode mode) =>
      _persist(state.copyWith(themeMode: mode));

  Future<void> setSearchRadiusKm(int kilometers) =>
      _persist(state.copyWith(searchRadiusKm: kilometers));

  Future<void> setShowOpenFirst(bool value) =>
      _persist(state.copyWith(showOpenFirst: value));

  Future<void> setInsuranceOnly(bool value) =>
      _persist(state.copyWith(insuranceOnly: value));

  Future<void> setDutyRosterAlerts(bool value) =>
      _persist(state.copyWith(dutyRosterAlerts: value));

  Future<void> setPreciseGps(bool value) =>
      _persist(state.copyWith(preciseGps: value));

  Future<void> _persist(AppPreferences next) async {
    if (next == state) return;
    emit(next);
    await PreferencesStore.save(next);
  }
}