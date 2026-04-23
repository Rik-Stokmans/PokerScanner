import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
                      ],
                    ),
                  ],
                ),
              ),
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
