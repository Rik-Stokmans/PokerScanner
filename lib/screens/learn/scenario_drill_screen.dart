import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/drill_scenarios.dart';
import '../../services/learning_service.dart';
import '../../theme/app_colors.dart';

class ScenarioDrillScreen extends StatefulWidget {
  const ScenarioDrillScreen({super.key});

  @override
  State<ScenarioDrillScreen> createState() => _ScenarioDrillScreenState();
}

class _ScenarioDrillScreenState extends State<ScenarioDrillScreen>
    with SingleTickerProviderStateMixin {
  ScenarioCategory? _selectedCategory; // null = All
  late List<DrillScenario> _filteredScenarios;
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _answerSubmitted = false;
  int _correctCount = 0;
  bool _sessionComplete = false;

  late AnimationController _explanationController;
  late Animation<Offset> _explanationOffset;

  @override
  void initState() {
    super.initState();
    _explanationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _explanationOffset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _explanationController,
      curve: Curves.easeOutCubic,
    ));
    _applyFilter(_selectedCategory);
  }

  @override
  void dispose() {
    _explanationController.dispose();
    super.dispose();
  }

  void _applyFilter(ScenarioCategory? category) {
    setState(() {
      _selectedCategory = category;
      _filteredScenarios = category == null
          ? List<DrillScenario>.from(drillScenarios)
          : drillScenarios
              .where((s) => s.category == category)
              .toList();
      _currentIndex = 0;
      _selectedOptionIndex = null;
      _answerSubmitted = false;
      _correctCount = 0;
      _sessionComplete = false;
      _explanationController.reset();
    });
  }

  void _selectOption(int index) {
    if (_answerSubmitted) return;
    final scenario = _filteredScenarios[_currentIndex];
    final wasCorrect = index == scenario.correctIndex;
    setState(() {
      _selectedOptionIndex = index;
      _answerSubmitted = true;
      if (wasCorrect) _correctCount++;
    });
    LearningService.recordDrillResult(
      drillId: 'scenarios_${scenario.category.name}',
      correct: wasCorrect,
    );
    _explanationController.forward();
  }

  void _continue() {
    if (_currentIndex + 1 >= _filteredScenarios.length) {
      setState(() {
        _sessionComplete = true;
      });
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedOptionIndex = null;
      _answerSubmitted = false;
    });
    _explanationController.reset();
  }

  void _restartSession() {
    _applyFilter(_selectedCategory);
  }

  String _categoryLabel(ScenarioCategory? cat) {
    if (cat == null) return 'All';
    switch (cat) {
      case ScenarioCategory.preflop:
        return 'Preflop';
      case ScenarioCategory.bbDefense:
        return 'BB Defense';
      case ScenarioCategory.flopCbet:
        return 'Flop';
      case ScenarioCategory.turnBarrel:
        return 'Turn';
      case ScenarioCategory.riverSpot:
        return 'River';
      case ScenarioCategory.bluffCatch:
        return 'Bluff Catch';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        title: Text(
          'SCENARIO DRILL',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: _sessionComplete
          ? _buildSummary()
          : _filteredScenarios.isEmpty
              ? _buildEmpty()
              : _buildDrill(),
    );
  }

  Widget _buildDrill() {
    final scenario = _filteredScenarios[_currentIndex];
    final total = _filteredScenarios.length;
    final progress = (_currentIndex + 1) / total;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Category filter ───────────────────────────────────────────
            _CategoryFilterRow(
              selected: _selectedCategory,
              onSelected: _applyFilter,
              labelOf: _categoryLabel,
            ),
            // ── Progress indicator ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question ${_currentIndex + 1} of $total',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                        AppColors.surfaceContainerHighest,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Scenario + options ────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Difficulty badge
                    _DifficultyBadge(difficulty: scenario.difficulty),
                    const SizedBox(height: 10),
                    // Title
                    Text(
                      scenario.title,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Situation card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.outlineVariant.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        scenario.situation,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          color: AppColors.onSurface,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Options
                    ...List.generate(scenario.options.length, (i) {
                      return _OptionButton(
                        label: scenario.options[i],
                        index: i,
                        selectedIndex: _selectedOptionIndex,
                        correctIndex: scenario.correctIndex,
                        submitted: _answerSubmitted,
                        onTap: () => _selectOption(i),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
        // ── Explanation panel (slides from bottom) ────────────────────────
        if (_answerSubmitted)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _explanationOffset,
              child: _ExplanationPanel(
                explanation: scenario.explanation,
                wasCorrect:
                    _selectedOptionIndex == scenario.correctIndex,
                onContinue: _continue,
                isLast: _currentIndex + 1 >= _filteredScenarios.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummary() {
    final total = _filteredScenarios.length;
    final pct = total > 0 ? (_correctCount / total * 100).round() : 0;
    final label = _categoryLabel(_selectedCategory);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.25),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Session Complete!',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '$pct%',
                    style: GoogleFonts.manrope(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: pct >= 70
                          ? AppColors.primary
                          : AppColors.error,
                    ),
                  ),
                  Text(
                    '$_correctCount / $total correct',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _GreenActionButton(
                    label: 'PLAY AGAIN',
                    onPressed: _restartSession,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: AppColors.onSurfaceVariant,
                      side: BorderSide(
                        color: AppColors.outlineVariant.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      'Back to Learn',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Text(
        'No scenarios for this category.',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

class _CategoryFilterRow extends StatelessWidget {
  final ScenarioCategory? selected;
  final ValueChanged<ScenarioCategory?> onSelected;
  final String Function(ScenarioCategory?) labelOf;

  const _CategoryFilterRow({
    required this.selected,
    required this.onSelected,
    required this.labelOf,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [null, ...ScenarioCategory.values];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                labelOf(cat),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.onSurfaceVariant,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(cat),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceContainerHigh,
              checkmarkColor: AppColors.onPrimary,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.outlineVariant.withOpacity(0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final int index;
  final int? selectedIndex;
  final int correctIndex;
  final bool submitted;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.correctIndex,
    required this.submitted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.outlineVariant.withOpacity(0.5);
    Color bgColor = AppColors.surfaceContainerLow;
    Color textColor = AppColors.onSurface;

    if (submitted) {
      if (index == correctIndex) {
        borderColor = AppColors.primary;
        bgColor = AppColors.primary.withOpacity(0.12);
        textColor = AppColors.primary;
      } else if (index == selectedIndex) {
        borderColor = AppColors.error;
        bgColor = AppColors.error.withOpacity(0.12);
        textColor = AppColors.error;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OutlinedButton(
        onPressed: submitted ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          disabledForegroundColor: textColor,
          disabledBackgroundColor: bgColor,
          side: BorderSide(color: borderColor, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          alignment: Alignment.centerLeft,
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                String.fromCharCode(65 + index), // A, B, C, D
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (submitted && index == correctIndex)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 18),
            if (submitted &&
                index == selectedIndex &&
                index != correctIndex)
              Icon(Icons.cancel, color: AppColors.error, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ExplanationPanel extends StatelessWidget {
  final String explanation;
  final bool wasCorrect;
  final VoidCallback onContinue;
  final bool isLast;

  const _ExplanationPanel({
    required this.explanation,
    required this.wasCorrect,
    required this.onContinue,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: wasCorrect
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.error.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  wasCorrect ? Icons.check_circle : Icons.info_outline,
                  color: wasCorrect ? AppColors.primary : AppColors.error,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  wasCorrect ? 'Correct!' : 'Not Quite',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: wasCorrect
                        ? AppColors.primary
                        : AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              explanation,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 16),
            _GreenActionButton(
              label: isLast ? 'SEE RESULTS' : 'CONTINUE →',
              onPressed: onContinue,
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final int difficulty;

  const _DifficultyBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final labels = {1: 'Beginner', 2: 'Intermediate', 3: 'Advanced'};
    final colors = {
      1: AppColors.primary,
      2: AppColors.tertiary,
      3: AppColors.error,
    };
    final bgColors = {
      1: AppColors.primary.withOpacity(0.15),
      2: AppColors.tertiary.withOpacity(0.15),
      3: AppColors.error.withOpacity(0.15),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColors[difficulty],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labels[difficulty] ?? '',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colors[difficulty],
        ),
      ),
    );
  }
}

class _GreenActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _GreenActionButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.onPrimary,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}
