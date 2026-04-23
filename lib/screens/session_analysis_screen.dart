import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hand_model.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../providers/providers.dart';

class SessionAnalysisScreen extends ConsumerWidget {
  const SessionAnalysisScreen({super.key});

  /// Compute all-time win rate and bb/100 from historical hands for [uid].
  /// Returns (allTimeBbPer100, totalHands). Returns null when insufficient data.
  static ({double bbPer100, int hands})? _allTimeStats(
      List<HandModel> recentHands, String uid) {
    if (recentHands.isEmpty) return null;
    double pnl = 0;
    for (final hand in recentHands) {
      if (hand.winnerId == uid) {
        pnl += hand.potAmount;
      } else {
        pnl -= hand.potAmount * 0.1;
      }
    }
    // Use a rough bb estimate of 0.10 as default if unknown
    const defaultBb = 0.10;
    final bbPer100 = (pnl / defaultBb) / (recentHands.length / 100);
    return (bbPer100: bbPer100, hands: recentHands.length);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(sessionAnalysisProvider);
    final handsAsync = ref.watch(activeGameHandsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final recentHandsAsync = ref.watch(userRecentHandsProvider);
    final user = userAsync.value;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ANALYSIS',
                          style: GoogleFonts.manrope(
                            fontSize: 24, fontWeight: FontWeight.w800,
                            color: AppColors.onSurface, letterSpacing: 3,
                          )),
                    ],
                  ),
                  const Icon(Icons.menu, color: AppColors.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 28),

              // Session P&L Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.surfaceContainerLow, AppColors.surfaceContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Session P&L',
                        style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w500,
                          color: AppColors.onSurfaceVariant, letterSpacing: 0.8,
                        )),
                    const SizedBox(height: 8),
                    Text(stats.pnlFormatted,
                        style: GoogleFonts.manrope(
                          fontSize: 48, fontWeight: FontWeight.w800,
                          color: stats.pnl >= 0 ? AppColors.primary : AppColors.error,
                        )),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _MiniStat(
                          label: 'Hands',
                          value: '${stats.handsPlayed}',
                        ),
                        const SizedBox(width: 20),
                        _MiniStat(
                          label: 'Duration',
                          value: stats.durationFormatted,
                        ),
                        const SizedBox(width: 20),
                        Builder(builder: (context) {
                          final allTime = recentHandsAsync.when(
                            data: (hands) => user != null
                                ? _allTimeStats(hands, user.id)
                                : null,
                            loading: () => null,
                            error: (_, __) => null,
                          );
                          final delta = allTime != null && stats.handsPlayed > 0
                              ? stats.bbPer100 - allTime.bbPer100
                              : null;
                          return _MiniStat(
                            label: 'bb/100',
                            value: stats.bbPer100Formatted,
                            valueColor: stats.bbPer100 >= 0
                                ? AppColors.primary
                                : AppColors.error,
                            deltaBadge: delta,
                          );
                        }),
                        const SizedBox(width: 20),
                        _MiniStat(
                          label: 'Win %',
                          value: stats.winRateFormatted,
                          valueColor: stats.handsPlayed > 0
                              ? (stats.winRate >= 0.5
                                  ? AppColors.primary
                                  : AppColors.error)
                              : null,
                        ),
                        const SizedBox(width: 20),
                        // g4: VPIP stat
                        _MiniStat(
                          label: 'VPIP',
                          value: stats.vpipFormatted,
                          valueColor: stats.vpip > 0.30
                              ? AppColors.error
                              : AppColors.onSurface,
                        ),
                      ],
                    ),
                    // g5: stack trajectory embedded in P&L card
                    if (stats.stackSeries.length >= 2) ...[
                      const SizedBox(height: 16),
                      _StackTrajectoryChart(series: stats.stackSeries),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Win Breakdown card
              _WinBreakdownCard(stats: stats),
              const SizedBox(height: 24),

              // Positional Edge
              Text('Positional Edge',
                  style: GoogleFonts.manrope(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  )),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: stats.positionalPnl.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('No data yet — play some hands',
                            style: GoogleFonts.inter(
                              fontSize: 13, color: AppColors.onSurfaceVariant,
                            )),
                      )
                    : _PositionalBarChart(positionalPnl: stats.positionalPnl),
              ),
              const SizedBox(height: 24),

              // g7: Opponents tendencies card
              handsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (hands) {
                  final myUid = user?.id ?? '';
                  // Collect all opponent UIDs and names
                  final opponentNames = <String, String>{};
                  for (final hand in hands) {
                    hand.playerNames.forEach((uid, name) {
                      if (uid != myUid) opponentNames[uid] = name;
                    });
                  }
                  if (opponentNames.isEmpty) return const SizedBox.shrink();

                  // Compute wins and hands played per opponent
                  final opponentWins = <String, int>{};
                  final opponentHands = <String, int>{};
                  for (final hand in hands) {
                    for (final uid in hand.playerNames.keys) {
                      if (uid == myUid) continue;
                      opponentHands[uid] = (opponentHands[uid] ?? 0) + 1;
                      if (hand.winnerId == uid) {
                        opponentWins[uid] = (opponentWins[uid] ?? 0) + 1;
                      }
                    }
                  }

                  // Sort by win rate descending
                  final sorted = opponentNames.keys.toList()
                    ..sort((a, b) {
                      final aHands = opponentHands[a] ?? 1;
                      final bHands = opponentHands[b] ?? 1;
                      final aRate = (opponentWins[a] ?? 0) / aHands;
                      final bRate = (opponentWins[b] ?? 0) / bHands;
                      return bRate.compareTo(aRate);
                    });

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Opponents',
                          style: GoogleFonts.manrope(
                            fontSize: 18, fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          )),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: sorted.map((uid) {
                            final name = opponentNames[uid] ?? uid;
                            final wins = opponentWins[uid] ?? 0;
                            final totalHands = opponentHands[uid] ?? 0;
                            final winRate = totalHands > 0
                                ? (wins / totalHands * 100)
                                : 0.0;
                            final isHot = winRate >= 50;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(name,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.onSurface,
                                        )),
                                  ),
                                  Text('$wins/$totalHands',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.onSurfaceVariant,
                                      )),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isHot
                                          ? AppColors.error.withOpacity(0.15)
                                          : AppColors.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${winRate.toStringAsFixed(0)}%',
                                      style: GoogleFonts.manrope(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isHot
                                            ? AppColors.error
                                            : AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),

              // Notable Hands section (Won / Lost tabs)
              _NotableHandsSection(
                handsAsync: handsAsync,
                userId: user?.id ?? '',
              ),
              const SizedBox(height: 24),

              // g3: Hand Strength section — hand rank frequency pills
              Text('Hand Strength',
                  style: GoogleFonts.manrope(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  )),
              const SizedBox(height: 12),
              handsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (hands) {
                  final myUid = user?.id ?? '';
                  final myWins = hands.where((h) => h.winnerId == myUid).toList();
                  if (myWins.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text('No winning hands yet',
                          style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.onSurfaceVariant,
                          )),
                    );
                  }
                  final freq = <String, int>{};
                  for (final h in myWins) {
                    if (h.handRank.isNotEmpty) {
                      freq[h.handRank] = (freq[h.handRank] ?? 0) + 1;
                    }
                  }
                  final sorted = freq.entries.toList()
                    ..sort((a, b) => b.value.compareTo(a.value));
                  return SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: sorted.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final entry = sorted[i];
                        return _HandRankPill(
                          rank: entry.key,
                          count: entry.value,
                          onTap: () => context.go(
                            '/history?handRank=${Uri.encodeComponent(entry.key)}',
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // AI Insight (g4: dynamic aiInsight)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.psychology,
                          color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Insight',
                              style: GoogleFonts.inter(
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: AppColors.primary, letterSpacing: 0.5,
                              )),
                          const SizedBox(height: 4),
                          Text(
                            stats.aiInsight,
                            style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // g4: Leak warning cards
              if (stats.leakWarnings.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...stats.leakWarnings.map((warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.warning_amber_rounded,
                              color: AppColors.error, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Leak Detected',
                                  style: GoogleFonts.inter(
                                    fontSize: 12, fontWeight: FontWeight.w700,
                                    color: AppColors.error, letterSpacing: 0.5,
                                  )),
                              const SizedBox(height: 4),
                              Text(warning,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                    height: 1.4,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
              const SizedBox(height: 24),
              GradientButton(
                label: 'START TRAINING DRILL',
                icon: Icons.sports_score,
                // Navigate to the Learn screen which hosts training drills.
                // A dedicated training/quiz screen can be added later at /training.
                onPressed: () => context.go('/learn'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  /// When non-null, shows a small coloured arrow badge with the delta value.
  final double? deltaBadge;

  const _MiniStat({
    required this.label,
    required this.value,
    this.valueColor,
    this.deltaBadge,
  });

  @override
  Widget build(BuildContext context) {
    final delta = deltaBadge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
              fontSize: 10, color: AppColors.onSurfaceVariant, letterSpacing: 0.5,
            )),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(value,
                style: GoogleFonts.manrope(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.onSurface,
                )),
            if (delta != null) ...[
              const SizedBox(width: 4),
              _DeltaBadge(delta: delta),
            ],
          ],
        ),
      ],
    );
  }
}

// g7: Delta badge for bb/100 multi-session comparison
class _DeltaBadge extends StatelessWidget {
  final double delta;
  const _DeltaBadge({required this.delta});

  @override
  Widget build(BuildContext context) {
    final isUp = delta >= 0;
    final color = isUp ? AppColors.primary : AppColors.error;
    final sign = isUp ? '+' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward : Icons.arrow_downward,
            size: 8,
            color: color,
          ),
          Text(
            '$sign${delta.toStringAsFixed(1)}',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotableHandsSection extends StatefulWidget {
  final AsyncValue<List<HandModel>> handsAsync;
  final String userId;

  const _NotableHandsSection({required this.handsAsync, required this.userId});

  @override
  State<_NotableHandsSection> createState() => _NotableHandsSectionState();
}

class _NotableHandsSectionState extends State<_NotableHandsSection>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(message,
          style: GoogleFonts.inter(
            fontSize: 13, color: AppColors.onSurfaceVariant,
          )),
    );
  }

  Widget _buildWonTab(List<HandModel> hands) {
    final myWins = hands
        .where((h) => h.winnerId == widget.userId)
        .toList()
      ..sort((a, b) => b.potAmount.compareTo(a.potAmount));
    final top3 = myWins.take(3).toList();
    if (top3.isEmpty) return _emptyState('No wins yet — keep playing!');
    return Column(
      children: top3.map((hand) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ErrorCard(
          type: hand.handRank,
          handId: 'Hand #${hand.handNumber}',
          metric: '+€${hand.potAmount.toStringAsFixed(2)}',
          isWin: true,
        ),
      )).toList(),
    );
  }

  Widget _buildLostTab(List<HandModel> hands) {
    final myId = widget.userId;
    // Hands where user played (has stack entry) but did not win
    final losses = hands
        .where((h) => h.winnerId != myId && h.playerStacksBefore.containsKey(myId))
        .toList()
      ..sort((a, b) => b.potAmount.compareTo(a.potAmount));
    final top3 = losses.take(3).toList();
    if (top3.isEmpty) return _emptyState('No losses recorded yet — great run!');
    return Column(
      children: top3.map((hand) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _ErrorCard(
          type: hand.handRank.isNotEmpty ? hand.handRank : 'Folded / Lost',
          handId: 'Hand #${hand.handNumber}',
          metric: '-€${hand.potAmount.toStringAsFixed(2)}',
          isWin: false,
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notable Hands',
            style: GoogleFonts.manrope(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            )),
        const SizedBox(height: 12),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Won'),
            Tab(text: 'Lost'),
          ],
        ),
        const SizedBox(height: 12),
        widget.handsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (hands) {
            if (hands.isEmpty) return _emptyState('No hands recorded yet');
            return AnimatedBuilder(
              animation: _tabController,
              builder: (context, _) {
                if (_tabController.index == 0) {
                  return _buildWonTab(hands);
                } else {
                  return _buildLostTab(hands);
                }
              },
            );
          },
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String type;
  final String handId;
  final String metric;
  final bool isWin;

  const _ErrorCard({
    required this.type, required this.handId,
    required this.metric, required this.isWin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 4, height: 44,
            decoration: BoxDecoration(
              color: isWin ? AppColors.primary : AppColors.error,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type,
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    )),
                Text(handId,
                    style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.onSurfaceVariant,
                    )),
              ],
            ),
          ),
          Text(metric,
              style: GoogleFonts.manrope(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: isWin ? AppColors.primary : AppColors.error,
              )),
        ],
      ),
    );
  }
}

class _WinBreakdownCard extends StatelessWidget {
  final SessionStats stats;

  const _WinBreakdownCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final flagColor = stats.nonShowdownWinRateHigh
        ? AppColors.primary
        : stats.nonShowdownWinRateLow
            ? AppColors.error
            : null;
    final flagText = stats.nonShowdownWinRateHigh
        ? 'High non-showdown win rate — strong aggression or bluffing'
        : stats.nonShowdownWinRateLow
            ? 'Low non-showdown win rate — consider more selective aggression'
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Win Breakdown',
            style: GoogleFonts.manrope(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            )),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _WinBreakdownTile(
                      label: 'Showdown',
                      winRate: stats.showdownWinRateFormatted,
                      detail: '${stats.showdownWins}/${stats.showdownHands}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _WinBreakdownTile(
                      label: 'Non-Showdown',
                      winRate: stats.nonShowdownWinRateFormatted,
                      detail: '${stats.nonShowdownWins}/${stats.nonShowdownHands}',
                      flagColor: flagColor,
                    ),
                  ),
                ],
              ),
              if (flagText != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: flagColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(flagText,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: flagColor,
                            height: 1.4,
                          )),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WinBreakdownTile extends StatelessWidget {
  final String label;
  final String winRate;
  final String detail;
  final Color? flagColor;

  const _WinBreakdownTile({
    required this.label,
    required this.winRate,
    required this.detail,
    this.flagColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: flagColor != null
            ? Border.all(color: flagColor!.withOpacity(0.4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.5,
              )),
          const SizedBox(height: 4),
          Text(winRate,
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: flagColor ?? AppColors.onSurface,
              )),
          const SizedBox(height: 2),
          Text(detail,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
              )),
        ],
      ),
    );
  }
}

/// g5: Line chart showing cumulative P&L trajectory over hand number.
/// Data comes from [SessionStats.stackSeries] computed in the provider.
class _StackTrajectoryChart extends StatelessWidget {
  final List<({int hand, double pnl})> series;

  const _StackTrajectoryChart({required this.series});

  @override
  Widget build(BuildContext context) {
    final spots = [
      const FlSpot(0, 0),
      ...series.map((e) => FlSpot(e.hand.toDouble(), e.pnl)),
    ];
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final isPositive = spots.last.y >= 0;
    final lineColor = isPositive ? AppColors.primary : AppColors.error;

    return SizedBox(
      height: 80,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: series.last.hand.toDouble(),
          minY: minY - 1,
          maxY: maxY + 1,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withOpacity(0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PositionalBarChart extends StatelessWidget {
  final Map<String, double> positionalPnl;

  const _PositionalBarChart({required this.positionalPnl});

  @override
  Widget build(BuildContext context) {
    final maxAbsValue = positionalPnl.values
        .map((v) => v.abs())
        .fold<double>(0, (a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: positionalPnl.entries.map((entry) {
          final isPositive = entry.value >= 0;
          final fraction = maxAbsValue > 0 ? entry.value.abs() / maxAbsValue : 0.0;
          final barColor = isPositive ? AppColors.primary : AppColors.error;
          final label = '${isPositive ? "+" : "-"}\$${entry.value.abs().toStringAsFixed(0)}';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        entry.key,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final barWidth = constraints.maxWidth * fraction;
                      return Stack(
                        children: [
                          Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            height: 20,
                            width: barWidth,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 60,
                  child: Text(
                    label,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: barColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// g3: Pill badge for a single hand-rank frequency entry (tappable → history filter).
class _HandRankPill extends StatelessWidget {
  final String rank;
  final int count;
  final VoidCallback onTap;

  const _HandRankPill({
    required this.rank,
    required this.count,
    required this.onTap,
  });

  /// Returns a colour that signals relative rarity of the hand rank.
  Color _rarityColor() {
    final lower = rank.toLowerCase();
    if (lower.contains('royal') || lower.contains('straight flush')) {
      return const Color(0xFFFFD700); // gold – legendary
    }
    if (lower.contains('four')) return const Color(0xFFFF6B9D); // pink – rare
    if (lower.contains('full')) return const Color(0xFFFF9800); // orange – very good
    if (lower.contains('flush')) return const Color(0xFF9C27B0); // purple – good
    if (lower.contains('straight')) return const Color(0xFFFFEB3B); // yellow – solid
    if (lower.contains('three') || lower.contains('set')) {
      return const Color(0xFF00BCD4); // teal – moderate
    }
    if (lower.contains('two')) return const Color(0xFF42A5F5); // blue – decent
    if (lower.contains('pair')) return const Color(0xFF78909C); // blue-grey – common
    return const Color(0xFF546E7A); // dark grey – high card
  }

  @override
  Widget build(BuildContext context) {
    final color = _rarityColor();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rank,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
