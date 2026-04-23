import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../data/concept_library.dart';
import '../../providers/learning_progress_provider.dart';
import '../../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category colours
// ─────────────────────────────────────────────────────────────────────────────

Color _categoryColor(ConceptCategory cat) {
  switch (cat) {
    case ConceptCategory.fundamentals:
      return const Color(0xFF54E98A); // primary green
    case ConceptCategory.preflop:
      return const Color(0xFF4FC3F7); // light blue
    case ConceptCategory.postflop:
      return const Color(0xFFFFB74D); // amber
    case ConceptCategory.math:
      return const Color(0xFFCE93D8); // purple
    case ConceptCategory.psychology:
      return const Color(0xFFF48FB1); // pink
    case ConceptCategory.advanced:
      return const Color(0xFFFF8A65); // orange
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State providers (local, scoped to the StudyTab)
// ─────────────────────────────────────────────────────────────────────────────

final _searchQueryProvider = StateProvider<String>((_) => '');
final _selectedCategoryProvider =
    StateProvider<ConceptCategory?>((_) => null);

// ─────────────────────────────────────────────────────────────────────────────
// StudyTab
// ─────────────────────────────────────────────────────────────────────────────

class StudyTab extends ConsumerWidget {
  const StudyTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(_searchQueryProvider);
    final selectedCat = ref.watch(_selectedCategoryProvider);
    final readIdsAsync = ref.watch(readConceptIdsProvider);
    final readIds = readIdsAsync.value ?? {};

    // Filtered concepts
    final filtered = allConcepts.where((c) {
      final matchesCat =
          selectedCat == null || c.category == selectedCat;
      final q = query.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          c.title.toLowerCase().contains(q) ||
          c.summary.toLowerCase().contains(q);
      return matchesCat && matchesSearch;
    }).toList();

    // Group by category
    final grouped = <ConceptCategory, List<PokerConcept>>{};
    for (final concept in filtered) {
      grouped.putIfAbsent(concept.category, () => []).add(concept);
    }

    return Column(
      children: [
        // ── Search bar ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _SearchBar(
            onChanged: (v) =>
                ref.read(_searchQueryProvider.notifier).state = v,
          ),
        ),

        // ── Category filter chips ──────────────────────────────────────────
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _CategoryChip(
                label: 'All',
                selected: selectedCat == null,
                color: AppColors.primary,
                onTap: () =>
                    ref.read(_selectedCategoryProvider.notifier).state = null,
              ),
              ...ConceptCategory.values.map(
                (cat) => _CategoryChip(
                  label: cat.label,
                  selected: selectedCat == cat,
                  color: _categoryColor(cat),
                  onTap: () => ref
                      .read(_selectedCategoryProvider.notifier)
                      .state =
                      selectedCat == cat ? null : cat,
                ),
              ),
            ],
          ),
        ),

        // ── Concept list ───────────────────────────────────────────────────
        Expanded(
          child: filtered.isEmpty
              ? _EmptyState(query: query)
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 32),
                  itemCount: _listItemCount(grouped),
                  itemBuilder: (context, index) {
                    return _buildListItem(
                      context,
                      index,
                      grouped,
                      readIds,
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Compute total item count (headers + concepts)
  int _listItemCount(Map<ConceptCategory, List<PokerConcept>> grouped) {
    int count = 0;
    for (final entry in grouped.entries) {
      count += 1 + entry.value.length; // 1 header + N cards
    }
    return count;
  }

  // Build header or concept card based on flattened index
  Widget _buildListItem(
    BuildContext context,
    int index,
    Map<ConceptCategory, List<PokerConcept>> grouped,
    Set<String> readIds,
  ) {
    int current = 0;
    for (final entry in grouped.entries) {
      if (index == current) {
        return _SectionHeader(category: entry.key);
      }
      current++;
      final concepts = entry.value;
      if (index < current + concepts.length) {
        final concept = concepts[index - current];
        return _ConceptCard(
          concept: concept,
          isRead: readIds.contains(concept.id),
          onTap: () => context.push('/learn/concept/${concept.id}'),
        );
      }
      current += concepts.length;
    }
    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search concepts…',
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.onSurfaceVariant,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.surface : AppColors.onSurfaceVariant,
          ),
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: color,
        backgroundColor: AppColors.surfaceContainerHigh,
        side: BorderSide(
          color: selected ? color : AppColors.outlineVariant,
          width: 1,
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final ConceptCategory category;
  const _SectionHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: _categoryColor(category),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category.label.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _categoryColor(category),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConceptCard extends StatelessWidget {
  final PokerConcept concept;
  final bool isRead;
  final VoidCallback onTap;

  const _ConceptCard({
    required this.concept,
    required this.isRead,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(concept.category);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(color: color, width: 3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            concept.title,
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (isRead)
                          const Padding(
                            padding: EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      concept.summary,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _DifficultyDots(difficulty: concept.difficulty),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyDots extends StatelessWidget {
  final int difficulty;
  const _DifficultyDots({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off,
              size: 48, color: AppColors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            query.isEmpty
                ? 'No concepts in this category'
                : 'No concepts match "$query"',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
