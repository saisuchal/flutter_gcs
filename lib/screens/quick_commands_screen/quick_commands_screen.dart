import 'package:flutter/material.dart';
import 'package:flutter_gcs/screens/plan_screen/waypoint_model.dart';
import 'package:flutter_gcs/src/provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gcs/widgets/floating_nav_menu.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../src/provider/mavlink_provider.dart';
import '../../src/services/mavlink_command_service.dart';
// import 'package:collection/collection.dart'; // for mapIndexed

class QuickCommandsScreen extends ConsumerStatefulWidget {
  const QuickCommandsScreen({super.key});

  @override
  ConsumerState<QuickCommandsScreen> createState() =>
      _QuickCommandsScreenState();
}

class _QuickCommandsScreenState extends ConsumerState<QuickCommandsScreen> {
  void _showFlushbar(
    String message, {
    Color color = Colors.blue,
    IconData icon = Icons.info,
  }) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(50.0),
      backgroundColor: color,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      icon: Icon(icon, color: Colors.white),
      maxWidth: 500,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final mav = ref.watch(mavlinkProvider);
    final socket = mav.socketService;

    if (socket == null) {
      return const Scaffold(
        body: Center(child: Text("⚠️ MAVLink Socket not available")),
      );
    }

    final commandService = MavlinkCommandService(socket);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Commands'),
        backgroundColor: Colors.grey[100],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 2.5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                ElevatedButton(
                  child: const Text("START MISSION"),
                  onPressed: () async {
                    try {
                      final userWaypoints = ref.read(waypointProvider);

                      if (userWaypoints.isEmpty) {
                        _showFlushbar(
                          "⚠️ No mission waypoints to upload",
                          color: Colors.red,
                          icon: Icons.warning,
                        );
                        return;
                      }

                      var telemetry = ref.read(mavlinkProvider);

                      if (telemetry == null) {
                        _showFlushbar(
                          "🔄 Waiting for drone telemetry...",
                          color: Colors.orange,
                          icon: Icons.sync,
                        );
                        while (telemetry == null) {
                          await Future.delayed(
                            const Duration(milliseconds: 1500),
                          );

                          telemetry = ref.read(mavlinkProvider);
                        }

                        if (telemetry == null) {
                          _showFlushbar(
                            "⚠️ Timeout: No telemetry received after 10 seconds",
                            color: Colors.red,
                            icon: Icons.signal_wifi_off,
                          );
                          return;
                        }
                      }

                      final currentLat = telemetry.latitude;
                      final currentLon = telemetry.longitude;
                      final currentAlt = telemetry.altitude;

                      if (currentLat == null || currentLon == null) {
                        _showFlushbar(
                          "⚠️ No GPS position available - waiting for GPS fix",
                          color: Colors.red,
                          icon: Icons.gps_off,
                        );
                        return;
                      }

                      if (currentLat == 0.0 || currentLon == 0.0) {
                        _showFlushbar(
                          "⚠️ Invalid GPS coordinates (0,0) - check GPS status",
                          color: Colors.red,
                          icon: Icons.gps_not_fixed,
                        );
                        return;
                      }

                      _showFlushbar(
                        "🚀 Starting mission: ${userWaypoints.length} waypoints",
                        color: Colors.blue,
                        icon: Icons.flight_takeoff,
                      );

                      await commandService.startMission(
                        missionItems: userWaypoints,
                        mavlink: telemetry,
                      );

                      _showFlushbar(
                        "✅ Mission started successfully!\nTAKEOFF → ${userWaypoints.length} waypoints",
                        color: Colors.green,
                        icon: Icons.check_circle,
                      );
                    } catch (e) {
                      print(e);
                      _showFlushbar(
                        "❌ Mission start failed: ${e.toString()}",
                        color: Colors.red,
                        icon: Icons.error,
                      );
                      print('Mission start error: $e');
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    commandService.takeoff();
                    _showFlushbar(
                      "🛫 Takeoff Command Sent",
                      color: Colors.green,
                      icon: Icons.flight_takeoff,
                    );
                  },
                  child: const Text("TAKEOFF"),
                ),
                ElevatedButton(
                  onPressed: () {
                    commandService.land();
                    _showFlushbar(
                      "🛬 Land Command Sent",
                      color: Colors.orange,
                      icon: Icons.flight_land,
                    );
                  },
                  child: const Text("LAND"),
                ),
                ElevatedButton(
                  onPressed: () {
                    commandService.returnToLaunch();
                    _showFlushbar(
                      "📍 RTL Command Sent",
                      color: Colors.teal,
                      icon: Icons.my_location,
                    );
                  },
                  child: const Text("RTL"),
                ),
                ElevatedButton(
                  onPressed: () {
                    commandService.setMode(0); // STABILIZE
                    _showFlushbar(
                      "🛠 Mode: STABILIZE",
                      color: Colors.blueGrey,
                      icon: Icons.stairs,
                    );
                  },
                  child: const Text("STABILIZE"),
                ),
                ElevatedButton(
                  onPressed: () {
                    commandService.setMode(3); // AUTO
                    _showFlushbar(
                      "🤖 Mode: AUTO",
                      color: Colors.deepPurple,
                      icon: Icons.autorenew,
                    );
                  },
                  child: const Text("AUTO"),
                ),
                ElevatedButton(
                  onPressed: () {
                    commandService.arm(true);
                    _showFlushbar(
                      "🔓 Drone Armed",
                      color: Colors.green,
                      icon: Icons.lock_open,
                    );
                  },
                  child: const Text("ARM"),
                ),
                ElevatedButton(
                  onPressed: () {
                    commandService.arm(false);
                    _showFlushbar(
                      "🔒 Drone Disarmed",
                      color: Colors.red,
                      icon: Icons.lock,
                    );
                  },
                  child: const Text("DISARM"),
                ),
              ],
            ),
          ),
          const Positioned(left: 16, bottom: 16, child: FloatingNavMenu()),
        ],
      ),
    );
  }
}
