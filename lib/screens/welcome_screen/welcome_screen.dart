import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gcs/screens/map_screen/map_screen.dart';
import 'package:flutter_gcs/src/provider/mavlink_provider.dart';
import 'package:flutter_gcs/src/provider/provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final ipController = TextEditingController(text: '10.0.2.2');
  final portController = TextEditingController(text: '5762');
  bool isWireless = false;

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final protocol = ref.read(selectedProtocolProvider);

    if (protocol == SelectedProtocol.udp) {
      _showSnack("❌ UDP not supported yet in native mode");
      return;
    }

    if (protocol == SelectedProtocol.usb) {
      _showSnack("❌ USB not implemented in native mode");
      return;
    }

    final ip = ipController.text.trim();
    final port = int.tryParse(portController.text.trim());

    if (ip.isEmpty || port == null) {
      _showSnack("⚠️ Enter a valid IP and port");
      return;
    }

    ref.read(isWirelessProvider.notifier).state =
        (protocol == SelectedProtocol.wirelessTcp);

    try {
      await ref.read(mavlinkProvider).connect(ip, port);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MapScreen()),
        );
      }
    } catch (e) {
      _showSnack('❌ Connection error: $e');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedProtocolProvider);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
        child: ListView(
          children: [
            const Text(
              "Flutter GCS",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Text("Select Connection Protocol:", textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildRadioOption("SITL (USB)", SelectedProtocol.usb)),
                Expanded(child: _buildRadioOption("SITL (TCP)", SelectedProtocol.tcp)),
                Expanded(child: _buildRadioOption("SITL (UDP)", SelectedProtocol.udp)),
              ],
            ),
            if (selected == SelectedProtocol.tcp || selected == SelectedProtocol.wirelessTcp)
              ..._buildConnectionFields(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _connect,
              child: const Text("Connect"),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildConnectionFields() {
    return [
      const SizedBox(height: 20),
      TextField(
        controller: ipController,
        decoration: const InputDecoration(
          labelText: 'Telemetry IP Address',
          hintText: 'e.g. 192.168.1.100',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: portController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Telemetry Port',
          hintText: 'e.g. 5762',
          border: OutlineInputBorder(),
        ),
      ),
      CheckboxListTile(
        title: const Text("Connect from physical device (Wireless TCP)"),
        value: isWireless,
        onChanged: (val) {
          final newValue = val ?? false;
          setState(() => isWireless = newValue);
          ref.read(selectedProtocolProvider.notifier).state =
              newValue ? SelectedProtocol.wirelessTcp : SelectedProtocol.tcp;
        },
      ),
    ];
  }

  Widget _buildRadioOption(String title, SelectedProtocol value) {
    final selected = ref.watch(selectedProtocolProvider);
    return ListTile(
      title: Text(title),
      leading: Radio<SelectedProtocol>(
        value: value,
        groupValue: selected,
        onChanged: (val) {
          if (val != null) {
            ref.read(selectedProtocolProvider.notifier).state = val;
            setState(() => isWireless = val == SelectedProtocol.wirelessTcp);
          }
        },
      ),
    );
  }
}
