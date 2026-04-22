import 'package:flutter_test/flutter_test.dart';
import 'package:poker_scanner/models/card_model.dart';
import 'package:poker_scanner/services/hand_evaluator.dart';

CardModel c(String rank, String suit) => CardModel(rank: rank, suit: suit);

void main() {
  group('CardModel', () {
    test('rankValue returns correct values', () {
      expect(c('A', 's').rankValue, 14);
      expect(c('K', 'h').rankValue, 13);
      expect(c('Q', 'd').rankValue, 12);
      expect(c('J', 'c').rankValue, 11);
      expect(c('10', 's').rankValue, 10);
      expect(c('2', 'h').rankValue, 2);
    });

    test('equality and hashCode', () {
      final a = c('A', 's');
      final b = c('A', 's');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('fullDeck has 52 unique cards', () {
      final deck = CardModel.fullDeck;
      expect(deck.length, 52);
      expect(deck.toSet().length, 52);
    });

    test('shuffledDeck has 52 cards', () {
      expect(CardModel.shuffledDeck().length, 52);
    });

    test('toMap / fromMap round-trip', () {
      final card = c('Q', 'd');
      final restored = CardModel.fromMap(card.toMap());
      expect(restored, card);
    });
  });

  group('HandEvaluator – five-card hands', () {
    test('royal flush', () {
      final hand = [c('A', 's'), c('K', 's'), c('Q', 's'), c('J', 's'), c('10', 's')];
      final result = HandEvaluator.evaluate(hand);
      expect(result.rank, HandRank.royalFlush);
    });

    test('straight flush', () {
      final hand = [c('9', 'h'), c('8', 'h'), c('7', 'h'), c('6', 'h'), c('5', 'h')];
      final result = HandEvaluator.evaluate(hand);
      expect(result.rank, HandRank.straightFlush);
    });

    test('four of a kind', () {
      final hand = [c('A', 's'), c('A', 'h'), c('A', 'd'), c('A', 'c'), c('K', 's')];
      final result = HandEvaluator.evaluate(hand);
      expect(result.rank, HandRank.fourOfAKind);
    });

    test('full house', () {
      final hand = [c('K', 's'), c('K', 'h'), c('K', 'd'), c('Q', 'c'), c('Q', 's')];
      final result = HandEvaluator.evaluate(hand);
      expect(result.rank, HandRank.fullHouse);
    });

    test('flush', () {
      final hand = [c('A', 'c'), c('J', 'c'), c('9', 'c'), c('6', 'c'), c('3', 'c')];
      final result = HandEvaluator.evaluate(hand);
      expect(result.rank, HandRank.flush);
    });

    test('straight', () {
      final hand = [c('9', 's'), c('8', 'h'), c('7', 'd'), c('6', 'c'), c('5', 's')];
      final result = HandEvaluator.evaluate(hand);
      expect(result.rank, HandRank.straight);
    });

    test('wheel straight (A-2-3-4-5)', () {
      final hand = [c('A', 's'), c('2', 'h'), c('3', 'd'), c('4', 'c'), c('5', 's')];
      final result = HandEvaluator.evaluate(hand);
      expect(result.rank, HandRank.straight);
    });

    test('three of a kind', () {
      final hand = [c('7', 's'), c('7', 'h'), c('7', 'd'), c('K', 'c'), c('2', 's')];
      final result = HandEvaluator.evaluate(hand);
      expect(result.rank, HandRank.threeOfAKind);
    });

    test('two pair', () {
      final hand = [c('J', 's'), c('J', 'h'), c('9', 'd'), c('9', 'c'), c('A', 's')];
      final result = HandEvaluator.evaluate(hand);
      expect(result.rank, HandRank.twoPair);
    });

    test('one pair', () {
      final hand = [c('Q', 's'), c('Q', 'h'), c('9', 'd'), c('6', 'c'), c('3', 's')];
      final result = HandEvaluator.evaluate(hand);
      expect(result.rank, HandRank.onePair);
    });

    test('high card', () {
      final hand = [c('A', 's'), c('J', 'h'), c('9', 'd'), c('6', 'c'), c('2', 's')];
      final result = HandEvaluator.evaluate(hand);
      expect(result.rank, HandRank.highCard);
    });
  });

  group('HandEvaluator – seven-card best-hand selection', () {
    test('picks royal flush from seven cards', () {
      final cards = [
        c('A', 's'), c('K', 's'), c('Q', 's'), c('J', 's'), c('10', 's'),
        c('2', 'h'), c('3', 'd'),
      ];
      expect(HandEvaluator.evaluate(cards).rank, HandRank.royalFlush);
    });

    test('picks best hand – flush over straight', () {
      // 5-card flush available: all hearts; also a straight present
      final cards = [
        c('A', 'h'), c('K', 'h'), c('Q', 'h'), c('J', 'h'), c('9', 'h'),
        c('10', 's'), c('8', 'd'),
      ];
      expect(HandEvaluator.evaluate(cards).rank, HandRank.flush);
    });

    test('picks full house when available with 7 cards', () {
      final cards = [
        c('K', 's'), c('K', 'h'), c('K', 'd'), c('Q', 'c'), c('Q', 's'),
        c('2', 'h'), c('3', 'd'),
      ];
      expect(HandEvaluator.evaluate(cards).rank, HandRank.fullHouse);
    });

    test('bestFive contains exactly 5 cards', () {
      final cards = [
        c('A', 's'), c('K', 's'), c('Q', 's'), c('J', 's'), c('10', 's'),
        c('2', 'h'), c('3', 'd'),
      ];
      expect(HandEvaluator.evaluate(cards).bestFive.length, 5);
    });
  });

  group('HandEvaluator – edge cases', () {
    test('single card returns high card', () {
      final result = HandEvaluator.evaluate([c('A', 's')]);
      expect(result.rank, HandRank.highCard);
    });

    test('two non-consecutive cards returns high card', () {
      final result = HandEvaluator.evaluate([c('A', 's'), c('J', 'h')]);
      expect(result.rank, HandRank.highCard);
    });
  });

  group('HandEvaluator – holeHandDescription', () {
    test('pocket pair', () {
      final desc = HandEvaluator.holeHandDescription([c('A', 's'), c('A', 'h')]);
      expect(desc, 'Pocket Aces');
    });

    test('suited connectors', () {
      final desc = HandEvaluator.holeHandDescription([c('K', 's'), c('Q', 's')]);
      expect(desc, contains('Suited'));
    });

    test('offsuit', () {
      final desc = HandEvaluator.holeHandDescription([c('A', 's'), c('K', 'h')]);
      expect(desc, contains('Offsuit'));
    });

    test('empty list returns empty string', () {
      expect(HandEvaluator.holeHandDescription([]), '');
    });
  });

  group('BLE raw-byte packet parsing', () {
    // The device firmware sends strings like "R1: AA BB CC DD" or
    // "BAT: 78%" over BLE NOTIFY. These helpers replicate what the
    // Flutter app must do to consume those packets.

    String decodeRfidPacket(List<int> bytes) {
      return String.fromCharCodes(bytes);
    }

    Map<String, String>? parseUidNotification(String raw) {
      // Expected format: "R1: AA BB CC DD" or "R2: AA BB CC DD"
      final match = RegExp(r'^(R[12]):\s+(.+)$').firstMatch(raw.trim());
      if (match == null) return null;
      return {'reader': match.group(1)!, 'uid': match.group(2)!};
    }

    int? parseBatteryNotification(String raw) {
      // Expected format: "BAT: 78%"
      final match = RegExp(r'^BAT:\s*(\d+)%$').firstMatch(raw.trim());
      if (match == null) return null;
      return int.tryParse(match.group(1)!);
    }

    test('UID packet from reader 1 decoded correctly', () {
      const packet = 'R1: AA BB CC DD';
      final bytes = packet.codeUnits;
      final decoded = decodeRfidPacket(bytes);
      final parsed = parseUidNotification(decoded);
      expect(parsed, isNotNull);
      expect(parsed!['reader'], 'R1');
      expect(parsed['uid'], 'AA BB CC DD');
    });

    test('UID packet from reader 2 decoded correctly', () {
      const packet = 'R2: 01 02 03 04 05';
      final parsed = parseUidNotification(packet);
      expect(parsed, isNotNull);
      expect(parsed!['reader'], 'R2');
      expect(parsed['uid'], '01 02 03 04 05');
    });

    test('battery packet parsed correctly', () {
      expect(parseBatteryNotification('BAT: 78%'), 78);
      expect(parseBatteryNotification('BAT: 0%'), 0);
      expect(parseBatteryNotification('BAT: 100%'), 100);
    });

    test('battery percentage clamped understanding', () {
      // Firmware can theoretically return values outside 0-100 for extreme
      // voltages; verify the parser still returns the raw integer.
      expect(parseBatteryNotification('BAT: -5%'), isNull); // negative invalid
      expect(parseBatteryNotification('BAT: 105%'), 105);   // over 100 raw
    });

    test('malformed UID packet returns null', () {
      expect(parseUidNotification(''), isNull);
      expect(parseUidNotification('R3: AA BB'), isNull); // R3 not valid
      expect(parseUidNotification('AA BB CC'), isNull);
    });

    test('malformed battery packet returns null', () {
      expect(parseBatteryNotification(''), isNull);
      expect(parseBatteryNotification('BATTERY: 50'), isNull);
    });

    test('multi-byte UID round-trips through UTF8 bytes', () {
      const packet = 'R1: DE AD BE EF';
      final bytes = packet.codeUnits;
      expect(decodeRfidPacket(bytes), packet);
    });
  });

  group('Deck resolution logic', () {
    // Map from RFID UID string to a CardModel — simulates what the app
    // must do to turn a scanned tag into a playing card.

    final Map<String, CardModel> uidToCard = {
      'AA BB CC DD': c('A', 's'),
      '11 22 33 44': c('K', 'h'),
      'DE AD BE EF': c('2', 'c'),
    };

    CardModel? resolveCard(String uid) => uidToCard[uid];

    List<CardModel> resolveHand(List<String> uids) =>
        uids.map(resolveCard).whereType<CardModel>().toList();

    test('known UID resolves to correct card', () {
      expect(resolveCard('AA BB CC DD'), c('A', 's'));
      expect(resolveCard('11 22 33 44'), c('K', 'h'));
    });

    test('unknown UID resolves to null', () {
      expect(resolveCard('FF FF FF FF'), isNull);
    });

    test('resolveHand skips unknown UIDs', () {
      final hand = resolveHand(['AA BB CC DD', 'FF FF FF FF', 'DE AD BE EF']);
      expect(hand.length, 2);
      expect(hand, containsAll([c('A', 's'), c('2', 'c')]));
    });

    test('resolveHand with all known UIDs returns full list', () {
      final hand = resolveHand(['AA BB CC DD', '11 22 33 44', 'DE AD BE EF']);
      expect(hand.length, 3);
    });

    test('resolveHand with empty list returns empty', () {
      expect(resolveHand([]), isEmpty);
    });

    test('no duplicate cards in a resolved hand from unique UIDs', () {
      final hand = resolveHand(['AA BB CC DD', '11 22 33 44', 'DE AD BE EF']);
      final unique = hand.toSet().toList();
      expect(hand.length, unique.length);
    });
  });
}
