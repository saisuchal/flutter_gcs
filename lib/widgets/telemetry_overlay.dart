import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../src/provider/mavlink_provider.dart';

class TelemetryOverlay extends ConsumerWidget {
  const TelemetryOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mav = ref.watch(mavlinkProvider);

    if (mav.latitude == null || mav.longitude == null || mav.altitude == null) {
      return const SizedBox(); // No telemetry yet
    }

    return Container(
      padding: const EdgeInsets.all(8),
      width: 160,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white, fontSize: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lat: ${mav.latitude!.toStringAsFixed(6)}'),
            Text('Lon: ${mav.longitude!.toStringAsFixed(6)}'),
            Text('Alt: ${mav.altitude!.toStringAsFixed(1)} m'),
            if (mav.heading != null)
              Text('Hdg: ${mav.heading!.toStringAsFixed(1)}°'),
            Text('Mode: ${mav.mode}'),
            Text('Armed: ${mav.armed ? 'Yes' : 'No'}'),
            Text('Status: ${mav.status}'),
          ],
        ),
      ),
    );
  }
}
