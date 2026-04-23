import 'package:cloud_firestore/cloud_firestore.dart';
import 'card_model.dart';

enum GameStatus { waiting, active, completed }

enum BettingRound { preflop, flop, turn, river }

class GameModel {
  final String id;
  final String name;
  final String hostId;
  final double smallBlind;
  final double bigBlind;
  final int maxPlayers;
  final List<String> playerIds;
  final Map<String, String> playerNames; // uid → username
  final GameStatus status;
  final double pot;
  final BettingRound currentRound;
  final List<CardModel> communityCards;
  final String? currentTurnPlayerId;
  final Map<String, List<CardModel>> playerHands; // uid → [card1, card2]
  final Map<String, double> playerBets; // uid → current round bet
  final Map<String, double> playerStacks; // uid → chips remaining
  final List<String> foldedPlayers;
  final List<String> shownHandPlayerIds; // players who pressed Show Hand this round
  final int handCount;
  final DateTime createdAt;
  final Map<String, double> stacksAtHandStart; // uid → stack at start of current hand
  final String? deckId; // references a DeckModel; null when no scanner deck is linked
  final bool handOver; // true after _resolveHand; cleared when next hand starts
  /// Visual seat layout: seat index (0-based string key) → player ID.
  final Map<String, String> seatAssignments;
  /// Which player currently holds the dealer button (visual only, does not affect betting order).
  final String? dealerPlayerId;

  const GameModel({
    required this.id,
    required this.name,
    required this.hostId,
    this.smallBlind = 0.05,
    this.bigBlind = 0.10,
    this.maxPlayers = 9,
    required this.playerIds,
    this.playerNames = const {},
    this.status = GameStatus.waiting,
    this.pot = 0.0,
    this.currentRound = BettingRound.preflop,
    this.communityCards = const [],
    this.currentTurnPlayerId,
    this.playerHands = const {},
    this.playerBets = const {},
    this.playerStacks = const {},
    this.foldedPlayers = const [],
    this.shownHandPlayerIds = const [],
    this.handCount = 0,
    required this.createdAt,
    this.stacksAtHandStart = const {},
    this.deckId,
    this.handOver = false,
    this.seatAssignments = const {},
    this.dealerPlayerId,
  });

  int get playerCount => playerIds.length;
  bool get isActive => status == GameStatus.active;

  String get roundLabel {
    switch (currentRound) {
      case BettingRound.preflop: return 'Pre-Flop';
      case BettingRound.flop: return 'Flop';
      case BettingRound.turn: return 'Turn';
      case BettingRound.river: return 'River';
    }
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'hostId': hostId,
        'smallBlind': smallBlind,
        'bigBlind': bigBlind,
        'maxPlayers': maxPlayers,
        'playerIds': playerIds,
        'playerNames': playerNames,
        'status': status.name,
        'pot': pot,
        'currentRound': currentRound.name,
        'communityCards': communityCards.map((c) => c.toMap()).toList(),
        'currentTurnPlayerId': currentTurnPlayerId,
        'playerHands': playerHands.map(
          (uid, cards) => MapEntry(uid, cards.map((c) => c.toMap()).toList()),
        ),
        'playerBets': playerBets,
        'playerStacks': playerStacks,
        'foldedPlayers': foldedPlayers,
        'shownHandPlayerIds': shownHandPlayerIds,
        'handCount': handCount,
        'createdAt': Timestamp.fromDate(createdAt),
        'stacksAtHandStart': stacksAtHandStart,
        if (deckId != null) 'deckId': deckId,
        'handOver': handOver,
        'seatAssignments': seatAssignments,
        if (dealerPlayerId != null) 'dealerPlayerId': dealerPlayerId,
      };

  factory GameModel.fromMap(String id, Map<String, dynamic> map) {
    final communityRaw = (map['communityCards'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final handsRaw = (map['playerHands'] as Map<String, dynamic>?) ?? {};
    final betsRaw = (map['playerBets'] as Map<String, dynamic>?) ?? {};
    final stacksRaw = (map['playerStacks'] as Map<String, dynamic>?) ?? {};
    final namesRaw = (map['playerNames'] as Map<String, dynamic>?) ?? {};
    final stacksAtHandStartRaw = (map['stacksAtHandStart'] as Map<String, dynamic>?) ?? {};

    return GameModel(
      id: id,
      name: map['name'] as String? ?? 'Table',
      hostId: map['hostId'] as String? ?? '',
      smallBlind: (map['smallBlind'] as num?)?.toDouble() ?? 0.05,
      bigBlind: (map['bigBlind'] as num?)?.toDouble() ?? 0.10,
      maxPlayers: (map['maxPlayers'] as num?)?.toInt() ?? 9,
      playerIds: List<String>.from(map['playerIds'] as List? ?? []),
      playerNames: namesRaw.map((k, v) => MapEntry(k, v as String)),
      status: GameStatus.values.byName(map['status'] as String? ?? 'waiting'),
      pot: (map['pot'] as num?)?.toDouble() ?? 0.0,
      currentRound: BettingRound.values.byName(map['currentRound'] as String? ?? 'preflop'),
      communityCards: communityRaw.map(CardModel.fromMap).toList(),
      currentTurnPlayerId: map['currentTurnPlayerId'] as String?,
      playerHands: handsRaw.map(
        (uid, cards) => MapEntry(
          uid,
          (cards as List).cast<Map<String, dynamic>>().map(CardModel.fromMap).toList(),
        ),
      ),
      playerBets: betsRaw.map((k, v) => MapEntry(k, (v as num).toDouble())),
      playerStacks: stacksRaw.map((k, v) => MapEntry(k, (v as num).toDouble())),
      foldedPlayers: List<String>.from(map['foldedPlayers'] ?? []),
      shownHandPlayerIds: List<String>.from(map['shownHandPlayerIds'] ?? []),
      handCount: (map['handCount'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      stacksAtHandStart: stacksAtHandStartRaw.map((k, v) => MapEntry(k, (v as num).toDouble())),
      deckId: map['deckId'] as String?,
      handOver: map['handOver'] as bool? ?? false,
      seatAssignments: (map['seatAssignments'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          const {},
      dealerPlayerId: map['dealerPlayerId'] as String?,
    );
  }
}
