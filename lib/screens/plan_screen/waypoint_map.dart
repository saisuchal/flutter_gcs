import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'waypoint_model.dart';

class WaypointMap extends StatelessWidget {
  final List<Waypoint> waypoints;
  final LatLng? dronePosition;
  final int? heading;
  final void Function(LatLng) onTap;
  final void Function(GoogleMapController) onMapCreated;
  final MapType mapType;

  const WaypointMap({
    super.key,
    required this.waypoints,
    required this.onTap,
    required this.onMapCreated,
    required this.mapType,
    this.dronePosition,
    this.heading,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng cameraTarget = waypoints.isNotEmpty
        ? waypoints.last.position
        : (dronePosition ?? const LatLng(0, 0));

    final Set<Marker> markers = {
      for (final wp in waypoints)
        Marker(
          markerId: MarkerId('wp${wp.sequence}'),
          position: wp.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'WP ${wp.sequence + 1}'),
        ),
      if (dronePosition != null)
        Marker(
          markerId: const MarkerId('drone'),
          position: dronePosition!,
          rotation: (heading ?? 0).toDouble(),
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Drone'),
        ),
    };

    final Polyline polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: waypoints.map((wp) => wp.position).toList(),
      color: Colors.blue,
      width: 4,
    );

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: cameraTarget,
        zoom: 15,
      ),
      onMapCreated: onMapCreated,
      onTap: onTap,
      markers: markers,
      polylines: {polyline},
      mapType: mapType,
      compassEnabled: true,
      myLocationEnabled: false,
      zoomControlsEnabled: false,
    );
  }
}
