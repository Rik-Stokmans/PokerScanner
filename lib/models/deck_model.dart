import 'package:cloud_firestore/cloud_firestore.dart';

/// A registered physical deck of cards.
///
/// Stored at: /decks/{deckId}
/// Card mappings are stored in a subcollection: /decks/{deckId}/cards/{uid}
/// where uid is the RFID tag UID and the document value is {"cardCode": "rank:suit"}.
///
/// The optional [chipToCard] field is populated in-memory when the full mapping
/// is loaded via [FirestoreService.getCardMappings] — it is NOT persisted in the
/// top-level document.
class DeckModel {
  final String id;
  final String ownerId;
  final String name;

  /// The id of the table/game this deck is currently assigned to, or null.
  final String? assignedTableId;

  final DateTime createdAt;

  /// In-memory chip-ID → card-code lookup, e.g. "A3F2B1C0" → "As".
  /// Populated after calling [FirestoreService.getCardMappings]; empty otherwise.
  final Map<String, String> chipToCard;

  const DeckModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.assignedTableId,
    required this.createdAt,
    this.chipToCard = const {},
  });

  /// Returns the card identifier for a given RFID chip ID, or null if unmapped.
  String? cardForChip(String chipId) => chipToCard[chipId.toUpperCase()];

  /// Returns how many chips are mapped in this deck (only valid after loading).
  int get mappedCount => chipToCard.length;

  Map<String, dynamic> toMap() => {
        'ownerId': ownerId,
        'name': name,
        'assignedTableId': assignedTableId,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory DeckModel.fromMap(String id, Map<String, dynamic> map,
          {Map<String, String>? chipToCard}) =>
      DeckModel(
        id: id,
        ownerId: map['ownerId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        assignedTableId: map['assignedTableId'] as String?,
        createdAt:
            (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        chipToCard: chipToCard ?? const {},
      );
}
