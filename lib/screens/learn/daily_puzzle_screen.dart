import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/daily_puzzles.dart';
import '../../models/learning_progress_model.dart';
import '../../providers/learning_progress_provider.dart';
import '../../theme/app_colors.dart';

// ─── State helpers ────────────────────────────────────────────────────────────

enum _PuzzleState { notAttempted, correct, incorrect }

// ─── Screen ───────────────────────────────────────────────────────────────────

class DailyPuzzleScreen extends ConsumerStatefulWidget {
  const DailyPuzzleScreen({super.key});

  @override
  ConsumerState<DailyPuzzleScreen> createState() => _DailyPuzzleScreenState();
}

class _DailyPuzzleScreenState extends ConsumerState<DailyPuzzleScreen>
    with SingleTickerProviderStateMixin {
  late final DailyPuzzle _puzzle;
  _PuzzleState _puzzleState = _PuzzleState.notAttempted;
  int? _selectedIndex;
  int _secondsElapsed = 0;
  Timer? _timer;

  // Confetti animation controller (simple scale burst)
  late final AnimationController _confettiController;
  late final Animation<double> _confettiScale;

  @override
  void initState() {
    super.initState();
    _puzzle = todaysPuzzle;

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _confettiScale = CurvedAnimation(
      parent: _confettiController,
      curve: Curves.elasticOut,
    );

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  // ── Timer ──────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_puzzleState == _PuzzleState.notAttempted) {
        setState(() => _secondsElapsed++);
      }
    });
  }

  String get _timerLabel {
    final m = _secondsElapsed ~/ 60;
    final s = _secondsElapsed % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Answer handling ────────────────────────────────────────────────────────

  Future<void> _onOptionTap(int index) async {
    if (_puzzleState != _PuzzleState.notAttempted) return;
    _timer?.cancel();

    final correct = index == _puzzle.correctIndex;
    setState(() {
      _selectedIndex = index;
      _puzzleState = correct ? _PuzzleState.correct : _PuzzleState.incorrect;
    });

    await ref.read(learningProgressProvider.notifier).recordPuzzleAttempt(
          puzzleId: _puzzle.id,
          correct: correct,
        );

    if (correct) {
      _confettiController.forward();
    }
  }

  // ── Share ──────────────────────────────────────────────────────────────────

  void _share() {
    final dateStr =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    final result = _puzzleState == _PuzzleState.correct ? 'Correct' : 'Wrong';
    final progressAsync = ref.read(learningProgressProvider);
    final streak = progressAsync.value?.puzzleStreakDays ?? 0;

    Share.share(
      'PokerScanner Daily Puzzle — $dateStr\n'
      '${_puzzle.title}\n'
      'Result: $result in $_timerLabel\n'
      '🔥 Streak: $streak day${streak == 1 ? '' : 's'}\n'
      'Download the app and test your poker IQ!',
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final progressAsync = ref.watch(learningProgressProvider);
    final progress = progressAsync.value;

    // If the puzzle was already solved before opening this screen, show
    // the "come back tomorrow" state.
    if (progress != null &&
        progress.solvedToday &&
        _puzzleState == _PuzzleState.notAttempted) {
      return _buildAlreadySolvedScreen(progress);
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        title: Text(
          'Daily Puzzle',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          if (_puzzleState != _PuzzleState.notAttempted)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              onPressed: _share,
              tooltip: 'Share result',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(progress),
              const SizedBox(height: 20),
              _buildDifficultyBadge(),
              const SizedBox(height: 16),
              _buildSituationCard(),
              const SizedBox(height: 16),
              _buildCardDisplay(),
              const SizedBox(height: 24),
              if (_puzzleState == _PuzzleState.notAttempted) _buildTimer(),
              if (_puzzleState == _PuzzleState.notAttempted)
                const SizedBox(height: 16),
              _buildOptions(),
              if (_puzzleState != _PuzzleState.notAttempted) ...[
                const SizedBox(height: 20),
                _buildResult(),
                const SizedBox(height: 16),
                _buildExplanationCard(),
                const SizedBox(height: 20),
                _buildShareButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _buildAlreadySolvedScreen(LearningProgressModel progress) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        title: Text(
          'Daily Puzzle',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _share,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle,
                    color: AppColors.primary, size: 64),
                const SizedBox(height: 20),
                Text(
                  'You solved today\'s puzzle!',
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Come back tomorrow for a new challenge.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _StreakChip(streak: progress.puzzleStreakDays),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share Result'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(LearningProgressModel? progress) {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr =
        '${months[now.month - 1]} ${now.day}, ${now.year}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _puzzle.title,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        if (progress != null)
          _StreakChip(streak: progress.puzzleStreakDays),
      ],
    );
  }

  Widget _buildDifficultyBadge() {
    Color badgeColor;
    Color textColor;
    switch (_puzzle.difficulty) {
      case 'Beginner':
        badgeColor = AppColors.primary.withOpacity(0.15);
        textColor = AppColors.primary;
      case 'Intermediate':
        badgeColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blue.shade300;
      case 'Advanced':
        badgeColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange.shade300;
      default: // Expert
        badgeColor = AppColors.error.withOpacity(0.15);
        textColor = AppColors.error;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _puzzle.difficulty,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _puzzle.category,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSituationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.3),
        ),
      ),
      child: Text(
        _puzzle.situation,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.onSurface,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildCardDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_puzzle.holeCards.isNotEmpty) ...[
          Text(
            'Your Hand',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: _puzzle.holeCards
                .map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CardChip(label: c),
                    ))
                .toList(),
          ),
        ],
        if (_puzzle.communityCards.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Board',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _puzzle.communityCards
                .map((c) => _CardChip(label: c))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTimer() {
    return Row(
      children: [
        const Icon(Icons.timer_outlined,
            color: AppColors.onSurfaceVariant, size: 16),
        const SizedBox(width: 6),
        Text(
          _timerLabel,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Column(
      children: List.generate(_puzzle.options.length, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _OptionButton(
            label: _puzzle.options[i],
            index: i,
            selectedIndex: _selectedIndex,
            correctIndex:
                _puzzleState != _PuzzleState.notAttempted ? _puzzle.correctIndex : null,
            onTap: () => _onOptionTap(i),
          ),
        );
      }),
    );
  }

  Widget _buildResult() {
    final isCorrect = _puzzleState == _PuzzleState.correct;
    return ScaleTransition(
      scale: isCorrect ? _confettiScale : const AlwaysStoppedAnimation(1.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCorrect
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCorrect
                ? AppColors.primary.withOpacity(0.3)
                : AppColors.error.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? AppColors.primary : AppColors.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect ? 'Correct! +25 XP' : 'Incorrect — +5 XP',
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isCorrect ? AppColors.primary : AppColors.error,
                    ),
                  ),
                  if (isCorrect)
                    Text(
                      'Time: $_timerLabel',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
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

  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              Text(
                'Explanation',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _puzzle.explanation,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurface,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _share,
        icon: const Icon(Icons.share_outlined, size: 18),
        label: const Text('Share Result'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

// ─── Reusable micro-widgets ───────────────────────────────────────────────────

class _StreakChip extends StatelessWidget {
  final int streak;
  const _StreakChip({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department,
              color: Colors.orange, size: 16),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardChip extends StatelessWidget {
  final String label;
  const _CardChip({required this.label});

  Color get _suitColor {
    if (label.contains('♥') || label.contains('♦')) {
      return Colors.red.shade400;
    }
    return AppColors.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _suitColor,
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String label;
  final int index;
  final int? selectedIndex;
  final int? correctIndex;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.correctIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.outlineVariant.withOpacity(0.3);
    Color bgColor = AppColors.surfaceContainerLow;
    Color textColor = AppColors.onSurface;
    IconData? trailingIcon;

    if (correctIndex != null) {
      if (index == correctIndex) {
        borderColor = AppColors.primary.withOpacity(0.5);
        bgColor = AppColors.primary.withOpacity(0.1);
        textColor = AppColors.primary;
        trailingIcon = Icons.check_circle;
      } else if (index == selectedIndex && index != correctIndex) {
        borderColor = AppColors.error.withOpacity(0.5);
        bgColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        trailingIcon = Icons.cancel;
      }
    }

    return GestureDetector(
      onTap: correctIndex == null ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode('A'.codeUnitAt(0) + index),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: textColor,
                  height: 1.4,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(
                trailingIcon,
                color: textColor,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
