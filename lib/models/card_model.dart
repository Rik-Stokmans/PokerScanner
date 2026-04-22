import 'package:flutter/material.dart';

class CardModel {
  final String rank; // '2'..'9', '10', 'J', 'Q', 'K', 'A'
  final String suit; // 's', 'h', 'd', 'c'

  const CardModel({required this.rank, required this.suit});

  String get suitSymbol => const {'s': '♠', 'h': '♥', 'd': '♦', 'c': '♣'}[suit]!;
  String get display => '$rank$suitSymbol';
  bool get isRed => suit == 'h' || suit == 'd';

  Color get suitColor => isRed ? const Color(0xFFE57373) : Colors.white;

  int get rankValue {
    const values = {
      '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8,
      '9': 9, '10': 10, 'J': 11, 'Q': 12, 'K': 13, 'A': 14,
    };
    return values[rank] ?? 0;
  }

  Map<String, dynamic> toMap() => {'rank': rank, 'suit': suit};

  factory CardModel.fromMap(Map<String, dynamic> map) => CardModel(
        rank: map['rank'] as String,
        suit: map['suit'] as String,
      );

  static List<CardModel> get fullDeck {
    final ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];
    final suits = ['s', 'h', 'd', 'c'];
    return [
      for (final suit in suits)
        for (final rank in ranks) CardModel(rank: rank, suit: suit),
    ];
  }

  static List<CardModel> shuffledDeck() {
    final deck = fullDeck;
    deck.shuffle();
    return deck;
  }

  @override
  bool operator ==(Object other) =>
      other is CardModel && rank == other.rank && suit == other.suit;

  @override
  int get hashCode => Object.hash(rank, suit);
}
