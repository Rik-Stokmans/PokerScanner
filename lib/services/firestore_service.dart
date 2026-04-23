import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';
import '../models/hand_model.dart';
import '../models/hand_action_model.dart';
import '../models/card_model.dart';
import '../models/deck_model.dart';
import '../models/invitation_model.dart';
import '../models/friendship_model.dart';
import '../services/hand_evaluator.dart';
import '../services/decision_evaluator.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // Exposed for screens that need direct document reads
  static FirebaseFirestore get db => _db;

  // ─── Users ───────────────────────────────────────────────────────────────

  static Stream<UserModel?> getUserStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((s) => s.exists ? UserModel.fromMap(s.id, s.data()!) : null);

  static Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists ? UserModel.fromMap(doc.id, doc.data()!) : null;
  }

  static Future<void> updateUserStatus(String uid, String status,
      {String? currentGameId, bool clearGameId = false}) {
    final data = <String, dynamic>{'status': status};
    if (clearGameId) {
      data['currentGameId'] = null;
    } else if (currentGameId != null) {
      data['currentGameId'] = currentGameId;
    }
    return _db.collection('users').doc(uid).update(data);
  }

  static Future<List<UserModel>> searchUsers(String query) async {
    final snapshot = await _db
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: '${query}z')
        .limit(10)
        .get();
    return snapshot.docs.map((d) => UserModel.fromMap(d.id, d.data())).toList();
  }

  // ─── Games ────────────────────────────────────────────────────────────────

  static Stream<GameModel?> getGameStream(String gameId) => _db
      .collection('games')
      .doc(gameId)
      .snapshots()
      .map((s) => s.exists ? GameModel.fromMap(s.id, s.data()!) : null);

  static Future<GameModel> createGame({
    required String hostId,
    required String hostUsername,
    required String name,
    double smallBlind = 0.05,
    double bigBlind = 0.10,
    int maxPlayers = 9,
  }) async {
    final game = GameModel(
      id: '',
      name: name,
      hostId: hostId,
      smallBlind: smallBlind,
      bigBlind: bigBlind,
      maxPlayers: maxPlayers,
      playerIds: [hostId],
      playerNames: {hostId: hostUsername},
      status: GameStatus.active,
      pot: bigBlind,
      currentRound: BettingRound.preflop,
      communityCards: [],
      currentTurnPlayerId: hostId,
      playerHands: {hostId: []},
      playerBets: {hostId: bigBlind},
      playerStacks: {hostId: 100.0},
      foldedPlayers: [],
      handCount: 1,
      createdAt: DateTime.now(),
    );

    final ref = await _db.collection('games').add(game.toMap());
    await _db.collection('users').doc(hostId).update({
      'currentGameId': ref.id,
      'status': 'in_game',
    });
    return GameModel.fromMap(ref.id, game.toMap());
  }

  static Future<void> dealNewHand(String gameId, GameModel game) async {
    final deck = CardModel.shuffledDeck();
    int cardIndex = 0;
    final hands = <String, List<CardModel>>{};
    final bets = <String, double>{};

    for (final uid in game.playerIds) {
      if (!game.foldedPlayers.contains(uid)) {
        hands[uid] = [deck[cardIndex++], deck[cardIndex++]];
        bets[uid] = 0.0;
      }
    }

    await _db.collection('games').doc(gameId).update({
      'playerHands': hands.map((uid, cards) =>
          MapEntry(uid, cards.map((c) => c.toMap()).toList())),
      'communityCards': [],
      'currentRound': BettingRound.preflop.name,
      'pot': game.bigBlind,
      'playerBets': {for (final uid in game.playerIds) uid: 0.0},
      'foldedPlayers': [],
      'shownHandPlayerIds': [],
      'currentTurnPlayerId': game.playerIds.first,
      'handCount': game.handCount + 1,
      'stacksAtHandStart': game.playerStacks,
      'playersToAct': game.playerIds,
    });
  }

  /// Start a new hand in scanner mode — bot players are auto-dealt random
  /// cards, human players get empty hands to be filled by the physical scanner.
  static Future<void> startNewHandForScanner(
      String gameId, GameModel game) async {
    final deck = CardModel.shuffledDeck();
    int cardIndex = 0;
    final hands = <String, List<CardModel>>{};
    for (final uid in game.playerIds) {
      if (uid.startsWith('bot_')) {
        hands[uid] = [deck[cardIndex++], deck[cardIndex++]];
      } else {
        hands[uid] = [];
      }
    }

    // Advance dealer button to the next player in turn order.
    String? newDealerPlayerId;
    if (game.playerIds.isNotEmpty) {
      final currentIdx = game.dealerPlayerId != null
          ? game.playerIds.indexOf(game.dealerPlayerId!)
          : -1;
      newDealerPlayerId = currentIdx >= 0
          ? game.playerIds[(currentIdx + 1) % game.playerIds.length]
          : game.playerIds.first;
    }

    // Determine SB/BB positions from the new dealer index
    final blindActions = <Map<String, dynamic>>[];
    if (game.playerIds.length >= 2 && newDealerPlayerId != null) {
      final dealerIdx = game.playerIds.indexOf(newDealerPlayerId);
      final n = game.playerIds.length;
      final sbUid = game.playerIds[(dealerIdx + 1) % n];
      final bbUid = game.playerIds[(dealerIdx + 2) % n];
      final now = DateTime.now();
      blindActions.add(HandActionModel(
        playerId: sbUid,
        playerName: game.playerNames[sbUid] ?? sbUid,
        actionType: ActionType.smallBlind,
        amount: game.smallBlind,
        bettingRound: BettingRound.preflop,
        timestamp: now,
      ).toMap());
      blindActions.add(HandActionModel(
        playerId: bbUid,
        playerName: game.playerNames[bbUid] ?? bbUid,
        actionType: ActionType.bigBlind,
        amount: game.bigBlind,
        bettingRound: BettingRound.preflop,
        timestamp: now.add(const Duration(milliseconds: 1)),
      ).toMap());
    }

    await _db.collection('games').doc(gameId).update({
      'playerHands': hands.map(
        (uid, cards) => MapEntry(uid, cards.map((c) => c.toMap()).toList()),
      ),
      'communityCards': [],
      'currentRound': BettingRound.preflop.name,
      'pot': game.bigBlind,
      'playerBets': {for (final uid in game.playerIds) uid: 0.0},
      'foldedPlayers': [],
      'shownHandPlayerIds': [],
      'currentTurnPlayerId': game.playerIds.first,
      'handCount': game.handCount + 1,
      'stacksAtHandStart': game.playerStacks,
      'handOver': false,
      'currentHandActions': blindActions,
      'playersToAct': game.playerIds,
      if (newDealerPlayerId != null) 'dealerPlayerId': newDealerPlayerId,
    });
  }

  static Future<void> _appendAction(
      String gameId, HandActionModel action) async {
    await _db.collection('games').doc(gameId).update({
      'currentHandActions': FieldValue.arrayUnion([action.toMap()]),
    });
  }

  static Future<void> playerCheck(
      String gameId, GameModel game, String uid) async {
    await _appendAction(
      gameId,
      HandActionModel(
        playerId: uid,
        playerName: game.playerNames[uid] ?? uid,
        actionType: ActionType.check,
        bettingRound: game.currentRound,
        timestamp: DateTime.now(),
      ),
    );
    await _advanceTurn(gameId, game, uid);
  }

  static Future<void> playerCall(
      String gameId, GameModel game, String uid) async {
    final highBet =
        game.playerBets.values.fold<double>(0, (a, b) => a > b ? a : b);
    final myBet = game.playerBets[uid] ?? 0;
    final myStack = game.playerStacks[uid] ?? 0;
    // Clamp to the player's remaining stack to avoid going negative (all-in call)
    final callAmount = (highBet - myBet).clamp(0.0, myStack);
    if (callAmount <= 0) return playerCheck(gameId, game, uid);

    final newStack = myStack - callAmount;
    final isAllIn = newStack <= 0;
    await _appendAction(
      gameId,
      HandActionModel(
        playerId: uid,
        playerName: game.playerNames[uid] ?? uid,
        actionType: isAllIn ? ActionType.allIn : ActionType.call,
        amount: callAmount,
        bettingRound: game.currentRound,
        timestamp: DateTime.now(),
      ),
    );
    return playerBet(gameId, game, uid, callAmount, skipActionLog: true);
  }

  static Future<void> playerFold(
      String gameId, GameModel game, String uid) async {
    await _appendAction(
      gameId,
      HandActionModel(
        playerId: uid,
        playerName: game.playerNames[uid] ?? uid,
        actionType: ActionType.fold,
        bettingRound: game.currentRound,
        timestamp: DateTime.now(),
      ),
    );

    final newFolded = [...game.foldedPlayers, uid];
    final activePlayers =
        game.playerIds.where((id) => !newFolded.contains(id)).toList();

    if (activePlayers.length == 1) {
      // Last player wins
      await _resolveHand(gameId, game, activePlayers.first,
          foldedPlayers: newFolded);
      return;
    }

    // Remove folder from playersToAct
    final newPlayersToAct =
        game.playersToAct.where((id) => id != uid).toList();

    if (newPlayersToAct.isEmpty) {
      await _db
          .collection('games')
          .doc(gameId)
          .update({'foldedPlayers': newFolded});
      await _advanceRound(
          gameId, game.copyWith(foldedPlayers: newFolded));
      return;
    }

    await _db.collection('games').doc(gameId).update({
      'foldedPlayers': newFolded,
      'currentTurnPlayerId': newPlayersToAct.first,
      'playersToAct': newPlayersToAct,
    });
  }

  static Future<void> playerBet(
      String gameId, GameModel game, String uid, double amount,
      {bool skipActionLog = false}) async {
    final highBet =
        game.playerBets.values.fold<double>(0, (a, b) => a > b ? a : b);
    final myBet = game.playerBets[uid] ?? 0;
    final total = myBet + amount;
    // A raise (total > highBet) must be at least 2× the current high bet.
    // A call (total == highBet) is always allowed without this restriction.
    if (highBet > 0 && total > highBet && total < highBet * 2) return;

    final newPot = game.pot + amount;
    final newBets = Map<String, double>.from(game.playerBets);
    newBets[uid] = (newBets[uid] ?? 0) + amount;

    final newStacks = Map<String, double>.from(game.playerStacks);
    newStacks[uid] = (newStacks[uid] ?? 0) - amount;

    final isAllIn = (newStacks[uid] ?? 0) <= 0;
    final isRaise = total > highBet;

    if (!skipActionLog) {
      await _appendAction(
        gameId,
        HandActionModel(
          playerId: uid,
          playerName: game.playerNames[uid] ?? uid,
          actionType:
              isAllIn ? ActionType.allIn : (isRaise ? ActionType.raise : ActionType.call),
          amount: amount,
          bettingRound: game.currentRound,
          timestamp: DateTime.now(),
        ),
      );
    }

    await _db.collection('games').doc(gameId).update({
      'pot': newPot,
      'playerBets': newBets,
      'playerStacks': newStacks,
    });

    if (isRaise) {
      // After a raise every other active player must act again.
      // Build playersToAct starting from the player after the raiser.
      final active = game.playerIds
          .where((id) => !game.foldedPlayers.contains(id))
          .toList();
      final raiserIdx = active.indexOf(uid);
      final newPlayersToAct = [
        for (int i = 1; i < active.length; i++)
          active[(raiserIdx + i) % active.length]
      ];

      if (newPlayersToAct.isEmpty) {
        await _advanceRound(
            gameId, game.copyWith(pot: newPot, playerBets: newBets));
        return;
      }

      await _db.collection('games').doc(gameId).update({
        'currentTurnPlayerId': newPlayersToAct.first,
        'playersToAct': newPlayersToAct,
      });
    } else {
      // Call — remove player from playersToAct via _advanceTurn
      await _advanceTurn(
          gameId, game.copyWith(pot: newPot, playerBets: newBets), uid);
    }
  }

  static Future<void> updatePlayerStack(
      String gameId, String uid, double newStackAmount) async {
    final doc = await _db.collection('games').doc(gameId).get();
    if (doc.exists) {
      final stacks = Map<String, double>.from(doc['playerStacks'] ?? {});
      stacks[uid] = newStackAmount;
      return _db.collection('games').doc(gameId).update({
        'playerStacks': stacks,
      });
    }
  }

  static Future<void> _advanceTurn(
      String gameId, GameModel game, String currentUid) async {
    // Remove the acting player from the queue
    final newPlayersToAct =
        game.playersToAct.where((id) => id != currentUid).toList();

    if (newPlayersToAct.isEmpty) {
      // Everyone has acted — move to the next betting round
      await _advanceRound(gameId, game);
      return;
    }

    await _db.collection('games').doc(gameId).update({
      'currentTurnPlayerId': newPlayersToAct.first,
      'playersToAct': newPlayersToAct,
    });
  }

  static Future<void> _advanceRound(
      String gameId, GameModel game) async {
    final deck = CardModel.shuffledDeck();
    // Filter out cards already in player hands
    final usedCards = game.playerHands.values.expand((c) => c).toSet();
    final remaining = deck.where((c) => !usedCards.contains(c)).toList();

    List<CardModel> newCommunity;
    BettingRound? nextRound;

    switch (game.currentRound) {
      case BettingRound.preflop:
        newCommunity = [...game.communityCards, ...remaining.take(3)];
        nextRound = BettingRound.flop;
        break;
      case BettingRound.flop:
        newCommunity = [...game.communityCards, remaining.first];
        nextRound = BettingRound.turn;
        break;
      case BettingRound.turn:
        newCommunity = [...game.communityCards, remaining.first];
        nextRound = BettingRound.river;
        break;
      case BettingRound.river:
        // Showdown
        await _showdown(gameId, game);
        return;
    }

    final active = game.playerIds
        .where((id) => !game.foldedPlayers.contains(id))
        .toList();

    await _db.collection('games').doc(gameId).update({
      'communityCards': newCommunity.map((c) => c.toMap()).toList(),
      'currentRound': nextRound.name,
      'playerBets': {for (final uid in game.playerIds) uid: 0.0},
      'currentTurnPlayerId': active.first,
      'playersToAct': active, // everyone acts fresh each new round
    });
  }

  static Future<void> _showdown(String gameId, GameModel game) async {
    final active =
        game.playerIds.where((id) => !game.foldedPlayers.contains(id)).toList();

    String? winnerId;
    HandRank? bestRank;

    for (final uid in active) {
      final hole = game.playerHands[uid] ?? [];
      final allCards = [...hole, ...game.communityCards];
      final result = HandEvaluator.evaluate(allCards);
      if (bestRank == null || result.rank.index > bestRank.index) {
        bestRank = result.rank;
        winnerId = uid;
      }
    }

    if (winnerId != null) {
      await _resolveHand(gameId, game, winnerId,
          wasShowdown: true, revealedPlayerIds: active);
    }
  }

  static Future<void> _resolveHand(
      String gameId, GameModel game, String winnerId,
      {List<String>? foldedPlayers,
      bool wasShowdown = false,
      List<String> revealedPlayerIds = const []}) async {
    final winnerName = game.playerNames[winnerId] ?? 'Unknown';

    // Evaluate winner's hand for description
    final hole = game.playerHands[winnerId] ?? [];
    final allCards = [...hole, ...game.communityCards];
    final result = HandEvaluator.evaluate(allCards);

    // Add pot to winner's stack and mark the hand as over so players can
    // optionally show their cards before the host starts the next round.
    final newStacks = Map<String, double>.from(game.playerStacks);
    newStacks[winnerId] = (newStacks[winnerId] ?? 0) + game.pot;
    await _db.collection('games').doc(gameId).update({
      'playerStacks': newStacks,
      'handOver': true,
    });

    // Read and clear the running action log
    final gameSnap = await _db.collection('games').doc(gameId).get();
    final rawActions =
        (gameSnap.data()?['currentHandActions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final actions = rawActions.map(HandActionModel.fromMap).toList();
    await _db.collection('games').doc(gameId).update({'currentHandActions': []});

    // Save hand to history
    final hand = HandModel(
      id: '',
      gameId: gameId,
      handNumber: game.handCount,
      winnerId: winnerId,
      winnerUsername: winnerName,
      potAmount: game.pot,
      communityCards: game.communityCards,
      playerCards: game.playerHands,
      playerNames: game.playerNames,
      handRank: result.description,
      timestamp: DateTime.now(),
      wasShowdown: wasShowdown,
      revealedPlayerIds: {
        ...revealedPlayerIds,
        ...game.shownHandPlayerIds,
      }.toList(),
      playerStacksBefore: game.stacksAtHandStart,
      actions: actions,
    );
    final handRef = await _db
        .collection('games')
        .doc(gameId)
        .collection('hands')
        .add(hand.toMap());

    // Persist win condition description on the hand document
    await setHandWinCondition(gameId, handRef.id, result.description);

    // Evaluate hand decisions and append XP events to the game document
    final xpEvents =
        DecisionEvaluator.evaluateHand(hand, winnerId, game.bigBlind);
    if (xpEvents.isNotEmpty) {
      await _db.collection('games').doc(gameId).update({
        'pendingXpEvents':
            FieldValue.arrayUnion(xpEvents.map((e) => e.toMap()).toList()),
      });
    }

    // Update winner stats (use set+merge so the doc is created if it doesn't exist yet)
    await _db.collection('users').doc(winnerId).set({
      'totalWinnings': FieldValue.increment(game.pot),
      'totalHandsPlayed': FieldValue.increment(1),
    }, SetOptions(merge: true));

    // Do NOT auto-start the next hand — the host manually triggers startNewHandForScanner
    // so players have time to optionally show their cards first.
  }

  /// Toggle [uid] in the `favoritedBy` array of a hand document.
  ///
  /// If [uid] is already in the array it is removed; otherwise it is added.
  static Future<void> toggleFavoriteHand(
      String gameId, String handId, String uid) async {
    final ref = _db
        .collection('games')
        .doc(gameId)
        .collection('hands')
        .doc(handId);
    final snap = await ref.get();
    final favoritedBy =
        List<String>.from((snap.data()?['favoritedBy'] as List?) ?? []);
    if (favoritedBy.contains(uid)) {
      await ref.update({'favoritedBy': FieldValue.arrayRemove([uid])});
    } else {
      await ref.update({'favoritedBy': FieldValue.arrayUnion([uid])});
    }
  }

  /// Write the [condition] string as the `winCondition` field on a hand document.
  static Future<void> setHandWinCondition(
          String gameId, String handId, String condition) =>
      _db
          .collection('games')
          .doc(gameId)
          .collection('hands')
          .doc(handId)
          .update({'winCondition': condition});

  static Future<void> endGame(String gameId, String hostId) async {
    // Clear the deck's table assignment if one was linked
    final gameDoc = await _db.collection('games').doc(gameId).get();
    final deckId = gameDoc.data()?['deckId'] as String?;
    if (deckId != null) {
      await _db
          .collection('decks')
          .doc(deckId)
          .update({'assignedTableId': null});
    }

    await _db.collection('games').doc(gameId).update({
      'status': GameStatus.completed.name,
    });
    await _db.collection('users').doc(hostId).update({
      'currentGameId': null,
      'status': 'online',
    });
  }

  // ─── Hands ────────────────────────────────────────────────────────────────

  static Future<void> addBotPlayer(
      String gameId, String botUid, String botName) async {
    final doc = await _db.collection('games').doc(gameId).get();
    final game = GameModel.fromMap(doc.id, doc.data()!);

    // Build set of already-used cards
    final usedCards = <CardModel>{
      ...game.playerHands.values.expand((c) => c),
      ...game.communityCards,
    };
    final available = CardModel.shuffledDeck()
        .where((c) => !usedCards.contains(c))
        .toList();

    final botCards = [available[0], available[1]];
    final newHands = {
      ...game.playerHands,
      botUid: botCards,
    };

    await _db.collection('games').doc(gameId).update({
      'playerIds': FieldValue.arrayUnion([botUid]),
      'playerNames.$botUid': botName,
      'playerStacks.$botUid': 100.0,
      'playerBets.$botUid': 0.0,
      'playerHands': newHands.map(
        (uid, cards) => MapEntry(uid, cards.map((c) => c.toMap()).toList()),
      ),
    });
  }

  /// Remove a player (human or bot) from the game entirely.
  /// Also clears any seat assignment for that player.
  static Future<void> removePlayerFromGame(
      String gameId, String playerId) async {
    await _db.collection('games').doc(gameId).update({
      'playerIds': FieldValue.arrayRemove([playerId]),
      'playerNames.$playerId': FieldValue.delete(),
      'playerStacks.$playerId': FieldValue.delete(),
      'playerBets.$playerId': FieldValue.delete(),
      'playerHands.$playerId': FieldValue.delete(),
      'stacksAtHandStart.$playerId': FieldValue.delete(),
    });
    // Remove from seatAssignments (requires reading current state since keys are dynamic)
    final doc = await _db.collection('games').doc(gameId).get();
    final data = doc.data();
    if (data == null) return;
    final seats = Map<String, dynamic>.from(
        (data['seatAssignments'] as Map?)?.cast<String, dynamic>() ?? {});
    seats.removeWhere((_, v) => v == playerId);
    await _db
        .collection('games')
        .doc(gameId)
        .update({'seatAssignments': seats});
  }

  static Future<void> showHandInGame(String gameId, String playerId) =>
      _db.collection('games').doc(gameId).update({
        'shownHandPlayerIds': FieldValue.arrayUnion([playerId]),
      });

  static Future<void> revealHand(
          String gameId, String handId, String playerId) =>
      _db
          .collection('games')
          .doc(gameId)
          .collection('hands')
          .doc(handId)
          .update({
        'revealedPlayerIds': FieldValue.arrayUnion([playerId]),
      });

  static Stream<List<HandModel>> getGameHandsStream(String gameId) => _db
      .collection('games')
      .doc(gameId)
      .collection('hands')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((s) => s.docs
          .map((d) => HandModel.fromMap(d.id, d.data()))
          .toList());

  static Future<List<HandModel>> getUserRecentHands(String userId,
      {int limit = 20}) async {
    // Get all games the user participated in
    final gamesSnap = await _db
        .collection('games')
        .where('playerIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .limit(5)
        .get();

    final hands = <HandModel>[];
    for (final gameDoc in gamesSnap.docs) {
      final handSnap = await _db
          .collection('games')
          .doc(gameDoc.id)
          .collection('hands')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      hands.addAll(handSnap.docs
          .map((d) => HandModel.fromMap(d.id, d.data())));
    }
    hands.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return hands.take(limit).toList();
  }

  // ─── Invitations ──────────────────────────────────────────────────────────

  static Stream<List<InvitationModel>> getInvitationsStream(String userId) =>
      _db
          .collection('invitations')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .snapshots()
          .map((s) {
            final invitations = s.docs
                .map((d) => InvitationModel.fromMap(d.id, d.data()))
                .toList();
            invitations.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return invitations;
          });

  static Future<void> sendInvitation({
    required String fromUserId,
    required String fromUsername,
    required String toUserId,
    required String gameId,
    required String gameName,
    required double smallBlind,
    required double bigBlind,
  }) {
    final inv = InvitationModel(
      id: '',
      fromUserId: fromUserId,
      fromUsername: fromUsername,
      toUserId: toUserId,
      gameId: gameId,
      gameName: gameName,
      gameDescription: 'No Limit Hold\'em · ${smallBlind.toStringAsFixed(2)}/${bigBlind.toStringAsFixed(2)}',
      stakes: '\$${smallBlind.toStringAsFixed(2)}/\$${bigBlind.toStringAsFixed(2)}',
      detail: 'Private game',
      createdAt: DateTime.now(),
    );
    return _db.collection('invitations').add(inv.toMap());
  }

  static Future<void> respondToInvitation(
      String invitationId, String response, String userId) async {
    if (response == 'accepted') {
      final invDoc =
          await _db.collection('invitations').doc(invitationId).get();
      final data = invDoc.data();
      if (data == null) {
        throw StateError(
            'Invitation $invitationId not found; it may have been deleted.');
      }
      final gameId = data['gameId'] as String?;
      if (gameId == null || gameId.isEmpty) {
        throw StateError(
            'Invitation $invitationId is missing a valid gameId.');
      }

      final batch = _db.batch();
      batch.update(
          _db.collection('invitations').doc(invitationId), {'status': response});
      batch.update(_db.collection('games').doc(gameId),
          {'playerIds': FieldValue.arrayUnion([userId])});
      batch.update(_db.collection('users').doc(userId),
          {'currentGameId': gameId, 'status': 'in_game'});
      await batch.commit();
    } else {
      await _db
          .collection('invitations')
          .doc(invitationId)
          .update({'status': response});
    }
  }

  // ─── Friendships ──────────────────────────────────────────────────────────

  static Stream<List<FriendshipModel>> getFriendshipsStream(String userId) =>
      _db
          .collection('friendships')
          .where(Filter.or(
            Filter('userId', isEqualTo: userId),
            Filter('friendId', isEqualTo: userId),
          ))
          .snapshots()
          .map((s) => s.docs
              .map((d) => FriendshipModel.fromMap(d.id, d.data()))
              .toList());

  static Future<void> sendFriendRequest({
    required String fromId,
    required String fromUsername,
    required String toId,
    required String toUsername,
  }) {
    final friendship = FriendshipModel(
      id: '',
      userId: fromId,
      friendId: toId,
      requestedBy: fromId,
      status: 'pending',
      userUsername: fromUsername,
      friendUsername: toUsername,
      createdAt: DateTime.now(),
    );
    return _db.collection('friendships').add(friendship.toMap());
  }

  static Future<void> respondToFriendRequest(
      String friendshipId, String response) {
    return _db
        .collection('friendships')
        .doc(friendshipId)
        .update({'status': response});
  }

  static Future<void> removeFriend(String friendshipId) =>
      _db.collection('friendships').doc(friendshipId).delete();

  // ─── Scanner-driven card assignment (host only) ───────────────────────────

  /// Assign [card] to a specific player's hole hand.
  ///
  /// The card is appended to that player's current hand (up to 2 cards).
  /// The host is responsible for calling this for each scanned hole card.
  static Future<void> assignHoleCard(
      String gameId, GameModel game, String targetPlayerId, CardModel card) async {
    final hand = game.playerHands[targetPlayerId] ?? [];
    if (hand.length >= 2) return; // already has 2 cards
    if (hand.contains(card)) return; // duplicate guard

    // Use arrayUnion so concurrent scans from both RFID readers don't
    // overwrite each other (both fire nearly simultaneously on a new hand).
    await _db.collection('games').doc(gameId).update({
      'playerHands.$targetPlayerId': FieldValue.arrayUnion([card.toMap()]),
    });
  }

  /// Add [card] to the community cards on the board.
  ///
  /// Enforces the maximum community card count for the current round.
  static Future<void> assignCommunityCard(
      String gameId, GameModel game, CardModel card) async {
    final maxCommunity = switch (game.currentRound) {
      BettingRound.preflop => 0,
      BettingRound.flop    => 3,
      BettingRound.turn    => 4,
      BettingRound.river   => 5,
    };

    if (game.communityCards.length >= maxCommunity) return;
    if (game.communityCards.contains(card)) return;

    final updated = [...game.communityCards, card];
    await _db.collection('games').doc(gameId).update({
      'communityCards': updated.map((c) => c.toMap()).toList(),
    });
  }

// ─── Decks ────────────────────────────────────────────────────────────────

  /// Live stream of all decks owned by [ownerId].
  static Stream<List<DeckModel>> getUserDecksStream(String ownerId) => _db
      .collection('decks')
      .where('ownerId', isEqualTo: ownerId)
      .snapshots()
      .map((s) {
        final decks = s.docs.map((d) => DeckModel.fromMap(d.id, d.data())).toList();
        decks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return decks;
      });

  /// Create a new deck document owned by [ownerId].
  static Future<DeckModel> createDeck({
    required String ownerId,
    required String name,
  }) async {
    final deck = DeckModel(
      id: '',
      ownerId: ownerId,
      name: name,
      createdAt: DateTime.now(),
    );
    final ref = await _db.collection('decks').add(deck.toMap());
    return DeckModel.fromMap(ref.id, deck.toMap());
  }

  /// Rename an existing deck. Only the deck owner should call this.
  static Future<void> updateDeckName(String deckId, String newName) =>
      _db.collection('decks').doc(deckId).update({'name': newName});

  /// Delete a deck and all its card-mapping sub-documents.
  ///
  /// Sub-collection documents are deleted in a batched write so the operation
  /// is efficient even for a full 52-card deck.
  static Future<void> deleteDeck(String deckId) async {
    final cardsSnap =
        await _db.collection('decks').doc(deckId).collection('cards').get();

    final batch = _db.batch();
    for (final doc in cardsSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_db.collection('decks').doc(deckId));
    await batch.commit();
  }

  /// Atomically write (or overwrite) a single card mapping for a deck.
  ///
  /// [rfidUid] is the hex UID read from the RFID tag.
  /// [cardCode] is the canonical "rank:suit" string, e.g. "A:s" or "10:h".
  ///
  /// Uses [SetOptions(merge: true)] so repeated calls during registration are
  /// safe — a re-scan of the same tag simply overwrites its mapping.
  static Future<void> upsertCardMapping({
    required String deckId,
    required String rfidUid,
    required String cardCode,
  }) =>
      _db
          .collection('decks')
          .doc(deckId)
          .collection('cards')
          .doc(rfidUid)
          .set({'cardCode': cardCode}, SetOptions(merge: true));

  /// Read back all card mappings for a deck as a {rfidUid → cardCode} map.
  static Future<Map<String, String>> getCardMappings(String deckId) async {
    final snap = await _db
        .collection('decks')
        .doc(deckId)
        .collection('cards')
        .get();
    return {for (final d in snap.docs) d.id: d.data()['cardCode'] as String};
  }

  /// Update the host's table layout: seat count, seat assignments, and dealer.
  static Future<void> updateTableSetup({
    required String gameId,
    required int seatCount,
    required Map<String, String> seatAssignments,
    required String? dealerPlayerId,
  }) =>
      _db.collection('games').doc(gameId).update({
        'maxPlayers': seatCount,
        'seatAssignments': seatAssignments,
        'dealerPlayerId': dealerPlayerId,
      });

  /// Set the deck linked to a game document.
  static Future<void> setGameDeck(String gameId, String deckId) =>
      _db.collection('games').doc(gameId).update({'deckId': deckId});

  /// Assign a deck to a table/game. Only the deck owner (host) should call
  /// this; the companion security rules enforce ownership on the server side.
  static Future<void> assignDeckToTable({
    required String deckId,
    required String tableId,
  }) =>
      _db
          .collection('decks')
          .doc(deckId)
          .update({'assignedTableId': tableId});

  /// Remove a deck's table assignment.
  static Future<void> unassignDeck(String deckId) =>
      _db.collection('decks').doc(deckId).update({'assignedTableId': null});

  /// Live stream of a single deck document.
  static Stream<DeckModel?> getDeckStream(String deckId) => _db
      .collection('decks')
      .doc(deckId)
      .snapshots()
      .map((s) => s.exists ? DeckModel.fromMap(s.id, s.data()!) : null);
}

extension GameModelCopyWith on GameModel {
  GameModel copyWith({
    List<String>? foldedPlayers,
    double? pot,
    Map<String, double>? playerBets,
    Map<String, double>? playerStacks,
    BettingRound? currentRound,
    List<CardModel>? communityCards,
    String? currentTurnPlayerId,
    List<String>? playersToAct,
  }) =>
      GameModel(
        id: id,
        name: name,
        hostId: hostId,
        smallBlind: smallBlind,
        bigBlind: bigBlind,
        maxPlayers: maxPlayers,
        playerIds: playerIds,
        playerNames: playerNames,
        status: status,
        pot: pot ?? this.pot,
        currentRound: currentRound ?? this.currentRound,
        communityCards: communityCards ?? this.communityCards,
        currentTurnPlayerId: currentTurnPlayerId ?? this.currentTurnPlayerId,
        playerHands: playerHands,
        playerBets: playerBets ?? this.playerBets,
        playerStacks: playerStacks ?? this.playerStacks,
        foldedPlayers: foldedPlayers ?? this.foldedPlayers,
        shownHandPlayerIds: shownHandPlayerIds,
        handCount: handCount,
        createdAt: createdAt,
        playersToAct: playersToAct ?? this.playersToAct,
      );
}
