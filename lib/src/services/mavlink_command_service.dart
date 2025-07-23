// import 'dart:async';
// import 'package:dart_mavlink/mavlink.dart';
// import 'package:dart_mavlink/dialects/common.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_gcs/screens/plan_screen/waypoint_model.dart';
// import 'package:flutter_gcs/src/provider/mavlink_provider.dart';
// import 'package:flutter_gcs/src/provider/provider.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'mavlink_socket_service.dart';

// class MavlinkCommandService {
//   final MavlinkSocketService socketService;

//   static const int _targetSystem = 1;
//   static const int _targetComponent = 1;

//   // static const int _modeStabilize = 0;
//   static const int _modeAuto = 3;
//   static const int _modeGuided = 4;
//   static const int _modeRTL = 6;

//   MavlinkCommandService(this.socketService);

//   Future<void> setMode(int mode) async {
//     final msg = SetMode(
//       targetSystem: _targetSystem,
//       baseMode: mavModeFlagCustomModeEnabled,
//       customMode: mode,
//     );
//     socketService.send(msg);
//   }

//   Future<void> arm(bool arm) async {
//     final cmd = CommandLong(
//       targetSystem: _targetSystem,
//       targetComponent: _targetComponent,
//       command: mavCmdComponentArmDisarm,
//       confirmation: 0,
//       param1: arm ? 1.0 : 0.0,
//       param2: 0.0,
//       param3: 0.0,
//       param4: 0.0,
//       param5: 0.0,
//       param6: 0.0,
//       param7: 0.0,
//     );
//     socketService.send(cmd);
//   }

//   Future<void> takeoff({double altitude = 10.0}) async {
//     await setMode(_modeGuided);
//     await Future.delayed(const Duration(milliseconds: 300));
//     await arm(true);
//     await Future.delayed(const Duration(seconds: 1));

//     final cmd = CommandLong(
//       targetSystem: _targetSystem,
//       targetComponent: _targetComponent,
//       command: mavCmdNavTakeoff,
//       confirmation: 0,
//       param1: 0.0,
//       param2: 0.0,
//       param3: 0.0,
//       param4: 0.0,
//       param5: 0.0,
//       param6: 0.0,
//       param7: altitude,
//     );
//     socketService.send(cmd);
//   }

//   Future<void> land() async {
//     final cmd = CommandLong(
//       targetSystem: _targetSystem,
//       targetComponent: _targetComponent,
//       command: mavCmdNavLand,
//       confirmation: 0,
//       param1: 0.0,
//       param2: 0.0,
//       param3: 0.0,
//       param4: 0.0,
//       param5: 0.0,
//       param6: 0.0,
//       param7: 0.0,
//     );
//     socketService.send(cmd);
//   }

//   Future<void> returnToLaunch() async {
//     await setMode(_modeRTL);
//   }

//   // Add these debug checks to your startMission function:

// // Future<void> startMission({required List<Waypoint> missionItems}) async {
// //   print("🚨 startMission() called with ${missionItems.length} items");

// //   try {
// //     print('🔄 Starting mission with ${missionItems.length} waypoints');

// //     for (int i = 0; i < missionItems.length; i++) {
// //       final wp = missionItems[i];
// //       print(
// //         'Mission Item $i: Seq=${wp.sequence}, Alt=${wp.altitude}, Pos=${wp.position.latitude},${wp.position.longitude}',
// //       );
// //     }

// //     print('🔍 Checking mission upload...');

// //     // Step 1: Set to GUIDED mode
// //     print('🎮 Setting GUIDED mode...');
// //     await setMode(_modeGuided);
// //     await Future.delayed(const Duration(seconds: 1));
// //     print('🔍 Current mode should be GUIDED');

// //     // Step 2: Arm the vehicle
// //     print('🔫 Arming vehicle...');
// //     await arm(true);
// //     await Future.delayed(const Duration(seconds: 2));
// //     print('🔍 Vehicle should be armed now');

// //     // ✅ Insert takeoff to force ACTIVE state
// //     // print('🛫 Sending takeoff to transition to ACTIVE...');
// //     // await takeoff(altitude: 10.0); // altitude can be changed if needed
// //     // await Future.delayed(const Duration(seconds: 5));

// //     // Step 3: Switch to AUTO mode
// //     print('🤖 Setting AUTO mode...');
// //     await setMode(_modeAuto);
// //     await Future.delayed(const Duration(seconds: 2));
// //     print('🔍 Current mode should be AUTO');

// //     // Step 4: Start the mission
// //     print('🚀 Starting mission...');
// //     await startMissionCommand();
// //     await Future.delayed(const Duration(seconds: 2));
// //     print('🔍 Mission should be starting now - check MISSION_CURRENT messages');

// //     print('✅ Mission started successfully');
// //   } catch (e) {
// //     print('❌ Error starting mission: $e');
// //     rethrow;
// //   }
// // }

// Future<void> startMission(BuildContext context) async {
//   final mavlink = Ref.read(mavlinkProvider);  // Access MavlinkCommandService
//   final waypoints = Ref.read(waypointProvider); // Your current mission

//   if (waypoints.isEmpty) {
//     print("❗ No mission waypoints loaded");
//     return;
//   }

//   try {
//     print("📤 Uploading mission...");

//     // 1. Send MISSION_COUNT
//     await mavlink.sendMissionCount(waypoints.length);

//     // 2. Send MISSION_ITEMs
//     for (final wp in waypoints) {
//       await mavlink.sendMissionItem(wp);
//     }

//     print("✅ Mission uploaded");

//     // 3. ARM
//     await mavlink.arm(true);
//     print("🛠️ Drone armed");

//     // 4. Set mode to AUTO
//     await mavlink.setMode(3); // 3 = AUTO
//    print("🚀 Switched to AUTO mode. Mission starting...");

//   } catch (e) {
//    print("❌ Mission failed: $e");
//   }
// }

// Future<void> sendMissionCount(int count) async {
//   final msg = MissionCount(
//     targetSystem: _targetSystem,
//     targetComponent: _targetComponent,
//     count: count,
//     missionType: mavMissionTypeMission,
//     opaqueId: 0,
//   );
//   socketService.send(msg);
// }

// Future<void> sendMissionItem(Waypoint wp) async {
//   final msg = MissionItemInt(
//     targetSystem: _targetSystem,
//     targetComponent: _targetComponent,
//     seq: wp.sequence,
//     frame: wp.frame,
//     command: wp.command,
//     current: wp.current ? 1 : 0,
//     autocontinue: wp.autocontinue ? 1 : 0,
//     x: (wp.position.latitude * 1e7).round(),
//     y: (wp.position.longitude * 1e7).round(),
//     z: wp.altitude,
//     param1: wp.param1,
//     param2: wp.param2,
//     param3: wp.param3,
//     param4: wp.param4,
//     missionType: mavMissionTypeMission,
//   );
//   socketService.send(msg);
// }

//   // Also add this to monitor mission progress
//   void onMissionCurrent(MissionCurrent msg) {
//     print('📍 Current mission item: ${msg.seq}');
//     if (msg.seq == 0) print('🏠 At HOME waypoint');
//     if (msg.seq == 1) print('🛫 TAKEOFF in progress');
//     if (msg.seq >= 2) print('🎯 Navigation waypoint ${msg.seq - 2}');
//   }

//   /// Start mission command
//   Future<void> startMissionCommand() async {
//     final cmd = CommandLong(
//       targetSystem: _targetSystem,
//       targetComponent: _targetComponent,
//       command: mavCmdMissionStart,
//       confirmation: 0,
//       param1: 0, // First mission item (0 = start from beginning)
//       param2: 0, // Last mission item (0 = all items)
//       param3: 0,
//       param4: 0,
//       param5: 0,
//       param6: 0,
//       param7: 0,
//     );

//     socketService.send(cmd);
//     print('🚀 Mission start command sent');
//   }

//   Future<void> uploadMission(List<Waypoint> missionItems) async {
//     print("🚨 uploadMission() called with ${missionItems.length} items");

//     final count = missionItems.length;
//     final controller = StreamController<MavlinkFrame>();
//     final sub = socketService.mavlinkStream.listen(controller.add);

//     socketService.send(
//       MissionClearAll(
//         targetSystem: _targetSystem,
//         targetComponent: _targetComponent,
//         missionType: mavMissionTypeMission,
//       ),
//     );
//     await Future.delayed(const Duration(milliseconds: 300));

//     socketService.send(
//       MissionCount(
//         targetSystem: _targetSystem,
//         targetComponent: _targetComponent,
//         count: count,
//         missionType: mavMissionTypeMission,
//         opaqueId: 0,
//       ),
//     );
//     await Future.delayed(const Duration(milliseconds: 300));

//     await for (final frame in controller.stream) {
//       final msg = frame.message;
//       if(msg is MissionRequestInt){
//         print('mission request int');
//       }
//       if (msg is MissionRequestInt || msg is MissionRequest) {
//         final seq = (msg is MissionRequestInt)
//             ? msg.seq
//             : (msg as MissionRequest).seq;

//         if (seq < 0 || seq >= count) break;

//         final wp = missionItems[seq];

//         final item = MissionItemInt(
//           targetSystem: _targetSystem,
//           targetComponent: _targetComponent,
//           seq: seq,
//           frame: wp.frame,
//           command: wp.command,
//           current: wp.current ? 1 : 0,
//           autocontinue: wp.autocontinue ? 1 : 0,
//           param1: wp.param1,
//           param2: wp.param2,
//           param3: wp.param3,
//           param4: wp.param4,
//           x: (wp.position.latitude * 1e7).toInt(),
//           y: (wp.position.longitude * 1e7).toInt(),
//           z: wp.altitude,
//           missionType: mavMissionTypeMission,
//         );

//         socketService.send(item);
//         print(
//           '📤 Sent mission item $seq: command=${wp.command}, alt=${wp.altitude}',
//         );
//         await Future.delayed(const Duration(milliseconds: 300));
//       } else if (msg is MissionAck) {
//         print('✅ Mission acknowledged with result: ${msg.type}');
//         break;
//       }
//     }

//     await sub.cancel();
//     await controller.close();
//   }
// }

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
    // try {
    //   // Option 1: MAV_CMD_MISSION_START (300)
    //   await sendCommand(
    //     command: 300, // MAV_CMD_MISSION_START
    //     param1: 0,    // First mission item (0 for start from beginning)
    //     param2: 0,    // Last mission item (0 for all items)
    //     param3: 0,
    //     param4: 0,
    //     param5: 0,
    //     param6: 0,
    //     param7: 0,
    //   );

    //   print('[Mission Start] ✅ Mission start command sent');
    // } catch (e) {
    //   print('[Mission Start] ❌ Failed to send mission start command: $e');

    //   // Fallback: Try setting mission current item
    //   try {
    //     print('[Mission Start] 📤 Trying fallback: Set mission current...');
    //     await sendCommand(
    //       command: 223, // MAV_CMD_DO_SET_MISSION_CURRENT
    //       param1: 1,    // Start from sequence 1 (takeoff)
    //       param2: 0,
    //       param3: 0,
    //       param4: 0,
    //       param5: 0,
    //       param6: 0,
    //       param7: 0,
    //     );
    //     print('[Mission Start] ✅ Mission current set to takeoff');
    //   } catch (e2) {
    //     print('[Mission Start] ❌ Fallback also failed: $e2');
    //   }
    // }
  }

  // Make sure you have this sendCommand method (adjust based on your MAVLink implementation)
  // Future<void> sendCommand({
  //   required int command,
  //   double param1 = 0,
  //   double param2 = 0,
  //   double param3 = 0,
  //   double param4 = 0,
  //   double param5 = 0,
  //   double param6 = 0,
  //   double param7 = 0,
  // }) async {
  //   // This should match your existing command sending implementation
  //   // Example based on common MAVLink patterns:

  //   final commandLong = CommandLong(
  //     targetSystem: targetSystemId, // Your target system ID
  //     targetComponent: targetComponentId, // Your target component ID
  //     command: command,
  //     confirmation: 0,
  //     param1: param1,
  //     param2: param2,
  //     param3: param3,
  //     param4: param4,
  //     param5: param5,
  //     param6: param6,
  //     param7: param7,
  //   );

  //   // Send the command through your MAVLink connection
  //   await mavlinkConnection.sendMessage(commandLong);
  // }

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
