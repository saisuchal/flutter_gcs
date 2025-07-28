import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gcs/src/services/mavlink_command_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:path_provider/path_provider.dart';
import '../../widgets/floating_nav_menu.dart';
import '../../src/provider/mavlink_provider.dart';
import '../../src/provider/provider.dart';
import 'waypoint_model.dart';
import 'waypoint_map.dart';

import 'package:another_flushbar/flushbar.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  gmaps.GoogleMapController? _mapController;
  final MapController _leafletController = MapController();
  gmaps.MapType _mapType = gmaps.MapType.normal;
  final _mapTypes = [gmaps.MapType.normal, gmaps.MapType.hybrid];
  bool _didListen = false;

  void _toggleGoogleMapType() {
    final index = _mapTypes.indexOf(_mapType);
    setState(() => _mapType = _mapTypes[(index + 1) % _mapTypes.length]);
  }

  void _addWaypoint(gmaps.LatLng pos) {
    ref.read(waypointProvider.notifier).add(pos);
  }

  void _clearWaypoints() {
    ref.read(waypointProvider.notifier).clear();
    ref.read(showMissionOverlayProvider.notifier).state = false;
  }

  void _locateDrone(gmaps.LatLng? position, MapProviderType type) {
    if (position == null) return;
    if (type == MapProviderType.google) {
      _mapController?.animateCamera(gmaps.CameraUpdate.newLatLng(position));
    } else {
      _leafletController.move(
        latlng.LatLng(position.latitude, position.longitude),
        15,
      );
    }
  }

  Future<String> _getLocalFilePath(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$name';
  }

  Future<void> _saveWaypointsToFile(List<Waypoint> wps) async {
    final path = await _getLocalFilePath('waypoints.json');
    final data = wps
        .map(
          (wp) => {
            'sequence': wp.sequence,
            'lat': wp.position.latitude,
            'lon': wp.position.longitude,
            'alt': wp.altitude,
            'command': wp.command,
            'param1': wp.param1,
            'param2': wp.param2,
            'param3': wp.param3,
            'param4': wp.param4,
            'current': wp.current,
          },
        )
        .toList();
    await File(path).writeAsString(jsonEncode(data));
    _showFlushbar("🔖 Waypoints saved to file", color: Colors.green);
  }

  Future<void> _loadWaypointsFromFile() async {
    try {
      final path = await _getLocalFilePath('waypoints.json');
      final raw = await File(path).readAsString();
      final List decoded = jsonDecode(raw);

      final waypoints = decoded
          .map(
            (wp) => Waypoint(
              sequence: wp['sequence'] ?? 0,
              position: gmaps.LatLng(wp['lat'], wp['lon']),
              altitude: wp['alt'] ?? 10.0,
              command: wp['command'] ?? 16,
              param1: wp['param1'] ?? 0.0,
              param2: wp['param2'] ?? 0.0,
              param3: wp['param3'] ?? 0.0,
              param4: wp['param4'] ?? 0.0,
              current: wp['current'] ?? false,
            ),
          )
          .toList();

      ref.read(waypointProvider.notifier).set(waypoints);
      _showFlushbar("📂 Waypoints loaded", color: Colors.teal);
    } catch (e) {
      _showFlushbar("❌ Failed to load waypoints", color: Colors.red);
    }
  }

  void _showFlushbar(
    String message, {
    Color color = Colors.blueAccent,
    IconData icon = Icons.info_outline,
  }) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: color,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.GROUNDED,
      icon: Icon(icon, color: Colors.white),
      maxWidth: 500,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    final telemetry = ref.watch(mavlinkProvider);
    final waypoints = ref.watch(waypointProvider);
    final mapType = ref.watch(mapProviderTypeProvider);

    if (!_didListen) {
      _didListen = true;
      ref.listen(mavlinkProvider, (prev, next) {
        if (next.latitude != null && next.longitude != null) {
          final lat = next.latitude!.toStringAsFixed(5);
          final lon = next.longitude!.toStringAsFixed(5);
          _showFlushbar(
            "📡 Telemetry Update: $lat, $lon",
            color: Colors.indigo,
            icon: Icons.my_location,
          );
        }
      });
    }

    final gmaps.LatLng? dronePos =
        (telemetry.latitude != null && telemetry.longitude != null)
        ? gmaps.LatLng(telemetry.latitude!, telemetry.longitude!)
        : null;

    final latlng.LatLng leafletDronePos = dronePos != null
        ? latlng.LatLng(dronePos.latitude, dronePos.longitude)
        : const latlng.LatLng(20.5937, 78.9629); // India

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Planner'),
        backgroundColor: Colors.grey[100],
        actions: [
          PopupMenuButton<MapProviderType>(
            icon: const Icon(Icons.map),
            onSelected: (type) =>
                ref.read(mapProviderTypeProvider.notifier).state = type,
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                value: MapProviderType.google,
                child: Text("Google Map"),
              ),
              PopupMenuItem(
                value: MapProviderType.leaflet,
                child: Text("Leaflet"),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _saveWaypointsToFile(waypoints),
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: _loadWaypointsFromFile,
            icon: const Icon(Icons.folder_open),
          ),
          IconButton(
            onPressed: _clearWaypoints,
            icon: const Icon(Icons.delete_forever),
          ),
          // IconButton(
          //   onPressed: _sendWaypointsToDrone,
          //   icon: const Icon(Icons.send),
          // ),
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: mapType == MapProviderType.google
                    ? _buildGoogleMap(
                        dronePos,
                        waypoints,
                        telemetry.heading?.toInt(),
                      )
                    : _buildLeafletMap(leafletDronePos, waypoints),
              ),
              Expanded(child: _buildWaypointSidebar(waypoints)),
            ],
          ),
          const Positioned(left: 16, bottom: 16, child: FloatingNavMenu()),
        ],
      ),
    );
  }

  Widget _buildGoogleMap(
    gmaps.LatLng? dronePos,
    List<Waypoint> waypoints,
    int? heading,
  ) {
    return Stack(
      children: [
        WaypointMap(
          waypoints: waypoints,
          dronePosition: dronePos,
          heading: heading,
          mapType: _mapType,
          onTap: _addWaypoint,
          onMapCreated: (c) => _mapController = c,
        ),
        Positioned(
          bottom: 85,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'toggle_map_type',
            onPressed: _toggleGoogleMapType,
            child: const Icon(Icons.layers),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'locate_drone',
            onPressed: () => _locateDrone(dronePos, MapProviderType.google),
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  Widget _buildLeafletMap(latlng.LatLng dronePos, List<Waypoint> waypoints) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _leafletController,
          options: MapOptions(
            initialCenter: dronePos,
            initialZoom: 15,
            onTap: (_, pos) =>
                _addWaypoint(gmaps.LatLng(pos.latitude, pos.longitude)),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_gcs',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: waypoints
                      .map(
                        (wp) => latlng.LatLng(
                          wp.position.latitude,
                          wp.position.longitude,
                        ),
                      )
                      .toList(),
                  color: Colors.blue,
                  strokeWidth: 4,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                ...waypoints.map(
                  (wp) => Marker(
                    point: latlng.LatLng(
                      wp.position.latitude,
                      wp.position.longitude,
                    ),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.place, color: Colors.red),
                  ),
                ),
                Marker(
                  point: dronePos,
                  width: 50,
                  height: 50,
                  child: const Icon(Icons.flight, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'locate_drone_leaflet',
            onPressed: () => _locateDrone(
              gmaps.LatLng(dronePos.latitude, dronePos.longitude),
              MapProviderType.leaflet,
            ),
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  Widget _buildWaypointSidebar(List<Waypoint> waypoints) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Waypoints:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: waypoints.length,
              itemBuilder: (context, index) {
                final wp = waypoints[index];
                return ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircleAvatar(
                      radius: 18, // Explicitly set radius smaller than SizedBox
                      child: Text('${index + 1}'),
                    ),
                  ),
                  title: Text(
                    'Lat: ${wp.position.latitude.toStringAsFixed(6)}\n'
                    'Lon: ${wp.position.longitude.toStringAsFixed(6)}\n'
                    'Alt: ${wp.altitude.toStringAsFixed(1)} m',
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        ref.read(waypointProvider.notifier).remove(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
