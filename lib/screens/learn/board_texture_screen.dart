import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/board_texture_data.dart';
import '../../services/learning_service.dart';
import '../../theme/app_colors.dart';

/// Interactive drill screen for recognising flop board textures.
///
/// Displays a 3-card flop and walks the user through 3 sub-questions covering:
///   1. Texture classification
///   2. Range advantage
///   3. Optimal c-bet size
///
/// The score bar at the top tracks session accuracy in real time.
class BoardTextureScreen extends StatefulWidget {
  const BoardTextureScreen({super.key});

  @override
  State<BoardTextureScreen> createState() => _BoardTextureScreenState();
}

class _BoardTextureScreenState extends State<BoardTextureScreen> {
  // ---------------------------------------------------------------------------
  // Session state
  // ---------------------------------------------------------------------------

  late List<BoardQuestion> _shuffledBoards;
  int _boardIndex = 0;
  int _subQuestionIndex = 0;

  /// null = unanswered; otherwise the index the user tapped.
  int? _selectedOption;

  int _totalAnswered = 0;
  int _totalCorrect = 0;

  final _random = Random();

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _initBoards();
  }

  void _initBoards() {
    _shuffledBoards = List<BoardQuestion>.from(boardTextureQuestions)
      ..shuffle(_random);
    _boardIndex = 0;
    _subQuestionIndex = 0;
    _selectedOption = null;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  BoardQuestion get _currentBoard => _shuffledBoards[_boardIndex];

  BoardSubQuestion get _currentSubQuestion =>
      _currentBoard.questions[_subQuestionIndex];

  bool get _isLastSubQuestion =>
      _subQuestionIndex == _currentBoard.questions.length - 1;

  double get _accuracy =>
      _totalAnswered == 0 ? 0.0 : _totalCorrect / _totalAnswered;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _onOptionSelected(int index) async {
    if (_selectedOption != null) return; // already answered
    final correct = index == _currentSubQuestion.correctIndex;

    setState(() {
      _selectedOption = index;
      _totalAnswered++;
      if (correct) _totalCorrect++;
    });

    await LearningService.recordDrillResult(
      drillId: 'board_texture',
      correct: correct,
    );
  }

  void _onNext() {
    if (_selectedOption == null) return;

    if (!_isLastSubQuestion) {
      setState(() {
        _subQuestionIndex++;
        _selectedOption = null;
      });
    } else {
      _onNewBoard();
    }
  }

  void _onNewBoard() {
    setState(() {
      _boardIndex = (_boardIndex + 1) % _shuffledBoards.length;
      _subQuestionIndex = 0;
      _selectedOption = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _ScoreBar(
              answered: _totalAnswered,
              correct: _totalCorrect,
              accuracy: _accuracy,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button + title
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: AppColors.onSurfaceVariant, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Board Texture Drill',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Flop card display
                    _FlopDisplay(cards: _currentBoard.cards),
                    const SizedBox(height: 24),

                    // Sub-question indicator
                    _SubQuestionIndicator(
                      total: _currentBoard.questions.length,
                      current: _subQuestionIndex,
                    ),
                    const SizedBox(height: 16),

                    // Question text
                    Text(
                      _currentSubQuestion.question,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Answer options
                    ..._currentSubQuestion.options.asMap().entries.map(
                          (entry) => _OptionTile(
                            index: entry.key,
                            label: entry.value,
                            selectedIndex: _selectedOption,
                            correctIndex: _currentSubQuestion.correctIndex,
                            onTap: () => _onOptionSelected(entry.key),
                          ),
                        ),

                    // Explanation (shown after answering)
                    if (_selectedOption != null) ...[
                      const SizedBox(height: 16),
                      _ExplanationCard(
                          explanation: _currentSubQuestion.explanation),
                    ],
                    const SizedBox(height: 24),

                    // Navigation buttons
                    if (_selectedOption != null)
                      _isLastSubQuestion
                          ? _NavButton(
                              label: 'New Board  →',
                              onPressed: _onNewBoard,
                            )
                          : _NavButton(
                              label: 'Next Question  →',
                              onPressed: _onNext,
                            ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score Bar
// ---------------------------------------------------------------------------

class _ScoreBar extends StatelessWidget {
  final int answered;
  final int correct;
  final double accuracy;

  const _ScoreBar({
    required this.answered,
    required this.correct,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Text(
            'Session Accuracy',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: accuracy,
                minHeight: 6,
                backgroundColor: AppColors.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            answered == 0
                ? '—'
                : '${(accuracy * 100).toStringAsFixed(0)}%  ($correct/$answered)',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Flop Display
// ---------------------------------------------------------------------------

class _FlopDisplay extends StatelessWidget {
  final List<String> cards;

  const _FlopDisplay({required this.cards});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: cards.map((code) => _CardWidget(code: code)).toList(),
    );
  }
}

class _CardWidget extends StatelessWidget {
  final String code;

  const _CardWidget({required this.code});

  Color get _suitColor {
    final suit = code.isNotEmpty ? code[code.length - 1] : '';
    return switch (suit) {
      'h' => const Color(0xFFE53935),
      'd' => const Color(0xFFE53935),
      'c' => const Color(0xFF43A047),
      's' => AppColors.onSurface,
      _ => AppColors.onSurface,
    };
  }

  String get _suitSymbol {
    final suit = code.isNotEmpty ? code[code.length - 1] : '';
    return switch (suit) {
      'h' => '♥',
      'd' => '♦',
      'c' => '♣',
      's' => '♠',
      _ => '',
    };
  }

  String get _rank => code.length >= 2 ? code.substring(0, code.length - 1) : code;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      width: 72,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _rank,
            style: GoogleFonts.manrope(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _suitColor,
            ),
          ),
          Text(
            _suitSymbol,
            style: TextStyle(
              fontSize: 22,
              color: _suitColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-Question Progress Indicator
// ---------------------------------------------------------------------------

class _SubQuestionIndicator extends StatelessWidget {
  final int total;
  final int current;

  const _SubQuestionIndicator({required this.total, required this.current});

  static const _labels = ['Texture', 'Range', 'C-Bet'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i == current;
        final done = i < current;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: done || active
                        ? AppColors.primary
                        : AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  i < _labels.length ? _labels[i] : '${i + 1}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w400,
                    color: active
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Option Tile
// ---------------------------------------------------------------------------

class _OptionTile extends StatelessWidget {
  final int index;
  final String label;
  final int? selectedIndex;
  final int correctIndex;
  final VoidCallback onTap;

  const _OptionTile({
    required this.index,
    required this.label,
    required this.selectedIndex,
    required this.correctIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final answered = selectedIndex != null;
    final isSelected = selectedIndex == index;
    final isCorrect = index == correctIndex;

    Color borderColor;
    Color bgColor;
    Color textColor;

    if (!answered) {
      borderColor = AppColors.outlineVariant;
      bgColor = AppColors.surfaceContainerLow;
      textColor = AppColors.onSurface;
    } else if (isCorrect) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withOpacity(0.12);
      textColor = AppColors.primary;
    } else if (isSelected) {
      borderColor = AppColors.error;
      bgColor = AppColors.error.withOpacity(0.10);
      textColor = AppColors.error;
    } else {
      borderColor = AppColors.outlineVariant.withOpacity(0.4);
      bgColor = AppColors.surfaceContainerLow.withOpacity(0.5);
      textColor = AppColors.onSurfaceVariant;
    }

    return GestureDetector(
      onTap: answered ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            _OptionBadge(
              label: String.fromCharCode(65 + index), // A, B, C, D
              active: !answered,
              correct: answered && isCorrect,
              wrong: answered && isSelected && !isCorrect,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected || (answered && isCorrect)
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: textColor,
                ),
              ),
            ),
            if (answered && isCorrect)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 18),
            if (answered && isSelected && !isCorrect)
              Icon(Icons.cancel, color: AppColors.error, size: 18),
          ],
        ),
      ),
    );
  }
}

class _OptionBadge extends StatelessWidget {
  final String label;
  final bool active;
  final bool correct;
  final bool wrong;

  const _OptionBadge({
    required this.label,
    required this.active,
    required this.correct,
    required this.wrong,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = correct
        ? AppColors.primary
        : wrong
            ? AppColors.error
            : AppColors.surfaceContainerHighest;
    final Color fg = correct || wrong ? AppColors.onPrimary : AppColors.onSurfaceVariant;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Explanation Card
// ---------------------------------------------------------------------------

class _ExplanationCard extends StatelessWidget {
  final String explanation;

  const _ExplanationCard({required this.explanation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              explanation,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurface,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Navigation Button
// ---------------------------------------------------------------------------

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _NavButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
