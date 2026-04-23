import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/learning_progress_model.dart';
import '../../providers/providers.dart';
import '../../theme/app_colors.dart';

// ─── Badge metadata ───────────────────────────────────────────────────────

class _BadgeMeta {
  final String id;
  final String label;
  final IconData icon;

  const _BadgeMeta({required this.id, required this.label, required this.icon});
}

const _kAllBadges = [
  _BadgeMeta(id: 'first_drill', label: 'First Drill', icon: Icons.flag),
  _BadgeMeta(
      id: 'pot_odds_pro', label: 'Pot Odds Pro', icon: Icons.calculate),
  _BadgeMeta(
      id: 'range_master', label: 'Range Master', icon: Icons.grid_view),
  _BadgeMeta(
      id: 'study_streak_7',
      label: 'Study Streak 7',
      icon: Icons.local_fire_department),
  _BadgeMeta(
      id: 'study_streak_30',
      label: 'Study Streak 30',
      icon: Icons.whatshot),
  _BadgeMeta(
      id: 'concept_graduate',
      label: 'Concept Graduate',
      icon: Icons.school),
  _BadgeMeta(
      id: 'scenario_shark',
      label: 'Scenario Shark',
      icon: Icons.water),
];

// ─── Main widget ──────────────────────────────────────────────────────────

/// Progress tab shown inside the Learn screen.
/// Reads [learningProgressProvider] (a [StreamProvider]) to display the
/// user's level, streak, skill breakdown, badges and recent activity.
class ProgressTab extends ConsumerWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(learningProgressProvider);

    return progressAsync.when(
      data: (progress) {
        final data = progress ?? LearningProgressModel.empty('');
        return _ProgressContent(progress: data);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (e, _) => Center(
        child: Text(
          'Failed to load progress',
          style: GoogleFonts.inter(color: AppColors.error),
        ),
      ),
    );
  }
}

// ─── Full-content layout ─────────────────────────────────────────────────

class _ProgressContent extends StatelessWidget {
  final LearningProgressModel progress;

  const _ProgressContent({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LevelCard(progress: progress),
          const SizedBox(height: 20),
          _StreakDisplay(progress: progress),
          const SizedBox(height: 20),
          _SkillBreakdownChart(progress: progress),
          const SizedBox(height: 20),
          _BadgesSection(earnedBadgeIds: progress.earnedBadgeIds),
          const SizedBox(height: 20),
          _RecentActivityFeed(events: progress.recentActivity),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Level card (t29) ────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  final LearningProgressModel progress;

  const _LevelCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final xpFraction = progress.xpToNextLevel > 0
        ? (progress.currentXp / progress.xpToNextLevel).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.25),
            AppColors.primaryContainer.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          width: 1.5,
          // Gradient border achieved via a custom painter; approximate with
          // the primary colour at reduced opacity.
          color: AppColors.primary.withOpacity(0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  progress.levelName.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 2,
                  ),
                ),
                _GradientBorderBadge(
                  child: Text(
                    'LEVEL',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: xpFraction,
                minHeight: 8,
                backgroundColor: AppColors.surfaceContainerHighest,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${progress.currentXp} XP',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  '${progress.xpToNextLevel} XP to next level',
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
    );
  }
}

class _GradientBorderBadge extends StatelessWidget {
  final Widget child;

  const _GradientBorderBadge({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
        color: AppColors.primary.withOpacity(0.1),
      ),
      child: child,
    );
  }
}

// ─── Streak display (t30) ────────────────────────────────────────────────

const _kDayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class _StreakDisplay extends StatelessWidget {
  final LearningProgressModel progress;

  const _StreakDisplay({required this.progress});

  @override
  Widget build(BuildContext context) {
    final week = progress.weekActivity.length == 7
        ? progress.weekActivity
        : List.generate(7, (i) {
            if (i < progress.weekActivity.length) {
              return progress.weekActivity[i];
            }
            return false;
          });

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Color(0xFFFF7043),
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                '${progress.currentStreak}',
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'day streak',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final active = i < week.length && week[i];
              return _DayDot(label: _kDayLabels[i], active: active);
            }),
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String label;
  final bool active;

  const _DayDot({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? AppColors.primary.withOpacity(0.9)
                : AppColors.surfaceContainerHigh,
            border: active
                ? null
                : Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: active
              ? const Icon(Icons.check, size: 16, color: AppColors.onPrimary)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── Skill breakdown chart (t31) ─────────────────────────────────────────

class _SkillBreakdownChart extends StatelessWidget {
  final LearningProgressModel progress;

  const _SkillBreakdownChart({required this.progress});

  @override
  Widget build(BuildContext context) {
    final skills = [
      _SkillEntry('Preflop Ranges', progress.preflopRanges),
      _SkillEntry('Pot Odds', progress.potOdds),
      _SkillEntry('Decision Making', progress.decisionMaking),
      _SkillEntry('Board Texture', progress.boardTexture),
      _SkillEntry('Hand Reading', progress.handReading),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skill Breakdown',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...skills.map((s) => _SkillRow(entry: s)),
        ],
      ),
    );
  }
}

class _SkillEntry {
  final String label;
  final double accuracy; // 0.0 – 1.0

  const _SkillEntry(this.label, this.accuracy);
}

class _SkillRow extends StatelessWidget {
  final _SkillEntry entry;

  const _SkillRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final pct = (entry.accuracy * 100).toStringAsFixed(0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                '$pct%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: entry.accuracy.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Badges section (t32) ────────────────────────────────────────────────

class _BadgesSection extends StatelessWidget {
  final List<String> earnedBadgeIds;

  const _BadgesSection({required this.earnedBadgeIds});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Badges',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _kAllBadges.map((badge) {
              final earned = earnedBadgeIds.contains(badge.id);
              return _BadgeChip(badge: badge, earned: earned);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final _BadgeMeta badge;
  final bool earned;

  const _BadgeChip({required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: earned
            ? AppColors.primary.withOpacity(0.15)
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: earned
              ? AppColors.primary.withOpacity(0.5)
              : AppColors.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            earned ? badge.icon : Icons.lock_outline,
            size: 14,
            color: earned ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            badge.label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: earned
                  ? AppColors.onSurface
                  : AppColors.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recent activity feed (t33) ──────────────────────────────────────────

class _RecentActivityFeed extends StatelessWidget {
  final List<LearningActivityEntry> events;

  const _RecentActivityFeed({required this.events});

  @override
  Widget build(BuildContext context) {
    final displayed = events.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          if (displayed.isEmpty)
            Text(
              'No activity yet. Complete a drill to earn XP!',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            )
          else
            ...displayed.map((e) => _ActivityRow(event: e)),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final LearningActivityEntry event;

  const _ActivityRow({required this.event});

  String _formatTime(DateTime ts) {
    final now = DateTime.now();
    final diff = now.difference(ts);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bolt,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  _formatTime(event.timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${event.xp} XP',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
