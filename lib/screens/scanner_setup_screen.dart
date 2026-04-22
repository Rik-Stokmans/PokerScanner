import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/scanner_status_badge.dart';
import '../widgets/gradient_button.dart';
import '../services/bluetooth_permission_service.dart';

class ScannerSetupScreen extends StatefulWidget {
  const ScannerSetupScreen({super.key});

  @override
  State<ScannerSetupScreen> createState() => _ScannerSetupScreenState();
}

class _ScannerSetupScreenState extends State<ScannerSetupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int? _selectedDevice;
  bool _scanReady = false;
  bool _checkingPermissions = true;

  final List<Map<String, dynamic>> _devices = [
    {'name': 'SilentReader-8B', 'status': 'Ready to pair', 'strength': 'strong'},
    {'name': 'Unknown Device', 'status': 'Weak signal', 'strength': 'weak'},
  ];

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
    // Request permissions as soon as the screen is visible.
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensurePermissions());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Checks Bluetooth readiness and shows the appropriate dialog when something
  /// is missing. Sets [_scanReady] to true only when everything is granted.
  Future<void> _ensurePermissions() async {
    if (!mounted) return;
    setState(() => _checkingPermissions = true);

    final readiness = await BluetoothPermissionService.checkReadiness();

    if (!mounted) return;
    setState(() => _checkingPermissions = false);

    switch (readiness) {
      case BluetoothReadiness.ready:
        setState(() => _scanReady = true);

      case BluetoothReadiness.bluetoothOff:
        await BluetoothPermissionService.showBluetoothOffDialog(context);
        // After the dialog the user may have enabled BT; re-check.
        if (mounted) _ensurePermissions();

      case BluetoothReadiness.permissionPermanentlyDenied:
        await BluetoothPermissionService.showPermanentlyDeniedDialog(context);
        // User must go to Settings; no automatic re-check.

      case BluetoothReadiness.permissionDenied:
        await BluetoothPermissionService.showPermissionDeniedDialog(context);
        // Give the user a chance to grant on next attempt.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.onSurface, size: 20),
                    onPressed: () => context.pop(),
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
                      const ScannerStatusBadge(isActive: false),
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
                            color: AppColors.primary
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
                            _checkingPermissions
                                ? Icons.bluetooth_searching
                                : _scanReady
                                    ? Icons.bluetooth_searching
                                    : Icons.bluetooth_disabled,
                            color: _scanReady || _checkingPermissions
                                ? AppColors.primary
                                : AppColors.onSurfaceVariant,
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
                child: _checkingPermissions
                    ? Text(
                        'Checking permissions...',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      )
                    : _scanReady
                        ? Text(
                            'Searching...',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          )
                        : TextButton(
                            onPressed: _ensurePermissions,
                            child: Text(
                              'Grant permissions to scan',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
              ),
              const SizedBox(height: 32),
              Text(
                'Available Devices',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _devices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    final isSelected = _selectedDevice == index;
                    final isStrong = device['strength'] == 'strong';

                    return GestureDetector(
                      onTap: isStrong && _scanReady
                          ? () => setState(() => _selectedDevice = index)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.08)
                              : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(14),
                          border: isSelected
                              ? Border.all(
                                  color: AppColors.primary.withOpacity(0.4))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.bluetooth,
                              color: isStrong && _scanReady
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device['name'] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isStrong && _scanReady
                                          ? AppColors.onSurface
                                          : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    device['status'] as String,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isStrong && _scanReady
                                          ? AppColors.primary
                                          : AppColors.onSurfaceVariant
                                              .withOpacity(0.6),
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
              const SizedBox(height: 8),
              Text(
                'Paired: ${_selectedDevice != null ? _devices[_selectedDevice!]['name'] : "None"}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              GradientButton(
                label: 'CONNECT',
                icon: Icons.bluetooth_connected,
                onPressed: _selectedDevice != null && _scanReady
                    ? () => context.pop()
                    : null,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Troubleshoot',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
