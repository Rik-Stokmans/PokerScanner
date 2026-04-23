import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
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
                  _DrillsTab(),
                  _StudyTab(),
                  _ProgressTab(),
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

class _ForYouTab extends StatelessWidget {
  const _ForYouTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mastering the Defensive Table',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Container(
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
                      'AI Mistake Analysis',
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
                  'You are currently overfolding in the Big Blind by 14%. '
                  'Our AI suggests focusing on wider defense ranges against Button opens.',
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
          ),
          const SizedBox(height: 24),
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

// ─── Drills ───────────────────────────────────────────────────────────────

class _DrillsTab extends StatelessWidget {
  const _DrillsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tactical Drill',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Defending the Big Blind',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Focus: Countering High-Frequency Steals',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Advanced',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                        child: _DrillStat(
                            label: 'Success\nRate', value: '68%')),
                    Expanded(
                        child: _DrillStat(
                            label: 'Target\nEV', value: '+0.42')),
                    Expanded(
                        child: _DrillStat(
                            label: 'Streak',
                            value: '5 Days',
                            valueColor: AppColors.primary)),
                    Expanded(
                        child: _DrillStat(label: 'Rank', value: '#124')),
                  ],
                ),
                const SizedBox(height: 16),
                GradientButton(
                  label: 'START SESSION',
                  icon: Icons.arrow_forward,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Range Master',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GTO vs Exploitative Ranges',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Visualize opening ranges',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.layers_outlined,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Open Charts',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Study ────────────────────────────────────────────────────────────────

class _StudyTab extends StatelessWidget {
  const _StudyTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Materials',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Concepts, articles and videos to deepen your game.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          const _StudyConceptCard(
            title: 'Pot Odds & Implied Odds',
            subtitle: 'Master the math behind every call',
            icon: Icons.calculate_outlined,
          ),
          const SizedBox(height: 10),
          const _StudyConceptCard(
            title: 'Board Texture Analysis',
            subtitle: 'Wet vs dry: adjusting your ranges',
            icon: Icons.grid_view_outlined,
          ),
          const SizedBox(height: 10),
          const _StudyConceptCard(
            title: 'GTO Fundamentals',
            subtitle: 'Balanced strategies explained',
            icon: Icons.balance_outlined,
          ),
        ],
      ),
    );
  }
}

class _StudyConceptCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _StudyConceptCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

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
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
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

// ─── Progress ─────────────────────────────────────────────────────────────

class _ProgressTab extends StatelessWidget {
  const _ProgressTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ProgressItem(
                      label: 'BB Defense', value: '+12%', positive: true),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.outlineVariant.withOpacity(0.15),
                ),
                Expanded(
                  child: _ProgressItem(
                      label: 'Pattern Match',
                      value: '+5%',
                      positive: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Badges',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _BadgeChip(label: 'First Drill', icon: Icons.star_outline),
              _BadgeChip(label: 'Pot Odds Pro', icon: Icons.calculate),
              _BadgeChip(label: 'Range Master', icon: Icons.layers),
            ],
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _BadgeChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────

class _DrillStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DrillStat({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

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

class _ProgressItem extends StatelessWidget {
  final String label;
  final String value;
  final bool positive;

  const _ProgressItem({
    required this.label,
    required this.value,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: positive ? AppColors.primary : AppColors.error,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
