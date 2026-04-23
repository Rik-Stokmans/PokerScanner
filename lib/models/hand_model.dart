import 'package:cloud_firestore/cloud_firestore.dart';
import 'card_model.dart';
import 'hand_action_model.dart';

class HandModel {
  final String id;
  final String gameId;
  final int handNumber;
  final String winnerId;
  final String winnerUsername;
  final double potAmount;
  final List<CardModel> communityCards;
  final Map<String, List<CardModel>> playerCards; // uid → [card1, card2]
  final Map<String, String> playerNames; // uid → username
  final String handRank;
  final DateTime timestamp;
  final bool wasShowdown;
  final List<String> revealedPlayerIds; // UIDs whose cards are publicly visible
  final Map<String, double> playerStacksBefore; // uid → stack before this hand
  final List<HandActionModel> actions;
  final List<String> favoritedBy; // user IDs who hearted this hand
  final int? handDurationSeconds;
  final String? winCondition; // 'showdown', 'everyone_folded', or 'uncontested'

  const HandModel({
    required this.id,
    required this.gameId,
    required this.handNumber,
    required this.winnerId,
    required this.winnerUsername,
    required this.potAmount,
    required this.communityCards,
    required this.playerCards,
    this.playerNames = const {},
    required this.handRank,
    required this.timestamp,
    this.wasShowdown = false,
    this.revealedPlayerIds = const [],
    this.playerStacksBefore = const {},
    this.actions = const [],
    this.favoritedBy = const [],
    this.handDurationSeconds,
    this.winCondition,
  });

  bool isCardVisible(String viewerUid, String cardOwnerUid) =>
      viewerUid == cardOwnerUid || revealedPlayerIds.contains(cardOwnerUid);

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ${diff.inMinutes.remainder(60)}m ago';
    return '${diff.inDays}d ago';
  }

  Map<String, dynamic> toMap() => {
        'gameId': gameId,
        'handNumber': handNumber,
        'winnerId': winnerId,
        'winnerUsername': winnerUsername,
        'potAmount': potAmount,
        'communityCards': communityCards.map((c) => c.toMap()).toList(),
        'playerCards': playerCards.map(
          (uid, cards) => MapEntry(uid, cards.map((c) => c.toMap()).toList()),
        ),
        'playerNames': playerNames,
        'handRank': handRank,
        'timestamp': Timestamp.fromDate(timestamp),
        'wasShowdown': wasShowdown,
        'revealedPlayerIds': revealedPlayerIds,
        'playerStacksBefore': playerStacksBefore,
        'actions': actions.map((a) => a.toMap()).toList(),
        'favoritedBy': favoritedBy,
        'handDurationSeconds': handDurationSeconds,
        'winCondition': winCondition,
      };

  factory HandModel.fromMap(String id, Map<String, dynamic> map) {
    final communityRaw = (map['communityCards'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final cardsRaw = (map['playerCards'] as Map<String, dynamic>?) ?? {};
    final namesRaw = (map['playerNames'] as Map<String, dynamic>?) ?? {};
    final actionsRaw = (map['actions'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return HandModel(
      id: id,
      gameId: map['gameId'] as String? ?? '',
      handNumber: (map['handNumber'] as num?)?.toInt() ?? 0,
      winnerId: map['winnerId'] as String? ?? '',
      winnerUsername: map['winnerUsername'] as String? ?? '',
      potAmount: (map['potAmount'] as num?)?.toDouble() ?? 0.0,
      communityCards: communityRaw.map(CardModel.fromMap).toList(),
      playerCards: cardsRaw.map(
        (uid, cards) => MapEntry(
          uid,
          (cards as List).cast<Map<String, dynamic>>().map(CardModel.fromMap).toList(),
        ),
      ),
      playerNames: namesRaw.map((k, v) => MapEntry(k, v as String)),
      handRank: map['handRank'] as String? ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      wasShowdown: map['wasShowdown'] as bool? ?? false,
      revealedPlayerIds: (map['revealedPlayerIds'] as List?)?.cast<String>() ?? [],
      playerStacksBefore: ((map['playerStacksBefore'] as Map<String, dynamic>?) ?? {})
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      actions: actionsRaw.map(HandActionModel.fromMap).toList(),
      favoritedBy: (map['favoritedBy'] as List?)?.cast<String>() ?? [],
      handDurationSeconds: (map['handDurationSeconds'] as num?)?.toInt(),
      winCondition: map['winCondition'] as String?,
    );
  }
}
