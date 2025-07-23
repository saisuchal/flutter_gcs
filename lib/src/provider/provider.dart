import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gcs/screens/plan_screen/waypoint_model.dart';
import 'package:flutter_gcs/screens/telemetry_screen/model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:dart_mavlink/dialects/common.dart'; // For MAV_CMD constants

/// --- Telemetry State ---
final telemetryProvider = StateProvider<TelemetryData?>((ref) => null);

/// --- Protocol Selection ---
enum SelectedProtocol {
  usb,
  tcp,
  udp,
  wirelessTcp,
}

final selectedProtocolProvider = StateProvider<SelectedProtocol>((ref) => SelectedProtocol.tcp);
final isWirelessProvider = StateProvider<bool>((ref) => true);
final tcpHostProvider = StateProvider<String>((ref) => '10.0.2.2');
final tcpPortProvider = StateProvider<int>((ref) => 5762);

/// --- Map Configuration ---
enum MapProviderType {
  google,
  leaflet,
}

final mapProviderTypeProvider = StateProvider<MapProviderType>((ref) => MapProviderType.google);
final googleMapTypeProvider = StateProvider<gmaps.MapType>((ref) => gmaps.MapType.normal);

/// --- Waypoint Management ---
final waypointProvider = StateNotifierProvider<WaypointNotifier, List<Waypoint>>(
  (ref) => WaypointNotifier(),
);


class WaypointNotifier extends StateNotifier<List<Waypoint>> {
  WaypointNotifier() : super([]);

  void add(gmaps.LatLng position) {
    final newWaypoint = Waypoint(
      sequence: state.length,
      position: position,
      altitude: 10.0,
      command: mavCmdNavWaypoint,
      param1: 0.0, // Hold time in seconds
      param2: 0.0, // Acceptance radius
      param3: 0.0, // Pass radius
      param4: double.nan, // Desired yaw angle
      current:false,
      // current: state.isEmpty,
      autocontinue: true,
      frame: 3, // MAV_FRAME_GLOBAL_RELATIVE_ALT
    );
    state = [...state, newWaypoint];
  }

  void remove(int index) {
    final updated = [...state]..removeAt(index);
    state = List.generate(
      updated.length,
      (i) => updated[i].copyWith(sequence: i, current: i == 0),
    );
  }

  void clear() => state = [];

  void set(List<Waypoint> newWaypoints) {
    state = List.generate(
      newWaypoints.length,
      (i) => newWaypoints[i].copyWith(sequence: i, current: i == 0),
    );
  }
}

final showMissionOverlayProvider = StateProvider<bool>((ref) => false);

/// --- USB (Placeholder) ---
final usbConnectionStatusProvider = StateProvider<String>((ref) => 'disconnected');
