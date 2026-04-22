import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/card_model.dart';
import '../providers/providers.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/scanner_status_badge.dart';

// All 52 cards in registration order (suit by suit)
final _registrationOrder = CardModel.fullDeck;

class DeckRegistrationScreen extends ConsumerStatefulWidget {
  /// When non-null, we are resuming an existing incomplete deck.
  final String? deckId;

  const DeckRegistrationScreen({super.key, this.deckId});

  @override
  ConsumerState<DeckRegistrationScreen> createState() =>
      _DeckRegistrationScreenState();
}

class _DeckRegistrationScreenState
    extends ConsumerState<DeckRegistrationScreen> {
  // ── state ────────────────────────────────────────────────────────────────
  String? _deckId;

  /// chipUid -> 'rank|suit'
  final Map<String, String> _chipToCard = {};

  /// index into _registrationOrder of the next card to scan
  int _nextIndex = 0;

  bool _isSaving = false;
  bool _isNamingStep = false;
  final TextEditingController _nameController = TextEditingController();

  // Simulates a scanner read – in production this would come from BLE
  bool _scannerConnected = true;

  @override
  void initState() {
    super.initState();
    _initDeck();
  }

  Future<void> _initDeck() async {
    if (widget.deckId != null) {
      // Resuming – load existing mappings from Firestore
      final user = ref.read(currentUserProvider).value;
      if (user == null) return;
      final snap = await FirestoreService.db
          .collection('decks')
          .doc(widget.deckId)
          .get();
      if (snap.exists) {
        final data = snap.data()!;
        final existing =
            Map<String, String>.from(data['chipToCard'] as Map? ?? {});
        setState(() {
          _deckId = widget.deckId;
          _chipToCard.addAll(existing);
          _nextIndex = existing.length.clamp(0, 52);
          _nameController.text = (data['name'] as String?) ?? '';
        });
      }
      return;
    }

    // New deck – create stub in Firestore immediately so we can stream updates
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    final deck =
        await FirestoreService.createDeck(user.id, 'New Deck');
    setState(() {
      _deckId = deck.id;
      _nameController.text = deck.name;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  CardModel get _nextCard => _registrationOrder[_nextIndex];

  String _cardKey(CardModel c) => '${c.rank}|${c.suit}';

  Color _suitColor(String suit) {
    return (suit == 'h' || suit == 'd')
        ? const Color(0xFFE57373)
        : AppColors.onSurface;
  }

  String _suitSymbol(String suit) =>
      const {'s': '♠', 'h': '♥', 'd': '♦', 'c': '♣'}[suit]!;

  // ── scan simulation / real BLE hook ───────────────────────────────────────

  /// Called when the scanner returns a chip UID for the current card prompt.
  Future<void> _onChipRead(String chipUid) async {
    if (_deckId == null) return;
    if (_nextIndex >= 52) return;

    final card = _nextCard;
    final key = _cardKey(card);

    setState(() {
      _chipToCard[chipUid] = key;
      _nextIndex++;
    });

    await FirestoreService.recordChipMapping(_deckId!, chipUid, key);

    if (_nextIndex == 52) {
      setState(() => _isNamingStep = true);
    }
  }

  /// Simulate a scan for demo / development purposes.
  void _simulateScan() {
    final fakeUid =
        'CHIP_${_nextIndex.toString().padLeft(2, '0')}_${DateTime.now().millisecondsSinceEpoch}';
    _onChipRead(fakeUid);
  }

  Future<void> _finaliseDeck() async {
    if (_deckId == null) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);
    await FirestoreService.finaliseDeck(_deckId!, name);
    if (mounted) {
      context.go('/decks');
    }
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: _isNamingStep ? _buildNamingStep() : _buildScanningStep(),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SILENT TABLE',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                letterSpacing: 2,
              ),
            ),
            ScannerStatusBadge(isActive: _scannerConnected),
          ],
        ),
      ],
    );
  }

  // ── scanning step ─────────────────────────────────────────────────────────

  Widget _buildScanningStep() {
    final progress = _nextIndex / 52;
    final remaining = 52 - _nextIndex;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 28),
          Text(
            'Register Deck',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$_nextIndex of 52 cards registered · $remaining remaining',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar
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

          // Current card prompt
          if (_nextIndex < 52) _buildCardPrompt(),

          const Spacer(),

          // Recent scans preview
          if (_nextIndex > 0) _buildRecentScans(),

          const SizedBox(height: 16),

          // Scan button (simulate)
          GradientButton(
            label: _scannerConnected
                ? 'SCAN NEXT CARD'
                : 'CONNECT SCANNER FIRST',
            icon: _scannerConnected
                ? Icons.nfc
                : Icons.bluetooth_disabled,
            onPressed: _scannerConnected && _nextIndex < 52
                ? _simulateScan
                : null,
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => context.go('/scanner-setup'),
              child: Text(
                _scannerConnected
                    ? 'Re-connect scanner'
                    : 'Connect scanner',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPrompt() {
    final card = _nextCard;
    return Center(
      child: Column(
        children: [
          Text(
            'Present this card to the scanner:',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
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
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: _suitColor(card.suit),
                  ),
                ),
                Text(
                  _suitSymbol(card.suit),
                  style: TextStyle(
                    fontSize: 28,
                    color: _suitColor(card.suit),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScans() {
    final recentCount = _nextIndex.clamp(0, 6);
    final recentCards = _registrationOrder
        .sublist(_nextIndex - recentCount, _nextIndex)
        .reversed
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently scanned',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: recentCards.map((c) {
            return Container(
              margin: const EdgeInsets.only(right: 8),
              width: 44,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    c.rank,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _suitColor(c.suit),
                    ),
                  ),
                  Text(
                    _suitSymbol(c.suit),
                    style: TextStyle(
                        fontSize: 12, color: _suitColor(c.suit)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── naming step ───────────────────────────────────────────────────────────

  Widget _buildNamingStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 36),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: AppColors.primary, size: 40),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'All 52 cards registered!',
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Give this deck a name before saving.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'Deck name',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            autofocus: true,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. Red Bicycle Deck',
              hintStyle: GoogleFonts.inter(
                  fontSize: 16, color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: AppColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(0.6), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
          const Spacer(),
          GradientButton(
            label: _isSaving ? 'SAVING…' : 'SAVE DECK',
            icon: Icons.save_outlined,
            onPressed: _isSaving ? null : _finaliseDeck,
          ),
        ],
      ),
    );
  }
}
