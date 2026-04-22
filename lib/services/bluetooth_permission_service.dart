import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

/// Result of a permission / Bluetooth-state check before initiating a BLE scan.
enum BluetoothReadiness {
  ready,
  bluetoothOff,
  permissionDenied,
  permissionPermanentlyDenied,
}

/// Handles runtime permission requests and Bluetooth-adapter state checks
/// required before any BLE scan is initiated.
class BluetoothPermissionService {
  /// Checks Bluetooth adapter state and all required runtime permissions.
  ///
  /// Returns [BluetoothReadiness.ready] only when everything is in order.
  static Future<BluetoothReadiness> checkReadiness() async {
    // 1. Bluetooth adapter state
    final adapterState = await FlutterBluePlus.adapterState.first;
    if (adapterState != BluetoothAdapterState.on) {
      return BluetoothReadiness.bluetoothOff;
    }

    // 2. Runtime permissions
    final statuses = await _requestPermissions();
    for (final status in statuses.values) {
      if (status.isPermanentlyDenied) {
        return BluetoothReadiness.permissionPermanentlyDenied;
      }
      if (!status.isGranted) {
        return BluetoothReadiness.permissionDenied;
      }
    }

    return BluetoothReadiness.ready;
  }

  static Future<Map<Permission, PermissionStatus>> _requestPermissions() async {
    if (Platform.isAndroid) {
      return await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();
    }
    if (Platform.isIOS) {
      return await [Permission.bluetooth].request();
    }
    return {};
  }

  // ---------------------------------------------------------------------------
  // Dialog helpers
  // ---------------------------------------------------------------------------

  /// Shows a dialog asking the user to enable Bluetooth, with an optional
  /// system prompt on Android via [FlutterBluePlus.turnOn].
  static Future<void> showBluetoothOffDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bluetooth is Off'),
        content: const Text(
          'Please enable Bluetooth to scan for your poker scanner device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );

    if (confirmed == true && Platform.isAndroid) {
      try {
        await FlutterBluePlus.turnOn();
      } catch (_) {
        // turnOn() may throw on some devices; the user must enable manually.
      }
    }
  }

  /// Shows a dialog informing the user that permissions have been permanently
  /// denied, directing them to the app settings.
  static Future<void> showPermanentlyDeniedDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Bluetooth and location permissions are required to find your '
          'scanner.\n\nPlease open Settings and grant the permissions.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog informing the user that permissions were denied and asking
  /// them to try again.
  static Future<void> showPermissionDeniedDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Permission Denied'),
        content: const Text(
          'Bluetooth and location permissions are needed to scan for nearby '
          'devices. Please accept the permission request to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
