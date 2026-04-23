import '../models/hand_model.dart';
import '../models/hand_action_model.dart';
import '../models/game_model.dart' show BettingRound;

class XpEvent {
  final String label;
  final int xp;
  final bool isPositive;

  const XpEvent({
    required this.label,
    required this.xp,
    required this.isPositive,
  });

  Map<String, dynamic> toMap() => {
        'label': label,
        'xp': xp,
        'isPositive': isPositive,
      };

  factory XpEvent.fromMap(Map<String, dynamic> map) => XpEvent(
        label: map['label'] as String? ?? '',
        xp: (map['xp'] as num?)?.toInt() ?? 0,
        isPositive: map['isPositive'] as bool? ?? true,
      );
}

class DecisionEvaluator {
  /// Evaluate a single completed hand for a given player and return XP events.
  static List<XpEvent> evaluateHand(
      HandModel hand, String userId, double bigBlind) {
    final events = <XpEvent>[];

    final userActions = hand.actions
        .where((a) => a.playerId == userId)
        .toList();
    final preflopActions = userActions
        .where((a) => a.bettingRound == BettingRound.preflop)
        .toList();
    final flopActions = userActions
        .where((a) => a.bettingRound == BettingRound.flop)
        .toList();
    final riverActions = userActions
        .where((a) => a.bettingRound == BettingRound.river)
        .toList();

    final userWon = hand.winnerId == userId;

    // ── Preflop decisions ────────────────────────────────────────────────────

    final preflopRaised = preflopActions
        .any((a) => a.actionType == ActionType.raise);
    final userFolded = userActions
        .any((a) => a.actionType == ActionType.fold);

    // Detect whether there was a 3-bet before user's raise
    // (i.e. user raised after someone else had already raised preflop)
    bool userThreeBet = false;
    if (preflopRaised) {
      // Find the first raise by any player in preflop
      final allPreflopActions = hand.actions
          .where((a) => a.bettingRound == BettingRound.preflop)
          .toList();
      int raiseCountBefore = 0;
      for (final a in allPreflopActions) {
        if (a.playerId == userId && a.actionType == ActionType.raise) {
          // User's raise — if there was already a raise by another player, this is a 3-bet
          if (raiseCountBefore >= 1) {
            userThreeBet = true;
          }
          break;
        }
        if (a.actionType == ActionType.raise) {
          raiseCountBefore++;
        }
      }
    }

    // Check if someone 3-bet against user (user raised, then another player re-raised)
    bool facedThreeBet = false;
    if (preflopRaised && !userThreeBet) {
      final allPreflopActions = hand.actions
          .where((a) => a.bettingRound == BettingRound.preflop)
          .toList();
      bool userRaiseSeen = false;
      for (final a in allPreflopActions) {
        if (a.playerId == userId && a.actionType == ActionType.raise) {
          userRaiseSeen = true;
        } else if (userRaiseSeen &&
            a.playerId != userId &&
            a.actionType == ActionType.raise) {
          facedThreeBet = true;
          break;
        }
      }
    }

    if (userThreeBet && userWon) {
      events.add(const XpEvent(
          label: '3-bet paid off', xp: 10, isPositive: true));
    } else if (preflopRaised && !userThreeBet && userWon && !hand.wasShowdown) {
      events.add(const XpEvent(
          label: 'Successful preflop steal', xp: 8, isPositive: true));
    }

    if (facedThreeBet && userFolded) {
      events.add(const XpEvent(
          label: 'Disciplined fold vs 3-bet', xp: 5, isPositive: true));
    }

    // Limped preflop: called the big blind without raising, and not in BB position.
    // Flagged as neutral/weak — no XP awarded per spec (intentionally no-op).

    // ── Postflop decisions ───────────────────────────────────────────────────

    // C-bet: user raised preflop and bet (raised) on the flop
    if (preflopRaised) {
      final flopRaised = flopActions
          .any((a) => a.actionType == ActionType.raise);
      if (flopRaised) {
        events.add(const XpEvent(
            label: 'C-bet executed', xp: 5, isPositive: true));
      }
    }

    // Won at showdown with top pair or better
    if (userWon && hand.wasShowdown) {
      final rank = hand.handRank.toLowerCase();
      final strongHands = [
        'two pair', 'three of a kind', 'straight', 'flush',
        'full house', 'four of a kind', 'straight flush', 'royal flush',
        'top pair', 'pair'
      ];
      // handRank description contains at least "pair" for top pair or better
      if (strongHands.any((h) => rank.contains(h))) {
        events.add(const XpEvent(
            label: 'Value bet rewarded', xp: 8, isPositive: true));
      }
    }

    // Check-raise: player checked then raised on the same street
    for (final round in BettingRound.values) {
      final roundActions = userActions
          .where((a) => a.bettingRound == round)
          .toList();
      bool checkedFirst = false;
      for (final a in roundActions) {
        if (a.actionType == ActionType.check) {
          checkedFirst = true;
        } else if (checkedFirst && a.actionType == ActionType.raise) {
          events.add(const XpEvent(
              label: 'Check-raise executed', xp: 10, isPositive: true));
          break;
        }
      }
    }

    // River value bet: user bet on river and won at showdown
    if (userWon && hand.wasShowdown) {
      final riverBet = riverActions
          .any((a) => a.actionType == ActionType.raise);
      if (riverBet) {
        events.add(const XpEvent(
            label: 'River value bet', xp: 12, isPositive: true));
      }
    }

    return events;
  }
}
