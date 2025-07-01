import 'package:flutter_serial/flutter_serial.dart';

class USBService {
  final FlutterSerial _serial = FlutterSerial();
  Stream<SerialResponse?>? _stream;

  Future<void> connect() async {
    List<String> ports = await _serial.getAvailablePorts() ?? [];

    if (ports.isEmpty) {
      print("No USB devices found.");
      return;
    }

    String selectedPort = ports.first;
    print("connecting to: $selectedPort");

    await _serial.openPort(
      serialPort: selectedPort,
      baudRate: 57600,
      dataFormat: DataFormat.HEX_STRING,
    );

    _stream = _serial.startSerial();
    _stream?.listen((SerialResponse? response) {
      if (response != null) {
        final data = response.readChannel;
        print("📥 Received data: $data");
      }
    });
  }

  void send(List<int> bytes) {
    _serial.sendCommand(message: String.fromCharCodes(bytes));
  }

  Future<void> disconnect() async {
    await _serial.closePort();
    print("Port Closed");
  }
}
