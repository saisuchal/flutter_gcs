import 'dart:async';
import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/dialects/common.dart';
import 'package:flutter_gcs/screens/plan_screen/waypoint_model.dart';
import 'package:flutter_gcs/screens/telemetry_screen/model.dart';
import 'package:flutter_gcs/src/provider/mavlink_provider.dart';
import 'package:flutter_gcs/src/services/mavlink_socket_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MavlinkCommandService {
  final MavlinkSocketService socketService;
  final int _targetSystem = 1;
  final int _targetComponent = 1;

  List<Waypoint> _uploadingWaypoints = [];
  final StreamController<void> _missionAckController = StreamController<void>();

  MavlinkCommandService(this.socketService) {
    socketService.mavlinkStream.listen((frame) {
      final msg = frame.message;
      if (msg is MissionRequest) {
        print(msg);
        final seq = msg.seq;
        print('➡️ MISSION_REQUEST for seq=$seq');
        if (seq < _uploadingWaypoints.length) {
          final wp = _uploadingWaypoints[seq];

          final item = MissionItemInt(
            targetSystem: _targetSystem,
            targetComponent: _targetComponent,
            seq: seq,
            frame: wp.frame,
            command: wp.command,
            current: seq == 0 ? 1 : 0,
            autocontinue: 1,
            x: (wp.position.latitude * 1e7).toInt(),
            y: (wp.position.longitude * 1e7).toInt(),
            z: wp.altitude,
            param1: wp.param1,
            param2: wp.param2,
            param3: wp.param3,
            param4: wp.param4,
            missionType: mavMissionTypeMission,
          );

          if (wp.command == 22 && wp.sequence == 1) {
            print('🚁 TAKEOFF ITEM DEBUG:');
            print('  seq: $seq');
            print('  frame: ${wp.frame}'); // should be 3
            print('  command: ${wp.command}'); // should be 22
            print('  lat: ${wp.position.latitude}');
            print('  lon: ${wp.position.longitude}');
            print('  alt (z): ${wp.altitude}');
            print('  current: ${seq == 0 ? 1 : 0}');
          }

          socketService.send(item);
          print('[Mission Upload] 📤 Sent MISSION_ITEM_INT seq=$seq');
        }
      } else if (msg is MissionAck) {
        final ack = msg as MissionAck;
        if (ack.type == mavMissionAccepted) {
          print('[Mission Upload] ✅ Mission accepted by FC');
          _missionAckController.add(null); // Signal completion
        } else {
          print('[Mission Upload] ❌ Mission rejected: ${ack.type}');
          _missionAckController.addError('Mission rejected: ${ack.type}');
        }
      }
    });
  }

  /// Uploads a mission using MAVLink MISSION_COUNT + handshake protocol
  Future<void> uploadMission(List<Waypoint> waypoints) async {
    if (waypoints.isEmpty) return;
    _uploadingWaypoints = waypoints;

    final countMsg = MissionCount(
      targetSystem: _targetSystem,
      targetComponent: _targetComponent,
      count: waypoints.length,
      missionType: mavMissionTypeMission,
      opaqueId: 0,
    );

    socketService.send(countMsg);
    
    print('[Mission Upload] 📤 Sent MISSION_COUNT (${waypoints.length})');

    // Wait for mission ack or error
    await _missionAckController.stream.first;
  }

  /// Arms or disarms the vehicle
  Future<void> arm(bool arm) async {
    final msg = CommandLong(
      targetSystem: _targetSystem,
      targetComponent: _targetComponent,
      command: mavCmdComponentArmDisarm,
      confirmation: 0,
      param1: arm ? 1 : 0,
      param2: 0,
      param3: 0,
      param4: 0,
      param5: 0,
      param6: 0,
      param7: 0,
    );

    socketService.send(msg);
    print('[Command] ${arm ? 'Arming' : 'Disarming'} vehicle...');
  }

  /// Sets flight mode (e.g. GUIDED, AUTO, etc.)
  Future<void> setMode(int mode) async {
    final msg = SetMode(
      targetSystem: _targetSystem,
      baseMode: mavModeFlagCustomModeEnabled,
      customMode: mode,
    );

    socketService.send(msg);
    print('[Command] Set mode = $mode');
  }
  

  Future<void> startMission({
    required List<Waypoint> missionItems,
    required MavlinkProvider mavlink,
  }) async {
    final currentLat = mavlink.latitude;
    final currentLon = mavlink.longitude;

    if (currentLat == null || currentLon == null) {
      print('[Mission Start] ❌ Telemetry unavailable (no GPS)');
      return;
    }

    if (missionItems.isEmpty) {
      print('[Mission Start] ❌ No waypoints to upload');
      return;
    }

    final homePosition = Waypoint(
      sequence: 0,
      position: LatLng(currentLat, currentLon),
      altitude: 587.07, // or your home altitude
      command: mavCmdNavWaypoint, // 16
      frame: mavFrameGlobalRelativeAlt, // 3
      current: true,
      autocontinue: true,
    );

    final takeoff = Waypoint(
      sequence: 1,
      position: LatLng(currentLat, currentLon),
      altitude: 10,
      frame: mavFrameGlobalRelativeAlt,
      command: mavCmdNavTakeoff,
      param1: 0,
      param2: 0,
      param3: 0,
      param4: 0,
      current: false,
      autocontinue: true,
    );

    final fullMission = [homePosition, takeoff, ...missionItems];

    print(
      '[Mission Start] 🚀 Uploading mission with TAKEOFF + ${missionItems.length} waypoints',
    );

    // Step 1: Upload mission
    await uploadMission(fullMission);
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 2: Arm the vehicle
    await arm(true);
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 3: Send mission start command - THIS IS THE KEY ADDITION
    print('[Mission Start] 📤 Sending mission start command...');
    await sendMissionStartCommand();
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 4: Set to AUTO mode
    await setMode(3); // AUTO
    print('[Mission Start] ✅ Mission started in AUTO mode');

    return; // ✅ Explicit return
  }

  // Add this new method to send the mission start command
  Future<void> sendMissionStartCommand() async {
    socketService.send(
      CommandLong(
        targetSystem: 1, // Your target system ID
        targetComponent: 1, // Your target component ID
        command: mavCmdMissionStart,
        confirmation: 0,
        param1: 0,
        param2: 0,
        param3: 0,
        param4: 0,
        param5: 0,
        param6: 0,
        param7: 0,
      ),
    );
  }

  /// Sends a TAKEOFF command
  Future<void> takeoff({double altitude = 10.0}) async {
    final msg = CommandLong(
      targetSystem: _targetSystem,
      targetComponent: _targetComponent,
      command: mavCmdNavTakeoff,
      confirmation: 0,
      param1: 0,
      param2: 0,
      param3: 0,
      param4: 0,
      param5: 0,
      param6: 0,
      param7: altitude,
    );

    socketService.send(msg);
    print('[Command] 🛫 Sent TAKEOFF (alt=$altitude)');
  }

  /// Sends a LAND command
  Future<void> land() async {
    final msg = CommandLong(
      targetSystem: _targetSystem,
      targetComponent: _targetComponent,
      command: mavCmdNavLand,
      confirmation: 0,
      param1: 0,
      param2: 0,
      param3: 0,
      param4: 0,
      param5: 0,
      param6: 0,
      param7: 0,
    );

    socketService.send(msg);
    print('[Command] 🛬 Sent LAND');
  }

  /// Sends a Return-to-Launch (RTL) command
  Future<void> returnToLaunch() async {
    final msg = CommandLong(
      targetSystem: _targetSystem,
      targetComponent: _targetComponent,
      command: mavCmdNavReturnToLaunch,
      confirmation: 0,
      param1: 0,
      param2: 0,
      param3: 0,
      param4: 0,
      param5: 0,
      param6: 0,
      param7: 0,
    );

    socketService.send(msg);
    print('[Command] 📍 Sent RETURN TO LAUNCH (RTL)');
  }
}
