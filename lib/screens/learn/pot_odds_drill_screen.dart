import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/pot_odds_scenarios.dart';
import '../../services/learning_service.dart';
import '../../theme/app_colors.dart';

enum _Difficulty { easy, medium, hard }

class PotOddsDrillScreen extends StatefulWidget {
  const PotOddsDrillScreen({super.key});

  @override
  State<PotOddsDrillScreen> createState() => _PotOddsDrillScreenState();
}

class _PotOddsDrillScreenState extends State<PotOddsDrillScreen> {
  _Difficulty _difficulty = _Difficulty.medium;

  late PotOddsScenario _scenario;
  int _questionNumber = 1;
  int _streak = 0;

  // Session tracking (resets every 10 questions)
  int _sessionCorrect = 0;
  int _sessionTotal = 0;

  bool _answered = false;
  bool _wasCorrect = false;

  // Shown after every 10 answers.
  bool _showSessionSummary = false;

  @override
  void initState() {
    super.initState();
    _scenario = _generateScenario();
  }

  PotOddsScenario _generateScenario() {
    switch (_difficulty) {
      case _Difficulty.easy:
        return PotOddsScenarioGenerator.generateEasy();
      case _Difficulty.medium:
        return PotOddsScenarioGenerator.generate();
      case _Difficulty.hard:
        return PotOddsScenarioGenerator.generateHard();
    }
  }

  void _handleAnswer(String action) {
    if (_answered) return;

    final correct = action == _scenario.correctAction;

    setState(() {
      _answered = true;
      _wasCorrect = correct;
      _streak = correct ? _streak + 1 : 0;
      _sessionCorrect += correct ? 1 : 0;
      _sessionTotal += 1;
    });

    learningService.recordDrillResult(drillId: 'pot_odds', correct: correct);

    if (_sessionTotal % 10 == 0) {
      setState(() => _showSessionSummary = true);
    }
  }

  void _nextScenario() {
    setState(() {
      _questionNumber += 1;
      _answered = false;
      _wasCorrect = false;
      _showSessionSummary = false;
      _scenario = _generateScenario();
    });
  }

  void _onDifficultyChanged(_Difficulty difficulty) {
    setState(() {
      _difficulty = difficulty;
      _answered = false;
      _wasCorrect = false;
      _showSessionSummary = false;
      _scenario = _generateScenario();
    });
  }

  @override
  Widget build(BuildContext context) {
    final neededPercent = _scenario.betSize /
        (_scenario.pot + _scenario.betSize + _scenario.betSize) *
        100;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Pot Odds',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              'Question $_questionNumber · Streak: $_streak',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Difficulty segmented control
              _DifficultyToggle(
                selected: _difficulty,
                onChanged: _onDifficultyChanged,
              ),
              const SizedBox(height: 20),

              // Scenario card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _scenario.description,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _MiniStat(
                            label: 'Pot',
                            value:
                                '\$${_scenario.pot.toStringAsFixed(0)}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniStat(
                            label: 'Bet',
                            value:
                                '\$${_scenario.betSize.toStringAsFixed(0)}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _MiniStat(
                            label: 'Your Equity',
                            value:
                                '${_scenario.equityPercent.toStringAsFixed(0)}%',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Decision buttons (disabled after answering)
              if (!_answered) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAnswer('call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A6B34),
                          foregroundColor: AppColors.primary,
                          padding:
                              const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'CALL',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAnswer('fold'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorContainer,
                          foregroundColor: AppColors.error,
                          padding:
                              const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'FOLD',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Feedback section
              if (_answered) ...[
                _FeedbackSection(
                  wasCorrect: _wasCorrect,
                  explanation: _scenario.explanation,
                  neededPercent: neededPercent,
                  equityPercent: _scenario.equityPercent,
                  correctAction: _scenario.correctAction,
                ),
                const SizedBox(height: 16),

                // Session summary (every 10 answers)
                if (_showSessionSummary) ...[
                  _SessionSummaryCard(
                    correct: _sessionCorrect,
                    total: _sessionTotal,
                  ),
                  const SizedBox(height: 16),
                ],

                // Next button
                ElevatedButton(
                  onPressed: _nextScenario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Next Scenario →',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _DifficultyToggle extends StatelessWidget {
  final _Difficulty selected;
  final ValueChanged<_Difficulty> onChanged;

  const _DifficultyToggle({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _Difficulty.values
            .map((d) => Expanded(child: _DifficultyChip(
                  label: _label(d),
                  selected: selected == d,
                  onTap: () => onChanged(d),
                )))
            .toList(),
      ),
    );
  }

  String _label(_Difficulty d) {
    switch (d) {
      case _Difficulty.easy:
        return 'Easy';
      case _Difficulty.medium:
        return 'Medium';
      case _Difficulty.hard:
        return 'Hard';
    }
  }
}

class _DifficultyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.surfaceContainerHighest
              : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected
                ? AppColors.primary
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackSection extends StatelessWidget {
  final bool wasCorrect;
  final String explanation;
  final double neededPercent;
  final double equityPercent;
  final String correctAction;

  const _FeedbackSection({
    required this.wasCorrect,
    required this.explanation,
    required this.neededPercent,
    required this.equityPercent,
    required this.correctAction,
  });

  @override
  Widget build(BuildContext context) {
    final color = wasCorrect ? AppColors.primary : AppColors.error;
    final bgColor = wasCorrect
        ? AppColors.primary.withOpacity(0.08)
        : AppColors.errorContainer.withOpacity(0.15);
    final borderColor = wasCorrect
        ? AppColors.primary.withOpacity(0.25)
        : AppColors.error.withOpacity(0.25);
    final icon = wasCorrect ? Icons.check_circle_outline : Icons.cancel_outlined;
    final headline = wasCorrect ? 'Correct!' : 'Incorrect';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                headline,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            explanation,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurface,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pot odds required: ${neededPercent.toStringAsFixed(1)}%  ·  '
            'Your equity: ${equityPercent.toStringAsFixed(0)}%  ·  '
            '${correctAction[0].toUpperCase()}${correctAction.substring(1)} is correct.',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionSummaryCard extends StatelessWidget {
  final int correct;
  final int total;

  const _SessionSummaryCard({required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (correct / total * 100).round() : 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session complete',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$correct/$total correct ($pct%)',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
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
