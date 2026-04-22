import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';

/// A chip-ID-to-card assignment in the active deck.
class DeckEntry {
  final String chipId; // RFID UID hex string, e.g. "A3:4F:22:10"
  final CardModel card;

  const DeckEntry({required this.chipId, required this.card});
}

/// Live state held by [ScannerService].
class ScannerState {
  /// Whether the scanner hardware is connected.
  final bool isOnline;

  /// The current deck mapping: chipId → CardModel.
  final Map<String, CardModel> deckMap;

  /// Cards that have been scanned and are pending assignment.
  final List<CardModel> pendingCards;

  const ScannerState({
    this.isOnline = false,
    this.deckMap = const {},
    this.pendingCards = const [],
  });

  ScannerState copyWith({
    bool? isOnline,
    Map<String, CardModel>? deckMap,
    List<CardModel>? pendingCards,
  }) =>
      ScannerState(
        isOnline: isOnline ?? this.isOnline,
        deckMap: deckMap ?? this.deckMap,
        pendingCards: pendingCards ?? this.pendingCards,
      );
}

/// Manages the RFID scanner connection and chip-ID → card lookup.
///
/// In the current implementation the scanner connection is simulated
/// (no real BLE calls). The [injectChipId] method is called by the BLE
/// layer (or, when offline, by the manual-entry UI) to feed a chip ID
/// into the service.
class ScannerService extends StateNotifier<ScannerState> {
  ScannerService() : super(const ScannerState());

  // ─── Connection ───────────────────────────────────────────────────────────

  /// Mark the scanner as connected/disconnected.
  void setOnline(bool online) => state = state.copyWith(isOnline: online);

  // ─── Deck management (host only) ─────────────────────────────────────────

  /// Replace the entire deck map with [entries].
  void loadDeck(List<DeckEntry> entries) {
    state = state.copyWith(
      deckMap: {for (final e in entries) e.chipId: e.card},
    );
  }

  /// Assign [chipId] to [card], overwriting any existing mapping.
  void assignChip(String chipId, CardModel card) {
    final updated = Map<String, CardModel>.from(state.deckMap);
    updated[chipId] = card;
    state = state.copyWith(deckMap: updated);
  }

  /// Remove the mapping for [chipId].
  void removeChip(String chipId) {
    final updated = Map<String, CardModel>.from(state.deckMap)
      ..remove(chipId);
    state = state.copyWith(deckMap: updated);
  }

  // ─── Chip ingestion ───────────────────────────────────────────────────────

  /// Feed a raw chip ID into the service (called by BLE layer or manual UI).
  ///
  /// If the chip ID is in the deck map the resolved [CardModel] is appended
  /// to [ScannerState.pendingCards]. If the chip has no mapping it is ignored
  /// (unknown chip) and `null` is returned.
  ///
  /// Returns the resolved [CardModel] or `null` if the chip is unknown.
  CardModel? injectChipId(String chipId) {
    final card = state.deckMap[chipId];
    if (card == null) return null;

    // Avoid duplicates in the pending list
    if (state.pendingCards.contains(card)) return card;

    state = state.copyWith(
      pendingCards: [...state.pendingCards, card],
    );
    return card;
  }

  /// Inject a card directly (used by the manual-entry fallback).
  void injectCard(CardModel card) {
    if (state.pendingCards.contains(card)) return;
    state = state.copyWith(
      pendingCards: [...state.pendingCards, card],
    );
  }

  /// Remove the first pending card once it has been consumed by the game layer.
  void consumePending() {
    if (state.pendingCards.isEmpty) return;
    state = state.copyWith(pendingCards: state.pendingCards.sublist(1));
  }

  /// Clear all pending cards.
  void clearPending() => state = state.copyWith(pendingCards: []);
}

// ─── Riverpod provider ────────────────────────────────────────────────────────

final scannerServiceProvider =
    StateNotifierProvider<ScannerService, ScannerState>(
  (_) => ScannerService(),
);
