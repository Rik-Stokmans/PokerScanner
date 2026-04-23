import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hand_model.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../providers/providers.dart';

class SessionAnalysisScreen extends ConsumerWidget {
  const SessionAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(sessionAnalysisProvider);
    final handsAsync = ref.watch(activeGameHandsProvider);
    final userAsync = ref.watch(currentUserProvider);
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
                        _MiniStat(
                          label: 'bb/100',
                          value: stats.bbPer100Formatted,
                          valueColor: stats.bbPer100 >= 0
                              ? AppColors.primary
                              : AppColors.error,
                        ),
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
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Win Breakdown card
              _WinBreakdownCard(stats: stats),
              const SizedBox(height: 24),

              // Stack over time sparkline (t22)
              handsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (hands) {
                  final myUid = user?.id ?? '';
                  if (hands.length < 2) return const SizedBox.shrink();
                  return _StackSparkline(hands: hands, myUid: myUid);
                },
              ),

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
                    : Column(
                        children: stats.positionalPnl.entries.map((entry) {
                          final isPositive = entry.value >= 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 40,
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(entry.key,
                                        style: GoogleFonts.inter(
                                          fontSize: 11, fontWeight: FontWeight.w700,
                                          color: AppColors.onSurfaceVariant,
                                          letterSpacing: 0.5,
                                        )),
                                  ),
                                ),
                                Text(
                                  '${isPositive ? "+" : ""}\$${entry.value.abs().toStringAsFixed(0)}',
                                  style: GoogleFonts.manrope(
                                    fontSize: 16, fontWeight: FontWeight.w700,
                                    color: isPositive ? AppColors.primary : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 24),

              // Winning hands section
              Text('Recent Winners',
                  style: GoogleFonts.manrope(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  )),
              const SizedBox(height: 12),
              handsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (hands) {
                  if (hands.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text('No hands recorded yet',
                          style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.onSurfaceVariant,
                          )),
                    );
                  }
                  final myWins = hands
                      .where((h) => h.winnerId == user?.id)
                      .take(3)
                      .toList();
                  if (myWins.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text('No wins yet — keep playing!',
                          style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.onSurfaceVariant,
                          )),
                    );
                  }
                  return Column(
                    children: myWins.map((hand) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ErrorCard(
                        type: hand.handRank,
                        handId: 'Hand #${hand.handNumber}',
                        metric: '+€${hand.potAmount.toStringAsFixed(2)}',
                        isWin: true,
                      ),
                    )).toList(),
                  );
                },
              ),
              const SizedBox(height: 10),

              // AI Insight
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
                            stats.handsPlayed == 0
                                ? 'Start a session to get personalised insights.'
                                : stats.bbPer100 > 0
                                    ? 'Solid session at ${stats.bbPer100Formatted} bb/100. Keep applying pressure in position.'
                                    : 'You are running below EV. Review your pre-flop ranges and avoid calling out of position.',
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
              const SizedBox(height: 24),
              GradientButton(
                label: 'START TRAINING DRILL',
                icon: Icons.sports_score,
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

  const _MiniStat({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
              fontSize: 10, color: AppColors.onSurfaceVariant, letterSpacing: 0.5,
            )),
        Text(value,
            style: GoogleFonts.manrope(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.onSurface,
            )),
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

/// Small sparkline showing running P&L across recorded hands (t22).
class _StackSparkline extends StatelessWidget {
  final List<HandModel> hands;
  final String myUid;

  const _StackSparkline({required this.hands, required this.myUid});

  List<FlSpot> _buildSpots() {
    double running = 0;
    final spots = <FlSpot>[const FlSpot(0, 0)];
    for (int i = 0; i < hands.length; i++) {
      final hand = hands[i];
      if (hand.winnerId == myUid) {
        running += hand.potAmount;
      } else {
        running -= hand.potAmount * 0.1; // rough approximation of ante/blind loss
      }
      spots.add(FlSpot((i + 1).toDouble(), running));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots();
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final isPositive = spots.last.y >= 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Stack Over Time',
              style: GoogleFonts.manrope(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              )),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (hands.length).toDouble(),
                minY: minY - 1,
                maxY: maxY + 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: isPositive ? AppColors.primary : AppColors.error,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: (isPositive ? AppColors.primary : AppColors.error)
                          .withOpacity(0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
