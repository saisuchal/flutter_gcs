import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'model.dart';

final telemetryProvider = StateNotifierProvider<TelemetryNotifier, TelemetryData>((ref){
  return TelemetryNotifier();
});

class TelemetryNotifier extends StateNotifier<TelemetryData>{
  TelemetryNotifier() : super(const TelemetryData());

  void updateTelemetry(double lat, double lon, double alt){
    state = state.copyWith(lat: lat, lon:lon, alt:alt);
  }
}