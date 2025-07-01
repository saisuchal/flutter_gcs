class TelemetryData{
  final double lat;
  final double lon;
  final double alt;

  const TelemetryData({
    this.lat = 0.0,
    this.lon = 0.0,
    this.alt = 0.0,
  });

  TelemetryData copyWith({double? lat, double? lon, double? alt}) {
    return TelemetryData(
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      alt: alt ?? this.alt,
    );
  }
}