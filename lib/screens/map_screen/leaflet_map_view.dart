import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as leaflet;

import '../../src/provider/mavlink_provider.dart';
import '../../widgets/telemetry_overlay.dart';

class LeafletMapView extends ConsumerStatefulWidget {
  const LeafletMapView({super.key});

  @override
  ConsumerState<LeafletMapView> createState() => _LeafletMapViewState();
}

class _LeafletMapViewState extends ConsumerState<LeafletMapView> {
  final MapController _mapController = MapController();
  late ProviderSubscription _mavListener;

  @override
  void initState() {
    super.initState();

    _mavListener = ref.listenManual(mavlinkProvider, (prev, next) {
      if (next.latitude != null && next.longitude != null) {
        final pos = leaflet.LatLng(next.latitude!, next.longitude!);
        _mapController.move(pos, 16.0); // Fixed zoom for smoother tracking
      }
    });
  }

  @override
  void dispose() {
    _mavListener.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mav = ref.watch(mavlinkProvider);

    final hasPosition = mav.latitude != null && mav.longitude != null;
    final dronePos = hasPosition
        ? leaflet.LatLng(mav.latitude!, mav.longitude!)
        : const leaflet.LatLng(0, 0);

    final markers = hasPosition
        ? [
            Marker(
              width: 40,
              height: 40,
              point: dronePos,
              child: Transform.rotate(
                angle: (mav.heading ?? 0) * (pi / 180),
                child: const Icon(
                  Icons.airplanemode_active,
                  color: Colors.red,
                  size: 32,
                ),
              ),
            )
          ]
        : <Marker>[];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: dronePos,
            initialZoom: 16.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_gcs',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
        const Positioned(top: 16, right: 16, child: TelemetryOverlay()),
      ],
    );
  }
}
