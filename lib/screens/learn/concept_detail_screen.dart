import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/concept_library.dart';
import '../../services/learning_service.dart';
import '../../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category colour helper (duplicated here to avoid coupling to study_tab.dart)
// ─────────────────────────────────────────────────────────────────────────────

Color _categoryColor(ConceptCategory cat) {
  switch (cat) {
    case ConceptCategory.fundamentals:
      return const Color(0xFF54E98A);
    case ConceptCategory.preflop:
      return const Color(0xFF4FC3F7);
    case ConceptCategory.postflop:
      return const Color(0xFFFFB74D);
    case ConceptCategory.math:
      return const Color(0xFFCE93D8);
    case ConceptCategory.psychology:
      return const Color(0xFFF48FB1);
    case ConceptCategory.advanced:
      return const Color(0xFFFF8A65);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ConceptDetailScreen
// ─────────────────────────────────────────────────────────────────────────────

/// Display detailed information about a [PokerConcept].
///
/// The screen can be constructed directly with a [PokerConcept] object, or
/// by passing a [conceptId] string — in which case the concept is resolved
/// from [allConcepts].
class ConceptDetailScreen extends ConsumerStatefulWidget {
  final PokerConcept? concept;
  final String? conceptId;

  const ConceptDetailScreen({
    super.key,
    this.concept,
    this.conceptId,
  }) : assert(
          concept != null || conceptId != null,
          'Either concept or conceptId must be provided.',
        );

  @override
  ConsumerState<ConceptDetailScreen> createState() =>
      _ConceptDetailScreenState();
}

class _ConceptDetailScreenState
    extends ConsumerState<ConceptDetailScreen> {
  bool _isMarkedRead = false;
  bool _isLoading = false;

  late final PokerConcept _concept;

  @override
  void initState() {
    super.initState();
    if (widget.concept != null) {
      _concept = widget.concept!;
    } else {
      _concept = allConcepts.firstWhere(
        (c) => c.id == widget.conceptId,
        orElse: () => allConcepts.first,
      );
    }
  }

  Future<void> _markAsRead() async {
    if (_isMarkedRead || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final xp =
          await LearningService.instance.markConceptRead(_concept.id);
      if (mounted) {
        setState(() {
          _isMarkedRead = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Text(
                  '+$xp XP — Concept marked as read!',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.surfaceContainerHigh,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cat = _concept.category;
    final color = _categoryColor(cat);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.onSurface, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Concept',
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isMarkedRead)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.check_circle,
                  color: AppColors.primary, size: 22),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              _Header(concept: _concept, color: color),

              const SizedBox(height: 24),

              // ── Body text ────────────────────────────────────────────────
              SelectableText(
                _concept.body,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.onSurface,
                  height: 1.7,
                ),
              ),

              const SizedBox(height: 28),

              // ── Key Points ───────────────────────────────────────────────
              _KeyPointsSection(
                keyPoints: _concept.keyPoints,
                color: color,
              ),

              const SizedBox(height: 32),

              // ── Mark as Read button ───────────────────────────────────────
              _MarkAsReadButton(
                isRead: _isMarkedRead,
                isLoading: _isLoading,
                onTap: _markAsRead,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final PokerConcept concept;
  final Color color;

  const _Header({required this.concept, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category chip + difficulty dots on the same row
        Row(
          children: [
            _CategoryChip(category: concept.category, color: color),
            const SizedBox(width: 12),
            _DifficultyDots(difficulty: concept.difficulty),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          concept.title,
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          concept.summary,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final ConceptCategory category;
  final Color color;

  const _CategoryChip({required this.category, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        category.label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _DifficultyDots extends StatelessWidget {
  final int difficulty;
  const _DifficultyDots({required this.difficulty});

  String get _label {
    switch (difficulty) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Intermediate';
      default:
        return 'Advanced';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(3, (i) {
          final filled = i < difficulty;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled
                    ? AppColors.primary
                    : AppColors.outlineVariant,
              ),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text(
          _label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _KeyPointsSection extends StatelessWidget {
  final List<String> keyPoints;
  final Color color;

  const _KeyPointsSection({
    required this.keyPoints,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                'Key Points',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...keyPoints.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        height: 1.5,
                      ),
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

class _MarkAsReadButton extends StatelessWidget {
  final bool isRead;
  final bool isLoading;
  final VoidCallback onTap;

  const _MarkAsReadButton({
    required this.isRead,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: isRead
            ? Container(
                key: const ValueKey('read'),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: AppColors.primary.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Marked as Read',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              )
            : GestureDetector(
                key: const ValueKey('unread'),
                onTap: isLoading ? null : onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: isLoading
                        ? const [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ]
                        : [
                            const Icon(Icons.check,
                                color: AppColors.onPrimary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Mark as Read  +5 XP',
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ],
                  ),
                ),
              ),
      ),
    );
  }
}
