/// Wraps a set of hand codes and provides utility accessors.
///
/// Hand codes follow the standard notation:
///   - Pairs: rank+rank, e.g. "AA", "KK", "22"
///   - Suited: rank1+rank2+'s', e.g. "AKs"
///   - Offsuit: rank1+rank2+'o', e.g. "AKo"
/// where rank1 ≥ rank2 in the canonical order A K Q J T 9 8 7 6 5 4 3 2.
class PokerRange {
  final Set<String> _hands;

  const PokerRange(Set<String> hands) : _hands = hands;

  // ── Canonical rank / hand ordering ─────────────────────────────────────────

  static const List<String> _ranks = [
    'A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2'
  ];

  /// All 169 unique starting-hand codes in standard grid order
  /// (descending rank, pairs on diagonal, suited above, offsuit below).
  static final List<String> allHands = _buildAllHands();

  static List<String> _buildAllHands() {
    final result = <String>[];
    for (int i = 0; i < _ranks.length; i++) {
      for (int j = 0; j < _ranks.length; j++) {
        final r1 = _ranks[i];
        final r2 = _ranks[j];
        if (i == j) {
          result.add('$r1$r2'); // pair
        } else if (i < j) {
          result.add('$r1${r2}s'); // suited (above diagonal)
        } else {
          result.add('$r2${r1}o'); // offsuit (below diagonal, canonical order)
        }
      }
    }
    return List.unmodifiable(result);
  }

  // ── Factory / builder helpers ───────────────────────────────────────────────

  /// Builds a canonical hand-code string from two rank characters and a
  /// suited flag. Rank1/rank2 are reordered so the higher rank comes first.
  static String handCode(String rank1, String rank2, bool suited) {
    final i1 = _ranks.indexOf(rank1);
    final i2 = _ranks.indexOf(rank2);
    if (i1 < 0 || i2 < 0) throw ArgumentError('Unknown rank: $rank1 or $rank2');
    if (i1 == i2) return '$rank1$rank2'; // pair
    final hi = i1 < i2 ? rank1 : rank2;
    final lo = i1 < i2 ? rank2 : rank1;
    return suited ? '$hi${lo}s' : '$hi${lo}o';
  }

  // ── Core access ────────────────────────────────────────────────────────────

  /// Returns `true` if [handCode] is in this range.
  bool contains(String handCode) => _hands.contains(handCode);

  /// The raw set of hand codes.
  Set<String> get hands => Set.unmodifiable(_hands);

  // ── Combo counting ─────────────────────────────────────────────────────────

  /// Number of distinct starting-hand combos represented by this range.
  ///   - Pairs:    6 combos  (C(4,2))
  ///   - Suited:   4 combos  (one per suit)
  ///   - Offsuit: 12 combos  (4×3 suit combinations)
  double get size {
    double total = 0;
    for (final code in _hands) {
      if (code.length == 2) {
        total += 6; // pair
      } else if (code.endsWith('s')) {
        total += 4; // suited
      } else {
        total += 12; // offsuit
      }
    }
    return total;
  }

  /// Range size as a percentage of the 1 326 possible starting hands.
  double get percentage => size / 1326 * 100;

  // ── Overrides ──────────────────────────────────────────────────────────────

  @override
  String toString() =>
      'PokerRange(${_hands.length} hands, '
      '${size.toStringAsFixed(0)} combos, '
      '${percentage.toStringAsFixed(1)}%)';
}
