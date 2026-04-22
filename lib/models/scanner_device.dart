/// Lightweight wrapper for a discovered BLE device with human-readable
/// signal strength buckets.
class ScannerDevice {
  /// Advertised device name (e.g. "RFID Scanner").
  final String name;

  /// Platform-level device ID (MAC address on Android, UUID on iOS).
  final String deviceId;

  /// Raw RSSI value in dBm; null if unknown.
  final int? rssi;

  const ScannerDevice({
    required this.name,
    required this.deviceId,
    this.rssi,
  });

  /// Human-readable signal strength: "strong", "medium", or "weak".
  String get signalStrength {
    final r = rssi;
    if (r == null) return 'weak';
    if (r >= -60) return 'strong';
    if (r >= -80) return 'medium';
    return 'weak';
  }

  @override
  bool operator ==(Object other) =>
      other is ScannerDevice && deviceId == other.deviceId;

  @override
  int get hashCode => deviceId.hashCode;

  @override
  String toString() => 'ScannerDevice($name, $deviceId, rssi: $rssi)';
}
