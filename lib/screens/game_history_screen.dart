import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../providers/providers.dart';
import '../models/hand_model.dart';
import '../models/card_model.dart';
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

class _HandCard extends ConsumerWidget {
  final HandModel hand;
  const _HandCard({required this.hand});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUid = ref.watch(currentUserProvider).value?.id ?? '';
    final myCards = hand.playerCards[myUid] ?? [];
    final isPublished = hand.revealedPlayerIds.contains(myUid);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
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
