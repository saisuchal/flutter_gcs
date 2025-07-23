class TelemetryData {
  final double latitude;
  final double longitude;
  final double altitude;
  final int vx;
  final int vy;
  final int vz;
  final double heading;

  final int? currentWp;
  final int? reachedWp;

  const TelemetryData({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.vx,
    required this.vy,
    required this.vz,
    required this.heading,
    this.currentWp,
    this.reachedWp,
  });

  TelemetryData copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    int? vx,
    int? vy,
    int? vz,
    double? heading,
    int? currentWp,
    int? reachedWp,
  }) {
    return TelemetryData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      vx: vx ?? this.vx,
      vy: vy ?? this.vy,
      vz: vz ?? this.vz,
      heading: heading ?? this.heading,
      currentWp: currentWp ?? this.currentWp,
      reachedWp: reachedWp ?? this.reachedWp,
    );
  }

  @override
  String toString() {
    return 'TelemetryData('
        'lat: $latitude, lon: $longitude, alt: $altitude, '
        'vx: $vx, vy: $vy, vz: $vz, '
        'hdg: $heading, '
        'currentWp: $currentWp, reachedWp: $reachedWp'
        ')';
  }
}
