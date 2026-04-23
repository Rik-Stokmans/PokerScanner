import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';
import '../models/hand_model.dart';
import '../models/invitation_model.dart';
import '../models/friendship_model.dart';
import '../models/deck_model.dart';
import '../services/firestore_service.dart';
import '../services/ble_service.dart';

// ─── Auth ─────────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final auth = ref.watch(authStateProvider);
  return auth.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return FirestoreService.getUserStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ─── Game ─────────────────────────────────────────────────────────────────

final activeGameProvider = StreamProvider<GameModel?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user?.currentGameId == null) return Stream.value(null);
      return FirestoreService.getGameStream(user!.currentGameId!);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// ─── Hands ────────────────────────────────────────────────────────────────

final activeGameHandsProvider = StreamProvider<List<HandModel>>((ref) {
  final gameAsync = ref.watch(activeGameProvider);
  return gameAsync.when(
    data: (game) {
      if (game == null) return Stream.value([]);
      return FirestoreService.getGameHandsStream(game.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final userRecentHandsProvider = FutureProvider<List<HandModel>>((ref) async {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  return FirestoreService.getUserRecentHands(user.id);
});

// ─── Session Analysis ─────────────────────────────────────────────────────

class SessionStats {
  final double pnl;
  final int handsPlayed;
  final Duration duration;
  final double bbPer100;
  final Map<String, double> positionalPnl;

  const SessionStats({
    required this.pnl,
    required this.handsPlayed,
    required this.duration,
    required this.bbPer100,
    required this.positionalPnl,
  });

  String get pnlFormatted {
    final sign = pnl >= 0 ? '+' : '';
    return '$sign\$${pnl.abs().toStringAsFixed(0)}';
  }

  String get durationFormatted {
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  String get bbPer100Formatted {
    final sign = bbPer100 >= 0 ? '+' : '';
    return '$sign${bbPer100.toStringAsFixed(1)}';
  }
}

final sessionAnalysisProvider = Provider<SessionStats>((ref) {
  final handsAsync = ref.watch(activeGameHandsProvider);
  final gameAsync = ref.watch(activeGameProvider);
  final userAsync = ref.watch(currentUserProvider);

  final hands = handsAsync.value ?? [];
  final game = gameAsync.value;
  final user = userAsync.value;

  if (user == null || game == null || hands.isEmpty) {
    return const SessionStats(
      pnl: 0,
      handsPlayed: 0,
      duration: Duration.zero,
      bbPer100: 0,
      positionalPnl: {},
    );
  }

  double pnl = 0;
  for (final hand in hands) {
    if (hand.winnerId == user.id) {
      pnl += hand.potAmount;
    } else {
      pnl -= game.bigBlind * 2;
    }
  }

  final duration = DateTime.now().difference(game.createdAt);

  final bbPer100 = hands.isNotEmpty
      ? (pnl / game.bigBlind) / (hands.length / 100)
      : 0.0;

  const positions = ['BTN', 'SB', 'UTG', 'BB'];
  final positionalPnl = <String, double>{};
  for (int i = 0; i < positions.length; i++) {
    final posHands = hands.where((h) => h.handNumber % positions.length == i);
    double posPnl = 0;
    for (final h in posHands) {
      posPnl += h.winnerId == user.id ? h.potAmount : -(game.bigBlind * 2);
    }
    positionalPnl[positions[i]] = posPnl;
  }

  return SessionStats(
    pnl: pnl,
    handsPlayed: hands.length,
    duration: duration,
    bbPer100: bbPer100,
    positionalPnl: positionalPnl,
  );
});

// ─── Invitations ──────────────────────────────────────────────────────────

final invitationsProvider = StreamProvider<List<InvitationModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return FirestoreService.getInvitationsStream(user.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

// ─── Friends ──────────────────────────────────────────────────────────────

final friendshipsProvider = StreamProvider<List<FriendshipModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return FirestoreService.getFriendshipsStream(user.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final acceptedFriendsProvider = Provider<List<FriendshipModel>>((ref) {
  final friendships = ref.watch(friendshipsProvider).value ?? [];
  return friendships.where((f) => f.isAccepted()).toList();
});

final pendingFriendRequestsProvider = Provider<List<FriendshipModel>>((ref) {
  final friendships = ref.watch(friendshipsProvider).value ?? [];
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return [];
  return friendships.where((f) => f.isPending(user.id)).toList();
});

// ─── BLE / Scanner ────────────────────────────────────────────────────────

/// Live connection-state of the BLE scanner service.
/// Emits the current state immediately so consumers that start listening
/// after auto-reconnect completes still get the correct initial value.
final bleConnectionStateProvider =
    StreamProvider<BleConnectionState>((ref) async* {
  yield BleService.instance.state;
  yield* BleService.instance.connectionStateStream;
});

/// Whether the scanner is currently connected.
final scannerConnectedProvider = Provider<bool>((ref) {
  final stateAsync = ref.watch(bleConnectionStateProvider);
  return stateAsync.value == BleConnectionState.connected;
});

/// Parsed battery percentage (0–100) from the scanner.
/// Emits the cached level immediately if one was already received before
/// this provider started listening (e.g. after auto-reconnect on startup).
final scannerBatteryProvider = StreamProvider<int>((ref) async* {
  final cached = BleService.instance.batteryLevel;
  if (cached != null) yield cached;
  yield* BleService.instance.batteryStream;
});

/// Raw chip-scan hex ID strings from the scanner.
final chipScanStreamProvider = StreamProvider<String>((ref) {
  return BleService.instance.chipStream;
});

// ─── Decks ────────────────────────────────────────────────────────────────

/// Live list of decks owned by the currently signed-in user.
final userDecksProvider = StreamProvider<List<DeckModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return FirestoreService.getUserDecksStream(user.id);
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// The ID of the deck currently assigned to the active table.
final activeDeckIdProvider = Provider<String?>((ref) {
  final game = ref.watch(activeGameProvider).value;
  return game?.deckId;
});

/// Live [DeckModel] for the deck assigned to the active table.
final activeDeckProvider = StreamProvider<DeckModel?>((ref) {
  final deckId = ref.watch(activeDeckIdProvider);
  if (deckId == null) return Stream.value(null);
  return FirestoreService.getDeckStream(deckId);
});
