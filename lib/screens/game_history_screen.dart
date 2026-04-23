import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../providers/providers.dart';
import '../models/hand_model.dart';
import '../models/card_model.dart';
import '../models/hand_action_model.dart';
import '../services/firestore_service.dart';

class GameHistoryScreen extends ConsumerWidget {
  const GameHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handsAsync = ref.watch(activeGameHandsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
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
                      Text('HISTORY',
                          style: GoogleFonts.manrope(
                            fontSize: 26, fontWeight: FontWeight.w800,
                            color: AppColors.onSurface, letterSpacing: 3,
                          )),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune, color: AppColors.onSurfaceVariant),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Recent Hands',
                  style: GoogleFonts.inter(
                    fontSize: 13, color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  )),
              const SizedBox(height: 20),
              Expanded(
                child: handsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, _) => Center(
                    child: Text('Error loading history',
                        style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
                  ),
                  data: (hands) {
                    if (hands.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history, size: 48,
                                color: AppColors.onSurfaceVariant.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text('No hands played yet',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.onSurfaceVariant,
                                )),
                            const SizedBox(height: 6),
                            Text('Start a session to record hand history',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant.withOpacity(0.6),
                                )),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: hands.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _HandCard(hand: hands[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HandCard extends ConsumerStatefulWidget {
  final HandModel hand;
  const _HandCard({required this.hand});

  @override
  ConsumerState<_HandCard> createState() => _HandCardState();
}

class _HandCardState extends ConsumerState<_HandCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _heartController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _heartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _heartController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _heartController.dispose();
    super.dispose();
  }

  void _onHeartTap(String myUid) {
    _heartController.forward(from: 0);
    FirestoreService.toggleFavoriteHand(widget.hand.gameId, widget.hand.id, myUid);
  }

  @override
  Widget build(BuildContext context) {
    final hand = widget.hand;
    final myUid = ref.watch(currentUserProvider).value?.id ?? '';
    final myCards = widget.hand.playerCards[myUid] ?? [];
    final isPublished = widget.hand.revealedPlayerIds.contains(myUid);
    final isFavorited = widget.hand.favoritedBy.contains(myUid);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: isFavorited
            ? Border.all(color: Colors.amber, width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collapsed summary (always visible)
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hand #${hand.handNumber}',
                          style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant, letterSpacing: 0.8,
                          )),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 12, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(hand.timeAgo,
                              style: GoogleFonts.inter(
                                fontSize: 11, color: AppColors.onSurfaceVariant,
                              )),
                          const SizedBox(width: 4),
                          ScaleTransition(
                            scale: _heartScale,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              icon: Icon(
                                isFavorited ? Icons.favorite : Icons.favorite_border,
                                size: 18,
                                color: isFavorited ? Colors.amber : AppColors.onSurfaceVariant,
                              ),
                              onPressed: myUid.isNotEmpty ? () => _onHeartTap(myUid) : null,
                            ),
                          ),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: _expanded ? 0.5 : 0.0,
                            duration: const Duration(milliseconds: 250),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(hand.winnerUsername,
                              style: GoogleFonts.manrope(
                                fontSize: 16, fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              )),
                          Text(hand.handRank,
                              style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.onSurfaceVariant,
                              )),
                        ],
                      ),
                      Text('€${hand.potAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.manrope(
                            fontSize: 22, fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          )),
                    ],
                  ),
                  if (hand.communityCards.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: hand.communityCards.map((card) => _CardChip(card: card)).toList(),
                    ),
                  ],
                  // Own cards — always visible to the player themselves
                  if (myCards.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text('Your cards  ',
                            style: GoogleFonts.inter(
                              fontSize: 11, color: AppColors.onSurfaceVariant,
                            )),
                        ...myCards.map((card) => _CardChip(card: card)),
                      ],
                    ),
                  ],
                  // Other players' revealed cards (showdown or voluntarily shown)
                  for (final entry in hand.playerCards.entries)
                    if (entry.key != myUid && hand.revealedPlayerIds.contains(entry.key)) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text('${hand.playerNames[entry.key] ?? entry.key}  ',
                              style: GoogleFonts.inter(
                                fontSize: 11, color: AppColors.onSurfaceVariant,
                              )),
                          ...entry.value.map((card) => _CardChip(card: card)),
                        ],
                      ),
                    ],
                  // Publish button — shown when own cards exist but aren't yet public
                  if (myCards.isNotEmpty && !isPublished) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => FirestoreService.revealHand(hand.gameId, hand.id, myUid),
                      child: Text('Publish Hand',
                          style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          )),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Expanded section with smooth animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _expanded
                ? _ExpandedSection(hand: hand, myUid: myUid)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ExpandedSection extends StatelessWidget {
  final HandModel hand;
  final String myUid;

  const _ExpandedSection({required this.hand, required this.myUid});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(
          height: 1,
          color: AppColors.outlineVariant,
          indent: 16,
          endIndent: 16,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Duration chip
              if (hand.handDurationSeconds != null) ...[
                _DurationChip(seconds: hand.handDurationSeconds!),
                const SizedBox(height: 12),
              ],

              // Action timeline
              if (hand.actions.isNotEmpty) ...[
                _ActionTimeline(actions: hand.actions),
                const SizedBox(height: 12),
              ] else ...[
                Text(
                  'No action log available',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Win condition banner
              _WinConditionBanner(hand: hand),
            ],
          ),
        ),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  final int seconds;
  const _DurationChip({required this.seconds});

  String get _formatted {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m == 0) return '${s}s';
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '\u23f1 $_formatted',
        style: GoogleFonts.inter(
          fontSize: 11,
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionTimeline extends StatelessWidget {
  final List<HandActionModel> actions;
  const _ActionTimeline({required this.actions});

  static const _roundOrder = ['preflop', 'flop', 'turn', 'river'];
  static const _roundLabels = {
    'preflop': 'Pre-Flop',
    'flop': 'Flop',
    'turn': 'Turn',
    'river': 'River',
  };

  Color _actionColor(ActionType type) {
    switch (type) {
      case ActionType.fold:
        return const Color(0xFF757575); // grey[600]
      case ActionType.raise:
      case ActionType.allIn:
      case ActionType.bet:
        return Colors.amber;
      case ActionType.call:
      case ActionType.check:
      case ActionType.blind:
        return Colors.white70;
    }
  }

  String _actionLabel(HandActionModel action) {
    switch (action.actionType) {
      case ActionType.fold:
        return 'Fold';
      case ActionType.raise:
        return action.amount != null
            ? 'Raise \u20ac${action.amount!.toStringAsFixed(2)}'
            : 'Raise';
      case ActionType.call:
        return action.amount != null
            ? 'Call \u20ac${action.amount!.toStringAsFixed(2)}'
            : 'Call';
      case ActionType.check:
        return 'Check';
      case ActionType.allIn:
        return action.amount != null
            ? 'All-In \u20ac${action.amount!.toStringAsFixed(2)}'
            : 'All-In';
      case ActionType.bet:
        return action.amount != null
            ? 'Bet \u20ac${action.amount!.toStringAsFixed(2)}'
            : 'Bet';
      case ActionType.blind:
        return action.amount != null
            ? 'Blind \u20ac${action.amount!.toStringAsFixed(2)}'
            : 'Blind';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Group actions by betting round, preserving standard order
    final grouped = <String, List<HandActionModel>>{};
    for (final round in _roundOrder) {
      final roundActions = actions.where((a) => a.bettingRound == round).toList();
      if (roundActions.isNotEmpty) {
        grouped[round] = roundActions;
      }
    }
    // Handle any non-standard rounds
    for (final action in actions) {
      if (!_roundOrder.contains(action.bettingRound)) {
        grouped.putIfAbsent(action.bettingRound, () => []).add(action);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Action Log',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        for (final entry in grouped.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Text(
              _roundLabels[entry.key] ?? entry.key.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary.withOpacity(0.8),
                letterSpacing: 1.2,
              ),
            ),
          ),
          for (final action in entry.value)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      action.playerName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _actionLabel(action),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _actionColor(action.actionType),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _WinConditionBanner extends StatelessWidget {
  final HandModel hand;

  const _WinConditionBanner({required this.hand});

  @override
  Widget build(BuildContext context) {
    final isShowdown = hand.wasShowdown;
    final condition = hand.winCondition;

    String bannerText;
    if (condition != null && condition.isNotEmpty) {
      bannerText = condition;
    } else if (isShowdown) {
      bannerText = 'Won at showdown with ${hand.handRank}';
    } else {
      bannerText = 'Won uncontested \u2014 everyone folded';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  bannerText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Show all revealed hole cards side by side at showdown
        if (isShowdown && hand.revealedPlayerIds.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Showdown Cards',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          for (final uid in hand.revealedPlayerIds)
            if (hand.playerCards[uid] != null && hand.playerCards[uid]!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      '${hand.playerNames[uid] ?? uid}  ',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    ...hand.playerCards[uid]!.map((card) => _CardChip(card: card)),
                  ],
                ),
              ),
        ],
      ],
    );
  }
}

class _CardChip extends StatelessWidget {
  final CardModel card;
  const _CardChip({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(card.display,
          style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: card.isRed ? const Color(0xFFE57373) : AppColors.onSurface,
            fontFamily: 'monospace',
          )),
    );
  }
}
