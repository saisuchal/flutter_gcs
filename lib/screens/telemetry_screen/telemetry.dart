import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../src/provider/mavlink_provider.dart';

class TelemetryView extends ConsumerWidget {
  const TelemetryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mav = ref.watch(mavlinkProvider);
    final telemetry = mav.telemetry;

    String formatDouble(double? value, {int decimals = 2}) =>
        value != null ? value.toStringAsFixed(decimals) : 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemetry Data'),
        backgroundColor: Colors.grey[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _entry("Status", mav.status),
            _entry("Mode", mav.mode),
            _entry("Armed", mav.armed ? "Yes" : "No"),
            const Divider(height: 32),
            _entry("Latitude", formatDouble(mav.latitude, decimals: 7)),
            _entry("Longitude", formatDouble(mav.longitude, decimals: 7)),
            _entry("Altitude", formatDouble(mav.altitude, decimals: 1)),
            _entry("Heading", '${formatDouble(mav.heading)}°'),
            const Divider(height: 32),
            if (telemetry?.currentWp != null)
              _entry("Current WP", telemetry!.currentWp.toString()),
            if (telemetry?.reachedWp != null)
              _entry("Reached WP", telemetry!.reachedWp.toString()),
          ],
        ),
      ),
    );
  }

  Widget _entry(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        "$label: $value",
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}
