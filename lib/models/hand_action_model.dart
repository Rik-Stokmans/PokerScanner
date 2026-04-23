import 'game_model.dart' show BettingRound;

enum ActionType { fold, call, raise, check, allIn, smallBlind, bigBlind }

class HandActionModel {
  final String playerId;
  final String playerName;
  final ActionType actionType;
  final double? amount;
  final BettingRound bettingRound;
  final DateTime timestamp;

  const HandActionModel({
    required this.playerId,
    required this.playerName,
    required this.actionType,
    this.amount,
    required this.bettingRound,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'playerId': playerId,
        'playerName': playerName,
        'actionType': actionType.name,
        'amount': amount,
        'bettingRound': bettingRound.name,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HandActionModel.fromMap(Map<String, dynamic> map) {
    return HandActionModel(
      playerId: map['playerId'] as String? ?? '',
      playerName: map['playerName'] as String? ?? '',
      actionType: ActionType.values.firstWhere(
        (e) => e.name == (map['actionType'] as String?),
        orElse: () => ActionType.fold,
      ),
      amount: (map['amount'] as num?)?.toDouble(),
      bettingRound: BettingRound.values.firstWhere(
        (e) => e.name == (map['bettingRound'] as String?),
        orElse: () => BettingRound.preflop,
      ),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
