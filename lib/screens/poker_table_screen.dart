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
import '../services/ble_service.dart';
import '../models/card_model.dart';
import '../models/game_model.dart';
import 'table_setup_sheet.dart';
import 'connect_deck_sheet.dart';

class PokerTableScreen extends ConsumerStatefulWidget {
  const PokerTableScreen({super.key});

  @override
  ConsumerState<PokerTableScreen> createState() => _PokerTableScreenState();
}

class _PokerTableScreenState extends ConsumerState<PokerTableScreen> {
  final _botService = BotService();

  @override
  void dispose() {
    _botService.dispose();
    super.dispose();
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
    final myStack = game.playerStacks[user.id] ?? 100.0;
    final highBet = game.playerBets.values.fold<double>(0, (a, b) => a > b ? a : b);
    final myBet = game.playerBets[user.id] ?? 0;
    final callAmount = (highBet - myBet).clamp(0.0, myStack);
    final isFacingBet = callAmount > 0;
    final minRaiseAmount = (isFacingBet ? (highBet * 2 - myBet) : game.bigBlind).clamp(0.0, myStack);
    final showActionBar = !game.handOver && !hasFolded && isMyTurn;
    final showNewHandBar = game.handOver && game.hostId == user.id && game.deckId != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                      // Table setup button (host only)
                      if (game.hostId == user.id)
                        GestureDetector(
                          onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => TableSetupSheet(game: game),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.table_restaurant_outlined,
                                size: 18, color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      GestureDetector(
                        onTap: () => context.push('/invite-friends'),
                        child: Container(
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
                          child: FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Row(
                              children: List.generate(5, (i) {
                                final card = i < game.communityCards.length
                                    ? game.communityCards[i]
                                    : null;
                                return Padding(
                                  padding: EdgeInsets.only(right: i < 4 ? 6 : 0),
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
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Your Hand ─────────────────────────────────────────────────
              _MyHandPanel(game: game, userId: user.id),

              // ── No deck connected banner ───────────────────────────────────
              if (game.deckId == null) ...[
                const SizedBox(height: 16),
                _NoDeckBanner(game: game, userId: user.id),
              ],

              const SizedBox(height: 24),

              // Waiting indicator when it's someone else's turn
              if (!game.handOver && !isMyTurn && !hasFolded) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 13, height: 13,
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
            ],
          ),
        ),
          ),
          // ── Sticky action bar ────────────────────────────────────────────
          if (showActionBar)
            _ActionBar(
              game: game,
              userId: user.id,
              isFacingBet: isFacingBet,
              callAmount: callAmount,
              minRaiseAmount: minRaiseAmount,
              myStack: myStack,
              onEditStack: () => _showEditStackDialog(context, game, user.id, myStack),
            ),

          // ── Sticky start new hand bar (host only) ─────────────────────
          if (showNewHandBar)
            _StartNewHandBar(
              onTap: () => FirestoreService.startNewHandForScanner(game.id, game),
            ),
        ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// YOUR HAND panel — subscribes to BLE and auto-fills cards for this player
// ─────────────────────────────────────────────────────────────────────────────

class _MyHandPanel extends ConsumerStatefulWidget {
  final GameModel game;
  final String userId;

  const _MyHandPanel({required this.game, required this.userId});

  @override
  ConsumerState<_MyHandPanel> createState() => _MyHandPanelState();
}

class _MyHandPanelState extends ConsumerState<_MyHandPanel> {
  StreamSubscription<String>? _chipSub;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _chipSub = BleService.instance.chipStream.listen(_onChipReceived);
    _loadDeckIfNeeded(widget.game.deckId);
  }

  @override
  void didUpdateWidget(_MyHandPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.game.deckId != widget.game.deckId) {
      _loadDeckIfNeeded(widget.game.deckId);
    }
    // Hide cards again when a new hand starts
    if (oldWidget.game.handCount != widget.game.handCount) {
      setState(() => _revealed = false);
    }
  }

  @override
  void dispose() {
    _chipSub?.cancel();
    super.dispose();
  }

  /// Strips the reader-slot prefix ("R1: " / "R2: ") emitted by the firmware
  /// so both RFID reader slots resolve to the same chip UID key.
  static String _normalizeChipId(String raw) {
    final m = RegExp(r'R\d+:\s*(.+)', caseSensitive: false).firstMatch(raw.trim());
    return (m?.group(1)?.trim() ?? raw.trim()).toUpperCase();
  }

  /// Auto-loads the deck's chip→card mapping from Firestore when the
  /// in-memory deckMap is empty (e.g. after an app restart).
  Future<void> _loadDeckIfNeeded(String? deckId) async {
    if (deckId == null) return;
    if (ref.read(scannerServiceProvider).deckMap.isNotEmpty) return;

    try {
      final mappings = await FirestoreService.getCardMappings(deckId);
      if (!mounted) return;
      final entries = mappings.entries.map((e) {
        final parts = e.value.split('|');
        return DeckEntry(
          chipId: _normalizeChipId(e.key),
          card: CardModel(rank: parts[0], suit: parts[1]),
        );
      }).toList();
      ref.read(scannerServiceProvider.notifier).loadDeck(entries);
    } catch (_) {}
  }

  Future<void> _onChipReceived(String rawChipId) async {
    if (!mounted) return;
    final chipId = _normalizeChipId(rawChipId);
    final card = ref.read(scannerServiceProvider).deckMap[chipId];
    if (card == null) return;

    final game = widget.game;
    final myCards = game.playerHands[widget.userId] ?? [];
    if (myCards.length >= 2) return;
    if (myCards.contains(card)) return;

    await FirestoreService.assignHoleCard(game.id, game, widget.userId, card);
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final myCards = game.playerHands[widget.userId] ?? [];
    final isConnected = ref.watch(scannerConnectedProvider);
    final hasCards = myCards.length == 2;
    final handShown = game.shownHandPlayerIds.contains(widget.userId);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with peek toggle
          Row(
            children: [
              Text('YOUR HAND',
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant, letterSpacing: 0.8,
                  )),
              const Spacer(),
              if (hasCards)
                GestureDetector(
                  onTap: () => setState(() => _revealed = !_revealed),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _revealed
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _revealed
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _revealed ? Icons.visibility : Icons.visibility_off,
                          size: 12,
                          color: _revealed ? AppColors.primary : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _revealed ? 'Peek' : 'Hidden',
                          style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: _revealed ? AppColors.primary : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Card faces or card backs
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(2, (i) {
                final card = i < myCards.length ? myCards[i] : null;
                return Padding(
                  padding: EdgeInsets.only(right: i == 0 ? 10 : 0),
                  child: card != null && _revealed
                      ? _HoleCard(card: card)
                      : card != null
                          ? _CardBack()
                          : Container(
                              width: 64, height: 88,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppColors.outlineVariant.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Center(
                                child: Icon(Icons.help_outline,
                                    size: 22,
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.3)),
                              ),
                            ),
                );
              }),
            ),
          ),

          // Show Hand button — only available when the hand is over
          if (game.handOver && hasCards) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: handShown
                  ? null
                  : () => FirestoreService.showHandInGame(game.id, widget.userId),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: handShown
                      ? AppColors.surfaceContainerHigh
                      : AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: handShown
                        ? AppColors.outlineVariant.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        handShown ? Icons.check_circle_outline : Icons.visibility,
                        size: 14,
                        color: handShown ? AppColors.onSurfaceVariant : AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        handShown ? 'Hand Shown' : 'Show Hand',
                        style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: handShown ? AppColors.onSurfaceVariant : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // Connect Scanner button when BLE is disconnected
          if (!isConnected) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => context.push('/scanner-setup'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bluetooth_searching,
                          size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text('Connect Scanner',
                          style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// No deck connected banner
// ─────────────────────────────────────────────────────────────────────────────

class _NoDeckBanner extends StatelessWidget {
  final GameModel game;
  final String userId;

  const _NoDeckBanner({required this.game, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isHost = game.hostId == userId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.style_outlined,
                size: 20, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No deck connected',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isHost
                      ? 'Connect a deck to start scanning cards'
                      : 'Waiting for host to connect a deck',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isHost) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ConnectDeckSheet(
                  gameId: game.id,
                  userId: userId,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Connect',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating Start New Hand bar (host only, shown when hand is over)
// ─────────────────────────────────────────────────────────────────────────────

class _StartNewHandBar extends StatelessWidget {
  final VoidCallback onTap;

  const _StartNewHandBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh, size: 16, color: AppColors.onPrimary),
                const SizedBox(width: 8),
                Text(
                  'START NEW HAND',
                  style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w800,
                    color: AppColors.onPrimary, letterSpacing: 1.0,
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

// ─────────────────────────────────────────────────────────────────────────────
// Floating 3-button action bar (Check/Call | Bet/Raise | Fold)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionBar extends StatelessWidget {
  final GameModel game;
  final String userId;
  final bool isFacingBet;
  final double callAmount;
  final double minRaiseAmount;
  final double myStack;
  final VoidCallback onEditStack;

  const _ActionBar({
    required this.game,
    required this.userId,
    required this.isFacingBet,
    required this.callAmount,
    required this.minRaiseAmount,
    required this.myStack,
    required this.onEditStack,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left — Check / Call
          Expanded(
            child: _ActionButton(
              label: isFacingBet
                  ? 'CALL\n€${callAmount.toStringAsFixed(2)}'
                  : 'CHECK',
              color: AppColors.surfaceContainerHigh,
              textColor: AppColors.onSurface,
              onTap: () => isFacingBet
                  ? FirestoreService.playerCall(game.id, game, userId)
                  : FirestoreService.playerCheck(game.id, game, userId),
            ),
          ),
          const SizedBox(width: 10),

          // Center — Bet / Raise (green, wider)
          Expanded(
            flex: 2,
            child: _ActionButton(
              label: isFacingBet ? 'RAISE' : 'BET',
              color: const Color(0xFF2E7D32),
              textColor: Colors.white,
              onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _BetSheet(
                  game: game,
                  userId: userId,
                  isFacingBet: isFacingBet,
                  minAmount: minRaiseAmount,
                  maxAmount: myStack,
                  onEditStack: onEditStack,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Right — Fold
          Expanded(
            child: _ActionButton(
              label: 'FOLD',
              color: AppColors.surfaceContainerHigh,
              textColor: AppColors.onSurfaceVariant,
              onTap: () => FirestoreService.playerFold(game.id, game, userId),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13, fontWeight: FontWeight.w800,
              color: textColor, letterSpacing: 0.6,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bet / Raise bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _BetSheet extends StatefulWidget {
  final GameModel game;
  final String userId;
  final bool isFacingBet;
  final double minAmount;
  final double maxAmount;
  final VoidCallback onEditStack;

  const _BetSheet({
    required this.game,
    required this.userId,
    required this.isFacingBet,
    required this.minAmount,
    required this.maxAmount,
    required this.onEditStack,
  });

  @override
  State<_BetSheet> createState() => _BetSheetState();
}

class _BetSheetState extends State<_BetSheet> {
  late double _amount;
  Timer? _repeatTimer;

  @override
  void initState() {
    super.initState();
    _amount = widget.minAmount;
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  void _adjust(double delta) {
    setState(() {
      _amount = (_amount + delta).clamp(widget.minAmount, widget.maxAmount);
    });
  }

  void _startRepeat(double delta) {
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 80), (_) => _adjust(delta));
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  Future<void> _place() async {
    Navigator.pop(context);
    await FirestoreService.playerBet(widget.game.id, widget.game, widget.userId, _amount);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final myStack = widget.game.playerStacks[widget.userId] ?? 0.0;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title + stack
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isFacingBet ? 'RAISE' : 'BET',
                style: GoogleFonts.manrope(
                  fontSize: 18, fontWeight: FontWeight.w800,
                  color: AppColors.onSurface, letterSpacing: 1,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  widget.onEditStack();
                },
                child: Row(
                  children: [
                    Text(
                      'Stack: €${myStack.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_outlined,
                        size: 14, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Amount display
          Center(
            child: Text(
              '€${_amount.toStringAsFixed(2)}',
              style: GoogleFonts.manrope(
                fontSize: 42, fontWeight: FontWeight.w800,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'min €${widget.minAmount.toStringAsFixed(2)}',
              style: GoogleFonts.inter(
                fontSize: 12, color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick-add chips
          Row(
            children: [
              for (final chip in [0.05, 0.10, 0.25, 1.00])
                Expanded(
                  child: GestureDetector(
                    onTap: () => _adjust(chip),
                    onLongPressStart: (_) => _startRepeat(chip),
                    onLongPressEnd: (_) => _stopRepeat(),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '+€${chip.toStringAsFixed(2)}',
                          style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // All-in shortcut
          GestureDetector(
            onTap: () => setState(() => _amount = widget.maxAmount),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  'ALL IN  €${widget.maxAmount.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant, letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Place bet button
          GestureDetector(
            onTap: _place,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '${widget.isFacingBet ? 'RAISE' : 'BET'}  €${_amount.toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w800,
                    color: Colors.white, letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
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

class _HoleCard extends StatelessWidget {
  final CardModel card;
  const _HoleCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64, height: 88,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(card.rank,
                style: GoogleFonts.inter(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: card.suitColor, height: 1.0,
                )),
            Center(
              child: Text(card.suitSymbol,
                  style: TextStyle(fontSize: 26, color: card.suitColor, height: 1.0)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64, height: 88,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.lock_outline,
          size: 20,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.35),
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
