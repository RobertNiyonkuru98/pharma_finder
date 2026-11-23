import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// User preferences persisted with `shared_preferences`.
///
/// A single immutable value object so every screen reads the same snapshot and
/// the whole set survives an app relaunch.
class AppPreferences extends Equatable {
  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.searchRadiusKm = 5,
    this.showOpenFirst = true,
    this.insuranceOnly = true,
    this.dutyRosterAlerts = true,
    this.preciseGps = true,
  });

  static const AppPreferences defaults = AppPreferences();

  /// Available search radii, in kilometres.
  static const List<int> radiusStops = <int>[1, 5, 10, 25];

  final ThemeMode themeMode;
  final int searchRadiusKm;
  final bool showOpenFirst;
  final bool insuranceOnly;
  final bool dutyRosterAlerts;
  final bool preciseGps;

  int get radiusIndex {
    final index = radiusStops.indexOf(searchRadiusKm);
    return index == -1 ? 1 : index;
  }

  AppPreferences copyWith({
    ThemeMode? themeMode,
    int? searchRadiusKm,
    bool? showOpenFirst,
    bool? insuranceOnly,
    bool? dutyRosterAlerts,
    bool? preciseGps,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
      showOpenFirst: showOpenFirst ?? this.showOpenFirst,
      insuranceOnly: insuranceOnly ?? this.insuranceOnly,
      dutyRosterAlerts: dutyRosterAlerts ?? this.dutyRosterAlerts,
      preciseGps: preciseGps ?? this.preciseGps,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    themeMode,
    searchRadiusKm,
    showOpenFirst,
    insuranceOnly,
    dutyRosterAlerts,
    preciseGps,
  ];
}
