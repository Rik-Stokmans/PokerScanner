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

  Color get _color {
    if (percentage >= 30) return AppColors.primary;
    if (percentage >= 15) return AppColors.tertiary;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 14),
      painter: _BatteryPainter(percentage: percentage, fillColor: _color),
    );
  }
}

class _BatteryPainter extends CustomPainter {
  final int percentage;
  final Color fillColor;

  const _BatteryPainter({required this.percentage, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    const double nubWidth = 2.5;
    const double nubHeight = 6.0;
    const double bodyRadius = 3.5;
    const double borderWidth = 1.2;
    const double innerPadding = 1.5;

    final double bodyWidth = size.width - nubWidth;
    final double bodyHeight = size.height;

    // Battery outline
    final outlinePaint = Paint()
      ..color = fillColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, bodyWidth, bodyHeight),
      const Radius.circular(bodyRadius),
    );
    canvas.drawRRect(bodyRect, outlinePaint);

    // Nub (positive terminal) on the right
    final nubPaint = Paint()
      ..color = fillColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final nubTop = (bodyHeight - nubHeight) / 2;
    final nubRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bodyWidth, nubTop, nubWidth, nubHeight),
      const Radius.circular(1.0),
    );
    canvas.drawRRect(nubRect, nubPaint);

    // Fill level inside the body
    final fillFraction = (percentage / 100).clamp(0.0, 1.0);
    const innerLeft = borderWidth + innerPadding;
    const innerTop = borderWidth + innerPadding;
    final innerRight = bodyWidth - borderWidth - innerPadding;
    final innerBottom = bodyHeight - borderWidth - innerPadding;
    final innerWidth = innerRight - innerLeft;
    final innerHeight = innerBottom - innerTop;

    if (fillFraction > 0) {
      const fillRadius = bodyRadius - borderWidth - innerPadding * 0.5;
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          innerLeft,
          innerTop,
          innerWidth * fillFraction,
          innerHeight,
        ),
        Radius.circular(fillRadius.clamp(0.0, double.infinity)),
      );
      canvas.drawRRect(fillRect, fillPaint);
    }

    // Percentage text centered in body
    final textColor = percentage > 20 ? Colors.black : fillColor;
    final textSpan = TextSpan(
      text: '$percentage',
      style: TextStyle(
        color: textColor,
        fontSize: 8.0,
        fontWeight: FontWeight.w700,
        height: 1.0,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final textOffset = Offset(
      (bodyWidth - textPainter.width) / 2,
      (bodyHeight - textPainter.height) / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(_BatteryPainter old) =>
      old.percentage != percentage || old.fillColor != fillColor;
}
