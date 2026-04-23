import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../services/learning_service.dart';
import '../../providers/providers.dart';
import '../../models/learning_progress_model.dart';
import '../../services/decision_evaluator.dart';

/// Shows an XP summary bottom sheet at the end of a session.
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => SessionXpSummarySheet(
///     userId: user.id,
///     events: xpEvents,
///   ),
/// );
/// ```
class SessionXpSummarySheet extends ConsumerStatefulWidget {
  final String userId;
  final List<XpEvent> events;

  const SessionXpSummarySheet({
    super.key,
    required this.userId,
    required this.events,
  });

  @override
  ConsumerState<SessionXpSummarySheet> createState() =>
      _SessionXpSummarySheetState();
}

class _SessionXpSummarySheetState
    extends ConsumerState<SessionXpSummarySheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _barController;
  late Animation<double> _barAnimation;
  bool _claimed = false;

  int get _totalXp =>
      widget.events.fold(0, (sum, e) => sum + e.xp);

  List<XpEvent> get _bonusEvents =>
      widget.events.where((e) => e.isPositive && e.xp > 0).toList();

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _barAnimation = CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOutCubic,
    );
    // Start after a short delay so the sheet has settled.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _barController.forward();
    });
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  Future<void> _claimXp() async {
    if (_claimed) return;
    setState(() => _claimed = true);
    // Award XP by recording each positive event as a drill result.
    for (final event in widget.events.where((e) => e.xp > 0)) {
      await LearningService.recordDrillResult(
        drillId: 'session_award',
        correct: event.isPositive,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(learningProgressProvider);
    final progress = progressAsync.value;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 24),
                  // XP event list
                  _buildEventList(),
                  const SizedBox(height: 24),
                  // Session bonuses
                  if (_bonusEvents.isNotEmpty) ...[
                    _buildBonusSection(),
                    const SizedBox(height: 24),
                  ],
                  // Level progress bar
                  _buildLevelProgress(progress),
                  const SizedBox(height: 32),
                  // Claim button
                  _buildClaimButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Complete',
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.onSurfaceVariant,
            ),
            children: [
              const TextSpan(text: 'You earned '),
              TextSpan(
                text: '+$_totalXp XP',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'XP Breakdown',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.events.map((event) => _XpEventRow(event: event)),
      ],
    );
  }

  Widget _buildBonusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Bonuses',
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.15),
            ),
          ),
          child: Column(
            children: _bonusEvents
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.primary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.label,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            '+${e.xp} XP',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelProgress(LearningProgressModel? progress) {
    final currentXp = progress?.xp ?? 0;
    final currentLevelIndex = progress?.levelIndex ?? 1;
    final projectedXp = currentXp + _totalXp;

    // Compute projected level name
    String projectedLevelName;
    int projectedLevelIndex;
    if (projectedXp >= 10000) {
      projectedLevelName = 'GTO Wizard';
      projectedLevelIndex = 6;
    } else if (projectedXp >= 6000) {
      projectedLevelName = 'Crusher';
      projectedLevelIndex = 5;
    } else if (projectedXp >= 3000) {
      projectedLevelName = 'Shark';
      projectedLevelIndex = 4;
    } else if (projectedXp >= 1500) {
      projectedLevelName = 'Grinder';
      projectedLevelIndex = 3;
    } else if (projectedXp >= 500) {
      projectedLevelName = 'Regular';
      projectedLevelIndex = 2;
    } else {
      projectedLevelName = 'Fish';
      projectedLevelIndex = 1;
    }

    final projectedModel = LearningProgressModel(
      userId: widget.userId,
      xp: projectedXp,
      streakDays: progress?.streakDays ?? 0,
      earnedBadges: progress?.earnedBadges ?? const [],
      drillStats: progress?.drillStats ?? const {},
      conceptsRead: progress?.conceptsRead ?? const [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              projectedLevelName,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            if (projectedLevelIndex > currentLevelIndex)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Level Up!',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: AnimatedBuilder(
            animation: _barAnimation,
            builder: (context, _) => LinearProgressIndicator(
              value: projectedModel.levelProgress * _barAnimation.value,
              minHeight: 10,
              backgroundColor:
                  AppColors.surfaceContainerHighest,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${projectedModel.xpInCurrentLevel} / ${projectedModel.xpForNextLevel} XP',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildClaimButton() {
    return FilledButton(
      onPressed: _claimed ? null : _claimXp,
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: AppColors.primary,
        disabledBackgroundColor:
            AppColors.primary.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: _claimed
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
          : Text(
              'Claim XP',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
    );
  }
}

// ─── Row widget ──────────────────────────────────────────────────────────────

class _XpEventRow extends StatelessWidget {
  final XpEvent event;

  const _XpEventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final isPositive = event.isPositive;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isPositive
                  ? AppColors.primary.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
              size: 18,
              color: isPositive ? AppColors.primary : AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              event.label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Text(
            isPositive ? '+${event.xp} XP' : '${event.xp} XP',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isPositive ? AppColors.primary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
