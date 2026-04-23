import 'dart:math';

class PotOddsScenario {
  final double pot;
  final double betSize;
  final double equityPercent;
  final String description;
  final String correctAction;
  final String explanation;

  const PotOddsScenario({
    required this.pot,
    required this.betSize,
    required this.equityPercent,
    required this.description,
    required this.correctAction,
    required this.explanation,
  });
}

enum _DrawType {
  flushDraw,
  oesd,
  gutshot,
  twoOvercards,
  comboDraw,
}

class PotOddsScenarioGenerator {
  static final Random _random = Random();

  /// Round [value] to the nearest [step].
  static double _roundTo(double value, double step) {
    return (value / step).round() * step;
  }

  /// Generate a scenario with fully random parameters.
  static PotOddsScenario generate() =>
      _generateWithConstraint(minEdge: null, maxEdge: null);

  /// Generate an "Easy" scenario where equity clearly exceeds or misses the
  /// required pot odds by at least [minEdge]%.
  static PotOddsScenario generateEasy() =>
      _generateWithConstraint(minEdge: 10.0, maxEdge: null);

  /// Generate a "Hard" scenario where equity is within [maxEdge]% of the
  /// required pot odds.
  static PotOddsScenario generateHard() =>
      _generateWithConstraint(minEdge: null, maxEdge: 5.0);

  static PotOddsScenario _generateWithConstraint({
    double? minEdge,
    double? maxEdge,
  }) {
    // We may need to retry to satisfy the constraint.
    for (int attempt = 0; attempt < 500; attempt++) {
      final scenario = _buildScenario();

      final needed =
          scenario.betSize / (scenario.pot + scenario.betSize + scenario.betSize) * 100;
      final edge = (scenario.equityPercent - needed).abs();

      if (minEdge != null && edge < minEdge) continue;
      if (maxEdge != null && edge > maxEdge) continue;

      return scenario;
    }

    // Fallback: return any valid scenario.
    return _buildScenario();
  }

  static PotOddsScenario _buildScenario() {
    // Random pot: 10–200, rounded to nearest 5.
    final pot = _roundTo(10 + _random.nextDouble() * 190, 5);

    // Random bet: 20–150% of pot, rounded to nearest 5.
    final betPercent = 0.20 + _random.nextDouble() * 1.30;
    final betSize = _roundTo(pot * betPercent, 5).clamp(5.0, 300.0);

    // Pick a draw type randomly.
    final drawType = _pickDrawType();

    final equityPercent = _equityFor(drawType);
    final drawName = _drawName(drawType);

    // Build description.
    final description =
        'The pot is \$${pot.toStringAsFixed(0)}. Villain bets \$${betSize.toStringAsFixed(0)}. '
        'You hold a $drawName.';

    // Calculate pot odds needed.
    final needed = betSize / (pot + betSize + betSize) * 100;
    final neededStr = needed.toStringAsFixed(1);
    final equityStr = equityPercent.toStringAsFixed(0);

    final correctAction = equityPercent > needed ? 'call' : 'fold';

    final explanation =
        'Pot odds: you need $neededStr% equity to call. '
        'You have $equityStr%, so $correctAction is correct.';

    return PotOddsScenario(
      pot: pot,
      betSize: betSize,
      equityPercent: equityPercent,
      description: description,
      correctAction: correctAction,
      explanation: explanation,
    );
  }

  /// Pick a draw type using the weighted distribution from the spec.
  static _DrawType _pickDrawType() {
    // Weights (must sum to 100 for clarity, but we just use cumulative):
    // flush draw   36 %
    // oesd         32 %
    // gutshot      16 %
    // two overcards 24 %
    // combo draw   54 %
    // Total weight = 162 (intentional – each probability is independent in
    // the spec, so we normalise).
    const weights = [36, 32, 16, 24, 54]; // total = 162
    const total = 36 + 32 + 16 + 24 + 54;

    final roll = _random.nextInt(total);
    int cumulative = 0;
    for (int i = 0; i < weights.length; i++) {
      cumulative += weights[i];
      if (roll < cumulative) return _DrawType.values[i];
    }
    return _DrawType.flushDraw;
  }

  static double _equityFor(_DrawType type) {
    switch (type) {
      case _DrawType.flushDraw:
        return 36;
      case _DrawType.oesd:
        return 32;
      case _DrawType.gutshot:
        return 16;
      case _DrawType.twoOvercards:
        return 24;
      case _DrawType.comboDraw:
        return 54;
    }
  }

  static String _drawName(_DrawType type) {
    switch (type) {
      case _DrawType.flushDraw:
        return 'flush draw (36% to hit by the river)';
      case _DrawType.oesd:
        return 'open-ended straight draw (32% to hit by the river)';
      case _DrawType.gutshot:
        return 'gutshot straight draw (16% to hit by the river)';
      case _DrawType.twoOvercards:
        return 'two overcards (24% equity by the river)';
      case _DrawType.comboDraw:
        return 'combo draw – flush + straight (54% to hit by the river)';
    }
  }
}
