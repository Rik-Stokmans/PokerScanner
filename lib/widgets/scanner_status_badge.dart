import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_colors.dart';

/// Displays the live BLE scanner connection state and battery percentage.
/// Pass [isActive] to override with a fixed value (e.g. in setup screens
/// before the provider is wired up). When omitted the badge reacts to the
/// real [scannerConnectedProvider].
class ScannerStatusBadge extends ConsumerWidget {
  final bool? isActive;

  const ScannerStatusBadge({super.key, this.isActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool active = isActive ?? ref.watch(scannerConnectedProvider);
    final int? battery =
        active ? ref.watch(scannerBatteryProvider).valueOrNull : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.onSurfaceVariant,
              shape: BoxShape.circle,
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.surfaceTint.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            active ? 'Scanner Active' : 'Scanner Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primary : AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          if (battery != null) ...[
            const SizedBox(width: 8),
            _BatteryIndicator(percentage: battery),
          ],
        ],
      ),
    );
  }
}

class _BatteryIndicator extends StatelessWidget {
  final int percentage;

  const _BatteryIndicator({required this.percentage});

  IconData get _icon {
    if (percentage >= 90) return Icons.battery_full;
    if (percentage >= 70) return Icons.battery_5_bar;
    if (percentage >= 50) return Icons.battery_4_bar;
    if (percentage >= 30) return Icons.battery_3_bar;
    if (percentage >= 15) return Icons.battery_2_bar;
    return Icons.battery_1_bar;
  }

  Color get _color {
    if (percentage >= 30) return AppColors.primary;
    if (percentage >= 15) return AppColors.tertiary;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 16, color: _color),
        const SizedBox(width: 2),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _color,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
