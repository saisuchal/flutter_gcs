import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'google_map_view.dart';
import 'leaflet_map_view.dart';
import 'package:flutter_gcs/widgets/floating_nav_menu.dart';
import 'package:flutter_gcs/src/provider/provider.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(mapProviderTypeProvider);

    final Widget mapView = switch (selected) {
      MapProviderType.google => const GoogleMapView(),
      MapProviderType.leaflet => const LeafletMapView(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Map View"),
        backgroundColor: Colors.grey[100],
        actions: [
          Row(
            children: [
              const Text("Map: ", style: TextStyle(color: Colors.black87)),
              DropdownButton<MapProviderType>(
                value: selected,
                items: const [
                  DropdownMenuItem(
                    value: MapProviderType.google,
                    child: Text('Google'),
                  ),
                  DropdownMenuItem(
                    value: MapProviderType.leaflet,
                    child: Text('Leaflet'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    ref.read(mapProviderTypeProvider.notifier).state = val;
                  }
                },
              ),
              const SizedBox(width: 16),
            ],
          ),
        ],
      ),
      body:Stack(
          children: [
            mapView,
            const FloatingNavMenu(),
          ],
        ),
    );
  }
}
