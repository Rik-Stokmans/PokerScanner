import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../providers/learning_progress_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class _DrillInfo {
  final String id;
  final String name;
  final String description;
  final String estimatedTime;
  final IconData icon;

  const _DrillInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.estimatedTime,
    required this.icon,
  });
}

const _kDrills = [
  _DrillInfo(
    id: 'range_trainer',
    name: 'Range Trainer',
    description: 'Practice pre-flop opening and 3-bet ranges by position.',
    estimatedTime: '10 min',
    icon: Icons.grid_view_rounded,
  ),
  _DrillInfo(
    id: 'pot_odds',
    name: 'Pot Odds',
    description: 'Calculate pot odds and implied odds quickly under pressure.',
    estimatedTime: '8 min',
    icon: Icons.calculate_outlined,
  ),
  _DrillInfo(
    id: 'scenarios',
    name: 'Scenarios',
    description: 'Spot the best action in common multi-street situations.',
    estimatedTime: '12 min',
    icon: Icons.psychology_outlined,
  ),
  _DrillInfo(
    id: 'board_texture',
    name: 'Board Texture',
    description: 'Read flop textures and adjust c-bet frequency correctly.',
    estimatedTime: '9 min',
    icon: Icons.layers_outlined,
  ),
  _DrillInfo(
    id: 'hand_review',
    name: 'Hand Review',
    description: 'Replay flagged hands and identify the biggest mistakes.',
    estimatedTime: '15 min',
    icon: Icons.history_edu_outlined,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// _DrillsTab
// ─────────────────────────────────────────────────────────────────────────────

class DrillsTab extends ConsumerWidget {
  const DrillsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(learningProgressProvider);

    // Determine drill with the lowest accuracy for "Today's Focus".
    _DrillInfo focusDrill = _kDrills.first;
    double lowestAccuracy = progress.accuracyFor(_kDrills.first.id);
    for (final drill in _kDrills.skip(1)) {
      final acc = progress.accuracyFor(drill.id);
      if (acc < lowestAccuracy) {
        lowestAccuracy = acc;
        focusDrill = drill;
      }
    }

    // Remaining drills (all drills displayed in list, focus drill shown first).
    final otherDrills = _kDrills.where((d) => d.id != focusDrill.id).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        // ── Today's Focus ──────────────────────────────────────────────────
        _TodaysFocusCard(
          drill: focusDrill,
          accuracy: lowestAccuracy,
          onStart: () => _navigateToDrill(context, focusDrill.id),
        ),
        const SizedBox(height: 24),

        // ── Section header ─────────────────────────────────────────────────
        Text(
          'All Drills',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),

        // ── Focus drill card in the list ───────────────────────────────────
        _DrillCard(
          drill: focusDrill,
          accuracy: lowestAccuracy,
          onTap: () => _navigateToDrill(context, focusDrill.id),
        ),
        const SizedBox(height: 10),

        // ── Other drill cards ──────────────────────────────────────────────
        ...otherDrills.map((drill) {
          final acc = progress.accuracyFor(drill.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DrillCard(
              drill: drill,
              accuracy: acc,
              onTap: () => _navigateToDrill(context, drill.id),
            ),
          );
        }),
      ],
    );
  }

  void _navigateToDrill(BuildContext context, String drillId) {
    // Route: /learn/drill/:id — adjust when the drill screen is wired up.
    context.push('/learn/drill/$drillId');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Today's Focus card
// ─────────────────────────────────────────────────────────────────────────────

class _TodaysFocusCard extends StatelessWidget {
  final _DrillInfo drill;
  final double accuracy;
  final VoidCallback onStart;

  const _TodaysFocusCard({
    required this.drill,
    required this.accuracy,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        // Primary gradient border
        gradient: AppColors.primaryGradient,
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "TODAY'S FOCUS",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onPrimary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const Spacer(),
                _AccuracyBadge(accuracy: accuracy),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(drill.icon,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        drill.name,
                        style: GoogleFonts.manrope(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        drill.estimatedTime,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              drill.description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            GradientButton(
              label: 'START NOW',
              icon: Icons.play_arrow_rounded,
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual drill card
// ─────────────────────────────────────────────────────────────────────────────

class _DrillCard extends StatelessWidget {
  final _DrillInfo drill;
  final double accuracy;
  final VoidCallback onTap;

  const _DrillCard({
    required this.drill,
    required this.accuracy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(drill.icon,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      drill.name,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      drill.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 12,
                            color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text(
                          drill.estimatedTime,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Accuracy badge + arrow
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _AccuracyBadge(accuracy: accuracy),
                  const SizedBox(height: 6),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.onSurfaceVariant),
                    onPressed: onTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Accuracy badge
// ─────────────────────────────────────────────────────────────────────────────

class _AccuracyBadge extends StatelessWidget {
  final double accuracy; // 0.0 – 1.0

  const _AccuracyBadge({required this.accuracy});

  @override
  Widget build(BuildContext context) {
    final percent = (accuracy * 100).round();

    Color bgColor;
    Color textColor;
    if (percent >= 80) {
      bgColor = AppColors.primary.withOpacity(0.15);
      textColor = AppColors.primary;
    } else if (percent >= 50) {
      bgColor = AppColors.tertiary.withOpacity(0.15);
      textColor = AppColors.tertiary;
    } else {
      bgColor = AppColors.errorContainer.withOpacity(0.3);
      textColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$percent%',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }
}
