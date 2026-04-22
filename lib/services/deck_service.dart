import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/deck_model.dart';

/// Firestore operations for the `decks` collection.
///
/// Security rules restrict writes to the deck owner.
/// Full CRUD and per-card atomic writes are added by the
/// "Firestore deck collection" todo; this file exposes the read streams
/// that the provider layer requires.
class DeckService {
  static final _db = FirebaseFirestore.instance;
  static const _col = 'decks';

  /// Live stream of all decks owned by [userId], ordered by creation date.
  static Stream<List<DeckModel>> getUserDecksStream(String userId) => _db
      .collection(_col)
      .where('ownerId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs
          .map((d) => DeckModel.fromMap(d.id, d.data()))
          .toList());

  /// Live stream for a single deck document; emits null if not found.
  static Stream<DeckModel?> getDeckStream(String deckId) => _db
      .collection(_col)
      .doc(deckId)
      .snapshots()
      .map((s) => s.exists ? DeckModel.fromMap(s.id, s.data()!) : null);
}
