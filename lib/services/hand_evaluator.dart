import '../models/card_model.dart';

enum HandRank {
  highCard,
  onePair,
  twoPair,
  threeOfAKind,
  straight,
  flush,
  fullHouse,
  fourOfAKind,
  straightFlush,
  royalFlush,
}

class EvaluatedHand {
  final HandRank rank;
  final String description;
  final List<CardModel> bestFive;

  const EvaluatedHand({
    required this.rank,
    required this.description,
    required this.bestFive,
  });
}

class HandEvaluator {
  // Evaluate best 5-card hand from up to 7 cards
  static EvaluatedHand evaluate(List<CardModel> cards) {
    if (cards.length < 2) {
      return EvaluatedHand(
        rank: HandRank.highCard,
        description: 'High Card',
        bestFive: cards,
      );
    }

    // Generate all 5-card combinations
    final combos = _combinations(cards, 5);
    EvaluatedHand? best;

    for (final combo in combos) {
      final hand = _evaluateFive(combo);
      if (best == null || hand.rank.index > best.rank.index) {
        best = hand;
      }
    }

    return best ?? _evaluateFive(cards.take(5).toList());
  }

  static EvaluatedHand _evaluateFive(List<CardModel> five) {
    final sorted = [...five]..sort((a, b) => b.rankValue.compareTo(a.rankValue));
    final ranks = sorted.map((c) => c.rankValue).toList();
    final suits = sorted.map((c) => c.suit).toList();

    final isFlush = suits.toSet().length == 1;
    final isStraight = _isStraight(ranks);

    if (isFlush && isStraight) {
      final isRoyal = ranks.first == 14 && ranks.last == 10;
      return EvaluatedHand(
        rank: isRoyal ? HandRank.royalFlush : HandRank.straightFlush,
        description: isRoyal
            ? 'Royal Flush'
            : 'Straight Flush, ${_rankName(ranks.first)} High',
        bestFive: sorted,
      );
    }

    final groups = _groupByRank(ranks);
    final counts = groups.values.toList()..sort((a, b) => b.compareTo(a));

    if (counts[0] == 4) {
      final quad = groups.entries.firstWhere((e) => e.value == 4).key;
      return EvaluatedHand(
        rank: HandRank.fourOfAKind,
        description: 'Four of a Kind, ${_rankName(quad)}s',
        bestFive: sorted,
      );
    }

    if (counts[0] == 3 && counts[1] == 2) {
      final trip = groups.entries.firstWhere((e) => e.value == 3).key;
      return EvaluatedHand(
        rank: HandRank.fullHouse,
        description: 'Full House, ${_rankName(trip)}s Full',
        bestFive: sorted,
      );
    }

    if (isFlush) {
      return EvaluatedHand(
        rank: HandRank.flush,
        description: '${_suitName(suits.first)} Flush, ${_rankName(ranks.first)} High',
        bestFive: sorted,
      );
    }

    if (isStraight) {
      return EvaluatedHand(
        rank: HandRank.straight,
        description: 'Straight, ${_rankName(ranks.first)} High',
        bestFive: sorted,
      );
    }

    if (counts[0] == 3) {
      final trip = groups.entries.firstWhere((e) => e.value == 3).key;
      return EvaluatedHand(
        rank: HandRank.threeOfAKind,
        description: 'Three ${_rankName(trip)}s',
        bestFive: sorted,
      );
    }

    if (counts[0] == 2 && counts[1] == 2) {
      final pairs = groups.entries
          .where((e) => e.value == 2)
          .map((e) => e.key)
          .toList()
        ..sort((a, b) => b.compareTo(a));
      return EvaluatedHand(
        rank: HandRank.twoPair,
        description: 'Two Pair, ${_rankName(pairs[0])}s and ${_rankName(pairs[1])}s',
        bestFive: sorted,
      );
    }

    if (counts[0] == 2) {
      final pair = groups.entries.firstWhere((e) => e.value == 2).key;
      return EvaluatedHand(
        rank: HandRank.onePair,
        description: 'Pair of ${_rankName(pair)}s',
        bestFive: sorted,
      );
    }

    return EvaluatedHand(
      rank: HandRank.highCard,
      description: '${_rankName(ranks.first)}-High',
      bestFive: sorted,
    );
  }

  static bool _isStraight(List<int> ranks) {
    final sorted = [...ranks]..sort((a, b) => b.compareTo(a));
    // Normal straight
    bool normal = true;
    for (int i = 0; i < sorted.length - 1; i++) {
      if (sorted[i] - sorted[i + 1] != 1) {
        normal = false;
        break;
      }
    }
    if (normal) return true;
    // Wheel (A-2-3-4-5)
    if (sorted.length == 5) {
      final wheel = [14, 5, 4, 3, 2];
      return sorted.toString() == wheel.toString();
    }
    return false;
  }

  static Map<int, int> _groupByRank(List<int> ranks) {
    final map = <int, int>{};
    for (final r in ranks) {
      map[r] = (map[r] ?? 0) + 1;
    }
    return map;
  }

  static List<List<CardModel>> _combinations(List<CardModel> cards, int r) {
    final result = <List<CardModel>>[];
    void helper(int start, List<CardModel> current) {
      if (current.length == r) {
        result.add([...current]);
        return;
      }
      for (int i = start; i < cards.length; i++) {
        current.add(cards[i]);
        helper(i + 1, current);
        current.removeLast();
      }
    }
    helper(0, []);
    return result;
  }

  static String _rankName(int rank) {
    const names = {
      14: 'Ace', 13: 'King', 12: 'Queen', 11: 'Jack', 10: 'Ten',
      9: 'Nine', 8: 'Eight', 7: 'Seven', 6: 'Six', 5: 'Five',
      4: 'Four', 3: 'Three', 2: 'Two',
    };
    return names[rank] ?? '$rank';
  }

  static String _suitName(String suit) {
    const names = {'s': 'Spade', 'h': 'Heart', 'd': 'Diamond', 'c': 'Club'};
    return names[suit] ?? suit;
  }

  // Quick description for a 2-card hole hand (before community cards)
  static String holeHandDescription(List<CardModel> hole) {
    if (hole.length < 2) return '';
    final sorted = [...hole]..sort((a, b) => b.rankValue.compareTo(a.rankValue));
    final isPair = sorted[0].rankValue == sorted[1].rankValue;
    final isSuited = sorted[0].suit == sorted[1].suit;
    if (isPair) return 'Pocket ${_rankName(sorted[0].rankValue)}s';
    final suffix = isSuited ? 'Suited' : 'Offsuit';
    return '${_rankName(sorted[0].rankValue)}-${_rankName(sorted[1].rankValue)} $suffix';
  }
}
