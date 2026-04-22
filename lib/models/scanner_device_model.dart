/// Signal strength category derived from raw RSSI.
enum SignalStrength { excellent, good, fair, poor }

/// Lightweight model wrapping a BLE discovery result with a human-readable
/// signal strength description.
///
/// Populated during device discovery and used to present scanner devices to
/// the user before pairing.
class ScannerDevice {
  final String deviceId; // BLE device identifier (platform-specific)
  final String name; // Advertised device name
  final int rssi; // Raw RSSI in dBm

  const ScannerDevice({
    required this.deviceId,
    required this.name,
    required this.rssi,
  });

  /// Categorises [rssi] into a [SignalStrength] bucket.
  SignalStrength get signalStrength {
    if (rssi >= -60) return SignalStrength.excellent;
    if (rssi >= -70) return SignalStrength.good;
    if (rssi >= -80) return SignalStrength.fair;
    return SignalStrength.poor;
  }

  /// Human-readable label for the signal strength.
  String get signalLabel {
    switch (signalStrength) {
      case SignalStrength.excellent:
        return 'Excellent';
      case SignalStrength.good:
        return 'Good';
      case SignalStrength.fair:
        return 'Fair';
      case SignalStrength.poor:
        return 'Poor';
    }
  }

  /// Returns a display-friendly signal strength string including the raw dBm.
  String get signalDescription => '$signalLabel ($rssi dBm)';

  @override
  String toString() =>
      'ScannerDevice(deviceId: $deviceId, name: $name, rssi: $rssi)';
}
