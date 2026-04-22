import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
}

class _ScannerSetupScreenState extends ConsumerState<ScannerSetupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnecting = false;
  String? _error;

  StreamSubscription<BluetoothDevice>? _scanSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startScan();
  }

  void _startScan() {
    _scanSub?.cancel();
    setState(() {
      _devices.clear();
      _selectedDevice = null;
      _error = null;
    });

    _scanSub = BleService.instance
        .scanForDevices(timeout: const Duration(seconds: 10))
        .listen(
      (device) {
        if (!mounted) return;
        setState(() {
          if (!_devices.any((d) => d.remoteId == device.remoteId)) {
            _devices.add(device);
          }
        });
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() => _error = e.toString());
      },
    );
  }

  Future<void> _connect() async {
    if (_selectedDevice == null) return;
    setState(() {
      _isConnecting = true;
      _error = null;
    });
    try {
      await BleService.instance.connectToDevice(_selectedDevice!);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) setState(() => _error = 'Connection failed: $e');
    } finally {
      if (mounted) setState(() => _isConnecting = false);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanSub?.cancel();
    super.dispose();
  }

  Future<void> _connect() async {
    final target = _selectedDevice;
    if (target == null) return;
    await ref.read(bleProvider.notifier).connectTo(target);

    if (!mounted) return;
    final bleState = ref.read(bleProvider);
    if (bleState.connectionStatus == ScannerConnectionStatus.connected) {
      // Navigate to deck management (lobby) once connected
      context.go('/lobby');
    } else if (bleState.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bleState.errorMessage!),
          backgroundColor: AppColors.errorContainer,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bleState = BleService.instance.state;
    final isConnected = bleState == BleConnectionState.connected;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.onSurface, size: 20),
                    onPressed: isConnecting ? null : () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SILENT TABLE',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          letterSpacing: 2,
                        ),
                      ),
                      ScannerStatusBadge(isActive: isConnected),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),

              Text(
                'Pair your scanner',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pair your secure hand scanner to begin dealing at the silent table.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // ── Scanning / connecting animation ───────────────────────
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100 * _pulseAnimation.value,
                          height: 100 * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isConnecting
                                ? AppColors.tertiary
                                    .withOpacity(0.05 * _pulseAnimation.value)
                                : AppColors.primary
                                    .withOpacity(0.05 * _pulseAnimation.value),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceContainerHighest,
                          ),
                          child: Icon(
                            isConnecting
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth_searching,
                            color: isConnecting
                                ? AppColors.tertiary
                                : AppColors.primary,
                            size: 36,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _devices.isEmpty
                      ? 'Searching...'
                      : '${_devices.length} device(s) found',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _error!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // ── Device list header ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Devices',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (!isScanning && !isConnecting)
                    TextButton.icon(
                      onPressed: () {
                        setState(() => _selectedDevice = null);
                        ref.read(bleProvider.notifier).startScan();
                      },
                      icon: const Icon(Icons.refresh,
                          size: 16, color: AppColors.primary),
                      label: Text(
                        'Rescan',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.primary),
                      ),
                    ),
                  if (isScanning)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _devices.isEmpty
                    ? Center(
                        child: Text(
                          'No RFID scanners found nearby.',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _devices.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final device = _devices[index];
                          final isSelected =
                              _selectedDevice?.remoteId == device.remoteId;
                          final name = device.platformName.isNotEmpty
                              ? device.platformName
                              : 'RFID Scanner';

                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDevice = device),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.08)
                                    : AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(14),
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.primary
                                            .withOpacity(0.4))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.bluetooth,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          device.remoteId.str,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color:
                                                AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle,
                                        color: AppColors.primary, size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              // ── Footer ────────────────────────────────────────────────
              const SizedBox(height: 8),
              Text(
                'Paired: ${_selectedDevice != null ? (_selectedDevice!.platformName.isNotEmpty ? _selectedDevice!.platformName : _selectedDevice!.remoteId.str) : "None"}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              _isConnecting
                  ? const Center(child: CircularProgressIndicator())
                  : GradientButton(
                      label: 'CONNECT',
                      icon: Icons.bluetooth_connected,
                      onPressed: _selectedDevice != null ? _connect : null,
                    ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _startScan,
                  child: Text(
                    'Scan again',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              if (isConnected) ...[
                const SizedBox(height: 4),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      await BleService.instance.disconnect();
                      if (mounted) setState(() {});
                    },
                    child: Text(
                      'Disconnect',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.redAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
