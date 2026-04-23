import 'package:cloud_firestore/cloud_firestore.dart';

/// A simple value class recording per-drill statistics.
class DrillStat {
  final int attempts;
  final int correct;
  final int bestStreak;

  const DrillStat({
    this.attempts = 0,
    this.correct = 0,
    this.bestStreak = 0,
  });

  Map<String, dynamic> toMap() => {
        'attempts': attempts,
        'correct': correct,
        'bestStreak': bestStreak,
      };

  factory DrillStat.fromMap(Map<String, dynamic> map) => DrillStat(
        attempts: (map['attempts'] as int?) ?? 0,
        correct: (map['correct'] as int?) ?? 0,
        bestStreak: (map['bestStreak'] as int?) ?? 0,
      );

  DrillStat copyWith({int? attempts, int? correct, int? bestStreak}) =>
      DrillStat(
        attempts: attempts ?? this.attempts,
        correct: correct ?? this.correct,
        bestStreak: bestStreak ?? this.bestStreak,
      );
}

class LearningProgressModel {
  final String userId;
  final int xp;
  final int streakDays;
  final DateTime? lastDrillDate;
  final List<String> earnedBadges;
  final Map<String, DrillStat> drillStats;
  final List<String> conceptsRead;

  const LearningProgressModel({
    required this.userId,
    required this.xp,
    required this.streakDays,
    this.lastDrillDate,
    required this.earnedBadges,
    required this.drillStats,
    required this.conceptsRead,
  });

  /// Computes the player level from accumulated XP.
  String get level {
    if (xp >= 10000) return 'GTO Wizard';
    if (xp >= 6000) return 'Crusher';
    if (xp >= 3000) return 'Shark';
    if (xp >= 1500) return 'Grinder';
    if (xp >= 500) return 'Regular';
    return 'Fish';
  }

  /// Returns an empty model for a user with no recorded progress.
  static LearningProgressModel empty(String userId) => LearningProgressModel(
        userId: userId,
        xp: 0,
        streakDays: 0,
        lastDrillDate: null,
        earnedBadges: const [],
        drillStats: const {},
        conceptsRead: const [],
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'xp': xp,
        'streakDays': streakDays,
        'lastDrillDate':
            lastDrillDate != null ? Timestamp.fromDate(lastDrillDate!) : null,
        'earnedBadges': earnedBadges,
        'drillStats': drillStats
            .map((key, value) => MapEntry(key, value.toMap())),
        'conceptsRead': conceptsRead,
      };

  factory LearningProgressModel.fromMap(
      String userId, Map<String, dynamic> map) {
    final rawStats =
        (map['drillStats'] as Map<String, dynamic>?) ?? {};
    final drillStats = rawStats.map(
      (key, value) =>
          MapEntry(key, DrillStat.fromMap(Map<String, dynamic>.from(value))),
    );

    DateTime? lastDrillDate;
    final rawDate = map['lastDrillDate'];
    if (rawDate is Timestamp) {
      lastDrillDate = rawDate.toDate();
    }

    return LearningProgressModel(
      userId: userId,
      xp: (map['xp'] as int?) ?? 0,
      streakDays: (map['streakDays'] as int?) ?? 0,
      lastDrillDate: lastDrillDate,
      earnedBadges:
          List<String>.from((map['earnedBadges'] as List?) ?? []),
      drillStats: drillStats,
      conceptsRead:
          List<String>.from((map['conceptsRead'] as List?) ?? []),
    );
  }

  LearningProgressModel copyWith({
    int? xp,
    int? streakDays,
    DateTime? lastDrillDate,
    List<String>? earnedBadges,
    Map<String, DrillStat>? drillStats,
    List<String>? conceptsRead,
    bool clearLastDrillDate = false,
  }) =>
      LearningProgressModel(
        userId: userId,
        xp: xp ?? this.xp,
        streakDays: streakDays ?? this.streakDays,
        lastDrillDate:
            clearLastDrillDate ? null : (lastDrillDate ?? this.lastDrillDate),
        earnedBadges: earnedBadges ?? this.earnedBadges,
        drillStats: drillStats ?? this.drillStats,
        conceptsRead: conceptsRead ?? this.conceptsRead,
      );

  // ── Computed getters for UI compatibility ──────────────────────────────

  /// Human-readable level name derived from XP.
  String get levelName => level;

  /// Alias for [xp] matching the progress-tab field name.
  int get currentXp => xp;

  /// XP threshold at which the current level begins.
  int get xpLevelFloor {
    if (xp >= 10000) return 10000;
    if (xp >= 6000) return 6000;
    if (xp >= 3000) return 3000;
    if (xp >= 1500) return 1500;
    if (xp >= 500) return 500;
    return 0;
  }

  /// XP required to reach the next level.
  int get xpToNextLevel {
    if (xp >= 10000) return 10000;
    if (xp >= 6000) return 10000;
    if (xp >= 3000) return 6000;
    if (xp >= 1500) return 3000;
    if (xp >= 500) return 1500;
    return 500;
  }

  /// XP earned within the current level band.
  int get xpInCurrentLevel => xp - xpLevelFloor;

  /// Total XP needed to span the current level band.
  int get xpForNextLevel => xpToNextLevel - xpLevelFloor;

  /// Progress fraction (0.0–1.0) within the current level band.
  double get levelProgress {
    final span = xpForNextLevel;
    if (span <= 0) return 1.0;
    return (xpInCurrentLevel / span).clamp(0.0, 1.0);
  }

  /// Returns true if the user has already attempted today's daily puzzle.
  bool get solvedToday {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    if (lastDrillDate == null) return false;
    final last = lastDrillDate!;
    final lastDate = DateTime(last.year, last.month, last.day);
    // Has a daily_puzzle drill result from today
    final hasPuzzleToday =
        drillStats.keys.any((k) => k.startsWith('daily_puzzle_'));
    return hasPuzzleToday &&
        lastDate.isAtSameMomentAs(todayDate);
  }

  /// Integer level index (1 = Fish … 6 = GTO Wizard).
  int get levelIndex {
    if (xp >= 10000) return 6;
    if (xp >= 6000) return 5;
    if (xp >= 3000) return 4;
    if (xp >= 1500) return 3;
    if (xp >= 500) return 2;
    return 1;
  }

  /// Alias for [streakDays].
  int get currentStreak => streakDays;

  /// 7-element list of booleans indicating activity for M–S of the current week.
  /// Derived from [streakDays]: the last N days of the week are marked active.
  List<bool> get weekActivity =>
      List.generate(7, (i) => i >= (7 - streakDays.clamp(0, 7)));

  /// Alias for [earnedBadges] matching the progress-tab field name.
  List<String> get earnedBadgeIds => earnedBadges;

  /// Placeholder recent activity list — sourced from drill stats.
  List<LearningActivityEntry> get recentActivity => const [];

  // ── Per-skill accuracy derived from drillStats ─────────────────────────

  double get preflopRanges => accuracyFor('range_trainer');
  double get potOdds => accuracyFor('pot_odds');
  double get decisionMaking => accuracyFor('scenarios');
  double get boardTexture => accuracyFor('board_texture');
  double get handReading => accuracyFor('hand_review');

  /// Returns the accuracy (0.0–1.0) for a given drill prefix.
  double accuracyFor(String drillIdPrefix) {
    final matching = drillStats.entries
        .where((e) => e.key.startsWith(drillIdPrefix))
        .toList();
    if (matching.isEmpty) return 0.0;
    final totalAttempts = matching.fold(0, (s, e) => s + e.value.attempts);
    final totalCorrect = matching.fold(0, (s, e) => s + e.value.correct);
    if (totalAttempts == 0) return 0.0;
    return totalCorrect / totalAttempts;
  }
}

/// Lightweight activity entry used for the recent-activity feed in the UI.
class LearningActivityEntry {
  final String description;
  final DateTime timestamp;
  final int xp;

  const LearningActivityEntry({
    required this.description,
    required this.timestamp,
    required this.xp,
  });
}
