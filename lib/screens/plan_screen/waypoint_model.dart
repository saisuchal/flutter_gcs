import 'package:google_maps_flutter/google_maps_flutter.dart';

class Waypoint {
  final int sequence;           // Mission item index
  final LatLng position;        // Latitude and longitude
  final double altitude;        // Altitude in meters (relative)
  final int command;            // MAV_CMD_NAV_WAYPOINT, TAKEOFF, LAND, etc.
  final double param1;          // Hold time (WAYPOINT) or Min pitch (TAKEOFF)
  final double param2;          // Acceptance radius
  final double param3;          // Pass radius
  final double param4;          // Desired yaw angle (NaN = don't change)
  final bool current;           // True only for first item
  final bool autocontinue;      // Autocontinue to next item
  final int frame;              // MAV_FRAME_GLOBAL_RELATIVE_ALT = 3

  const Waypoint({
    required this.sequence,
    required this.position,
    required this.altitude,
    this.command = 16, // Default: MAV_CMD_NAV_WAYPOINT
    this.param1 = 0.0,
    this.param2 = 0.0,
    this.param3 = 0.0,
    this.param4 = double.nan,
    this.current = false,
    this.autocontinue = true,
    this.frame = 3, // MAV_FRAME_GLOBAL_RELATIVE_ALT
  });

  Waypoint copyWith({
    int? sequence,
    LatLng? position,
    double? altitude,
    int? command,
    double? param1,
    double? param2,
    double? param3,
    double? param4,
    bool? current,
    bool? autocontinue,
    int? frame,
  }) {
    return Waypoint(
      sequence: sequence ?? this.sequence,
      position: position ?? this.position,
      altitude: altitude ?? this.altitude,
      command: command ?? this.command,
      param1: param1 ?? this.param1,
      param2: param2 ?? this.param2,
      param3: param3 ?? this.param3,
      param4: param4 ?? this.param4,
      current: current ?? this.current,
      autocontinue: autocontinue ?? this.autocontinue,
      frame: frame ?? this.frame,
    );
  }

  Map<String, dynamic> toJson() => {
        'sequence': sequence,
        'lat': position.latitude,
        'lon': position.longitude,
        'alt': altitude,
        'command': command,
        'param1': param1,
        'param2': param2,
        'param3': param3,
        'param4': param4,
        'current': current,
        'autocontinue': autocontinue,
        'frame': frame,
      };

  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
        sequence: json['sequence'],
        position: LatLng(json['lat'], json['lon']),
        altitude: json['alt'],
        command: json['command'],
        param1: json['param1'],
        param2: json['param2'],
        param3: json['param3'],
        param4: json['param4'],
        current: json['current'],
        autocontinue: json['autocontinue'],
        frame: json['frame'],
      );
}
