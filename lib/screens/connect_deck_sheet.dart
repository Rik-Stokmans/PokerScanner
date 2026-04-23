import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/card_model.dart';
import '../models/deck_model.dart';
import '../providers/providers.dart';
import '../services/ble_service.dart';
import '../services/firestore_service.dart';
import '../services/scanner_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ConnectDeckSheet — top-level bottom sheet wrapper
// ─────────────────────────────────────────────────────────────────────────────

class ConnectDeckSheet extends ConsumerStatefulWidget {
  final String gameId;
  final String userId;

  const ConnectDeckSheet({
    super.key,
    required this.gameId,
    required this.userId,
  });

  @override
  ConsumerState<ConnectDeckSheet> createState() => _ConnectDeckSheetState();
}

class _ConnectDeckSheetState extends ConsumerState<ConnectDeckSheet> {
  bool _showWizard = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _showWizard
            ? _DeckWizard(
                key: const ValueKey('wizard'),
                gameId: widget.gameId,
                userId: widget.userId,
                onBack: () => setState(() => _showWizard = false),
                onComplete: () => Navigator.of(context).pop(),
              )
            : _DeckSelector(
                key: const ValueKey('selector'),
                gameId: widget.gameId,
                userId: widget.userId,
                onCreateDeck: () => setState(() => _showWizard = true),
                onClose: () => Navigator.of(context).pop(),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DeckSelector — lists existing decks or shows empty state with create CTA
// ─────────────────────────────────────────────────────────────────────────────

class _DeckSelector extends ConsumerWidget {
  final String gameId;
  final String userId;
  final VoidCallback onCreateDeck;
  final VoidCallback onClose;

  const _DeckSelector({
    super.key,
    required this.gameId,
    required this.userId,
    required this.onCreateDeck,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(userDecksProvider).value ?? [];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'CONNECT DECK',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.onSurfaceVariant, size: 20),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          if (decks.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.style_outlined,
                          size: 28, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No decks registered yet',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Scan all 52 cards with your hand scanner to register a deck.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: GradientButton(
                label: 'CREATE A DECK',
                icon: Icons.add_card,
                onPressed: onCreateDeck,
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'SELECT A DECK',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...decks.map(
              (deck) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _DeckTile(
                  deck: deck,
                  onTap: () => _connectDeck(ref, deck, onClose),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: OutlinedButton.icon(
                onPressed: onCreateDeck,
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  'Create New Deck',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  foregroundColor: AppColors.onSurface,
                  side: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _connectDeck(
    WidgetRef ref,
    DeckModel deck,
    VoidCallback onClose,
  ) async {
    await FirestoreService.setGameDeck(gameId, deck.id);
    await FirestoreService.assignDeckToTable(
        deckId: deck.id, tableId: gameId);
    final mappings = await FirestoreService.getCardMappings(deck.id);
    final entries = mappings.entries.map((e) {
      final parts = e.value.split('|');
      return DeckEntry(
        chipId: e.key,
        card: CardModel(rank: parts[0], suit: parts[1]),
      );
    }).toList();
    ref.read(scannerServiceProvider.notifier).loadDeck(entries);
    onClose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DeckTile
// ─────────────────────────────────────────────────────────────────────────────

class _DeckTile extends StatelessWidget {
  final DeckModel deck;
  final VoidCallback onTap;

  const _DeckTile({required this.deck, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.style_outlined,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                deck.name,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _DeckWizard — step-by-step deck registration wizard
// ─────────────────────────────────────────────────────────────────────────────

class _DeckWizard extends ConsumerStatefulWidget {
  final String gameId;
  final String userId;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  const _DeckWizard({
    super.key,
    required this.gameId,
    required this.userId,
    required this.onBack,
    required this.onComplete,
  });

  @override
  ConsumerState<_DeckWizard> createState() => _DeckWizardState();
}

class _DeckWizardState extends ConsumerState<_DeckWizard> {
  static final _cards = CardModel.fullDeck;

  String? _deckId;

  /// Chip UIDs in scan order; length == number of cards registered.
  final List<String> _scannedChips = [];

  bool _isNamingStep = false;
  bool _isSaving = false;
  final _nameController = TextEditingController();
  StreamSubscription<String>? _chipSub;

  int get _nextIndex => _scannedChips.length;

  /// Strips the reader-slot prefix ("R1: " / "R2: ") so both RFID reader
  /// slots store the same normalized chip UID in Firestore.
  static String _normalizeChipId(String raw) {
    final m = RegExp(r'R\d+:\s*(.+)', caseSensitive: false).firstMatch(raw.trim());
    return (m?.group(1)?.trim() ?? raw.trim()).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _initDeck();
    _chipSub = BleService.instance.chipStream.listen(_onChipRead);
  }

  Future<void> _initDeck() async {
    final deck = await FirestoreService.createDeck(
      ownerId: widget.userId,
      name: 'New Deck',
    );
    if (mounted) setState(() => _deckId = deck.id);
  }

  @override
  void dispose() {
    _chipSub?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onChipRead(String rawUid) async {
    if (!mounted || _isNamingStep || _nextIndex >= 52 || _deckId == null) {
      return;
    }
    final chipUid = _normalizeChipId(rawUid);

    // Duplicate: this chip was already scanned earlier in this deck
    if (_scannedChips.contains(chipUid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This card has already been scanned — skipping.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final card = _cards[_nextIndex];
    final cardCode = '${card.rank}|${card.suit}';

    setState(() => _scannedChips.add(chipUid));

    await FirestoreService.upsertCardMapping(
      deckId: _deckId!,
      rfidUid: chipUid,
      cardCode: cardCode,
    );

    if (mounted && _nextIndex == 52) {
      setState(() => _isNamingStep = true);
    }
  }

  Future<void> _completeForTesting() async {
    if (_deckId == null || _isNamingStep) return;
    while (_nextIndex < 52 && mounted) {
      final fakeUid =
          'TEST_${_nextIndex.toString().padLeft(2, '0')}_${DateTime.now().microsecondsSinceEpoch}';
      await _onChipRead(fakeUid);
    }
  }

  void _goBack() {
    if (_nextIndex == 0) {
      widget.onBack();
      return;
    }
    setState(() {
      if (_isNamingStep) _isNamingStep = false;
      _scannedChips.removeLast();
    });
  }

  Future<void> _saveDeck() async {
    if (_deckId == null) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);
    await FirestoreService.updateDeckName(_deckId!, name);
    await FirestoreService.setGameDeck(widget.gameId, _deckId!);
    await FirestoreService.assignDeckToTable(
        deckId: _deckId!, tableId: widget.gameId);

    final entries = <DeckEntry>[];
    for (int i = 0; i < _scannedChips.length; i++) {
      entries.add(DeckEntry(chipId: _scannedChips[i], card: _cards[i]));
    }
    ref.read(scannerServiceProvider.notifier).loadDeck(entries);

    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return _isNamingStep ? _buildNamingStep(context) : _buildScanningStep(context);
  }

  Widget _buildScanningStep(BuildContext context) {
    final progress = _nextIndex / 52;
    final remaining = 52 - _nextIndex;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.90,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                GestureDetector(
                  onTap: _goBack,
                  child: const Icon(Icons.arrow_back_ios_new,
                      size: 20, color: AppColors.onSurface),
                ),
                const SizedBox(width: 14),
                Text(
                  'REGISTER DECK',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress
            Row(
              children: [
                Text(
                  '$_nextIndex of 52',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '$remaining remaining',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceContainerHighest,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 32),

            // Card prompt
            if (_nextIndex < 52) _buildCardPrompt(),

            const Spacer(),

            // Recent scans
            if (_nextIndex > 0) ...[
              _buildRecentScans(),
              const SizedBox(height: 16),
            ],

            // Complete for testing shortcut
            Center(
              child: TextButton(
                onPressed: _deckId != null && !_isNamingStep
                    ? _completeForTesting
                    : null,
                child: Text(
                  'Complete deck for testing',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    decoration: TextDecoration.underline,
                    decorationColor:
                        AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Waiting for scan indicator
            Row(
              children: [
                if (_nextIndex > 0) ...[
                  GestureDetector(
                    onTap: _goBack,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              AppColors.outlineVariant.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(Icons.arrow_back,
                          size: 20, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _deckId != null
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _deckId != null
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.outlineVariant.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_deckId != null) ...[
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Waiting for scanner...',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ] else ...[
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Initialising...',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPrompt() {
    final card = _cards[_nextIndex];
    return Center(
      child: Column(
        children: [
          Text(
            'Scan this card with your hand scanner:',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 110,
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  card.rank,
                  style: GoogleFonts.manrope(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: card.suitColor,
                  ),
                ),
                Text(
                  card.suitSymbol,
                  style: TextStyle(fontSize: 26, color: card.suitColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScans() {
    final count = _nextIndex.clamp(0, 5);
    final recentCards =
        _cards.sublist(_nextIndex - count, _nextIndex).reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently scanned',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: recentCards.map((c) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              width: 42,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    c.rank,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.suitColor,
                    ),
                  ),
                  Text(
                    c.suitSymbol,
                    style: TextStyle(fontSize: 11, color: c.suitColor),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNamingStep(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.72,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: AppColors.primary, size: 38),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'All 52 cards scanned!',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                'Give this deck a name, then connect it to the table.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              'DECK NAME',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true,
              style:
                  GoogleFonts.inter(fontSize: 15, color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'e.g. Red Bicycle Deck',
                hintStyle: GoogleFonts.inter(
                    fontSize: 15, color: AppColors.onSurfaceVariant),
                filled: true,
                fillColor: AppColors.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: _goBack,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                foregroundColor: AppColors.onSurfaceVariant,
                side: BorderSide(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Back to scanning',
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            GradientButton(
              label: _isSaving ? 'SAVING...' : 'SAVE & CONNECT DECK',
              icon: Icons.link,
              onPressed: _isSaving ? null : _saveDeck,
            ),
          ],
        ),
      ),
    );
  }
}
