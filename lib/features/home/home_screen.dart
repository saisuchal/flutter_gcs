import 'package:flutter/material.dart';
import 'package:flutter_gcs/bottom_navigation_bar.dart';
import 'package:flutter_gcs/features/telemetry/model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../telemetry/telemetry.dart'; // Adjust if needed
import '../telemetry/provider.dart';

class HomeScreen extends ConsumerStatefulWidget {

  HomeScreen({super.key});
  
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  BitmapDescriptor? _droneIcon;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
  }

  void _loadCustomMarker() async {
    _droneIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/drone.png',
    );
    setState(() {}); // Rebuild with marker
  }

  @override
Widget build(BuildContext context) {

  final telemetry = ref.watch(telemetryProvider);
  final LatLng dronePosition = LatLng(17.42148332361922, 78.34810094056964); //telemetry.lat, telemetry.lon;

  ref.listen<TelemetryData>(telemetryProvider, (previous, next) {
  final dronePosition = LatLng(next.lat, next.lon);
  _mapController?.animateCamera(CameraUpdate.newLatLng(dronePosition));
});

  return Scaffold(
    appBar: AppBar(
      title: const Text('Flutter GCS'),
      // actions: [
      //   TextButton(
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => const Telemetry()),
      //       );
      //     },
      //     child: const Text('Connect', style: TextStyle(color: Colors.white)),
      //   ),
      // ],
    ),
    body: GoogleMap(
      initialCameraPosition: CameraPosition(
        target: dronePosition,
        zoom: 15,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('drone'),
          position: dronePosition,
          infoWindow: const InfoWindow(title: 'Drone'),
          icon: _droneIcon ?? BitmapDescriptor.defaultMarker,
        ),
      },
      onMapCreated: (controller) {
        _mapController = controller;
      },
      myLocationEnabled: true,
      compassEnabled: true,
    ),
  );
}

}
