import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/providers.dart';
import '../theme/app_colors.dart';
import 'learn/drills_tab.dart';
import 'learn/study_tab.dart';
import 'learn/progress_tab.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = ['For You', 'Drills', 'Study', 'Progress'];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LEARN',
                    style: GoogleFonts.manrope(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: 3,
                    ),
                  ),
                  const Icon(Icons.school,
                      color: AppColors.primary, size: 28),
                ],
              ),
            ),
            // TabBar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 2,
              dividerColor: AppColors.outlineVariant.withOpacity(0.3),
              labelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: _tabs
                  .map((label) => Tab(text: label, height: 40))
                  .toList(),
            ),
            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  _ForYouTab(),
                  DrillsTab(),
                  StudyTab(),
                  ProgressTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── For You ──────────────────────────────────────────────────────────────

class _ForYouTab extends ConsumerWidget {
  const _ForYouTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(learningProgressProvider);
    final session = ref.watch(sessionAnalysisProvider);
    final userAsync = ref.watch(currentUserProvider);

    final progress = progressAsync.value;
    final userName = userAsync.value?.username ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Level & XP banner ───────────────────────────────────────────
          if (progress != null) ...[
            _LevelBanner(progress: progress),
            const SizedBox(height: 20),
          ],

          // ── Greeting / section title ────────────────────────────────────
          Text(
            userName.isNotEmpty
                ? 'Good session, $userName'
                : 'Your Personalised Feed',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // ── Session insight card ────────────────────────────────────────
          _SessionInsightCard(insight: session.aiInsight),
          const SizedBox(height: 20),

          // ── Drill recommendations ───────────────────────────────────────
          if (session.leakWarnings.isNotEmpty) ...[
            Text(
              'Recommended Drills',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            ...session.leakWarnings
                .take(3)
                .map((leak) => _DrillRecommendationCard(leak: leak)),
            const SizedBox(height: 20),
          ],

          // ── Resume last drill ───────────────────────────────────────────
          if (progress != null && progress.lastDrillDate != null) ...[
            _ResumeLastDrillCard(lastDrillDate: progress.lastDrillDate!),
            const SizedBox(height: 20),
          ],

          // ── Video leak section ──────────────────────────────────────────
          Text(
            'Pattern Recognition',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Video analysis of your most frequent showdown leaks',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          const _VideoLeakCard(
            title: 'Overvaluing Top-Pair on Wet Boards',
            duration: '04:20',
          ),
          const SizedBox(height: 10),
          const _VideoLeakCard(
            title: 'Identifying 3-Bet Bluff Frequencies',
            duration: '07:45',
          ),
          const SizedBox(height: 10),
          const _VideoLeakCard(
            title: 'River C-Betting: The Polarization Rule',
            duration: '03:12',
          ),
        ],
      ),
    );
  }
}

// ─── Level & XP Banner ────────────────────────────────────────────────────

class _LevelBanner extends StatelessWidget {
  final dynamic progress; // LearningProgressModel

  const _LevelBanner({required this.progress});

  @override
  Widget build(BuildContext context) {
    final xpFraction = progress.xpToNextLevel > 0
        ? (progress.currentXp / progress.xpToNextLevel).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  progress.levelName.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              // Daily streak chip
              _DailyStreakChip(streak: progress.currentStreak),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: xpFraction,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${progress.currentXp} XP',
                style: GoogleFonts.inter(
                  fontSize: 12,
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
    );
  }
}

// ─── Daily Streak Chip ────────────────────────────────────────────────────

class _DailyStreakChip extends StatelessWidget {
  final int streak;

  const _DailyStreakChip({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: streak > 0
            ? const Color(0xFFFF7043).withOpacity(0.15)
            : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: streak > 0
              ? const Color(0xFFFF7043).withOpacity(0.4)
              : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 14,
            color: streak > 0
                ? const Color(0xFFFF7043)
                : AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            '$streak day${streak == 1 ? '' : 's'}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: streak > 0
                  ? const Color(0xFFFF7043)
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Session Insight Card ─────────────────────────────────────────────────

class _SessionInsightCard extends StatelessWidget {
  final String insight;

  const _SessionInsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'AI Session Insight',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            insight,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: Text(
                    'Resume Drill',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: Text(
                    'Review Hands',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Drill Recommendation Card ────────────────────────────────────────────

class _DrillRecommendationCard extends StatelessWidget {
  final String leak;

  const _DrillRecommendationCard({required this.leak});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.errorContainer.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                leak,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Resume Last Drill Card ───────────────────────────────────────────────

class _ResumeLastDrillCard extends StatelessWidget {
  final DateTime lastDrillDate;

  const _ResumeLastDrillCard({required this.lastDrillDate});

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.play_arrow_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resume Last Drill',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Last played ${_formatDate(lastDrillDate)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}

// ─── Video Leak Card ──────────────────────────────────────────────────────

class _VideoLeakCard extends StatelessWidget {
  final String title;
  final String duration;

  const _VideoLeakCard({required this.title, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.play_circle_outline,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Text(
            duration,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
