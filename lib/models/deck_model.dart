import 'package:cloud_firestore/cloud_firestore.dart';
import 'card_model.dart';

/// A registered physical deck of cards.
///
/// Stored at: /decks/{deckId}
/// Card mappings are stored in a subcollection: /decks/{deckId}/cards/{uid}
/// where uid is the RFID tag UID and the document value is {"cardCode": "rank:suit"}.
///
/// The [chipToCard] field is populated in-memory after loading the subcollection
/// via [FirestoreService.getCardMappings] — it is NOT persisted in the top-level
/// document.

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

  /// Resolve a raw chip ID to a [CardModel], or null if unmapped.
  CardModel? resolve(String chipId) {
    final identifier = chipToCard[chipId] ?? chipToCard[chipId.toUpperCase()];
    if (identifier == null || identifier.length < 2) return null;
    final rank = identifier.substring(0, identifier.length - 1);
    final suit = identifier[identifier.length - 1].toLowerCase();
    return CardModel(rank: rank, suit: suit);
  }

  /// Number of cards that have been mapped so far.
  int get mappedCount => chipToCard.length;

  /// Whether all 52 cards have been registered.
  bool get isComplete => chipToCard.length == 52;

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

  DeckModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? assignedTableId,
    DateTime? createdAt,
    Map<String, String>? chipToCard,
  }) =>
      DeckModel(
        id: id ?? this.id,
        ownerId: ownerId ?? this.ownerId,
        name: name ?? this.name,
        assignedTableId: assignedTableId ?? this.assignedTableId,
        createdAt: createdAt ?? this.createdAt,
        chipToCard: chipToCard ?? Map.of(this.chipToCard),
      );
}
