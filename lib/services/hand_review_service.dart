import '../models/hand_model.dart';
import '../models/card_model.dart';
import '../models/hand_action_model.dart';
import '../models/game_model.dart' show BettingRound;

/// A single quiz question extracted from a real hand.
class HandReviewQuestion {
  final String handId;
  final int handNumber;
  final List<CardModel> holeCards;
  final List<CardModel> communityCards;
  final double pot;
  final double betToCall;
  final String description;
  final String whatPlayerDid;
  final String correctAction;
  final String explanation;

  const HandReviewQuestion({
    required this.handId,
    required this.handNumber,
    required this.holeCards,
    required this.communityCards,
    required this.pot,
    required this.betToCall,
    required this.description,
    required this.whatPlayerDid,
    required this.correctAction,
    required this.explanation,
  });
}

/// Service that turns real [HandModel] history into [HandReviewQuestion]s.
class HandReviewService {
  HandReviewService._();

  /// Extract up to 20 quiz questions from [hands] for [userId].
  ///
  /// For each hand the user participated in, the service finds the most
  /// interesting decision point (the first non-blind action the user took)
  /// and wraps it as a [HandReviewQuestion].
  static List<HandReviewQuestion> extractQuestions(
    List<HandModel> hands,
    String userId,
  ) {
    final questions = <HandReviewQuestion>[];

    for (final hand in hands) {
      if (questions.length >= 20) break;

      // Skip hands where the user was not a player
      final holeCards = hand.playerCards[userId];
      if (holeCards == null || holeCards.isEmpty) continue;

      // Find the first meaningful action by the user (skip blinds)
      final userActions = hand.actions.where(
        (a) =>
            a.playerId == userId &&
            a.actionType != ActionType.smallBlind &&
            a.actionType != ActionType.bigBlind,
      ).toList();

      if (userActions.isEmpty) continue;

      final action = userActions.first;

      // Build community cards visible at the time of the action
      final visibleCommunity = _communityCardsForRound(
        hand.communityCards,
        action.bettingRound,
      );

      // Estimate pot and bet-to-call at the decision point
      final pot = _estimatePotBefore(hand, action);
      final betToCall = action.amount ?? 0;

      // Determine what the player actually did
      final whatPlayerDid = _describeAction(action);

      // Build the correct-action recommendation
      final correctAction = _recommendAction(
        holeCards: holeCards,
        communityCards: visibleCommunity,
        pot: pot,
        betToCall: betToCall,
        playerAction: action,
      );

      final explanation = _buildExplanation(
        holeCards: holeCards,
        communityCards: visibleCommunity,
        pot: pot,
        betToCall: betToCall,
        playerAction: action,
        correctAction: correctAction,
        hand: hand,
        userId: userId,
      );

      final round = _roundName(action.bettingRound);
      final description = 'Hand #${hand.handNumber} — $round '
          '(pot: \$${pot.toStringAsFixed(2)}, '
          'to call: \$${betToCall.toStringAsFixed(2)})';

      questions.add(HandReviewQuestion(
        handId: hand.id,
        handNumber: hand.handNumber,
        holeCards: holeCards,
        communityCards: visibleCommunity,
        pot: pot,
        betToCall: betToCall,
        description: description,
        whatPlayerDid: whatPlayerDid,
        correctAction: correctAction,
        explanation: explanation,
      ));
    }

    return questions;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Return only the community cards that were on the board during [round].
  static List<CardModel> _communityCardsForRound(
    List<CardModel> all,
    BettingRound round,
  ) {
    switch (round) {
      case BettingRound.preflop:
        return [];
      case BettingRound.flop:
        return all.take(3).toList();
      case BettingRound.turn:
        return all.take(4).toList();
      case BettingRound.river:
        return all.toList();
    }
  }

  /// A rough estimate of the pot at the moment the user acted.
  ///
  /// We sum up all bets that occurred before [action] in the same round,
  /// falling back to the recorded pot amount as an upper bound.
  static double _estimatePotBefore(HandModel hand, HandActionModel action) {
    double pot = 0;
    for (final a in hand.actions) {
      if (a == action) break;
      if (a.amount != null) pot += a.amount!;
    }
    // Never return 0 — use the final pot if no prior actions have amounts
    return pot > 0 ? pot : hand.potAmount;
  }

  /// Human-readable label for a player action.
  static String _describeAction(HandActionModel action) {
    switch (action.actionType) {
      case ActionType.fold:
        return 'Folded';
      case ActionType.call:
        return 'Called \$${action.amount?.toStringAsFixed(2) ?? '0'}';
      case ActionType.raise:
        return 'Raised to \$${action.amount?.toStringAsFixed(2) ?? '0'}';
      case ActionType.check:
        return 'Checked';
      case ActionType.allIn:
        return 'Went all-in (\$${action.amount?.toStringAsFixed(2) ?? '0'})';
      case ActionType.smallBlind:
        return 'Small blind \$${action.amount?.toStringAsFixed(2) ?? '0'}';
      case ActionType.bigBlind:
        return 'Big blind \$${action.amount?.toStringAsFixed(2) ?? '0'}';
    }
  }

  /// Simple hand-strength heuristic: return a 0–1 score for hole cards.
  static double _holeCardStrength(List<CardModel> holeCards) {
    if (holeCards.length < 2) return 0;
    final a = holeCards[0];
    final b = holeCards[1];
    final hi = a.rankValue > b.rankValue ? a.rankValue : b.rankValue;
    final lo = a.rankValue < b.rankValue ? a.rankValue : b.rankValue;
    final isPair = a.rank == b.rank;
    final isSuited = a.suit == b.suit;
    // Premium pairs
    if (isPair && hi >= 10) return 1.0;
    if (isPair) return 0.6 + (hi - 2) / 40.0;
    // High cards
    final score = (hi + lo) / 28.0; // max 28 = A + K
    return isSuited ? (score + 0.1).clamp(0.0, 1.0) : score;
  }

  /// Recommend a simple GTO-leaning action given the hand state.
  static String _recommendAction({
    required List<CardModel> holeCards,
    required List<CardModel> communityCards,
    required double pot,
    required double betToCall,
    required HandActionModel playerAction,
  }) {
    final strength = _holeCardStrength(holeCards);
    final potOdds = pot > 0 ? betToCall / (pot + betToCall) : 0.0;

    if (communityCards.isEmpty) {
      // Pre-flop
      if (strength >= 0.85) return 'Raise';
      if (strength >= 0.55) return betToCall > 0 ? 'Call' : 'Raise';
      if (potOdds < 0.25 && betToCall > 0) return 'Call';
      return betToCall > 0 ? 'Fold' : 'Check';
    }

    // Post-flop: simplified equity-based advice
    if (strength >= 0.80) return 'Raise';
    if (strength >= 0.50) return betToCall > 0 ? 'Call' : 'Check';
    if (potOdds < 0.20 && betToCall > 0) return 'Call';
    return betToCall > 0 ? 'Fold' : 'Check';
  }

  /// Build a natural-language explanation for the recommended action.
  static String _buildExplanation({
    required List<CardModel> holeCards,
    required List<CardModel> communityCards,
    required double pot,
    required double betToCall,
    required HandActionModel playerAction,
    required String correctAction,
    required HandModel hand,
    required String userId,
  }) {
    final strength = _holeCardStrength(holeCards);
    final potOdds = pot > 0 ? betToCall / (pot + betToCall) : 0.0;
    final playerDidFold = playerAction.actionType == ActionType.fold;
    final playerWon = hand.winnerId == userId;

    final buf = StringBuffer();

    // Summarise hole cards
    final cardLabels = holeCards.map((c) => c.display).join(' ');
    buf.write('You held $cardLabels. ');

    // Describe hand strength
    if (strength >= 0.85) {
      buf.write('This is a premium hand — you should be building the pot. ');
    } else if (strength >= 0.55) {
      buf.write('This is a medium-strength hand with good playability. ');
    } else {
      buf.write('This hand has limited strength and is often a fold. ');
    }

    // Pot odds comment
    if (betToCall > 0) {
      final poPct = (potOdds * 100).toStringAsFixed(0);
      buf.write(
          'Pot odds were $poPct% — you needed roughly that much equity to call. ');
    }

    // Outcome
    if (playerWon) {
      buf.write('You won this hand');
      if (playerDidFold) buf.write(' despite folding (the pot was uncontested)');
      buf.write('. ');
    } else {
      buf.write(
          playerDidFold ? 'You folded and lost your invested chips. ' : 'You lost this hand. ');
    }

    // Recommendation summary
    buf.write('The recommended action here is $correctAction.');
    return buf.toString();
  }

  static String _roundName(BettingRound round) {
    switch (round) {
      case BettingRound.preflop:
        return 'Pre-flop';
      case BettingRound.flop:
        return 'Flop';
      case BettingRound.turn:
        return 'Turn';
      case BettingRound.river:
        return 'River';
    }
  }
}
