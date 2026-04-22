import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/scanner_status_badge.dart';
import '../widgets/gradient_button.dart';
import '../providers/providers.dart';
import '../services/firestore_service.dart';
import '../services/bot_service.dart';
import '../services/scanner_service.dart';
import '../models/card_model.dart';
import '../models/game_model.dart';

class PokerTableScreen extends ConsumerStatefulWidget {
  const PokerTableScreen({super.key});

  @override
  ConsumerState<PokerTableScreen> createState() => _PokerTableScreenState();
}

class _PokerTableScreenState extends ConsumerState<PokerTableScreen> {
  double _betAmount = 0.25;
  Timer? _subtractTimer;
  final _botService = BotService();

  void _startSubtractingBet(double amount, double minBet, double maxBet) {
    _subtractTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() => _betAmount = (_betAmount - amount).clamp(minBet, maxBet));
    });
  }

  void _stopSubtractingBet() {
    _subtractTimer?.cancel();
    _subtractTimer = null;
  }

  @override
  void dispose() {
    _subtractTimer?.cancel();
    _botService.dispose();
    super.dispose();
  }

  Future<void> _check(GameModel game, String uid) async {
    await FirestoreService.playerCheck(game.id, game, uid);
  }

  Future<void> _call(GameModel game, String uid) async {
    await FirestoreService.playerCall(game.id, game, uid);
  }

  Future<void> _fold(GameModel game, String uid) async {
    await FirestoreService.playerFold(game.id, game, uid);
  }

  Future<void> _bet(GameModel game, String uid) async {
    await FirestoreService.playerBet(game.id, game, uid, _betAmount);
  }

  void _showEditStackDialog(BuildContext context, GameModel game, String uid, double currentStack) {
    showDialog(
      context: context,
      builder: (ctx) => _EditStackDialog(
        currentStack: currentStack,
        onSave: (newStack) async {
          Navigator.pop(ctx);
          await FirestoreService.updatePlayerStack(game.id, uid, newStack);
        },
      ),
    );
  }

  void _showCreateTableDialog(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (ctx) => _CreateTableDialog(
        onTableCreated: () {
          Navigator.pop(ctx);
          context.go('/table');
        },
        userId: user.id,
        username: user.username,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(activeGameProvider);
    final userAsync = ref.watch(currentUserProvider);

    final game = gameAsync.value;
    final user = userAsync.value;

    // Drive bot actions whenever the game state changes
    ref.listen(activeGameProvider, (_, next) {
      if (user != null) _botService.onGameUpdate(next.value, user.id);
    });

    if (game == null || user == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TABLE',
                  style: GoogleFonts.manrope(
                    fontSize: 26, fontWeight: FontWeight.w800,
                    color: AppColors.onSurface, letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.table_restaurant_outlined,
                          size: 64,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No tables found',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 22, fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a table to get started',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GradientButton(
                  label: 'CREATE A NEW TABLE',
                  icon: Icons.add,
                  onPressed: () => _showCreateTableDialog(context, user),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isMyTurn = game.currentTurnPlayerId == user.id;
    final hasFolded = game.foldedPlayers.contains(user.id);
    final maxBet = (game.playerStacks[user.id] ?? 100.0);
    final highBet = game.playerBets.values.fold<double>(0, (a, b) => a > b ? a : b);
    final myBet = game.playerBets[user.id] ?? 0;
    final callAmount = (highBet - myBet).clamp(0, maxBet);
    final isFacingBet = callAmount > 0;
    final minRaiseAmount = isFacingBet ? (highBet * 2 - myBet).clamp(0, maxBet) : game.bigBlind;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.name.toUpperCase(),
                        style: GoogleFonts.manrope(
                          fontSize: 20, fontWeight: FontWeight.w800,
                          color: AppColors.onSurface, letterSpacing: 2,
                        ),
                      ),
                      const ScannerStatusBadge(),
                    ],
                  ),
                  Row(
                    children: [
                      // Add Bot button (host only, max 4 bots)
                      if (game.hostId == user.id) ...[
                        Builder(builder: (context) {
                          final botCount = game.playerIds
                              .where(BotService.isBot)
                              .length;
                          final allBotIds = BotService.availableBots.keys.toList();
                          final nextBotId = allBotIds.firstWhere(
                            (id) => !game.playerIds.contains(id),
                            orElse: () => '',
                          );
                          if (nextBotId.isEmpty) return const SizedBox.shrink();
                          return GestureDetector(
                            onTap: () => FirestoreService.addBotPlayer(
                              game.id,
                              nextBotId,
                              BotService.availableBots[nextBotId]!,
                            ),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.smart_toy_outlined,
                                      size: 15, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 5),
                                  Text('+ Bot ($botCount)',
                                      style: GoogleFonts.inter(
                                        fontSize: 12, fontWeight: FontWeight.w600,
                                        color: AppColors.onSurfaceVariant,
                                      )),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people_outline,
                                size: 16, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 6),
                            Text('${game.playerCount}/${game.maxPlayers}',
                                style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w600,
                                  color: AppColors.onSurfaceVariant,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Table Info
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TABLE INFO',
                            style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: AppColors.onSurfaceVariant, letterSpacing: 0.8,
                            )),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(game.roundLabel,
                              style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w600,
                                color: AppColors.onSecondaryContainer,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // 5 community card placeholders
                        Expanded(
                          child: Row(
                            children: List.generate(5, (i) {
                              final card = i < game.communityCards.length
                                  ? game.communityCards[i]
                                  : null;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: card != null
                                    ? _CommunityCard(card: card)
                                    : Container(
                                        width: 44, height: 60,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceContainerHigh,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: AppColors.outlineVariant
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                      ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Pot amount
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('POT',
                                style: GoogleFonts.inter(
                                  fontSize: 10, fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant, letterSpacing: 0.8,
                                )),
                            Text('€${game.pot.toStringAsFixed(2)}',
                                style: GoogleFonts.manrope(
                                  fontSize: 28, fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                )),
                          ],
                        ),
                      ],
                    ),
                    if (isMyTurn && !hasFolded)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('Your turn',
                              style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              )),
                        ),
                      ),
                    if (hasFolded)
                      Builder(builder: (context) {
                        final activePlayers = game.playerIds
                            .where((id) => !game.foldedPlayers.contains(id))
                            .length;
                        final roundActive = activePlayers > 1;
                        final handShown = game.shownHandPlayerIds.contains(user.id);
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Center(
                            child: GestureDetector(
                              onTap: handShown
                                  ? null
                                  : () async {
                                      await FirestoreService.showHandInGame(
                                          game.id, user.id);
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: (handShown || roundActive)
                                      ? AppColors.surfaceContainerHigh
                                      : AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: (handShown || roundActive)
                                        ? AppColors.outlineVariant.withValues(alpha: 0.3)
                                        : AppColors.primary.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      handShown
                                          ? Icons.check_circle_outline
                                          : roundActive
                                              ? Icons.hourglass_empty
                                              : Icons.visibility,
                                      size: 14,
                                      color: (handShown || roundActive)
                                          ? AppColors.onSurfaceVariant
                                          : AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      handShown
                                          ? 'Hand Shown'
                                          : roundActive
                                              ? 'Show Hand After Round'
                                              : 'Show Hand',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: (handShown || roundActive)
                                            ? AppColors.onSurfaceVariant
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Scanner / Card Assignment Panel (host only) ──────────────
              if (game.hostId == user.id)
                _ScannerPanel(game: game),

              const SizedBox(height: 24),

              // Actions
              if (!hasFolded && isMyTurn) ...[
                Text('Actions',
                    style: GoogleFonts.manrope(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    )),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => isFacingBet
                            ? _call(game, user.id)
                            : _check(game, user.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                                isFacingBet
                                    ? 'CALL €${callAmount.toStringAsFixed(2)}'
                                    : 'CHECK',
                                style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface, letterSpacing: 0.8,
                                )),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _fold(game, user.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text('FOLD',
                                style: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                  color: AppColors.onSurfaceVariant,
                                  letterSpacing: 0.8,
                                )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Stack Management
                GestureDetector(
                  onTap: () => _showEditStackDialog(context, game, user.id, maxBet),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your Stack',
                                style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w500,
                                  color: AppColors.onSurfaceVariant, letterSpacing: 0.8,
                                )),
                            const SizedBox(height: 4),
                            Text('€${maxBet.toStringAsFixed(2)}',
                                style: GoogleFonts.manrope(
                                  fontSize: 28, fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                )),
                          ],
                        ),
                        const Spacer(),
                        Icon(Icons.edit_outlined, size: 18, color: AppColors.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Place Bet / Raise
                Text(isFacingBet ? 'Raise' : 'Place Bet',
                    style: GoogleFonts.manrope(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    )),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('Min: €${minRaiseAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.onSurfaceVariant,
                        )),
                    const Spacer(),
                    Text('€${_betAmount.clamp(minRaiseAmount, maxBet).toStringAsFixed(2)}',
                        style: GoogleFonts.manrope(
                          fontSize: 20, fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final amount in [0.05, 0.10, 0.25, 1.00])
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _betAmount = (_betAmount + amount).clamp(minRaiseAmount, maxBet).toDouble()),
                          onLongPressStart: (_) => _startSubtractingBet(amount, minRaiseAmount.toDouble(), maxBet),
                          onLongPressEnd: (_) => _stopSubtractingBet(),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text('+€${amount.toStringAsFixed(2)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11, fontWeight: FontWeight.w600,
                                    color: AppColors.onSurfaceVariant,
                                  )),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _bet(game, user.id),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('BET  €${_betAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w800,
                            color: AppColors.onPrimary, letterSpacing: 1.5,
                          )),
                    ),
                  ),
                ),
              ] else if (!isMyTurn && !hasFolded)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Waiting for ${game.playerNames[game.currentTurnPlayerId] ?? "opponent"}...',
                        style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scanner / Card-Assignment Panel  (shown to the host only)
// ─────────────────────────────────────────────────────────────────────────────

/// Displays the live scanner state and lets the host route scanned (or
/// manually-entered) cards into the correct destination:
///
///  * Pre-flop  → hole hands (host selects target player)
///  * Flop/Turn/River → community cards (appended automatically)
///
/// When the scanner is offline a manual card-entry fallback is shown.
class _ScannerPanel extends ConsumerStatefulWidget {
  final GameModel game;
  const _ScannerPanel({required this.game});

  @override
  ConsumerState<_ScannerPanel> createState() => _ScannerPanelState();
}

class _ScannerPanelState extends ConsumerState<_ScannerPanel> {
  String? _selectedPlayerId;

  // ─── Manual entry ──────────────────────────────────────────────────────────

  void _showManualEntryDialog() {
    showDialog(
      context: context,
      builder: (_) => _ManualCardEntryDialog(
        onCard: (card) {
          Navigator.pop(context);
          _routeCard(card);
        },
      ),
    );
  }

  // ─── Routing ───────────────────────────────────────────────────────────────

  Future<void> _routeCard(CardModel card) async {
    final game = widget.game;
    if (game.currentRound == BettingRound.preflop) {
      final targetId = _selectedPlayerId;
      if (targetId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Select a player to assign the hole card to')),
          );
        }
        return;
      }
      await FirestoreService.assignHoleCard(game.id, game, targetId, card);
    } else {
      await FirestoreService.assignCommunityCard(game.id, game, card);
    }

    // Consume the pending card from the scanner queue
    ref.read(scannerServiceProvider.notifier).consumePending();
  }

  // ─── Simulated scan trigger (demo helper for host) ─────────────────────────

  /// Injects the next pending card from the scanner service into the game.
  Future<void> _consumeNextPending() async {
    final scanner = ref.read(scannerServiceProvider);
    if (scanner.pendingCards.isEmpty) return;
    await _routeCard(scanner.pendingCards.first);
  }

  @override
  Widget build(BuildContext context) {
    final scanner = ref.watch(scannerServiceProvider);
    final game = widget.game;
    final isPreflop = game.currentRound == BettingRound.preflop;
    final humanPlayers = game.playerIds
        .where((id) => !BotService.isBot(id))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scanner.isOnline
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(
                Icons.contactless_outlined,
                size: 16,
                color: scanner.isOnline
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'CARD SCANNER',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              // Toggle scanner online/offline (demo)
              GestureDetector(
                onTap: () => ref
                    .read(scannerServiceProvider.notifier)
                    .setOnline(!scanner.isOnline),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scanner.isOnline
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: scanner.isOnline
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : AppColors.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    scanner.isOnline ? 'Online' : 'Offline',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: scanner.isOnline
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Pending scanned cards queue
          if (scanner.pendingCards.isNotEmpty) ...[
            Text(
              'Pending',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: scanner.pendingCards.take(5).map((card) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _MiniCard(card: card),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          // Pre-flop: player selector
          if (isPreflop) ...[
            Text(
              'Assign hole card to:',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: humanPlayers.map((pid) {
                final name =
                    game.playerNames[pid] ?? pid.substring(0, 6);
                final isSelected = _selectedPlayerId == pid;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedPlayerId = pid),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.outlineVariant
                                .withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],

          // Action row: assign pending card + manual entry
          Row(
            children: [
              if (scanner.pendingCards.isNotEmpty)
                Expanded(
                  child: GestureDetector(
                    onTap: _consumeNextPending,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryContainer
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          isPreflop
                              ? 'ASSIGN HOLE CARD'
                              : 'PLACE ON BOARD',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (scanner.pendingCards.isNotEmpty)
                const SizedBox(width: 10),
              // Manual entry fallback (always available)
              Expanded(
                child: GestureDetector(
                  onTap: _showManualEntryDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color:
                            AppColors.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_outlined,
                              size: 13, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 5),
                          Text(
                            scanner.isOnline
                                ? 'MANUAL ENTRY'
                                : 'ENTER CARD',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (!scanner.isOnline) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.info_outline,
                    size: 13,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(
                  'Scanner offline — use manual entry to add cards',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color:
                        AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small card chip widget used in the pending-cards list
// ─────────────────────────────────────────────────────────────────────────────

class _MiniCard extends StatelessWidget {
  final CardModel card;
  const _MiniCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              card.rank,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
                height: 1.0,
              ),
            ),
            Center(
              child: Text(
                card.suitSymbol,
                style: TextStyle(
                  fontSize: 14,
                  color: card.suitColor,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Manual card entry dialog  (offline fallback)
// ─────────────────────────────────────────────────────────────────────────────

class _ManualCardEntryDialog extends StatefulWidget {
  final void Function(CardModel) onCard;
  const _ManualCardEntryDialog({required this.onCard});

  @override
  State<_ManualCardEntryDialog> createState() => _ManualCardEntryDialogState();
}

class _ManualCardEntryDialogState extends State<_ManualCardEntryDialog> {
  static const _ranks = [
    '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'
  ];
  static const _suits = ['s', 'h', 'd', 'c'];
  static const _suitLabels = {'s': '♠', 'h': '♥', 'd': '♦', 'c': '♣'};

  String? _rank;
  String? _suit;

  @override
  Widget build(BuildContext context) {
    final canSubmit = _rank != null && _suit != null;

    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Card Manually',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 20),

            // Rank picker
            Text('Rank',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _ranks.map((r) {
                final selected = _rank == r;
                return GestureDetector(
                  onTap: () => setState(() => _rank = r),
                  child: Container(
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        r,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? AppColors.primary
                              : AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Suit picker
            Text('Suit',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 8),
            Row(
              children: _suits.map((s) {
                final selected = _suit == s;
                final isRed = s == 'h' || s == 'd';
                final suitColor = isRed
                    ? const Color(0xFFE57373)
                    : AppColors.onSurface;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _suit = s),
                    child: Container(
                      width: 52,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? suitColor.withValues(alpha: 0.12)
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? suitColor.withValues(alpha: 0.5)
                              : AppColors.outlineVariant.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _suitLabels[s]!,
                          style: TextStyle(
                            fontSize: 20,
                            color: selected ? suitColor : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        )),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: canSubmit
                        ? () => widget.onCard(
                            CardModel(rank: _rank!, suit: _suit!))
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Add Card',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditStackDialog extends StatefulWidget {
  final double currentStack;
  final Future<void> Function(double) onSave;

  const _EditStackDialog({required this.currentStack, required this.onSave});

  @override
  State<_EditStackDialog> createState() => _EditStackDialogState();
}

class _EditStackDialogState extends State<_EditStackDialog> {
  late double _pendingStack;
  bool _isAdding = true;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pendingStack = widget.currentStack;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    final parsed = double.tryParse(value) ?? 0.0;
    setState(() {
      _pendingStack = (_isAdding
              ? widget.currentStack + parsed
              : widget.currentStack - parsed)
          .clamp(0.0, double.infinity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final diff = _pendingStack - widget.currentStack;
    final diffText = diff == 0
        ? 'No change'
        : '${diff > 0 ? '+' : ''}€${diff.toStringAsFixed(2)}';
    final diffColor = diff > 0
        ? AppColors.primary
        : diff < 0
            ? Colors.redAccent
            : AppColors.onSurfaceVariant;

    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Edit Stack',
                style: GoogleFonts.manrope(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                )),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current',
                        style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.onSurfaceVariant,
                        )),
                    Text('€${widget.currentStack.toStringAsFixed(2)}',
                        style: GoogleFonts.manrope(
                          fontSize: 22, fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        )),
                  ],
                ),
                Icon(Icons.arrow_forward, size: 18, color: AppColors.onSurfaceVariant),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('New',
                        style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.onSurfaceVariant,
                        )),
                    Text('€${_pendingStack.toStringAsFixed(2)}',
                        style: GoogleFonts.manrope(
                          fontSize: 22, fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(diffText,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w600,
                  color: diffColor,
                )),
            const SizedBox(height: 20),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() { _isAdding = !_isAdding; });
                    _onAmountChanged(_controller.text);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: _isAdding
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isAdding
                            ? AppColors.primary.withValues(alpha: 0.4)
                            : Colors.redAccent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _isAdding ? 'Add' : 'Remove',
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: _isAdding ? AppColors.primary : Colors.redAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.manrope(
                      fontSize: 16, fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      prefixText: '€ ',
                      prefixStyle: GoogleFonts.inter(
                        fontSize: 14, color: AppColors.onSurfaceVariant,
                      ),
                      hintText: '0.00',
                      hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                      filled: true,
                      fillColor: AppColors.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    onChanged: _onAmountChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text('Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        )),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onSave(_pendingStack),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Save',
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CardModel card;
  const _CommunityCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 60,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(card.rank,
                style: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700,
                  color: AppColors.onSurface, height: 1.0,
                )),
            Center(
              child: Text(card.suitSymbol,
                  style: TextStyle(fontSize: 18, color: card.suitColor, height: 1.0)),
            ),
          ],
        ),
      ),
    );
  }
}

enum _CreateTableStep { form, connecting, connected }

class _CreateTableDialog extends StatefulWidget {
  final VoidCallback onTableCreated;
  final String userId;
  final String username;

  const _CreateTableDialog({
    required this.onTableCreated,
    required this.userId,
    required this.username,
  });

  @override
  State<_CreateTableDialog> createState() => _CreateTableDialogState();
}

class _CreateTableDialogState extends State<_CreateTableDialog> {
  final _nameController = TextEditingController();
  final _scannerIdController = TextEditingController();
  _CreateTableStep _step = _CreateTableStep.form;
  bool _connecting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _scannerIdController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a table name')),
      );
      return;
    }
    if (_scannerIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a scanner ID')),
      );
      return;
    }

    setState(() {
      _step = _CreateTableStep.connecting;
      _connecting = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _step = _CreateTableStep.connected;
        _connecting = false;
      });
    }
  }

  Future<void> _createTable() async {
    try {
      await FirestoreService.createGame(
        hostId: widget.userId,
        hostUsername: widget.username,
        name: _nameController.text.trim(),
      );
      if (mounted) {
        widget.onTableCreated();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create table: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_step == _CreateTableStep.form) ...[
              Text(
                'CREATE A NEW TABLE',
                style: GoogleFonts.manrope(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                style: GoogleFonts.inter(color: AppColors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Table name',
                  prefixIcon: const Icon(Icons.table_restaurant, color: AppColors.onSurfaceVariant),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _scannerIdController,
                style: GoogleFonts.inter(color: AppColors.onSurface),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Flop scanner ID',
                  prefixIcon: const Icon(Icons.bluetooth, color: AppColors.onSurfaceVariant),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _connecting ? null : _connect,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'SCAN & CONNECT',
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700,
                          color: AppColors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (_step == _CreateTableStep.connecting) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 20),
              Text(
                'Connecting to Scanner #${_scannerIdController.text}...',
                style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ] else ...[
              const SizedBox(height: 12),
              Icon(
                Icons.check_circle,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Connected',
                style: GoogleFonts.manrope(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scanner #${_scannerIdController.text}',
                style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _createTable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'CREATE TABLE',
                  style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w700,
                    color: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
