import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/gto_ranges.dart';
import '../../providers/learning_progress_provider.dart';
import '../../services/learning_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_button.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const List<String> _positions = ['UTG', 'MP', 'CO', 'BTN', 'SB', 'BB'];
const List<String> _scenarios = ['open', '3bet', 'call'];
const List<String> _scenarioLabels = ['Open', '3-Bet', 'Call vs Open'];

const List<String> _ranks = [
  'A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'
];

String _cellCode(int row, int col) {
  // row == col → pair, row < col → offsuit (below diagonal in UI),
  // row > col → suited (above diagonal in UI).
  // Note: the grid is displayed with ranks decreasing from top-left so
  // the "suited" cells appear above the diagonal (col > row) and
  // "offsuit" cells appear below (col < row).
  final r1 = _ranks[row];
  final r2 = _ranks[col];
  if (row == col) return '$r1$r2';
  if (col > row) {
    // above diagonal → suited (higher rank is the row rank)
    return '$r1${r2}s';
  } else {
    // below diagonal → offsuit (higher rank is the col rank)
    return '$r2${r1}o';
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class RangeTrainerScreen extends ConsumerStatefulWidget {
  const RangeTrainerScreen({super.key});

  @override
  ConsumerState<RangeTrainerScreen> createState() => _RangeTrainerScreenState();
}

class _RangeTrainerScreenState extends ConsumerState<RangeTrainerScreen> {
  String _position = 'BTN';
  String _scenario = 'open';

  /// Hand codes the user has tapped to select.
  final Set<String> _selected = {};

  /// Whether the user has pressed "Check" for the current drill.
  bool _checked = false;

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Set<String> get _gtoSet =>
      gtoRanges[_position]?[_scenario] ?? const {};

  void _toggleCell(String code) {
    if (_checked) return; // locked after checking
    setState(() {
      if (_selected.contains(code)) {
        _selected.remove(code);
      } else {
        _selected.add(code);
      }
    });
  }

  Future<void> _check() async {
    setState(() => _checked = true);

    final gto = _gtoSet;
    final correct = _selected.intersection(gto).length;
    final missed = gto.difference(_selected).length;
    final falsePositives = _selected.difference(gto).length;
    final total = gto.length;
    final score = total > 0 ? correct / total * 100 : 0.0;

    await LearningService.recordDrillResult(
      drillId: 'range_trainer_${_position}_$_scenario',
      correct: score > 70,
    );

    if (!mounted) return;
    _showScoreCard(
      score: score,
      correct: correct,
      missed: missed,
      falsePositives: falsePositives,
    );
  }

  void _reset() {
    setState(() {
      _selected.clear();
      _checked = false;
    });
  }

  /// Returns the position with the lowest historical accuracy, defaulting to
  /// the next position in the list after the current one.
  String _nextWeakPosition() {
    final progress = ref.read(learningProgressProvider);
    String? weakest;
    double lowestAccuracy = 2.0;

    for (final pos in _positions) {
      if (pos == _position) continue;
      final drillId = 'range_trainer_${pos}_$_scenario';
      final entry = progress.where((p) => p.drillId == drillId).firstOrNull;
      final accuracy = entry?.accuracy ?? -1.0; // unseen = try first
      if (accuracy < lowestAccuracy) {
        lowestAccuracy = accuracy;
        weakest = pos;
      }
    }

    if (weakest != null) return weakest;
    final idx = (_positions.indexOf(_position) + 1) % _positions.length;
    return _positions[idx];
  }

  void _showScoreCard({
    required double score,
    required int correct,
    required int missed,
    required int falsePositives,
  }) {
    final gto = _gtoSet;
    final tip = _generateTip(score: score, gto: gto);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Score: ${score.toStringAsFixed(0)}%',
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: score >= 70 ? AppColors.primary : AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You matched ${score.toStringAsFixed(0)}% of the correct range'
                ' — $correct hands correct, $missed missed,'
                ' $falsePositives false positives.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                label: 'NEXT POSITION',
                icon: Icons.arrow_forward,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  final next = _nextWeakPosition();
                  setState(() {
                    _position = next;
                    _selected.clear();
                    _checked = false;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _generateTip({required double score, required Set<String> gto}) {
    if (score >= 90) {
      return 'Excellent! Your $_position $_scenario range is spot-on. '
          'Keep drilling other positions to maintain consistency.';
    }
    if (score >= 70) {
      return 'Good work! You have the core of the $_position $_scenario range. '
          'Review a few borderline hands to tighten up further.';
    }
    // Provide position-specific guidance
    switch (_position) {
      case 'UTG':
        return 'You\'re ${score < 50 ? "opening too wide" : "slightly off"} from '
            'UTG — tighten to 77+ and AQs+, AKo only.';
      case 'MP':
        return 'MP requires pairs 44+, AJs+, KQs and AKo–AQo, KQo. '
            'Avoid weak offsuit hands.';
      case 'CO':
        return 'CO opens around 30% — include suited aces, KJs+, and AKo–AJo. '
            'Drop weak offsuit holdings.';
      case 'BTN':
        return 'BTN is the widest position (~45%). Include all pairs, AXs, '
            'K9s+, and suited connectors down to 65s.';
      case 'SB':
        return 'SB opens wide but is OOP post-flop. Focus on playable hands '
            'with good post-flop equity.';
      case 'BB':
        return 'BB has no open range. In 3-bet or call spots, '
            'defend wide — you have pot odds.';
      default:
        return 'Study the GTO chart for $_position $_scenario and drill daily '
            'to improve range accuracy.';
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: const BackButton(color: AppColors.onSurface),
        title: Text(
          'Range Trainer',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PositionSelector(
                    selected: _position,
                    onSelect: (p) {
                      setState(() {
                        _position = p;
                        _selected.clear();
                        _checked = false;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _ScenarioSelector(
                    selected: _scenario,
                    onSelect: (s) {
                      setState(() {
                        _scenario = s;
                        _selected.clear();
                        _checked = false;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _HandGrid(
                    selected: _selected,
                    gtoSet: _checked ? _gtoSet : const {},
                    checked: _checked,
                    onToggle: _toggleCell,
                  ),
                  const SizedBox(height: 80), // breathing room above action bar
                ],
              ),
            ),
          ),
          _ActionBar(
            checked: _checked,
            onCheck: _check,
            onReset: _reset,
          ),
        ],
      ),
    );
  }
}

// ─── Position Selector ────────────────────────────────────────────────────────

class _PositionSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _PositionSelector({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _positions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final pos = _positions[index];
          final isSelected = pos == selected;
          return GestureDetector(
            onTap: () => onSelect(pos),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                pos,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Scenario Selector ───────────────────────────────────────────────────────

class _ScenarioSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _ScenarioSelector({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_scenarios.length, (i) {
        final scenario = _scenarios[i];
        final label = _scenarioLabels[i];
        final isSelected = scenario == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(scenario),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(
                left: i == 0 ? 0 : 4,
                right: i == _scenarios.length - 1 ? 0 : 4,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.15)
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Hand Grid ───────────────────────────────────────────────────────────────

class _HandGrid extends StatelessWidget {
  final Set<String> selected;
  final Set<String> gtoSet;
  final bool checked;
  final ValueChanged<String> onToggle;

  const _HandGrid({
    required this.selected,
    required this.gtoSet,
    required this.checked,
    required this.onToggle,
  });

  Color _cellColor(String code) {
    final isSelected = selected.contains(code);
    final isGto = gtoSet.contains(code);

    if (!checked) {
      // Before checking: only show user selection
      return isSelected
          ? Colors.amber.withOpacity(0.6)
          : AppColors.surfaceContainer;
    }

    // After checking: show correctness
    if (isSelected && isGto) {
      return AppColors.primary.withOpacity(0.7); // correct
    }
    if (!isSelected && isGto) {
      return Colors.red.withOpacity(0.4); // GTO missed
    }
    if (isSelected && !isGto) {
      return Colors.orange.withOpacity(0.5); // false positive
    }
    return AppColors.surfaceContainer;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = (constraints.maxWidth - 12) / 13;
        return Column(
          children: List.generate(13, (row) {
            return Row(
              children: List.generate(13, (col) {
                final code = _cellCode(row, col);
                final color = _cellColor(code);
                return GestureDetector(
                  onTap: () => onToggle(code),
                  child: Container(
                    width: cellSize,
                    height: cellSize,
                    margin: const EdgeInsets.all(0.5),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          code,
                          style: GoogleFonts.inter(
                            fontSize: 7,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface.withOpacity(0.85),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        );
      },
    );
  }
}

// ─── Action Bar ──────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final bool checked;
  final VoidCallback onCheck;
  final VoidCallback onReset;

  const _ActionBar({
    required this.checked,
    required this.onCheck,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withOpacity(0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.outlineVariant),
              ),
              child: Text(
                'Reset',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GradientButton(
              label: checked ? 'CHECKED' : 'CHECK',
              icon: checked ? Icons.check_circle_outline : Icons.check,
              onPressed: checked ? null : onCheck,
            ),
          ),
        ],
      ),
    );
  }
}
