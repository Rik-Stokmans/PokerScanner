import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/card_model.dart';
import '../../providers/providers.dart';
import '../../services/hand_review_service.dart';
import '../../services/learning_service.dart';
import '../../theme/app_colors.dart';

class HandReviewScreen extends ConsumerStatefulWidget {
  const HandReviewScreen({super.key});

  @override
  ConsumerState<HandReviewScreen> createState() => _HandReviewScreenState();
}

class _HandReviewScreenState extends ConsumerState<HandReviewScreen> {
  List<HandReviewQuestion>? _questions;
  int _currentIndex = 0;
  bool _revealed = false;
  String? _chosenAction;
  int _correctCount = 0;

  @override
  Widget build(BuildContext context) {
    final handsAsync = ref.watch(userRecentHandsForReviewProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Hand Review',
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: handsAsync.when(
        loading: () => _buildLoading(),
        error: (e, _) => _buildError(e),
        data: (hands) {
          final userId = userAsync.value?.id;
          if (userId == null) {
            return _buildEmpty('Sign in to review your hands.');
          }

          // Extract questions once
          if (_questions == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _questions =
                    HandReviewService.extractQuestions(hands, userId);
              });
            });
            return _buildLoading();
          }

          if (_questions!.isEmpty) {
            return _buildEmpty(
                'No reviewable hands found yet.\nPlay more hands to unlock hand review!');
          }

          if (_currentIndex >= _questions!.length) {
            return _buildSummary();
          }

          final question = _questions![_currentIndex];
          return _buildQuestion(question);
        },
      ),
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Failed to load hands.\n$error',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppColors.error),
        ),
      ),
    );
  }

  // ── Empty ────────────────────────────────────────────────────────────────

  Widget _buildEmpty(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_edu_outlined,
                color: AppColors.onSurfaceVariant, size: 56),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Summary ───────────────────────────────────────────────────────────────

  Widget _buildSummary() {
    final total = _questions!.length;
    final pct =
        total > 0 ? (_correctCount / total * 100).round() : 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Review Complete!',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$_correctCount / $total correct ($pct%)',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                  _correctCount = 0;
                  _revealed = false;
                  _chosenAction = null;
                });
              },
              child: const Text('Restart'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Question Card ─────────────────────────────────────────────────────────

  Widget _buildQuestion(HandReviewQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress
          _buildProgress(),
          const SizedBox(height: 16),

          // Description
          Text(
            question.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Hole cards
          _buildCardSection('Your Hand', question.holeCards),
          const SizedBox(height: 16),

          // Community cards
          if (question.communityCards.isNotEmpty) ...[
            _buildCardSection('Board', question.communityCards),
            const SizedBox(height: 16),
          ],

          // Pot info
          _buildInfoRow('Pot', '\$${question.pot.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildInfoRow(
              'Bet to Call', '\$${question.betToCall.toStringAsFixed(2)}'),
          const SizedBox(height: 28),

          // Action buttons (hidden after reveal)
          if (!_revealed) _buildActionButtons(question),

          // Reveal panel
          if (_revealed) _buildReveal(question),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    final total = _questions!.length;
    final current = _currentIndex + 1;
    return Row(
      children: [
        Text(
          'Hand $current / $total',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: current / total,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardSection(String label, List<CardModel> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: cards
              .map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CardChip(card: c),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(HandReviewQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What should you do?',
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _ActionButton(
              label: 'Fold',
              color: AppColors.error,
              onTap: () => _onAction('Fold', question),
            ),
            const SizedBox(width: 10),
            _ActionButton(
              label: 'Call',
              color: AppColors.primary,
              onTap: () => _onAction('Call', question),
            ),
            const SizedBox(width: 10),
            _ActionButton(
              label: 'Raise',
              color: const Color(0xFFFFB74D),
              onTap: () => _onAction('Raise', question),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReveal(HandReviewQuestion question) {
    final wasCorrect = _chosenAction == question.correctAction;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Correct / incorrect banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: wasCorrect
                ? AppColors.primary.withOpacity(0.12)
                : AppColors.error.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: wasCorrect
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.error.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                wasCorrect ? Icons.check_circle : Icons.cancel,
                color: wasCorrect ? AppColors.primary : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                wasCorrect ? 'Correct!' : 'Incorrect',
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: wasCorrect ? AppColors.primary : AppColors.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // What player did
        _buildInfoRow('You chose', _chosenAction ?? '—'),
        const SizedBox(height: 6),
        _buildInfoRow('Player actually', question.whatPlayerDid),
        const SizedBox(height: 6),
        _buildInfoRow('Recommended', question.correctAction),
        const SizedBox(height: 16),

        // Explanation
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            question.explanation,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Next button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _nextQuestion,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentIndex + 1 < _questions!.length ? 'Next Hand' : 'Finish',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.surface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Logic ────────────────────────────────────────────────────────────────

  Future<void> _onAction(
      String chosen, HandReviewQuestion question) async {
    final wasCorrect = chosen == question.correctAction;
    setState(() {
      _chosenAction = chosen;
      _revealed = true;
      if (wasCorrect) _correctCount++;
    });

    await LearningService.recordDrillResult(
      drillId: 'hand_review',
      correct: wasCorrect,
    );
  }

  void _nextQuestion() {
    setState(() {
      _currentIndex++;
      _revealed = false;
      _chosenAction = null;
    });
  }
}

// ── Small widgets ────────────────────────────────────────────────────────────

class _CardChip extends StatelessWidget {
  final CardModel card;

  const _CardChip({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Center(
        child: Text(
          card.display,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: card.suitColor == Colors.white
                ? const Color(0xFF1A1A1A)
                : card.suitColor,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
