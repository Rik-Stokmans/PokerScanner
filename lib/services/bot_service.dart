import 'dart:math';
import '../models/game_model.dart';
import 'firestore_service.dart';

class BotService {
  static const botPrefix = 'bot_';
  static const availableBots = {
    'bot_alice': 'Alice',
    'bot_bob': 'Bob',
    'bot_charlie': 'Charlie',
    'bot_diana': 'Diana',
  };

  static bool isBot(String uid) => uid.startsWith(botPrefix);

  final _random = Random();
  bool _acting = false;

  void onGameUpdate(GameModel? game, String hostId) {
    if (game == null) return;
    if (game.hostId != hostId) return; // only host drives bots
    final currentPlayer = game.currentTurnPlayerId;
    if (currentPlayer == null || !isBot(currentPlayer)) return;
    if (_acting) return;
    _act(game, currentPlayer);
  }

  void dispose() {
    _acting = false;
  }

  Future<void> _act(GameModel game, String botUid) async {
    _acting = true;
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1000)));
    try {
      final highBet =
          game.playerBets.values.fold<double>(0, (a, b) => a > b ? a : b);
      switch (_decide(game, botUid)) {
        case _Action.check:
          await FirestoreService.playerCheck(game.id, game, botUid);
        case _Action.call:
          await FirestoreService.playerCall(game.id, game, botUid);
        case _Action.bet:
          // Open bet of 1 big blind
          await FirestoreService.playerBet(
              game.id, game, botUid, game.bigBlind);
        case _Action.raise:
          // Raise to 2× the current high bet
          final myBet = game.playerBets[botUid] ?? 0;
          final raiseAmount = highBet * 2 - myBet;
          await FirestoreService.playerBet(
              game.id, game, botUid, raiseAmount);
        case _Action.fold:
          await FirestoreService.playerFold(game.id, game, botUid);
      }
    } finally {
      _acting = false;
    }
  }

  _Action _decide(GameModel game, String botUid) {
    final highBet =
        game.playerBets.values.fold<double>(0, (a, b) => a > b ? a : b);
    final myBet = game.playerBets[botUid] ?? 0;
    final r = _random.nextDouble();

    if (highBet > myBet) {
      // Facing a bet: call 60%, raise 10%, fold 30%
      if (r < 0.60) return _Action.call;
      if (r < 0.70) return _Action.raise;
      return _Action.fold;
    } else {
      // No outstanding bet: check 65%, bet 25%, fold 10%
      if (r < 0.65) return _Action.check;
      if (r < 0.90) return _Action.bet;
      return _Action.fold;
    }
  }
}

enum _Action { check, call, bet, raise, fold }
