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
}
