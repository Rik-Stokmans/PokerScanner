import 'package:cloud_firestore/cloud_firestore.dart';

/// Maps raw RFID chip IDs (as read by the MFRC522 scanners) to card identifiers.
///
/// A [DeckModel] is stored in Firestore and referenced by [GameModel.deckId].
/// The [chipToCard] map keys are hex-encoded RFID UIDs (e.g. "A3F2B1C0") and
/// values are card identifiers in the form "<rank><suit>" (e.g. "As", "Kh").
class DeckModel {
  final String id;
  final String name;
  final Map<String, String> chipToCard; // chipId → "<rank><suit>"
  final DateTime createdAt;

  const DeckModel({
    required this.id,
    required this.name,
    required this.chipToCard,
    required this.createdAt,
  });

  /// Returns the card identifier for a given RFID chip ID, or null if unmapped.
  String? cardForChip(String chipId) => chipToCard[chipId.toUpperCase()];

  /// Returns how many chips are mapped in this deck.
  int get mappedCount => chipToCard.length;

  Map<String, dynamic> toMap() => {
        'name': name,
        'chipToCard': chipToCard,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory DeckModel.fromMap(String id, Map<String, dynamic> map) {
    final rawMapping = (map['chipToCard'] as Map<String, dynamic>?) ?? {};
    return DeckModel(
      id: id,
      name: map['name'] as String? ?? 'Unnamed Deck',
      chipToCard: rawMapping.map((k, v) => MapEntry(k, v as String)),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
