import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'usb_service.dart';

final usbserviceprovider = Provider<USBService>((ref) => USBService());