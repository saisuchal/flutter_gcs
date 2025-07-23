import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/dialects/common.dart';
// import 'package:flutter_gcs/screens/plan_screen/waypoint_model.dart';
import 'package:flutter_gcs/screens/telemetry_screen/model.dart';
import 'package:flutter_gcs/src/services/mavlink_command_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/mavlink_socket_service.dart';

final mavlinkProvider = ChangeNotifierProvider<MavlinkProvider>((ref) {
  final socketService = MavlinkSocketService();
  return MavlinkProvider(socketService);
});

final mavlinkCommandServiceProvider = Provider<MavlinkCommandService>((ref) {
  final socketService = ref.read(mavlinkProvider).socketService;
  return MavlinkCommandService(socketService);
});

class MavlinkProvider extends ChangeNotifier {
  final MavlinkSocketService socketService;
  TelemetryData? telemetry;

  bool isConnected = false;
  bool armed = false;
  String mode = 'UNKNOWN';
  String status = 'Disconnected';
  double? latitude;
  double? longitude;
  double? altitude;
  double? heading;

  MavlinkProvider(this.socketService) {
    socketService.mavlinkStream.listen(_handleFrame);
  }

  Future<void> connect(String host, int port) async {
    status = 'Connecting...';
    notifyListeners();

    try {
      await socketService.connect(host, port);
      isConnected = true;
      status = 'Connected';
    } catch (e) {
      isConnected = false;
      status = 'Error: $e';
    }

    notifyListeners();
  }

  void disconnect() {
    socketService.disconnect();
    isConnected = false;
    status = 'Disconnected';
    notifyListeners();
  }

  void _handleFrame(MavlinkFrame frame) {
    final msg = frame.message;

    switch (msg.runtimeType) {
      case Heartbeat:
        final hb = msg as Heartbeat;

        // ✅ Only accept HEARTBEAT from actual autopilot
        if (frame.systemId == 1 && frame.componentId == 1) {
          final newArmed = (hb.baseMode & 0x80) != 0;
          final newMode = _modeFromCustomMode(hb.customMode);
          final newStatus = _systemStatusText(hb.systemStatus);

          // ✅ Update only if changed
          if (newArmed != armed || newMode != mode || newStatus != status) {
            armed = newArmed;
            mode = newMode;
            status = newStatus;
            print('💓 [Filtered] Heartbeat: Armed=$armed, Mode=$mode, Status=$status');
            notifyListeners();
          }
        } else {
          // Debug only: unfiltered heartbeat
          // print('💓 Ignored Heartbeat: SYS=${hb.systemId}, COMP=${hb.componentId}');
        }
        break;

      case GlobalPositionInt:
        final pos = msg as GlobalPositionInt;
        final newLat = pos.lat / 1e7;
        final newLon = pos.lon / 1e7;
        final newAlt = pos.relativeAlt / 1000;
        final newHdg = (pos.hdg != 65535) ? pos.hdg / 100.0 : null;

        if (latitude != newLat ||
            longitude != newLon ||
            altitude != newAlt ||
            heading != newHdg) {
          latitude = newLat;
          longitude = newLon;
          altitude = newAlt;
          heading = newHdg;
          notifyListeners();
        }

        if (DateTime.now().millisecondsSinceEpoch % 5000 < 100) {
          print('📍 Position: $latitude, $longitude, Alt: ${altitude}m');
        }
        break;

      case MissionCurrent:
        final current = msg as MissionCurrent;
        print('📍 Current mission item: ${current.seq}');
        break;

      case CommandAck:
        final ack = msg as CommandAck;
        print('✅ Command ACK: cmd=${ack.command}, result=${ack.result}');
        if (ack.command == 176) {
          print('🎮 Mode change ${ack.result == 0 ? "✅ SUCCESS" : "❌ FAILED"}');
        }
        if (ack.command == 400) {
          print('🔫 Arm/Disarm ${ack.result == 0 ? "✅ SUCCESS" : "❌ FAILED"}');
        }
        if (ack.command == 300) {
          print('🚀 Mission start ${ack.result == 0 ? "✅ SUCCESS" : "❌ FAILED"}');
        }
        break;

      case MissionAck:
        final ack = msg as MissionAck;
        print('📋 Mission ACK: missionType=${ack.missionType}, resultCode=${ack.type}');

        break;

      case Statustext:
        final status = msg as Statustext;
        print('📢 Status: ${String.fromCharCodes(status.text).trim()}');
        break;
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }

  String _modeFromCustomMode(int customMode) {
    switch (customMode) {
      case 0:
        return 'STABILIZE';
      case 3:
        return 'AUTO';
      case 4:
        return 'GUIDED';
      case 5:
        return 'LOITER';
      case 6:
        return 'RTL';
      case 9:
        return 'LAND';
      default:
        return 'Unknown ($customMode)';
    }
  }

  String _systemStatusText(int status) {
    switch (status) {
      case 0:
        return 'UNINIT';
      case 3:
        return 'STANDBY';
      case 4:
        return 'ACTIVE';
      case 5:
        return 'CRITICAL';
      case 6:
        return 'EMERGENCY';
      default:
        return 'Unknown ($status)';
    }
  }
}
