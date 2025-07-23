import 'dart:io';
import 'package:dart_mavlink/mavlink.dart';
import 'package:dart_mavlink/dialects/common.dart';

class MavlinkSocketService {
  Socket? _socket;
  final MavlinkParser parser = MavlinkParser(MavlinkDialectCommon());

  late final Stream<MavlinkFrame> _broadcastStream =
      parser.stream.asBroadcastStream();

  Future<void> connect(String host, int port) async {
    _socket = await Socket.connect(host, port);
    _socket!.listen(
      parser.parse,
      onDone: disconnect,
      onError: (e) {
        print("❌ Socket error: $e");
        disconnect();
      },
    );
  }

  void send(MavlinkMessage message) {
  if (_socket != null) {
    try {
      final frame = MavlinkFrame.v2(255, 0, 0, message);
      _socket!.add(frame.serialize());
    } catch (e) {
      print("❌ Failed to send MAVLink message: $e");
      disconnect();
    }
  }
}


  void disconnect() {
    _socket?.destroy();
    _socket = null;
  }

  bool get isConnected => _socket != null;

  Stream<MavlinkFrame> get mavlinkStream => _broadcastStream;
}
