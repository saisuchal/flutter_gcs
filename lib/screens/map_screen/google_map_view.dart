import 'package:flutter/material.dart';
import 'package:flutter_gcs/widgets/telemetry_overlay.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../src/provider/mavlink_provider.dart';

class GoogleMapView extends ConsumerStatefulWidget {
  const GoogleMapView({super.key});

  @override
  ConsumerState<GoogleMapView> createState() => _GoogleMapViewState();
}

class _GoogleMapViewState extends ConsumerState<GoogleMapView> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _droneIcon;
  late ProviderSubscription<MavlinkProvider> listener;

  final List<MapType> _mapTypes = [MapType.hybrid, MapType.normal];
  int _currentMapTypeIndex = 0;

  MapType get _currentMapType => _mapTypes[_currentMapTypeIndex];

  void _toggleMapType() {
    setState(() {
      _currentMapTypeIndex = (_currentMapTypeIndex + 1) % _mapTypes.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMarker();

    listener = ref.listenManual(mavlinkProvider, (prev, next) {
      if (_mapController != null &&
          next.latitude != null &&
          next.longitude != null) {
        final LatLng newPos = LatLng(next.latitude!, next.longitude!);
        _mapController!.animateCamera(CameraUpdate.newLatLng(newPos));
      }
    });
  }

  @override
  void dispose() {
    listener.close();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMarker() async {
    final icon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/icons/drone.png',
    );
    setState(() {
      _droneIcon = icon;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mav = ref.watch(mavlinkProvider);

    final hasValidPosition = mav.latitude != null && mav.longitude != null;
    final LatLng dronePosition = hasValidPosition
        ? LatLng(mav.latitude!, mav.longitude!)
        : const LatLng(0, 0);

    final markerSet = hasValidPosition
        ? {
            Marker(
              markerId: const MarkerId('drone'),
              position: dronePosition,
              icon: _droneIcon ?? BitmapDescriptor.defaultMarker,
              rotation: mav.heading ?? 0.0,
              anchor: const Offset(0.5, 0.5),
              infoWindow: const InfoWindow(title: 'Drone'),
            ),
          }
        : <Marker>{};

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: dronePosition,
            zoom: 16,
          ),
          mapType: _currentMapType,
          onMapCreated: (controller) => _mapController = controller,
          markers: markerSet,
          compassEnabled: true,
          myLocationEnabled: false,
          zoomControlsEnabled: false,
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            heroTag: 'toggle_map_type',
            onPressed: _toggleMapType,
            tooltip: 'Toggle Map Type',
            child: const Icon(Icons.layers),
          ),
        ),
        const Positioned(top: 16, right: 16, child: TelemetryOverlay()),
      ],
    );
  }
}
