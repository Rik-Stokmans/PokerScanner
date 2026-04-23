import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// UUIDs must match Poker_RFID_Reader.ino firmware
const String _kServiceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
const String _kRfidCharUuid = 'beb5483e-36e1-4688-b7f5-ea07361b26a8';
const String _kBatteryCharUuid = '6e400002-b5a3-f393-e0a9-e50e24dcca9e';

const String _kPrefsLastDeviceId = 'ble_last_device_id';
const String _kPrefsLastDeviceName = 'ble_last_device_name';
const String _kPrefsIntentionalDisconnect = 'ble_intentional_disconnect';

enum BleConnectionState { disconnected, scanning, connecting, connected }

/// Singleton BLE service that manages the full device lifecycle:
/// scanning, connecting, characteristic notifications, and auto-reconnect.
class BleService {
  BleService._();
  static final BleService instance = BleService._();

  // ── Public streams ───────────────────────────────────────────────────────

  /// Emits hex RFID IDs as they arrive from the device (e.g. "R1: AB 12 CD EF").
  final StreamController<String> _chipStreamController =
      StreamController<String>.broadcast();
  Stream<String> get chipStream => _chipStreamController.stream;

  /// Connection state changes.
  final StreamController<BleConnectionState> _stateController =
      StreamController<BleConnectionState>.broadcast();
  Stream<BleConnectionState> get connectionStateStream =>
      _stateController.stream;

  BleConnectionState _state = BleConnectionState.disconnected;
  BleConnectionState get state => _state;

  /// Parsed battery percentage (0–100). Null until first notification.
  int? get batteryLevel => _batteryLevel;
  int? _batteryLevel;

  /// Emits parsed battery percentage as it arrives from the device.
  final StreamController<int> _batteryStreamController =
      StreamController<int>.broadcast();
  Stream<int> get batteryStream => _batteryStreamController.stream;

  // ── Private state ────────────────────────────────────────────────────────

  BluetoothDevice? _device;
  StreamSubscription<BluetoothConnectionState>? _connectionSub;
  StreamSubscription<List<int>>? _rfidSub;
  StreamSubscription<List<int>>? _batterySub;

  bool _reconnecting = false;
  // ignore: prefer_final_fields
  bool _disposed = false;

  // ── Public API ───────────────────────────────────────────────────────────

  /// Waits until the BT adapter is powered on (or times out after [timeout]).
  Future<bool> _waitForBluetoothReady({
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on) return true;
    try {
      await FlutterBluePlus.adapterState
          .where((s) => s == BluetoothAdapterState.on)
          .first
          .timeout(timeout);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Scan for nearby RFID Scanner devices and return them as a stream.
  Stream<BluetoothDevice> scanForDevices({
    Duration timeout = const Duration(seconds: 10),
  }) {
    _setState(BleConnectionState.scanning);
    final ctrl = StreamController<BluetoothDevice>();
    StreamSubscription<List<ScanResult>>? sub;

    Future(() async {
      final ready = await _waitForBluetoothReady();
      if (!ready || ctrl.isClosed) {
        if (!ctrl.isClosed) ctrl.addError(Exception('Bluetooth is not available'));
        if (!ctrl.isClosed) ctrl.close();
        _setState(BleConnectionState.disconnected);
        return;
      }

      sub = FlutterBluePlus.scanResults.listen(
        (results) {
          for (final r in results) {
            if (!ctrl.isClosed) ctrl.add(r.device);
          }
        },
        onDone: () {
          if (!ctrl.isClosed) ctrl.close();
          sub?.cancel();
          if (_state == BleConnectionState.scanning) {
            _setState(BleConnectionState.disconnected);
          }
        },
        onError: (Object e) {
          if (!ctrl.isClosed) ctrl.addError(e);
          sub?.cancel();
        },
      );

      await FlutterBluePlus.startScan(
        withServices: [Guid(_kServiceUuid)],
        timeout: timeout,
      );
    });

    ctrl.onCancel = () {
      sub?.cancel();
      FlutterBluePlus.stopScan();
    };

    return ctrl.stream;
  }

  /// Connect to [device] and subscribe to its chip notifications.
  /// Persists the device so startup auto-reconnect can restore it.
  Future<void> connectToDevice(BluetoothDevice device) async {
    await _disconnect(intentional: false);

    _setState(BleConnectionState.connecting);
    _device = device;

    try {
      await device.connect(autoConnect: false);
      await _setupDevice(device);
      await _persistDevice(device);
      _setState(BleConnectionState.connected);
    } catch (e) {
      _setState(BleConnectionState.disconnected);
      rethrow;
    }
  }

  /// Intentionally disconnect and suppress startup reconnect.
  Future<void> disconnect() async {
    await _saveIntentionalDisconnect(true);
    await _disconnect(intentional: true);
  }

  /// Attempt to silently reconnect to the last paired device.
  /// Returns true if reconnection succeeded.
  /// Skipped when the user previously disconnected intentionally.
  Future<bool> tryAutoReconnect() async {
    final prefs = await SharedPreferences.getInstance();
    final intentional =
        prefs.getBool(_kPrefsIntentionalDisconnect) ?? false;
    if (intentional) return false;

    final savedId = prefs.getString(_kPrefsLastDeviceId);
    if (savedId == null) return false;

    try {
      final ready = await _waitForBluetoothReady();
      if (!ready) return false;

      // Check if the device is already in the system's known-devices list.
      final knownDevices = await FlutterBluePlus.bondedDevices;
      BluetoothDevice? target;
      for (final d in knownDevices) {
        if (d.remoteId.str == savedId) {
          target = d;
          break;
        }
      }

      if (target == null) {
        // Not bonded — do a short scan to find it.
        final completer = Completer<BluetoothDevice?>();
        final sub = scanForDevices(timeout: const Duration(seconds: 6))
            .listen((d) {
          if (d.remoteId.str == savedId && !completer.isCompleted) {
            completer.complete(d);
          }
        }, onDone: () {
          if (!completer.isCompleted) completer.complete(null);
        });
        target = await completer.future;
        sub.cancel();
        FlutterBluePlus.stopScan();
      }

      if (target == null) return false;

      await connectToDevice(target);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Internals ────────────────────────────────────────────────────────────

  Future<void> _setupDevice(BluetoothDevice device) async {
    final services = await device.discoverServices();
    BluetoothService? targetService;
    for (final s in services) {
      if (s.serviceUuid == Guid(_kServiceUuid)) {
        targetService = s;
        break;
      }
    }
    if (targetService == null) {
      throw Exception('RFID service not found on device');
    }

    for (final char in targetService.characteristics) {
      if (char.characteristicUuid == Guid(_kRfidCharUuid)) {
        await char.setNotifyValue(true);
        _rfidSub = char.onValueReceived.listen(_onRfidData);
      } else if (char.characteristicUuid == Guid(_kBatteryCharUuid)) {
        await char.setNotifyValue(true);
        _batterySub = char.onValueReceived.listen(_onBatteryData);
      }
    }

    // Watch for unexpected disconnects and auto-reconnect.
    _connectionSub = device.connectionState.listen((cs) async {
      if (cs == BluetoothConnectionState.disconnected &&
          _state == BleConnectionState.connected &&
          !_reconnecting) {
        _setState(BleConnectionState.disconnected);
        _scheduleReconnect(device);
      }
    });
  }

  void _onRfidData(List<int> bytes) {
    if (bytes.isEmpty) return;
    final raw = utf8.decode(bytes, allowMalformed: true).trim();
    if (raw.isNotEmpty) _chipStreamController.add(raw);
  }

  static final RegExp _batteryRegex = RegExp(r'BAT:\s*(\d+)%');

  void _onBatteryData(List<int> bytes) {
    if (bytes.isEmpty) return;
    final raw = utf8.decode(bytes, allowMalformed: true).trim();
    final match = _batteryRegex.firstMatch(raw);
    if (match != null) {
      final pct = int.parse(match.group(1)!).clamp(0, 100);
      _batteryLevel = pct;
      if (!_batteryStreamController.isClosed) {
        _batteryStreamController.add(pct);
      }
    }
  }

  void _scheduleReconnect(BluetoothDevice device) {
    if (_reconnecting || _disposed) return;
    _reconnecting = true;
    Future.delayed(const Duration(seconds: 3), () async {
      if (_disposed || _state == BleConnectionState.connected) {
        _reconnecting = false;
        return;
      }
      try {
        _setState(BleConnectionState.connecting);
        await device.connect(autoConnect: false);
        await _setupDevice(device);
        _setState(BleConnectionState.connected);
      } catch (_) {
        _setState(BleConnectionState.disconnected);
        _scheduleReconnect(device);
      } finally {
        _reconnecting = false;
      }
    });
  }

  Future<void> _disconnect({required bool intentional}) async {
    _reconnecting = false;
    await _rfidSub?.cancel();
    await _batterySub?.cancel();
    await _connectionSub?.cancel();
    _rfidSub = null;
    _batterySub = null;
    _connectionSub = null;

    if (_device != null) {
      try {
        await _device!.disconnect();
      } catch (_) {}
      _device = null;
    }
    _setState(BleConnectionState.disconnected);
  }

  void _setState(BleConnectionState s) {
    _state = s;
    if (!_stateController.isClosed) _stateController.add(s);
  }

  Future<void> _persistDevice(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsLastDeviceId, device.remoteId.str);
    await prefs.setString(
        _kPrefsLastDeviceName, device.platformName.isNotEmpty
            ? device.platformName
            : 'RFID Scanner');
    // Clear any previous intentional-disconnect flag on fresh pair.
    await prefs.remove(_kPrefsIntentionalDisconnect);
  }

  Future<void> _saveIntentionalDisconnect(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefsIntentionalDisconnect, value);
  }

  /// Returns the name stored for the last paired device, or null.
  Future<String?> getLastPairedDeviceName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kPrefsLastDeviceName);
  }
}
