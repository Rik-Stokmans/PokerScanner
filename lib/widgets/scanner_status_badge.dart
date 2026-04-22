import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/scanner_service.dart';
import '../theme/app_colors.dart';

/// Displays the scanner online/offline state.
///
/// When [isActive] is provided explicitly it overrides the provider value
/// (useful for screens where no scanner is associated yet).
class ScannerStatusBadge extends ConsumerWidget {
  /// Explicit override; when null the provider value is used.
  final bool? isActive;

  const ScannerStatusBadge({super.key, this.isActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool scannerOnline = isActive ??
        ref.watch(scannerServiceProvider.select((s) => s.isOnline));
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
              color: scannerOnline
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
              shape: BoxShape.circle,
              boxShadow: scannerOnline
                  ? [
                      BoxShadow(
                        color: AppColors.surfaceTint.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            scannerOnline ? 'Scanner Active' : 'Scanner Offline',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: scannerOnline
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
