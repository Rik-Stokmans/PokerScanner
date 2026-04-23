/// Data models and static data for board texture recognition drills.

class BoardSubQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const BoardSubQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class BoardQuestion {
  final String id;

  /// 3-card flop represented as card codes, e.g. ['Kh', '7c', '2d'].
  final List<String> cards;

  /// Exactly 3 sub-questions: texture classification, range advantage, c-bet size.
  final List<BoardSubQuestion> questions;

  const BoardQuestion({
    required this.id,
    required this.cards,
    required this.questions,
  });
}

// ---------------------------------------------------------------------------
// Static dataset – 30 flops
// ---------------------------------------------------------------------------

const List<BoardQuestion> boardTextureQuestions = [
  // 1 — Dry unconnected rainbow (K-high)
  BoardQuestion(
    id: 'bt_01',
    cards: ['Kh', '7c', '2d'],
    questions: [
      BoardSubQuestion(
        question: 'How would you classify this flop texture?',
        options: [
          'Wet connected',
          'Dry unconnected rainbow',
          'Monotone',
          'Paired board',
        ],
        correctIndex: 1,
        explanation:
            'K-7-2 rainbow has no flush draw and only a gutshot at best. '
            'There are no two-card straight draws, making this a very dry board.',
      ),
      BoardSubQuestion(
        question: 'Who has the range advantage on K-7-2r?',
        options: [
          'The big blind (BB)',
          'The pre-flop raiser (PFR)',
          'Neither — it is roughly even',
          'Depends entirely on stack depth',
        ],
        correctIndex: 1,
        explanation:
            'The pre-flop raiser holds K-K, A-K, K-Q, etc. much more often '
            'than the caller. A king-high dry board heavily favours the aggressor.',
      ),
      BoardSubQuestion(
        question: 'What is the recommended c-bet sizing on K-7-2r?',
        options: [
          '75–100 % pot (large)',
          '50–66 % pot (medium)',
          '25–33 % pot (small)',
          'Check back — no c-bet advantage',
        ],
        correctIndex: 2,
        explanation:
            'On static dry boards the PFR can bet small at high frequency. '
            'A 25–33 % pot c-bet extracts value and keeps the range wide.',
      ),
    ],
  ),

  // 2 — Wet connected (J-T-9 two-tone)
  BoardQuestion(
    id: 'bt_02',
    cards: ['Jd', 'Ts', '9h'],
    questions: [
      BoardSubQuestion(
        question: 'How would you classify J-T-9 two-tone?',
        options: [
          'Dry unconnected',
          'Paired board',
          'Wet connected',
          'Monotone',
        ],
        correctIndex: 2,
        explanation:
            'J-T-9 contains multiple straight draws and a flush draw. '
            'It is one of the most connected, draw-heavy flops possible.',
      ),
      BoardSubQuestion(
        question: 'Who has the range advantage on J-T-9 two-tone?',
        options: [
          'The pre-flop raiser',
          'The big blind caller',
          'Roughly even — both ranges hit well',
          'The button open-raiser always dominates',
        ],
        correctIndex: 1,
        explanation:
            'Callers (especially BB) have suited connectors and two-gap hands '
            'that smash this board. The PFR\'s range is more polarised to big pairs '
            'which are vulnerable here.',
      ),
      BoardSubQuestion(
        question: 'What c-bet sizing is appropriate on J-T-9 two-tone?',
        options: [
          '25–33 % pot',
          '50 % pot',
          '75–100 % pot or check',
          'Always check — never c-bet',
        ],
        correctIndex: 2,
        explanation:
            'On very wet boards the PFR should use a polarised large sizing '
            'or check. A small bet is exploitable because opponents have too many '
            'equity-rich calling hands.',
      ),
    ],
  ),

  // 3 — Monotone (A-Q-5 all clubs)
  BoardQuestion(
    id: 'bt_03',
    cards: ['Ac', 'Qc', '5c'],
    questions: [
      BoardSubQuestion(
        question: 'What texture is A-Q-5 all clubs?',
        options: [
          'Dry paired',
          'Wet rainbow',
          'Monotone',
          'Two-tone connected',
        ],
        correctIndex: 2,
        explanation:
            'All three cards share the same suit — this is a monotone board. '
            'It dramatically changes the effective nut advantage.',
      ),
      BoardSubQuestion(
        question: 'How does a monotone board affect range advantage?',
        options: [
          'It greatly favours the pre-flop raiser who has more flushes',
          'It greatly favours the caller who defends wider suited combos',
          'It is neutral — suits cancel out',
          'Only matters on the river',
        ],
        correctIndex: 0,
        explanation:
            'Pre-flop raisers hold more of the nut-flush combos (A-Kc, A-Jc, etc.). '
            'This gives them a significant nut advantage on monotone boards.',
      ),
      BoardSubQuestion(
        question: 'What is the best c-bet approach on A-Q-5 monotone?',
        options: [
          'Bet small (25 %) at high frequency',
          'Bet large (75 %+) at low frequency',
          'Check-raise to protect equity',
          'Never bet — always check',
        ],
        correctIndex: 1,
        explanation:
            'Polarised large bets work well on monotone boards. The PFR can '
            'represent strong flushes and deny equity from opponents who lack flush draws.',
      ),
    ],
  ),

  // 4 — Ace-high dry rainbow (A-7-2)
  BoardQuestion(
    id: 'bt_04',
    cards: ['Ah', '7d', '2c'],
    questions: [
      BoardSubQuestion(
        question: 'Classify A-7-2 rainbow.',
        options: [
          'Wet connected',
          'Ace-high dry rainbow',
          'Monotone',
          'Paired board',
        ],
        correctIndex: 1,
        explanation:
            'A-7-2 rainbow features three un-connected cards of different suits. '
            'The ace makes it ace-high dry — a classic static board.',
      ),
      BoardSubQuestion(
        question: 'Who has the strongest range advantage on A-7-2r?',
        options: [
          'The big blind',
          'The pre-flop raiser',
          'The small blind',
          'Neither — it is balanced',
        ],
        correctIndex: 1,
        explanation:
            'The PFR holds A-A, A-K, A-Q and other ace-containing combos far '
            'more often. A-7-2r is one of the boards where the aggressor has the '
            'highest range advantage.',
      ),
      BoardSubQuestion(
        question: 'Optimal c-bet sizing on A-7-2r?',
        options: [
          '75–100 % pot',
          '50 % pot',
          '25–33 % pot',
          'Check — no advantage',
        ],
        correctIndex: 2,
        explanation:
            'Small high-frequency bets are correct on ace-high dry boards. '
            'The aggressor has the range advantage and does not need large sizes '
            'to extract value.',
      ),
    ],
  ),

  // 5 — Paired board (Q-Q-6 rainbow)
  BoardQuestion(
    id: 'bt_05',
    cards: ['Qh', 'Qs', '6d'],
    questions: [
      BoardSubQuestion(
        question: 'How would you classify Q-Q-6 rainbow?',
        options: [
          'Dry paired board',
          'Wet connected',
          'Monotone',
          'Low connected',
        ],
        correctIndex: 0,
        explanation:
            'Q-Q-6 is a dry paired board — the paired top card removes many '
            'strong made hands and draws from both ranges.',
      ),
      BoardSubQuestion(
        question: 'On a Q-Q-6r paired board, who benefits most?',
        options: [
          'The caller with pocket sixes',
          'The pre-flop raiser with overpairs and Q-x',
          'Neither — it neutralises ranges',
          'Whoever has the most bluffs',
        ],
        correctIndex: 1,
        explanation:
            'Paired boards favour ranges that contain trips and overpairs. '
            'The PFR has Q-Q, A-Q, K-Q and big pairs which benefit most.',
      ),
      BoardSubQuestion(
        question: 'What c-bet sizing fits Q-Q-6 rainbow?',
        options: [
          'Very large (75–100 %)',
          'Medium (50 %)',
          'Small (25–33 %)',
          'Skip — always check paired boards',
        ],
        correctIndex: 2,
        explanation:
            'On dry paired boards the preferred strategy is small frequent bets. '
            'Opponents rarely have a queen, so they must fold or call with little equity.',
      ),
    ],
  ),

  // 6 — Low connected two-tone (5-4-3)
  BoardQuestion(
    id: 'bt_06',
    cards: ['5h', '4d', '3h'],
    questions: [
      BoardSubQuestion(
        question: 'Classify 5-4-3 two-tone.',
        options: [
          'High dry board',
          'Monotone',
          'Low connected two-tone',
          'Paired board',
        ],
        correctIndex: 2,
        explanation:
            '5-4-3 is a three-connected low board with two cards of the same '
            'suit — a low connected two-tone texture rich with straight and flush draws.',
      ),
      BoardSubQuestion(
        question: 'Who has better range coverage on 5-4-3 two-tone?',
        options: [
          'The pre-flop raiser with big cards',
          'The BB defender with suited connectors and small pairs',
          'Neither — top pair is still dominant',
          'Only the player holding A-2',
        ],
        correctIndex: 1,
        explanation:
            'Low connected boards favour callers who defend with hands like '
            '6-5s, 7-6s, 2-2, 3-3. The PFR\'s high-card range misses most of this board.',
      ),
      BoardSubQuestion(
        question: 'Should the PFR c-bet frequently on 5-4-3 two-tone?',
        options: [
          'Yes — always c-bet large to protect',
          'No — check at high frequency and c-bet selectively',
          'Yes — small bet to keep pot small',
          'Yes — the flop is too dangerous to check',
        ],
        correctIndex: 1,
        explanation:
            'On boards that favour the defender, the PFR should check often to '
            'control pot size. When betting, a medium size is used to balance protection '
            'with pot odds.',
      ),
    ],
  ),

  // 7 — Dry paired low (8-8-3 rainbow)
  BoardQuestion(
    id: 'bt_07',
    cards: ['8h', '8c', '3d'],
    questions: [
      BoardSubQuestion(
        question: 'What is the texture of 8-8-3 rainbow?',
        options: [
          'Wet connected',
          'Dry paired low board',
          'Monotone',
          'Ace-high',
        ],
        correctIndex: 1,
        explanation:
            '8-8-3 rainbow is a dry paired low board. It is static with very '
            'little draw equity for either player.',
      ),
      BoardSubQuestion(
        question: 'How do paired boards affect c-betting ranges?',
        options: [
          'They widen c-bet frequency — both players miss',
          'They narrow c-bet frequency — risk of slow-playing',
          'No change to c-bet frequency',
          'Only over-pairs should c-bet',
        ],
        correctIndex: 0,
        explanation:
            'Since neither player often has a trip eight, the PFR can bet almost '
            'any two cards as a bluff and still have credibility.',
      ),
      BoardSubQuestion(
        question: 'Best c-bet size on 8-8-3r?',
        options: [
          'Large (75 %+)',
          'Medium (50 %)',
          'Small (25–33 %)',
          'Check always',
        ],
        correctIndex: 2,
        explanation:
            'Small high-frequency bets are optimal on dry paired boards. '
            'The aggressor gains without risking much when the opponent folds frequently.',
      ),
    ],
  ),

  // 8 — Wet two-tone (T-9-8)
  BoardQuestion(
    id: 'bt_08',
    cards: ['Td', '9h', '8d'],
    questions: [
      BoardSubQuestion(
        question: 'How would you label T-9-8 two-tone?',
        options: [
          'Dry unconnected',
          'Monotone',
          'Paired',
          'Wet connected two-tone',
        ],
        correctIndex: 3,
        explanation:
            'T-9-8 is highly connected (straight everywhere) with a flush draw '
            'on two suits — a very wet and dynamic texture.',
      ),
      BoardSubQuestion(
        question: 'Which range benefits most from T-9-8 two-tone?',
        options: [
          'The PFR with A-A and K-K',
          'The BB caller with suited connectors',
          'Both equally — it is balanced',
          'The small blind 3-bettor',
        ],
        correctIndex: 1,
        explanation:
            'Hands like J-9s, 8-7s, 7-6s, and Q-Js connect powerfully with '
            'T-9-8. The BB\'s wide defence range benefits far more than the PFR\'s '
            'concentrated value range.',
      ),
      BoardSubQuestion(
        question: 'What c-bet approach is correct on T-9-8 two-tone?',
        options: [
          'Bet small across your entire range',
          'Bet large with strong hands, check draws and misses',
          'Never c-bet — too many draws out',
          'Pot-size bet to deny equity immediately',
        ],
        correctIndex: 1,
        explanation:
            'Polarised large-bet strategy: jam top two pair+ for value and '
            'check behind speculative holdings to control pot size on a dangerous board.',
      ),
    ],
  ),

  // 9 — Ace-high two-tone (A-J-4)
  BoardQuestion(
    id: 'bt_09',
    cards: ['As', 'Jh', '4s'],
    questions: [
      BoardSubQuestion(
        question: 'Classify A-J-4 two-tone.',
        options: [
          'Ace-high slightly wet',
          'Dry rainbow',
          'Monotone',
          'Low connected',
        ],
        correctIndex: 0,
        explanation:
            'A-J-4 with a flush draw is moderately dynamic. The ace-high nature '
            'still favours the PFR, but the flush draw adds some wetness.',
      ),
      BoardSubQuestion(
        question: 'Who has range advantage on A-J-4 two-tone?',
        options: [
          'The caller — flush draws help',
          'The PFR — more aces and top pairs',
          'Balanced — no clear favourite',
          'Whoever is in position',
        ],
        correctIndex: 1,
        explanation:
            'The PFR has A-K, A-Q, A-J and J-J more frequently. '
            'The flush draw only partially offsets the ace-high advantage.',
      ),
      BoardSubQuestion(
        question: 'What c-bet sizing fits A-J-4 two-tone?',
        options: [
          '25–33 % always',
          '50 % mixed or 33 % high-frequency',
          '75 % polarised',
          'Check — the flush draw neutralises it',
        ],
        correctIndex: 1,
        explanation:
            'A balanced 33–50 % sizing works on ace-high two-tone boards. '
            'Small sizes remain profitable with the range advantage, while medium '
            'sizes better protect against draws.',
      ),
    ],
  ),

  // 10 — Low dry rainbow (6-3-2)
  BoardQuestion(
    id: 'bt_10',
    cards: ['6c', '3h', '2d'],
    questions: [
      BoardSubQuestion(
        question: 'How would you classify 6-3-2 rainbow?',
        options: [
          'Low dry rainbow',
          'Wet connected',
          'Monotone',
          'Paired board',
        ],
        correctIndex: 0,
        explanation:
            '6-3-2 rainbow is the classic low dry board. Almost no hand from '
            'either range connects strongly, and there are no flush draws.',
      ),
      BoardSubQuestion(
        question: 'Who benefits from a 6-3-2 rainbow flop?',
        options: [
          'The caller — small pairs dominate',
          'The PFR — over-cards have good equity',
          'Neither — both miss heavily',
          'The player with the button',
        ],
        correctIndex: 2,
        explanation:
            'Both ranges miss this board heavily, but the PFR can leverage '
            'positional advantage. Neither has an obvious range advantage from raw card coverage.',
      ),
      BoardSubQuestion(
        question: 'Recommended c-bet sizing on 6-3-2 rainbow?',
        options: [
          'Large (75 %)',
          'Small (25–33 %)',
          'Pot (100 %)',
          'Check — never bet this board',
        ],
        correctIndex: 1,
        explanation:
            'Small bets work well on dry low boards. The PFR can attack with '
            'their entire range at a tiny size because opponents rarely have a strong made hand.',
      ),
    ],
  ),

  // 11 — Monotone low (7-5-3 all spades)
  BoardQuestion(
    id: 'bt_11',
    cards: ['7s', '5s', '3s'],
    questions: [
      BoardSubQuestion(
        question: 'What is the texture of 7-5-3 all spades?',
        options: [
          'Low connected rainbow',
          'Dry paired',
          'Monotone low connected',
          'Two-tone high',
        ],
        correctIndex: 2,
        explanation:
            '7-5-3 all spades is both monotone and connected — a particularly '
            'dynamic board that is rarely seen but strategically complex.',
      ),
      BoardSubQuestion(
        question: 'Who has nut advantage on 7-5-3 monotone?',
        options: [
          'The caller with suited low connectors',
          'The PFR with big suited holdings',
          'Balanced',
          'Whoever 3-bet pre-flop',
        ],
        correctIndex: 1,
        explanation:
            'The PFR holds As-Ks, Ks-Qs and similar high spade combos more often. '
            'The nut flush and near-nut holdings belong to the aggressor\'s range.',
      ),
      BoardSubQuestion(
        question: 'How should the PFR approach betting on 7-5-3 monotone?',
        options: [
          'Small frequent bets with the full range',
          'Large polarised bets or check',
          'Only bet with the nut flush',
          'Always check — board too dangerous',
        ],
        correctIndex: 1,
        explanation:
            'Monotone boards call for polarised strategies. Bet large with '
            'nut flushes and strong draws; check back weaker parts of the range.',
      ),
    ],
  ),

  // 12 — High dry rainbow (K-Q-2)
  BoardQuestion(
    id: 'bt_12',
    cards: ['Kd', 'Qh', '2c'],
    questions: [
      BoardSubQuestion(
        question: 'Classify K-Q-2 rainbow.',
        options: [
          'Wet connected',
          'High dry rainbow',
          'Monotone',
          'Paired board',
        ],
        correctIndex: 1,
        explanation:
            'K-Q-2 rainbow lacks a flush draw and has only a distant gutshot. '
            'The two high cards connect well with the PFR\'s strong combos.',
      ),
      BoardSubQuestion(
        question: 'Who has range advantage on K-Q-2r?',
        options: [
          'The BB defender',
          'The pre-flop raiser',
          'Balanced — K-Q is in many ranges',
          'Neither — low card balances it',
        ],
        correctIndex: 1,
        explanation:
            'The PFR has more K-K, Q-Q, A-K, A-Q and K-Q combos. '
            'K-Q-2r is a strong PFR board.',
      ),
      BoardSubQuestion(
        question: 'Best c-bet size on K-Q-2r?',
        options: [
          'Large (75 %+)',
          'Medium (50 %)',
          'Small (25–33 %)',
          'Check — too risky',
        ],
        correctIndex: 2,
        explanation:
            'Small high-frequency c-bets are correct. This dry board does not '
            'threaten draws, so a small bet forces tough decisions without risk.',
      ),
    ],
  ),

  // 13 — Connected rainbow mid (8-7-6)
  BoardQuestion(
    id: 'bt_13',
    cards: ['8c', '7h', '6d'],
    questions: [
      BoardSubQuestion(
        question: 'What texture is 8-7-6 rainbow?',
        options: [
          'Dry unconnected',
          'Connected rainbow mid',
          'Monotone',
          'Paired dry',
        ],
        correctIndex: 1,
        explanation:
            '8-7-6 is three-connected but rainbow. The absence of a flush draw '
            'reduces wetness slightly, but straight draws are abundant.',
      ),
      BoardSubQuestion(
        question: 'Who has the equity edge on 8-7-6 rainbow?',
        options: [
          'The PFR with over-cards',
          'The caller with mid connectors and pairs',
          'Balanced',
          'Only the player with 9-5',
        ],
        correctIndex: 1,
        explanation:
            'Callers playing suited connectors (9-7, 7-5, 6-5) and pocket pairs '
            '(6-6, 7-7, 8-8) hit this board very hard. The PFR\'s range of big pairs '
            'and broadway cards is mostly bluffing here.',
      ),
      BoardSubQuestion(
        question: 'How should the PFR bet on 8-7-6 rainbow?',
        options: [
          'Bet full range small',
          'Bet medium frequency at 50 %',
          'Check often; bet large when betting',
          'Overbet to deny straight draws',
        ],
        correctIndex: 2,
        explanation:
            'On mid-connected boards that favour the caller, the PFR should '
            'check back much of their range. When choosing to bet, a larger size '
            'better represents value and denies equity.',
      ),
    ],
  ),

  // 14 — Paired high (A-A-K rainbow)
  BoardQuestion(
    id: 'bt_14',
    cards: ['Ah', 'Ad', 'Kc'],
    questions: [
      BoardSubQuestion(
        question: 'Classify A-A-K rainbow.',
        options: [
          'Dry paired ace-high',
          'Wet connected',
          'Monotone',
          'Low paired',
        ],
        correctIndex: 0,
        explanation:
            'A-A-K is a dry paired board with the highest possible pair on top. '
            'It is extremely static and nutted hands are almost impossible for defenders.',
      ),
      BoardSubQuestion(
        question: 'How does A-A-K affect calling ranges?',
        options: [
          'Callers connect strongly with trips',
          'Callers rarely have an ace, making them under-represented',
          'It is balanced — everyone has some equity',
          'Only the BB can profitably call c-bets',
        ],
        correctIndex: 1,
        explanation:
            'A-A-K is heavily skewed toward the PFR who 3-bets A-K, A-A, K-K. '
            'Callers seldom hold an ace, making them vulnerable to any c-bet.',
      ),
      BoardSubQuestion(
        question: 'What c-bet strategy fits A-A-K rainbow?',
        options: [
          'Overbet — polarise hard',
          'Small frequent bet — opponent can rarely continue',
          'Check back — no need to bet',
          'Medium 50 % balanced bet',
        ],
        correctIndex: 1,
        explanation:
            'Small bets are highly effective. The opponent cannot call often '
            'with a board this hostile to their range, so the PFR can profit with tiny bets.',
      ),
    ],
  ),

  // 15 — Two-tone low connected (4-3-2)
  BoardQuestion(
    id: 'bt_15',
    cards: ['4c', '3s', '2c'],
    questions: [
      BoardSubQuestion(
        question: 'What is the texture of 4-3-2 two-tone?',
        options: [
          'Dry high',
          'Low connected two-tone',
          'Monotone',
          'Paired low',
        ],
        correctIndex: 1,
        explanation:
            '4-3-2 is three-connected with a flush draw. It is the lowest '
            'possible connected board — highly dynamic despite the low card values.',
      ),
      BoardSubQuestion(
        question: 'Who has range advantage on 4-3-2 two-tone?',
        options: [
          'The PFR — they have A-5 for the wheel',
          'The caller — wide suited ranges connect well',
          'Balanced',
          'Only the early position opener',
        ],
        correctIndex: 0,
        explanation:
            'Interestingly, the PFR has A-5s and A-5o for the nut straight, '
            'and also holds more flush-draw combos with suited aces. This gives '
            'the PFR a nut advantage despite the low board.',
      ),
      BoardSubQuestion(
        question: 'Best c-bet sizing on 4-3-2 two-tone?',
        options: [
          '25 % small',
          '50 % medium',
          '75 % large',
          'Check — always too risky',
        ],
        correctIndex: 1,
        explanation:
            'A medium 50 % bet balances protection against the flush draw with '
            'value from straights and sets while not over-committing when behind.',
      ),
    ],
  ),

  // 16 — High paired two-tone (K-K-T)
  BoardQuestion(
    id: 'bt_16',
    cards: ['Ks', 'Kd', 'Th'],
    questions: [
      BoardSubQuestion(
        question: 'Classify K-K-T rainbow.',
        options: [
          'Wet connected',
          'High dry paired',
          'Monotone',
          'Low connected',
        ],
        correctIndex: 1,
        explanation:
            'K-K-T is a paired high board. The paired kings dramatically reduce '
            'the number of trips combos in any range.',
      ),
      BoardSubQuestion(
        question: 'On K-K-T, who has the range advantage?',
        options: [
          'The BB caller with T-x hands',
          'The PFR with K-x and A-A',
          'Balanced',
          'No one — board neutralises ranges',
        ],
        correctIndex: 1,
        explanation:
            'The PFR has K-Q, K-J, A-K and pocket aces more frequently. '
            'K-K-T skews heavily toward the aggressor.',
      ),
      BoardSubQuestion(
        question: 'C-bet sizing on K-K-T rainbow?',
        options: [
          'Large 75 %',
          'Small 25–33 %',
          'Pot overbet',
          'Never c-bet',
        ],
        correctIndex: 1,
        explanation:
            'Small high-frequency bets dominate on dry paired boards. '
            'The strong range advantage means even a small bet creates significant pressure.',
      ),
    ],
  ),

  // 17 — Flush-heavy two-tone (Q-8-4 hearts)
  BoardQuestion(
    id: 'bt_17',
    cards: ['Qh', '8h', '4d'],
    questions: [
      BoardSubQuestion(
        question: 'How do you classify Q-8-4 with two hearts?',
        options: [
          'Dry unconnected rainbow',
          'Moderately wet two-tone',
          'Monotone',
          'Low connected',
        ],
        correctIndex: 1,
        explanation:
            'Q-8-4 two-tone has a flush draw but limited straight draws. '
            'It sits in the moderate wetness range.',
      ),
      BoardSubQuestion(
        question: 'Who benefits from the flush draw on Q-8-4 two-tone?',
        options: [
          'The PFR who holds more suited broadways',
          'The caller with suited connectors in hearts',
          'Balanced between both ranges',
          'Only the nut flush holder',
        ],
        correctIndex: 0,
        explanation:
            'The PFR has Ah-Kh, Ah-Jh, Kh-Qh and similar premium suited combos '
            'more often, giving them the nut flush advantage.',
      ),
      BoardSubQuestion(
        question: 'Recommended c-bet approach on Q-8-4 two-tone?',
        options: [
          'Small 25–33 % high frequency',
          'Medium 50 % balanced',
          'Large 75 % polarised',
          'Check all non-made hands',
        ],
        correctIndex: 1,
        explanation:
            'A balanced 50 % strategy works well here. It extracts value from '
            'top pairs while also protecting against the flush draw.',
      ),
    ],
  ),

  // 18 — Broadway connected two-tone (K-Q-J)
  BoardQuestion(
    id: 'bt_18',
    cards: ['Kc', 'Qd', 'Jc'],
    questions: [
      BoardSubQuestion(
        question: 'Classify K-Q-J two-tone.',
        options: [
          'Broadway connected two-tone',
          'Dry unconnected',
          'Monotone',
          'Paired board',
        ],
        correctIndex: 0,
        explanation:
            'K-Q-J is three-connected Broadway with a flush draw — one of the '
            'most action-packed textures due to numerous two-pair and straight combinations.',
      ),
      BoardSubQuestion(
        question: 'Who dominates K-Q-J two-tone?',
        options: [
          'The BB with suited connectors',
          'The PFR with A-T, A-K, K-K, Q-Q',
          'Balanced — both hit well',
          'Depends only on position',
        ],
        correctIndex: 1,
        explanation:
            'The PFR has A-T for the nut straight, K-K, Q-Q, J-J and top two '
            'pairs. This is a PFR-favoured board despite its wet nature.',
      ),
      BoardSubQuestion(
        question: 'What c-bet size is appropriate on K-Q-J two-tone?',
        options: [
          '25 % small',
          '50–66 % medium',
          '100 % pot',
          'Check — too many draws',
        ],
        correctIndex: 1,
        explanation:
            'Medium sizing at moderate frequency makes sense. The PFR values '
            'top pairs and sets but must be cautious about draws completing on the turn.',
      ),
    ],
  ),

  // 19 — Mid paired two-tone (7-7-4)
  BoardQuestion(
    id: 'bt_19',
    cards: ['7c', '7h', '4d'],
    questions: [
      BoardSubQuestion(
        question: 'What texture is 7-7-4 rainbow?',
        options: [
          'Wet connected',
          'Mid paired dry board',
          'Monotone',
          'Broadway board',
        ],
        correctIndex: 1,
        explanation:
            '7-7-4 rainbow is a mid paired dry board. Sevens are rare in any '
            'range, making this very static.',
      ),
      BoardSubQuestion(
        question: 'On 7-7-4 rainbow, who has the advantage?',
        options: [
          'The caller with pocket fours',
          'The PFR with over-pairs (A-A, K-K, etc.)',
          'Balanced — both miss the sevens',
          'Whoever bet pre-flop last',
        ],
        correctIndex: 1,
        explanation:
            'Neither range has sevens often, but the PFR has over-pairs which '
            'are the second nuts. The PFR can bluff or value-bet comfortably.',
      ),
      BoardSubQuestion(
        question: 'Optimal c-bet size on 7-7-4 rainbow?',
        options: [
          '75–100 %',
          '50 %',
          '25–33 %',
          'Always check',
        ],
        correctIndex: 2,
        explanation:
            'Small bets are ideal on dry paired boards. The PFR can bet the '
            'entire range at minimal size and profit from the opponent\'s difficulty in calling.',
      ),
    ],
  ),

  // 20 — Ace-high monotone (A-5-2 all diamonds)
  BoardQuestion(
    id: 'bt_20',
    cards: ['Ad', '5d', '2d'],
    questions: [
      BoardSubQuestion(
        question: 'Classify A-5-2 all diamonds.',
        options: [
          'Dry ace-high rainbow',
          'Wet connected two-tone',
          'Ace-high monotone',
          'Low paired',
        ],
        correctIndex: 2,
        explanation:
            'A-5-2 with all cards sharing the diamond suit is an ace-high '
            'monotone board — the made flush is already on the flop.',
      ),
      BoardSubQuestion(
        question: 'Who has the nut flush advantage on A-5-2 all diamonds?',
        options: [
          'The caller with suited low cards',
          'The PFR with Ad-Kd, Ad-Qd and similar',
          'Balanced — wheel draws cancel it',
          'No one — all flushes are equal',
        ],
        correctIndex: 1,
        explanation:
            'The PFR holds more nut flush combinations (Ad-Kd, Ad-Qd). '
            'On an ace-high monotone board the PFR has a significant nut advantage.',
      ),
      BoardSubQuestion(
        question: 'What is the best c-bet strategy on A-5-2 monotone?',
        options: [
          'Small bet with entire range',
          'Medium 50 % balanced',
          'Large or overbet with nut flushes; check others',
          'Never bet — caller always has a flush',
        ],
        correctIndex: 2,
        explanation:
            'On monotone boards the strategy is highly polarised. Bet very large '
            'with nut flushes to get maximum value and check back non-flush holdings.',
      ),
    ],
  ),

  // 21 — Connected high two-tone (A-K-Q)
  BoardQuestion(
    id: 'bt_21',
    cards: ['Ah', 'Kh', 'Qd'],
    questions: [
      BoardSubQuestion(
        question: 'Classify A-K-Q two-tone.',
        options: [
          'Dry paired',
          'High Broadway connected two-tone',
          'Monotone',
          'Low connected',
        ],
        correctIndex: 1,
        explanation:
            'A-K-Q is the highest possible three-connected board. J-T makes '
            'the nut straight, and there is a flush draw on two suits.',
      ),
      BoardSubQuestion(
        question: 'Who has the range advantage on A-K-Q two-tone?',
        options: [
          'The caller — J-T is in wide ranges',
          'The PFR — dominant in A-x, K-x, Q-x combos',
          'Balanced',
          'Whoever flopped two pair',
        ],
        correctIndex: 1,
        explanation:
            'The PFR holds more A-K, A-Q, K-Q, A-A, K-K and Q-Q. '
            'Despite callers having J-T, the overall range advantage belongs to the PFR.',
      ),
      BoardSubQuestion(
        question: 'What c-bet size is recommended on A-K-Q two-tone?',
        options: [
          '25 % small',
          '50 % medium',
          '75 %+ large polarised',
          'Check — too coordinated',
        ],
        correctIndex: 1,
        explanation:
            'Medium 50 % sizing works: value-bet two pairs and sets at medium size '
            'and be cautious about J-T completing the straight on later streets.',
      ),
    ],
  ),

  // 22 — Dry unconnected low (9-5-2 rainbow)
  BoardQuestion(
    id: 'bt_22',
    cards: ['9h', '5c', '2d'],
    questions: [
      BoardSubQuestion(
        question: 'Classify 9-5-2 rainbow.',
        options: [
          'Wet connected',
          'Dry unconnected low-mid',
          'Monotone',
          'Paired',
        ],
        correctIndex: 1,
        explanation:
            '9-5-2 rainbow has a wide gap between all three cards with no flush draw. '
            'It is a dry, unconnected, low-to-mid board.',
      ),
      BoardSubQuestion(
        question: 'Who has range advantage on 9-5-2 rainbow?',
        options: [
          'The PFR slightly — over-card advantage',
          'The BB — pocket pairs and suited gappers connect',
          'Balanced',
          'The CO raiser always dominates',
        ],
        correctIndex: 0,
        explanation:
            'The PFR has a small range advantage from over-pairs and strong '
            'over-card combos. The board is dry enough that the PFR can attack comfortably.',
      ),
      BoardSubQuestion(
        question: 'What c-bet size fits 9-5-2 rainbow?',
        options: [
          '75–100 %',
          '50 %',
          '25–33 %',
          'Never c-bet',
        ],
        correctIndex: 2,
        explanation:
            'Small c-bets are ideal. On dry unconnected boards the PFR can '
            'apply pressure at minimal cost across their entire range.',
      ),
    ],
  ),

  // 23 — Wet suited gapper (J-9-7 two-tone)
  BoardQuestion(
    id: 'bt_23',
    cards: ['Jc', '9h', '7c'],
    questions: [
      BoardSubQuestion(
        question: 'What is J-9-7 two-tone?',
        options: [
          'Dry unconnected',
          'Paired board',
          'Wet gapped connected two-tone',
          'Monotone',
        ],
        correctIndex: 2,
        explanation:
            'J-9-7 has two-card gaps but creates numerous straight draws '
            '(T-8, Q-8, Q-T). With a flush draw it is a moderately wet board.',
      ),
      BoardSubQuestion(
        question: 'Who benefits from J-9-7 two-tone?',
        options: [
          'The PFR with over-pairs',
          'The caller with suited connectors and wheel hands',
          'Balanced — J-T is strong for both',
          'Only the button open',
        ],
        correctIndex: 1,
        explanation:
            'Callers with T-8s, Q-Js, 8-6s, and K-T have significant equity '
            'on J-9-7. The board\'s gapped structure still heavily favours connected hands.',
      ),
      BoardSubQuestion(
        question: 'What c-bet approach is recommended on J-9-7 two-tone?',
        options: [
          'Small frequent bet',
          'Large polarised bet or check',
          '50 % all hands',
          'Pot overbet to deny draws',
        ],
        correctIndex: 1,
        explanation:
            'Use a polarised large-bet strategy or check on wet gapped boards. '
            'Checking protects the range and a large bet commits opponents who have strong draws.',
      ),
    ],
  ),

  // 24 — Dry mid rainbow (T-6-2)
  BoardQuestion(
    id: 'bt_24',
    cards: ['Td', '6h', '2c'],
    questions: [
      BoardSubQuestion(
        question: 'Classify T-6-2 rainbow.',
        options: [
          'Dry mid rainbow',
          'Wet connected',
          'Monotone',
          'Broadway board',
        ],
        correctIndex: 0,
        explanation:
            'T-6-2 rainbow is unconnected across three distinct ranks with no '
            'flush draw — a dry mid-range board.',
      ),
      BoardSubQuestion(
        question: 'Who has range advantage on T-6-2 rainbow?',
        options: [
          'The PFR — over-pairs and T-x combos',
          'The BB — low pairs connect',
          'Balanced',
          'No range advantage exists',
        ],
        correctIndex: 0,
        explanation:
            'The PFR has A-T, K-T, T-T and over-pairs that connect well. '
            'T-6-2 is a clear PFR-favoured board.',
      ),
      BoardSubQuestion(
        question: 'Best c-bet size on T-6-2 rainbow?',
        options: [
          '75 %+',
          '50 %',
          '25–33 %',
          'Check always',
        ],
        correctIndex: 2,
        explanation:
            'Small frequent bets on dry mid boards. High frequency and small '
            'size extracts maximum profit given the range advantage.',
      ),
    ],
  ),

  // 25 — Connected three-tone low (6-5-4 rainbow)
  BoardQuestion(
    id: 'bt_25',
    cards: ['6d', '5h', '4c'],
    questions: [
      BoardSubQuestion(
        question: 'Classify 6-5-4 rainbow.',
        options: [
          'Low connected rainbow',
          'Dry unconnected',
          'Monotone',
          'Paired board',
        ],
        correctIndex: 0,
        explanation:
            '6-5-4 rainbow is three-connected with no flush draw. '
            'It is highly connected but without flush texture.',
      ),
      BoardSubQuestion(
        question: 'Who has range advantage on 6-5-4 rainbow?',
        options: [
          'The PFR — nut straight with 7-8',
          'The BB — wide suited range hits straight draws',
          'Balanced',
          'The UTG opener always advantages',
        ],
        correctIndex: 1,
        explanation:
            'The BB\'s wide defence range contains many hands like 7-5, 3-2, 8-7 '
            'that connect directly. Low connected boards consistently favour callers.',
      ),
      BoardSubQuestion(
        question: 'What c-bet size is best on 6-5-4 rainbow?',
        options: [
          '25–33 % always bet',
          '50 % medium',
          '75 % large or check',
          'Overbet pot',
        ],
        correctIndex: 2,
        explanation:
            'On boards that heavily favour the caller, the PFR should check '
            'frequently. When betting, a larger size is required to have credibility.',
      ),
    ],
  ),

  // 26 — High paired two-tone (A-A-5)
  BoardQuestion(
    id: 'bt_26',
    cards: ['Ac', 'As', '5h'],
    questions: [
      BoardSubQuestion(
        question: 'Classify A-A-5 rainbow.',
        options: [
          'Ace-high paired dry',
          'Wet connected',
          'Monotone',
          'Low connected',
        ],
        correctIndex: 0,
        explanation:
            'A-A-5 is the ultimate paired dry board — the pair of aces on top '
            'makes it near impossible for any range to have trips.',
      ),
      BoardSubQuestion(
        question: 'What is the betting dynamic on A-A-5 rainbow?',
        options: [
          'Both players slow-play',
          'The PFR can bet any two cards with impunity',
          'The defender has an equity edge with pocket fives',
          'Calling is always correct',
        ],
        correctIndex: 1,
        explanation:
            'Since neither range holds an ace often (4 combos of AA removed), '
            'the PFR can bluff freely. The board hits no one, making any bet threatening.',
      ),
      BoardSubQuestion(
        question: 'Best c-bet size on A-A-5 rainbow?',
        options: [
          'Large 75–100 %',
          'Medium 50 %',
          'Small 25–33 %',
          'No bet',
        ],
        correctIndex: 2,
        explanation:
            'Tiny bets work best. The defender rarely has continuing equity '
            'on A-A-5, so small bets achieve folds at very high rates.',
      ),
    ],
  ),

  // 27 — Wet two-pair-heavy (Q-J-T two-tone)
  BoardQuestion(
    id: 'bt_27',
    cards: ['Qh', 'Js', 'Th'],
    questions: [
      BoardSubQuestion(
        question: 'Classify Q-J-T two-tone.',
        options: [
          'Dry unconnected',
          'Monotone',
          'Wet Broadway connected two-tone',
          'Paired low',
        ],
        correctIndex: 2,
        explanation:
            'Q-J-T is a connected Broadway board with a flush draw — '
            'one of the most draw-heavy and complex flop textures.',
      ),
      BoardSubQuestion(
        question: 'Who has the range edge on Q-J-T two-tone?',
        options: [
          'The PFR — more nut straight combos (A-K, K-9)',
          'The BB — wide range hits sets and two pairs',
          'Balanced',
          'Depends entirely on pre-flop action',
        ],
        correctIndex: 0,
        explanation:
            'The PFR holds A-K for the nut straight more than the caller. '
            'K-9 also makes a strong straight. The PFR\'s nut advantage is present '
            'despite both ranges connecting well.',
      ),
      BoardSubQuestion(
        question: 'C-bet size on Q-J-T two-tone?',
        options: [
          '25 % small',
          '50 % medium',
          '75 %+ large polarised',
          'Pot overbet only with nuts',
        ],
        correctIndex: 2,
        explanation:
            'Polarised large sizing: bet big with the nuts (A-K, K-9, sets) '
            'and check back marginal holdings. Avoid medium bets when the board is this wet.',
      ),
    ],
  ),

  // 28 — Mid dry rainbow (J-7-3)
  BoardQuestion(
    id: 'bt_28',
    cards: ['Jh', '7d', '3c'],
    questions: [
      BoardSubQuestion(
        question: 'Classify J-7-3 rainbow.',
        options: [
          'Wet connected',
          'Mid dry rainbow',
          'Monotone',
          'Paired',
        ],
        correctIndex: 1,
        explanation:
            'J-7-3 rainbow has no flush draw and minimal straight draws — '
            'a straightforward mid dry board.',
      ),
      BoardSubQuestion(
        question: 'Who has range advantage on J-7-3 rainbow?',
        options: [
          'The caller with 7-x hands',
          'The PFR with J-x and over-pairs',
          'Balanced — 3 and 7 are in both ranges',
          'No clear advantage',
        ],
        correctIndex: 1,
        explanation:
            'The PFR holds A-J, K-J, Q-J and over-pairs that dominate this board. '
            'J-7-3 rainbow is a classic PFR advantage board.',
      ),
      BoardSubQuestion(
        question: 'What c-bet size is best on J-7-3 rainbow?',
        options: [
          '25–33 %',
          '50 %',
          '75 %+',
          'Check always',
        ],
        correctIndex: 0,
        explanation:
            'Small high-frequency bets. Dry boards with a range advantage '
            'call for the most efficient betting approach.',
      ),
    ],
  ),

  // 29 — Double suited Broadway (A-Q-9 two-tone)
  BoardQuestion(
    id: 'bt_29',
    cards: ['As', 'Qd', '9s'],
    questions: [
      BoardSubQuestion(
        question: 'How would you classify A-Q-9 two-tone?',
        options: [
          'Dry ace-high rainbow',
          'Ace-high moderately wet two-tone',
          'Monotone',
          'Paired board',
        ],
        correctIndex: 1,
        explanation:
            'A-Q-9 with a flush draw is moderately wet. There is also a backdoor '
            'straight possibility, making this slightly more dynamic than a pure dry board.',
      ),
      BoardSubQuestion(
        question: 'Who has the range edge on A-Q-9 two-tone?',
        options: [
          'The BB with suited medium connectors',
          'The PFR — more aces, queens, and suited combos',
          'Balanced',
          'Depends only on stack depth',
        ],
        correctIndex: 1,
        explanation:
            'The PFR holds A-Q, A-A, Q-Q and top-pair strong kickers more often. '
            'The flush draw slightly reduces the gap but the PFR still leads.',
      ),
      BoardSubQuestion(
        question: 'Recommended c-bet size on A-Q-9 two-tone?',
        options: [
          '25 %',
          '50 %',
          '75 %',
          'Check — board is too wet',
        ],
        correctIndex: 1,
        explanation:
            'A 50 % balanced sizing works on ace-high boards with a flush draw. '
            'It provides good value while controlling risk on a somewhat dynamic texture.',
      ),
    ],
  ),

  // 30 — Dry low paired (3-3-7 rainbow)
  BoardQuestion(
    id: 'bt_30',
    cards: ['3h', '3c', '7d'],
    questions: [
      BoardSubQuestion(
        question: 'What texture is 3-3-7 rainbow?',
        options: [
          'Wet connected',
          'Low paired dry rainbow',
          'Monotone',
          'Broadway board',
        ],
        correctIndex: 1,
        explanation:
            '3-3-7 rainbow features a low pair on the bottom of the board with '
            'no draws — an extremely static, dry texture.',
      ),
      BoardSubQuestion(
        question: 'Who has the advantage on 3-3-7 rainbow?',
        options: [
          'The caller — pocket 7s or 3-x hands',
          'The PFR — over-pairs dominate',
          'Balanced',
          'Neither — board is too neutral',
        ],
        correctIndex: 1,
        explanation:
            'The PFR has over-pairs (A-A through 8-8) which are the effective '
            'nuts on 3-3-7. The caller only occasionally holds 7-x or 3-x.',
      ),
      BoardSubQuestion(
        question: 'C-bet strategy on 3-3-7 rainbow?',
        options: [
          'Large 75 % to charge draws',
          'Medium 50 % balanced',
          'Small 25–33 % high frequency',
          'Check back — too risky',
        ],
        correctIndex: 2,
        explanation:
            'Small high-frequency bets are optimal on low dry paired boards. '
            'The PFR extracts maximum value at minimal risk given the range advantage.',
      ),
    ],
  ),
];
