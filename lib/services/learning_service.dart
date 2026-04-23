import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/learning_progress_model.dart';

class LearningService {
  static final _db = FirebaseFirestore.instance;

  static DocumentReference _doc(String userId) => _db
      .collection('users')
      .doc(userId)
      .collection('learningProgress')
      .doc('main');

  // ─── Read ─────────────────────────────────────────────────────────────────

  static Future<LearningProgressModel> getProgress(String userId) async {
    final snap = await _doc(userId).get();
    if (!snap.exists) return LearningProgressModel.empty(userId);
    return LearningProgressModel.fromMap(
        userId, snap.data()! as Map<String, dynamic>);
  }

  static Future<void> saveProgress(LearningProgressModel progress) =>
      _doc(progress.userId).set(progress.toMap());

  static Stream<LearningProgressModel> streamProgress(String userId) =>
      _doc(userId).snapshots().map((snap) {
        if (!snap.exists) return LearningProgressModel.empty(userId);
        return LearningProgressModel.fromMap(
            userId, snap.data()! as Map<String, dynamic>);
      });

  // ─── Drill result recording ───────────────────────────────────────────────

  static Future<void> recordDrillResult({
    required String userId,
    required String drillId,
    required bool correct,
  }) async {
    final docRef = _doc(userId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final progress = snap.exists
          ? LearningProgressModel.fromMap(
              userId, snap.data()! as Map<String, dynamic>)
          : LearningProgressModel.empty(userId);

      // Update drill stats
      final existing =
          progress.drillStats[drillId] ?? const DrillStat();
      final updated = existing.copyWith(
        attempts: existing.attempts + 1,
        correct: correct ? existing.correct + 1 : existing.correct,
      );
      final newStats = Map<String, DrillStat>.from(progress.drillStats)
        ..[drillId] = updated;

      // Streak logic
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      int newStreak = progress.streakDays;
      if (progress.lastDrillDate == null) {
        newStreak = 1;
      } else {
        final last = progress.lastDrillDate!;
        final lastDate = DateTime(last.year, last.month, last.day);
        final diff = todayDate.difference(lastDate).inDays;
        if (diff == 0) {
          // Same day — streak unchanged
        } else if (diff == 1) {
          // Consecutive day
          newStreak = progress.streakDays + 1;
        } else {
          // Gap — reset
          newStreak = 1;
        }
      }

      // XP: +10 for correct, +2 regardless
      final xpGain = correct ? 12 : 2;
      final newXp = progress.xp + xpGain;

      final updatedProgress = progress.copyWith(
        xp: newXp,
        streakDays: newStreak,
        lastDrillDate: todayDate,
        drillStats: newStats,
      );

      // Badge checks
      final badges = List<String>.from(updatedProgress.earnedBadges);

      // first_drill
      final totalAttempts =
          newStats.values.fold<int>(0, (acc, s) => acc + s.attempts);
      if (totalAttempts == 1 && !badges.contains('first_drill')) {
        badges.add('first_drill');
      }

      // pot_odds_pro — 20 correct pot-odds answers
      final potOdds = newStats['pot_odds'];
      if (potOdds != null &&
          potOdds.correct >= 20 &&
          !badges.contains('pot_odds_pro')) {
        badges.add('pot_odds_pro');
      }

      // range_master — 10 range trainer sessions completed
      final rangeTrainer = newStats['range_trainer'];
      if (rangeTrainer != null &&
          rangeTrainer.attempts >= 10 &&
          !badges.contains('range_master')) {
        badges.add('range_master');
      }

      // scenario_shark — 50 correct scenario drill answers
      final scenarios = newStats['scenarios'];
      if (scenarios != null &&
          scenarios.correct >= 50 &&
          !badges.contains('scenario_shark')) {
        badges.add('scenario_shark');
      }

      // study_streak_7 / study_streak_30
      if (newStreak >= 7 && !badges.contains('study_streak_7')) {
        badges.add('study_streak_7');
      }
      if (newStreak >= 30 && !badges.contains('study_streak_30')) {
        badges.add('study_streak_30');
      }

      final finalProgress = updatedProgress.copyWith(earnedBadges: badges);
      tx.set(docRef, finalProgress.toMap());
    });
  }

  // ─── Concept reads ────────────────────────────────────────────────────────

  static Future<void> markConceptRead(
      String userId, String conceptId) async {
    final docRef = _doc(userId);
    // Award XP atomically alongside the arrayUnion
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      final progress = snap.exists
          ? LearningProgressModel.fromMap(
              userId, snap.data()! as Map<String, dynamic>)
          : LearningProgressModel.empty(userId);

      if (progress.conceptsRead.contains(conceptId)) return;

      final newConceptsRead = List<String>.from(progress.conceptsRead)
        ..add(conceptId);
      final newXp = progress.xp + 5;

      final badges = List<String>.from(progress.earnedBadges);
      if (newConceptsRead.length >= 20 &&
          !badges.contains('concept_graduate')) {
        badges.add('concept_graduate');
      }

      final updated = progress.copyWith(
        xp: newXp,
        conceptsRead: newConceptsRead,
        earnedBadges: badges,
      );
      tx.set(docRef, updated.toMap());
    });
  }

  // ─── Badge award ─────────────────────────────────────────────────────────

  static Future<void> awardBadge(String userId, String badgeId) => _doc(userId)
      .update({
    'earnedBadges': FieldValue.arrayUnion([badgeId]),
  });
}
