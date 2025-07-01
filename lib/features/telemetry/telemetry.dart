import 'package:flutter/material.dart';
import 'package:flutter_gcs/core/usb/usb_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider.dart';


class Telemetry extends ConsumerWidget{
  const Telemetry ({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final telemetry = ref.watch(telemetryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter GCS'),  
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: double.infinity,),
            Text("Lat: ${telemetry.lat.toStringAsFixed(6)}", style: const TextStyle(fontSize: 20)),
            Text("Lon: ${telemetry.lon.toStringAsFixed(6)}", style: const TextStyle(fontSize: 20)),
            Text("Alt: ${telemetry.alt.toStringAsFixed(2)} m", style: const TextStyle(fontSize: 20)),
            const SizedBox(height:20),
            ElevatedButton(
              onPressed: () async {
                final usbService = ref.read(usbserviceprovider);
                await usbService.connect(); // This starts the USB connection
                // In the future: Connect this to MAVLink decoding and telemetry updates
              },
              child: const Text("Connect USB"),
            ),
          ],
          ),
        ),
      );
  }
}
