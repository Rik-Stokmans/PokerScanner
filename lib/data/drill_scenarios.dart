enum ScenarioCategory {
  preflop,
  flopCbet,
  turnBarrel,
  riverSpot,
  bbDefense,
  bluffCatch,
}

class DrillScenario {
  final String id;
  final ScenarioCategory category;
  final String title;
  final String situation;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int difficulty;

  const DrillScenario({
    required this.id,
    required this.category,
    required this.title,
    required this.situation,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
  });
}

const List<DrillScenario> drillScenarios = [
  // ── PREFLOP (15 scenarios) ──────────────────────────────────────────────────

  DrillScenario(
    id: 'pre_01',
    category: ScenarioCategory.preflop,
    title: 'UTG Open with AKs',
    situation:
        '6-handed cash game, 100BB effective. You are UTG with A♠K♠. '
        'Action folds to you.',
    options: ['Fold', 'Open raise to 2.5BB', 'Open raise to 3BB', 'Limp'],
    correctIndex: 2,
    explanation:
        'AKs is a premium hand that plays well from any position. A standard '
        '3BB open from UTG is correct. Limping under-realises the hand\'s '
        'equity and a 2.5BB open is slightly small for UTG where you want '
        'more fold equity.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'pre_02',
    category: ScenarioCategory.preflop,
    title: 'MP Fold with 87s',
    situation:
        '6-handed cash game, 100BB effective. You are in MP with 8♥7♥. '
        'UTG has opened to 3BB. Action is on you.',
    options: [
      'Fold',
      'Call',
      '3-bet to 9BB',
      'All-in shove',
    ],
    correctIndex: 1,
    explanation:
        '87s has enough implied odds to call a single raise in position. '
        'Folding is too tight; 87s can flop well and is profitable to call. '
        '3-betting as a bluff is a higher-variance line that requires a '
        'balanced range in MP.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'pre_03',
    category: ScenarioCategory.preflop,
    title: 'CO 3-Bet vs BTN Open',
    situation:
        '6-handed cash game, 100BB effective. BTN opens to 2.5BB. You are '
        'in CO with Q♣J♣. Action folds to you.',
    options: [
      'Fold',
      'Call',
      '3-bet to 8BB',
      '3-bet to 12BB',
    ],
    correctIndex: 0,
    explanation:
        'From the CO you are out of position against the BTN. QJo/QJs are '
        'marginal hands OOP. Facing a BTN open from CO, folding is the most '
        'common correct play with hands like QJo. If it were QJs the call '
        'becomes viable. Against active players a disciplined fold here '
        'avoids tough spots OOP.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'pre_04',
    category: ScenarioCategory.preflop,
    title: 'BTN Steal vs Weak Blinds',
    situation:
        '6-handed cash game, 100BB effective. Folds to you on the BTN with '
        'K♦9♦. SB and BB are passive recreational players.',
    options: [
      'Fold',
      'Open raise to 2.5BB',
      'Limp',
      'Open raise to 4BB',
    ],
    correctIndex: 1,
    explanation:
        'K9s on the BTN vs weak blinds is a profitable open. 2.5BB is the '
        'standard sizing. Limping gives up initiative; 4BB is unnecessarily '
        'large. Folding K9s from the BTN is far too tight.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'pre_05',
    category: ScenarioCategory.preflop,
    title: 'SB 3-Bet vs BTN Open',
    situation:
        '6-handed cash game, 100BB effective. BTN opens to 2.5BB. SB with '
        'A♥J♠. BB folds.',
    options: [
      'Fold',
      'Call',
      '3-bet to 9BB',
      '3-bet to 7BB',
    ],
    correctIndex: 2,
    explanation:
        'AJo from SB vs BTN open should usually 3-bet. AJo is too strong to '
        'fold and calling OOP with a hand that dominates much of BTN\'s range '
        'is suboptimal. 9BB (3x the open) is the standard SB 3-bet size.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'pre_06',
    category: ScenarioCategory.preflop,
    title: 'UTG+1 Open TT',
    situation:
        '6-handed cash game, 100BB effective. UTG folds. You are UTG+1 with '
        'T♣T♦.',
    options: [
      'Fold',
      'Open raise to 2.5BB',
      'Open raise to 3BB',
      'Limp',
    ],
    correctIndex: 2,
    explanation:
        'TT is a strong hand that should always be opened from any position. '
        'A 3BB raise from early position is standard. Limping gives up '
        'initiative, and folding TT is never correct.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'pre_07',
    category: ScenarioCategory.preflop,
    title: '4-Bet or Fold QQ vs 3-Bet',
    situation:
        '6-handed cash game, 100BB effective. You open UTG to 3BB with Q♠Q♦. '
        'CO 3-bets to 10BB. Action is on you.',
    options: [
      'Fold',
      'Call',
      '4-bet to 26BB',
      '4-bet all-in',
    ],
    correctIndex: 2,
    explanation:
        'QQ is strong enough to 4-bet for value vs a CO 3-bet. A typical '
        '4-bet size is ~2.5-3x the 3-bet (26BB). Calling is also viable but '
        'can be exploited by aggressive 3-bettors. Folding QQ vs a CO 3-bet '
        'is far too tight.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'pre_08',
    category: ScenarioCategory.preflop,
    title: 'BTN vs SB 3-Bet with A5s',
    situation:
        '6-handed cash game, 100BB effective. You open BTN to 2.5BB with '
        'A♣5♣. SB 3-bets to 8BB. BB folds.',
    options: [
      'Fold',
      'Call',
      '4-bet to 22BB',
      '4-bet all-in',
    ],
    correctIndex: 2,
    explanation:
        'A5s is a classic 4-bet bluff candidate. It blocks the nut flush and '
        'has an ace blocker (reducing AA combos). 4-betting A5s as a bluff '
        'mixed with value hands like QQ+ creates a balanced 4-betting range. '
        'Calling OOP vs SB is also acceptable but 4-betting is the GTO play.',
    difficulty: 3,
  ),

  DrillScenario(
    id: 'pre_09',
    category: ScenarioCategory.preflop,
    title: 'MP Open 22',
    situation:
        '6-handed cash game, 100BB effective. Folds to you in MP with 2♠2♦.',
    options: [
      'Fold',
      'Open raise to 2.5BB',
      'Open raise to 3BB',
      'Limp',
    ],
    correctIndex: 2,
    explanation:
        'Small pairs have set-mining value. From MP, opening 22 to 3BB is '
        'standard in 6-max. It is profitable to open all pocket pairs. '
        'Limping is a weaker play that gives up fold equity.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'pre_10',
    category: ScenarioCategory.preflop,
    title: 'CO vs UTG Open with KQo',
    situation:
        '6-handed cash game, 100BB effective. UTG opens to 3BB. Folds to you '
        'in CO with K♥Q♠.',
    options: [
      'Fold',
      'Call',
      '3-bet to 10BB',
      '3-bet to 7BB',
    ],
    correctIndex: 1,
    explanation:
        'KQo in CO vs UTG open is typically a call. 3-betting KQo vs UTG '
        'range is marginally profitable but risky since UTG is very strong. '
        'Calling in position with KQo and good implied odds is the standard '
        'solver play.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'pre_11',
    category: ScenarioCategory.preflop,
    title: 'BTN Open ATo',
    situation:
        '6-handed cash game, 100BB effective. Folds to BTN with A♣T♦. SB '
        'and BB are unknown.',
    options: [
      'Fold',
      'Open raise to 2.5BB',
      'Open raise to 3BB',
      'Limp',
    ],
    correctIndex: 1,
    explanation:
        'ATo is a profitable open from the BTN. 2.5BB is the standard BTN '
        'sizing. Folding ATo on the BTN is too tight; it has strong equity '
        'vs calling ranges and benefits from positional advantage.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'pre_12',
    category: ScenarioCategory.preflop,
    title: 'HJ Open JTs',
    situation:
        '6-handed cash game, 100BB effective. Folds to HJ with J♦T♦.',
    options: [
      'Fold',
      'Open raise to 2.5BB',
      'Open raise to 3BB',
      'Limp',
    ],
    correctIndex: 2,
    explanation:
        'JTs is a premium suited connector that plays well from all positions. '
        'From HJ (MP in 6-max), a 3BB raise is standard. It has great '
        'playability, makes straights, flushes, and strong pairs.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'pre_13',
    category: ScenarioCategory.preflop,
    title: 'UTG Fold K2o',
    situation:
        '6-handed cash game, 100BB effective. You are UTG with K♣2♦.',
    options: [
      'Fold',
      'Open raise to 3BB',
      'Limp',
      'Open raise to 2.5BB',
    ],
    correctIndex: 0,
    explanation:
        'K2o is well below the UTG opening threshold in 6-max. UTG should '
        'open roughly the top 15-20% of hands. K2o does not make the cut — '
        'it has poor playability, is dominated by better kings, and plays '
        'poorly from the worst position.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'pre_14',
    category: ScenarioCategory.preflop,
    title: 'SB Complete or Raise vs BTN Limp',
    situation:
        '6-handed cash game, 100BB effective. BTN limps. You are in SB with '
        '9♥8♥.',
    options: [
      'Fold',
      'Complete (limp)',
      'Raise to 4BB',
      'Raise to 3BB',
    ],
    correctIndex: 2,
    explanation:
        '98s in SB vs a BTN limp should raise to isolate. A 4BB raise '
        'punishes the limp and sets up a heads-up pot with positional '
        'disadvantage mitigated by the raise. Limping along creates a '
        'multi-way pot where suited connectors have decent equity but you '
        'lose initiative.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'pre_15',
    category: ScenarioCategory.preflop,
    title: '3-Bet Squeeze vs Open and Call',
    situation:
        '6-handed cash game, 100BB effective. UTG opens to 3BB, HJ calls. '
        'You are on the BTN with A♥K♦.',
    options: [
      'Fold',
      'Call',
      '3-bet to 13BB',
      '3-bet to 10BB',
    ],
    correctIndex: 2,
    explanation:
        'AKo in a squeeze spot is a mandatory 3-bet. Squeezing isolates '
        'against one of the two opponents and builds a pot with a premium '
        'hand in position. 13BB is the standard squeeze size (3x open + '
        '1BB per caller). Calling creates a bloated multi-way pot where AK '
        'plays poorly without flopping top pair.',
    difficulty: 3,
  ),

  // ── BB DEFENSE (10 scenarios) ──────────────────────────────────────────────

  DrillScenario(
    id: 'bb_01',
    category: ScenarioCategory.bbDefense,
    title: 'BB vs BTN Open 2.5BB with 97s',
    situation:
        '6-handed cash game, 100BB effective. BTN opens to 2.5BB. SB folds. '
        'You are BB with 9♣7♣.',
    options: [
      'Fold',
      'Call',
      '3-bet to 9BB',
      'Raise to 6BB',
    ],
    correctIndex: 1,
    explanation:
        '97s is a clear BB defend vs a BTN 2.5BB open. You are getting 3:1 '
        'pot odds and already have 1BB invested. Suited connectors play well '
        'multiway and heads-up. Folding 97s here is too tight.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'bb_02',
    category: ScenarioCategory.bbDefense,
    title: 'BB vs UTG Open with T4o',
    situation:
        '6-handed cash game, 100BB effective. UTG opens to 3BB. Folds to BB '
        'with T♦4♠.',
    options: [
      'Fold',
      'Call',
      '3-bet to 10BB',
      'Call, planning to check-fold flop',
    ],
    correctIndex: 0,
    explanation:
        'T4o is too weak to defend vs a UTG open. UTG has a tight range and '
        'T4o has poor playability and is dominated by much of UTG\'s range. '
        'Even though you get a discount in the BB, T4o doesn\'t have the '
        'equity to be profitable.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'bb_03',
    category: ScenarioCategory.bbDefense,
    title: 'BB vs SB Complete with K6o',
    situation:
        '6-handed cash game, 100BB effective. Folds to SB who completes. '
        'You are BB with K♥6♠.',
    options: [
      'Check',
      'Raise to 4BB',
      'Raise to 3BB',
      'Fold',
    ],
    correctIndex: 1,
    explanation:
        'K6o vs SB complete: raising is correct to punish the limp and take '
        'initiative. K6o has reasonable top-pair potential and you should '
        'build pots against weak SB ranges. A 4BB raise (4x the BB) is '
        'standard isolation sizing.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'bb_04',
    category: ScenarioCategory.bbDefense,
    title: 'BB 3-Bet vs BTN Open with JJ',
    situation:
        '6-handed cash game, 100BB effective. BTN opens to 2.5BB. SB folds. '
        'You are BB with J♥J♦.',
    options: [
      'Fold',
      'Call',
      '3-bet to 9BB',
      '3-bet to 12BB',
    ],
    correctIndex: 2,
    explanation:
        'JJ is a strong 3-bet hand from the BB vs BTN. 3-betting builds the '
        'pot with a premium hand and denies equity from BTN\'s wide opening '
        'range. 9BB (3.5x open) is standard BB 3-bet sizing. Calling is also '
        'viable but 3-betting is slightly better EV.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'bb_05',
    category: ScenarioCategory.bbDefense,
    title: 'BB vs CO Open with A2s',
    situation:
        '6-handed cash game, 100BB effective. CO opens to 3BB. BTN and SB '
        'fold. You are BB with A♠2♠.',
    options: [
      'Fold',
      'Call',
      '3-bet to 10BB',
      '3-bet to 9BB',
    ],
    correctIndex: 1,
    explanation:
        'A2s is a borderline 3-bet or call vs CO. Calling is fine; A2s has '
        'nut flush potential and a strong ace. 3-betting is also viable as a '
        'light 3-bet. Calling keeps the pot manageable and allows you to '
        'realize equity. Folding A2s vs CO is too tight.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'bb_06',
    category: ScenarioCategory.bbDefense,
    title: 'BB vs BTN 3x Open with Q8o',
    situation:
        '6-handed cash game, 100BB effective. BTN opens to 3BB (larger '
        'sizing). SB folds. You are BB with Q♦8♣.',
    options: [
      'Fold',
      'Call',
      '3-bet to 10BB',
      '3-bet to 12BB',
    ],
    correctIndex: 0,
    explanation:
        'Q8o vs a 3BB BTN open should fold. The larger open size reduces '
        'your pot odds and Q8o out of position doesn\'t have enough equity '
        'to continue profitably. Against a 2.5BB open Q8o becomes a call, '
        'but vs 3BB it is a fold.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'bb_07',
    category: ScenarioCategory.bbDefense,
    title: 'BB vs HJ Open with 55',
    situation:
        '6-handed cash game, 100BB effective. HJ opens to 3BB. CO, BTN, and '
        'SB fold. You are BB with 5♣5♦.',
    options: [
      'Fold',
      'Call',
      '3-bet to 10BB',
      '3-bet to 9BB',
    ],
    correctIndex: 1,
    explanation:
        '55 in the BB vs HJ open is a standard call. Small pairs have set '
        'value but 3-betting 55 for value is too thin. Calling with the '
        'intention of set mining is the correct GTO approach. Folding 55 '
        'vs a HJ open in the BB is too tight.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'bb_08',
    category: ScenarioCategory.bbDefense,
    title: 'BB vs SB 3-Bet with KTs',
    situation:
        '6-handed cash game, 100BB effective. BTN opens to 2.5BB. SB '
        '3-bets to 8BB. You are BB with K♣T♣.',
    options: [
      'Fold',
      'Call',
      '4-bet to 24BB',
      '4-bet to 20BB',
    ],
    correctIndex: 0,
    explanation:
        'Facing a 3-bet squeeze from SB while cold from BB with KTs, folding '
        'is correct. You are OOP vs both players and KTs, while strong, is '
        'dominated by SB\'s 3-betting range. Cold 4-betting here is reckless. '
        'Calling in a 3-way OOP scenario is also unprofitable.',
    difficulty: 3,
  ),

  DrillScenario(
    id: 'bb_09',
    category: ScenarioCategory.bbDefense,
    title: 'BB vs BTN 2.5BB Open with 64s',
    situation:
        '6-handed cash game, 100BB effective. BTN opens to 2.5BB. SB folds. '
        'You are BB with 6♥4♥.',
    options: [
      'Fold',
      'Call',
      '3-bet to 9BB',
      'Raise to 6BB',
    ],
    correctIndex: 1,
    explanation:
        '64s is a borderline call in the BB vs BTN at 2.5BB. The pot odds '
        'and positional discount make it profitable. Suited connectors can '
        'make strong hands and charge more to bluff. 3-betting 64s is a '
        'viable but less common line.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'bb_10',
    category: ScenarioCategory.bbDefense,
    title: 'BB 3-Bet Bluff vs Frequent BTN Stealer',
    situation:
        '6-handed cash game, 100BB effective. BTN (who opens 60% of BTNs) '
        'opens to 2.5BB. SB folds. You are BB with 7♦5♦.',
    options: [
      'Fold',
      'Call',
      '3-bet to 9BB',
      '3-bet to 12BB',
    ],
    correctIndex: 2,
    explanation:
        'Against a very frequent BTN stealer (60% open), widening your '
        '3-bet range is profitable. 75s makes an excellent light 3-bet: it '
        'blocks few strong hands, has good playability when called, and '
        'forces a loose opener to fold a lot. 9BB is standard.',
    difficulty: 3,
  ),

  // ── FLOP C-BET (12 scenarios) ──────────────────────────────────────────────

  DrillScenario(
    id: 'flop_01',
    category: ScenarioCategory.flopCbet,
    title: 'Dry Board Overpair C-Bet',
    situation:
        'You opened BTN with A♠A♦ to 2.5BB. BB calls. Flop: 7♣3♦2♠ '
        '(rainbow, dry). BB checks. Pot: 5.5BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (1.8BB)',
      'Bet 2/3 pot (3.6BB)',
      'Bet pot (5.5BB)',
    ],
    correctIndex: 1,
    explanation:
        'On a dry, low board with an overpair from position, a small c-bet '
        '(1/3 pot) is optimal. The board is great for your range, villain '
        'cannot have many strong holdings, and a small bet gets value while '
        'keeping bluffs in. Betting large charges too much and folds out '
        'hands that can call small.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'flop_02',
    category: ScenarioCategory.flopCbet,
    title: 'Wet Board Check Back Top Pair',
    situation:
        'You opened CO with K♥T♠ to 3BB. BTN calls. Flop: J♣9♦8♣ '
        '(three-way straight draw, flush draw). BTN checks. Pot: 6.5BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (2.2BB)',
      'Bet 2/3 pot (4.3BB)',
      'Bet pot (6.5BB)',
    ],
    correctIndex: 0,
    explanation:
        'J98 is a dangerous board that connects well with BTN calling ranges. '
        'You have a gutshot (QK for straight) but only K-high. Checking back '
        'controls the pot, keeps in weaker hands, and protects your checking '
        'range. Betting here over-bets a wet board where you are frequently '
        'behind.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'flop_03',
    category: ScenarioCategory.flopCbet,
    title: 'Top Pair Top Kicker vs Multiway',
    situation:
        'You opened HJ with A♣K♠ to 3BB. CO and BTN call. Flop: K♦7♥3♣ '
        '(rainbow). CO and BTN check. Pot: 9.5BB.',
    options: [
      'Check',
      'Bet 1/3 pot (3.2BB)',
      'Bet 2/3 pot (6.3BB)',
      'Bet pot (9.5BB)',
    ],
    correctIndex: 1,
    explanation:
        'Multiway you want to bet smaller on a dry board. TPTK is strong but '
        'multiway you face more combined equity. A 1/3 pot bet gets value '
        'from second pair, worse kings, and sets up later streets. Big bets '
        'multiway fold out too many worse hands.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'flop_04',
    category: ScenarioCategory.flopCbet,
    title: 'Missed C-Bet on Ace-High Board',
    situation:
        'You opened BTN with K♠Q♦ to 2.5BB. BB calls. Flop: A♣9♦4♥ '
        '(rainbow). BB checks. Pot: 5.5BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (1.8BB)',
      'Bet 2/3 pot (3.6BB)',
      'Bet pot (5.5BB)',
    ],
    correctIndex: 1,
    explanation:
        'An ace-high board as BTN preflop raiser should be bet frequently '
        'because you represent aces strongly. KQ has a gutshot and backdoor '
        'flush potential. A small 1/3 bet is correct here — it represents '
        'strength with your range advantage and you can barrel turns.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'flop_05',
    category: ScenarioCategory.flopCbet,
    title: 'Strong Draw: Bet or Check?',
    situation:
        'You opened CO with J♥T♥ to 3BB. BTN calls. Flop: 9♦8♣2♥. '
        'You have OESD + backdoor flush. BB checks. Pot: 6.5BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (2.2BB)',
      'Bet 2/3 pot (4.3BB)',
      'Bet pot (6.5BB)',
    ],
    correctIndex: 2,
    explanation:
        'A strong draw (OESD) should bet to protect equity and semi-bluff. '
        'A 2/3 pot bet applies pressure and can win the pot immediately or '
        'on later streets. Checking gives opponent free cards and under- '
        'realizes your equity. Large bets with strong draws is the standard '
        'GTO approach.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'flop_06',
    category: ScenarioCategory.flopCbet,
    title: 'Monotone Board with Overpair',
    situation:
        'You opened UTG with Q♥Q♣ to 3BB. BTN calls. Flop: 9♠6♠3♠ '
        '(all spades). BTN checks. Pot: 6.5BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (2.2BB)',
      'Bet 2/3 pot (4.3BB)',
      'Bet pot (6.5BB)',
    ],
    correctIndex: 0,
    explanation:
        'On a monotone board without the top spade, your QQ is significantly '
        'devalued. BTN calls UTG and a spade board heavily favors their suited '
        'connector and suited gapper range. Checking back protects your hand '
        'and re-evaluates on the turn.',
    difficulty: 3,
  ),

  DrillScenario(
    id: 'flop_07',
    category: ScenarioCategory.flopCbet,
    title: 'Paired Board with AA',
    situation:
        'You opened BTN with A♠K♣ to 2.5BB. BB calls. Flop: J♣J♥4♦. '
        'BB checks. Pot: 5.5BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (1.8BB)',
      'Bet 2/3 pot (3.6BB)',
      'Bet pot (5.5BB)',
    ],
    correctIndex: 1,
    explanation:
        'On a paired board you hold an overpair but BB could have a jack. '
        'A small probe bet (1/3 pot) is reasonable to collect value from '
        'worse overcards and pairs. If raised, you can fold or reassess. '
        'Large bets inflate the pot when behind to Jx.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'flop_08',
    category: ScenarioCategory.flopCbet,
    title: 'Bottom Pair C-Bet or Check?',
    situation:
        'You opened BTN with 5♠5♣ to 2.5BB. BB calls. Flop: K♦9♥5♦. '
        'BB checks. Pot: 5.5BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (1.8BB)',
      'Bet 2/3 pot (3.6BB)',
      'Bet pot (5.5BB)',
    ],
    correctIndex: 2,
    explanation:
        'Bottom set on a wet board should bet large to protect against draws. '
        'K95 with a flush draw is a dangerous board. 2/3 pot charges draws '
        'appropriately. Checking risks a free card that completes straights '
        'and flushes. Slowplaying sets on wet boards is a common mistake.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'flop_09',
    category: ScenarioCategory.flopCbet,
    title: 'Air C-Bet on Low Dry Board',
    situation:
        'You opened HJ with A♣J♦ to 3BB. BTN calls. Flop: 6♥3♦2♠ '
        '(rainbow). BTN checks. Pot: 6.5BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (2.2BB)',
      'Bet 2/3 pot (4.3BB)',
      'Bet pot (6.5BB)',
    ],
    correctIndex: 1,
    explanation:
        'A♣J♦ on 632 rainbow has A-high with backdoor draws. The board '
        'misses BTN\'s connected range, and your range has a big advantage '
        'here. A small 1/3 c-bet frequently folds out Kx, Qx, and small '
        'pairs. This is a high-frequency, small-size spot.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'flop_10',
    category: ScenarioCategory.flopCbet,
    title: 'Check-Raise Bluff vs Flop C-Bet',
    situation:
        'You are in the BB with 8♦7♦. BTN opened, you called. Flop: '
        'K♣9♣2♦. You check, BTN bets 1/3 pot. Pot: 9BB. You have 87dd '
        '(backdoor flush, gutshot).',
    options: [
      'Fold',
      'Call',
      'Check-raise to 3x',
      'Check-raise to 5x',
    ],
    correctIndex: 1,
    explanation:
        '87d on K92 has backdoor equity but not enough to check-raise bluff '
        'profitably vs a 1/3 c-bet. Calling is correct here — the pot odds '
        'are good, you have backdoor outs, and you can continue on good '
        'turn cards. Check-raising without enough equity or fold equity is '
        'burning money.',
    difficulty: 3,
  ),

  DrillScenario(
    id: 'flop_11',
    category: ScenarioCategory.flopCbet,
    title: 'Two Overcards C-Bet on Low Board',
    situation:
        'You opened CO with A♦Q♥ to 3BB. BB calls. Flop: 8♣5♥2♣. '
        'BB checks. Pot: 6.5BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (2.2BB)',
      'Bet 2/3 pot (4.3BB)',
      'Bet pot (6.5BB)',
    ],
    correctIndex: 1,
    explanation:
        'AQo on 852 has two overcards and a backdoor flush draw. As the CO '
        'preflop raiser you have range advantage — your range has more AA, '
        'KK, QQ, and AK. A small 1/3 c-bet is appropriate as a high- '
        'frequency "range bet" on low boards.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'flop_12',
    category: ScenarioCategory.flopCbet,
    title: 'Middle Pair on 3-Way Wet Board',
    situation:
        'You opened UTG with K♠Q♠ to 3BB. CO and BTN call. Flop: Q♦J♠T♦. '
        'CO and BTN check. Pot: 9.5BB.',
    options: [
      'Check',
      'Bet 1/3 pot (3.2BB)',
      'Bet 2/3 pot (6.3BB)',
      'Bet pot (9.5BB)',
    ],
    correctIndex: 0,
    explanation:
        'KQ on QJT is a dangerous spot. You have top pair but the board is '
        'extremely wet with straight and flush possibilities. You are OOP '
        '3-way. Checking is correct to pot control and evaluate the turn. '
        'Many worse hands won\'t fold to any bet here.',
    difficulty: 3,
  ),

  // ── TURN BARREL (10 scenarios) ─────────────────────────────────────────────

  DrillScenario(
    id: 'turn_01',
    category: ScenarioCategory.turnBarrel,
    title: 'Brick Turn with TPTK',
    situation:
        'You opened BTN with A♣K♦. BB called. Flop: K♥7♦3♣ (rainbow). '
        'You bet 2/3 pot, villain called. Turn: 2♠. Villain checks. '
        'Pot: 18BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (6BB)',
      'Bet 2/3 pot (12BB)',
      'Bet pot (18BB)',
    ],
    correctIndex: 1,
    explanation:
        'TPTK on a bricked turn should bet again, but smaller. The board is '
        'still dry, the turn changed nothing. A 1/3 pot bet extracts value '
        'from worse kings and pairs. You want to bet every street but sizing '
        'down on turns and rivers is often correct with strong but vulnerable '
        'made hands.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'turn_02',
    category: ScenarioCategory.turnBarrel,
    title: 'Flush Completes on Turn',
    situation:
        'You opened BTN with A♣Q♣. BB called. Flop: K♣8♣4♦. You bet 2/3 '
        'pot with nut flush draw, villain called. Turn: J♠. Villain checks. '
        'Pot: 20BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (6.7BB)',
      'Bet 2/3 pot (13.3BB)',
      'Bet pot (20BB)',
    ],
    correctIndex: 0,
    explanation:
        'Your flush draw missed and J on the turn completes a lot of villain\'s '
        'calling range (KJ, QJ, JT etc.). AQ has overcards but no equity '
        'boost on this turn. Giving up and checking back is correct — '
        'barreling turns without equity or fold equity burns money.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'turn_03',
    category: ScenarioCategory.turnBarrel,
    title: 'Two-Pair Turn Bet for Value',
    situation:
        'You opened CO with K♠J♦. BTN called. Flop: K♦J♣5♥. You bet 2/3 '
        'pot, BTN called. Turn: 9♠. BTN checks. Pot: 22BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (7.3BB)',
      'Bet 2/3 pot (14.7BB)',
      'Bet pot (22BB)',
    ],
    correctIndex: 2,
    explanation:
        'Two pair on a somewhat wet board should bet large. 9♠ brings a '
        'potential straight draw (QT, T8). You need to charge draws and get '
        'max value from worse hands. A 2/3 pot bet is balanced between value '
        'and protection. Checking risks free cards.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'turn_04',
    category: ScenarioCategory.turnBarrel,
    title: 'Scare Card on Turn: Give Up?',
    situation:
        'You opened UTG with Q♠Q♦. BTN called. Flop: 8♥6♣3♦. You bet '
        '2/3 pot, BTN called. Turn: A♣. BTN checks. Pot: 20BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (6.7BB)',
      'Bet 2/3 pot (13.3BB)',
      'Bet pot (20BB)',
    ],
    correctIndex: 0,
    explanation:
        'An ace on the turn is a scare card for QQ. BTN called a flop bet '
        'on 863 and an ace hits their calling range (A8, A6, AA, AK, AQ). '
        'Checking back is the prudent play here — the pot is still winnable '
        'at showdown and you avoid bloating against hands that now beat you.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'turn_05',
    category: ScenarioCategory.turnBarrel,
    title: 'Semi-Bluff Barrel with Flush Draw',
    situation:
        'You opened BTN with A♦9♦. BB called. Flop: K♦7♦2♣. You bet 1/3 '
        'pot, BB called. Turn: T♦ (flush completes). BB checks. Pot: 16BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (5.3BB)',
      'Bet 2/3 pot (10.7BB)',
      'Bet pot (16BB)',
    ],
    correctIndex: 2,
    explanation:
        'You rivered the nut flush on the turn! Bet large for value. A 2/3 '
        'bet extracts maximum value from KX, worse flushes, and sets that '
        'won\'t fold. Checking here is a massive mistake with the nut flush — '
        'you need to get as much money in as possible.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'turn_06',
    category: ScenarioCategory.turnBarrel,
    title: 'Over-Pair Double Barrel Wet Board',
    situation:
        'You opened CO with J♠J♣. BB called. Flop: 8♦6♣3♣ (club flush '
        'draw). You bet 2/3 pot, BB called. Turn: T♥. BB checks. Pot: 22BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (7.3BB)',
      'Bet 2/3 pot (14.7BB)',
      'Bet pot (22BB)',
    ],
    correctIndex: 1,
    explanation:
        'JJ on T863 with a flush draw: turn brings a T which could pair '
        'villain\'s top pair. A small turn bet is appropriate — you still '
        'have an overpair but the board gets wetter. 1/3 pot probes for '
        'information and charges the club draw while pot controlling '
        'against sets and two pair.',
    difficulty: 3,
  ),

  DrillScenario(
    id: 'turn_07',
    category: ScenarioCategory.turnBarrel,
    title: 'Turned Straight: Bet or Slow Play?',
    situation:
        'You called BTN with 9♠8♠ vs CO open. Flop: J♦T♣2♥. CO bets, you '
        'call (OESD). Turn: 7♦ (you made straight). CO bets 2/3 pot. '
        'Pot: 28BB.',
    options: [
      'Fold',
      'Call',
      'Raise to 3x',
      'Raise all-in',
    ],
    correctIndex: 2,
    explanation:
        'You made the nuts (9876 straight is not quite nuts, 8-high straight). '
        'Actually you have 7-J for a J-high straight. Raising here for value '
        'is correct. A 3x raise extracts value from flushes, two pairs, and '
        'sets. Calling keeps the pot small but the turn is the spot to '
        'build the pot with the nuts.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'turn_08',
    category: ScenarioCategory.turnBarrel,
    title: 'Bluff Barrel Missed Flop Continuation',
    situation:
        'You opened HJ with A♣K♥. BTN called. Flop: 9♦6♠3♣. You c-bet '
        '1/3 pot, BTN called. Turn: 5♥. BTN checks. Pot: 18BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (6BB)',
      'Bet 2/3 pot (12BB)',
      'Bet pot (18BB)',
    ],
    correctIndex: 0,
    explanation:
        'AK with no pair, no draw on 9635 should check back the turn. You '
        'have two overcards but no equity improvement. The turn 5 adds a '
        'straight possibility (78) that BTN could have. Giving up here '
        'and re-evaluating on the river is correct. Double barreling '
        'air without equity is a leak.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'turn_09',
    category: ScenarioCategory.turnBarrel,
    title: 'Set on Wet Board: Protect',
    situation:
        'You opened BTN with 7♠7♦. BB called. Flop: J♣7♥4♣. You bet '
        '2/3 pot with middle set, BB called. Turn: 8♣ (three clubs). '
        'BB checks. Pot: 24BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (8BB)',
      'Bet 2/3 pot (16BB)',
      'Bet pot (24BB)',
    ],
    correctIndex: 2,
    explanation:
        'Middle set on a flushing board must bet for protection. The 8♣ '
        'brings three clubs and a straight draw (9T, T9). You need to '
        'charge flush and straight draws maximally. 2/3 pot is appropriate '
        '— pot allows you to get stacks in by the river.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'turn_10',
    category: ScenarioCategory.turnBarrel,
    title: 'Turn Probe Bet vs Checked Flop',
    situation:
        'You are BB with T♥9♥. BTN opened, you called. Flop: 8♦5♠2♣. '
        'You check, BTN checks back. Turn: 7♥ (you have OESD + bdfd). '
        'Pot: 5.5BB.',
    options: [
      'Check',
      'Bet 1/3 pot (1.8BB)',
      'Bet 2/3 pot (3.7BB)',
      'Bet pot (5.5BB)',
    ],
    correctIndex: 2,
    explanation:
        'When the pre-flop raiser checks back the flop, their range is '
        'capped — they don\'t have strong hands. You now have OESD + backdoor '
        'flush on the turn and should probe-bet at the checked-back range. '
        'A 2/3 pot probe with draws is strong and can win immediately or '
        'hit the river.',
    difficulty: 3,
  ),

  // ── RIVER SPOT (8 scenarios) ───────────────────────────────────────────────

  DrillScenario(
    id: 'river_01',
    category: ScenarioCategory.riverSpot,
    title: 'Thin Value River Bet',
    situation:
        'You opened BTN with A♦J♦. BB called. Flop: A♣8♥4♠. Turn: 3♦. '
        'River: 2♣. You bet flop and turn; villain called twice. '
        'Villain checks river. Pot: 42BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (14BB)',
      'Bet 2/3 pot (28BB)',
      'Bet pot (42BB)',
    ],
    correctIndex: 1,
    explanation:
        'Ax on A8432 board should value bet thin on the river. Villain called '
        'two streets and is likely holding a weak ace, 8x, or a pair. A '
        'small 1/3 river bet gets called by worse aces and weak pairs. '
        'Larger bets fold out too many bluff catchers.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'river_02',
    category: ScenarioCategory.riverSpot,
    title: 'Missed Draw River Bluff',
    situation:
        'You opened CO with K♣Q♣. BTN called. Flop: J♠T♣4♣ (flush draw, '
        'OESD). Turn: 5♦. River: 2♥. Villain checked both turns. '
        'Pot: 18BB. You missed everything.',
    options: [
      'Check back',
      'Bet 1/3 pot (6BB)',
      'Bet 2/3 pot (12BB)',
      'Bet pot (18BB)',
    ],
    correctIndex: 2,
    explanation:
        'With missed draws on a board that shouldn\'t have improved villain\'s '
        'range, a 2/3 pot bluff is correct. Checking gives up the pot. You '
        'have strong blockers (KQ blocks KJ, QJ straights). A polarized '
        'river bluff forces villain to make a tough decision with pairs.',
    difficulty: 3,
  ),

  DrillScenario(
    id: 'river_03',
    category: ScenarioCategory.riverSpot,
    title: 'Bet for Value with Two Pair on River',
    situation:
        'You opened UTG with A♠J♠. BB called. Flop: A♦J♥7♣. You bet '
        'each street for value. River: 6♦. Villain check-calls twice. '
        'River check from villain. Pot: 50BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (16.7BB)',
      'Bet 2/3 pot (33.3BB)',
      'Bet pot (50BB)',
    ],
    correctIndex: 2,
    explanation:
        'Two pair on a dry board with a villain who has called twice should '
        'value bet large on the river. You beat all single pair hands and '
        'weaker two pair. 2/3 pot extracts maximum value. A player who '
        'check-calls twice typically has a strong but not nuts hand.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'river_04',
    category: ScenarioCategory.riverSpot,
    title: 'River Check-Back Showdown Value',
    situation:
        'You opened BTN with K♠T♠. BB called. Flop: K♦9♣3♠. You bet '
        '2/3 pot. BB calls. Turn: 8♣. Both check. River: 5♥. Villain '
        'checks. Pot: 18BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (6BB)',
      'Bet 2/3 pot (12BB)',
      'Bet pot (18BB)',
    ],
    correctIndex: 0,
    explanation:
        'After checking the turn, your KT is now in a showdown position. '
        'The river is a blank. Betting doesn\'t accomplish much — worse hands '
        'fold, better hands call or raise. Checking back and winning at '
        'showdown is the highest-EV play. This is a "blocking bet" spot '
        'that many players misplay.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'river_05',
    category: ScenarioCategory.riverSpot,
    title: 'River Overbet Bluff',
    situation:
        'You opened CO with 5♣4♣. BTN called. Flop: A♠K♦3♣. You '
        'c-bet 1/3, BTN called. Turn: 2♦ (you have a straight draw). '
        'You bet 2/3, BTN called. River: J♥ (missed). BTN checks. Pot: 44BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (14.7BB)',
      'Bet 2/3 pot (29.3BB)',
      'Overbet 1.5x pot (66BB)',
    ],
    correctIndex: 3,
    explanation:
        'Overbetting the river as a bluff on AKJ23 is a high-level play. '
        'Your range when you fire three streets on this board is extremely '
        'polarized — sets, two pair, and big draws. An overbet bluff with '
        '54 (which missed the straight) represents the strongest part of '
        'your range. BTN is forced to call with very strong hands only.',
    difficulty: 3,
  ),

  DrillScenario(
    id: 'river_06',
    category: ScenarioCategory.riverSpot,
    title: 'Nut Flush River Value',
    situation:
        'You opened BTN with A♥8♥. BB called. Flop: K♥7♥2♣. You bet, '
        'villain called. Turn: 3♦. Check-check. River: 5♥ (you hit nut '
        'flush). Villain checks. Pot: 22BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (7.3BB)',
      'Bet 2/3 pot (14.7BB)',
      'Bet pot (22BB)',
    ],
    correctIndex: 3,
    explanation:
        'Nut flush on the river should almost always bet pot or close to it. '
        'Villain\'s check twice on this board suggests a weak hand or a '
        'medium flush. You should extract maximum value. Many players under- '
        'bet the river with the nuts — this is a massive EV loss.',
    difficulty: 1,
  ),

  DrillScenario(
    id: 'river_07',
    category: ScenarioCategory.riverSpot,
    title: 'Polarized River Bet Sizing',
    situation:
        'You opened HJ with Q♦Q♣. BTN called. Flop: Q♠J♦T♣ (you flop '
        'top set on dangerous board). You bet all streets. River: 4♠. '
        'Villain check-called flop and turn. Villain checks river. Pot: 60BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (20BB)',
      'Bet 2/3 pot (40BB)',
      'Bet pot (60BB)',
    ],
    correctIndex: 2,
    explanation:
        'Top set on QJT4 after two streets: you should bet again for value. '
        'Villain has been calling twice — they likely have a straight (AK, K9) '
        'or weaker sets/two pair. 2/3 pot is appropriate because villain is '
        'likely strong and will call. Going for maximum value when ahead is '
        'critical.',
    difficulty: 3,
  ),

  DrillScenario(
    id: 'river_08',
    category: ScenarioCategory.riverSpot,
    title: 'River Probe Bet IP after Turn Check',
    situation:
        'You called in position with T♣9♦ vs CO opener. Flop: J♥T♠4♦. '
        'CO bets, you call. Turn: 2♣. CO checks, you check. River: K♦. '
        'CO checks. Pot: 20BB.',
    options: [
      'Check back',
      'Bet 1/3 pot (6.7BB)',
      'Bet 2/3 pot (13.3BB)',
      'Bet pot (20BB)',
    ],
    correctIndex: 1,
    explanation:
        'Second pair (tens) after CO shows weakness (checks turn, checks '
        'river). A thin value bet of 1/3 pot gets called by hands worse than '
        'tens: 9s, 8s, and busted draws. Checking gives up value. A large '
        'bet folds out the weaker hands that would call small.',
    difficulty: 2,
  ),

  // ── BLUFF CATCH (5 scenarios) ──────────────────────────────────────────────

  DrillScenario(
    id: 'catch_01',
    category: ScenarioCategory.bluffCatch,
    title: 'Call River Bet with Top Pair',
    situation:
        'You called BTN open from BB with K♥7♥. Flop: K♦9♠3♣. '
        'You check-called. Turn: 2♦. You check-called. River: 8♠. '
        'Villain bets 2/3 pot. Pot: 40BB.',
    options: [
      'Fold',
      'Call',
      'Raise to 3x',
      'Raise all-in',
    ],
    correctIndex: 1,
    explanation:
        'Top pair top kicker should be a bluff catcher on K932 board. '
        'Villain can have value (sets, two pair) but also has many bluffs '
        '(missed QJ, missed flush draws, JT). At 2/3 pot odds you need '
        '~40% equity to break even. Against a balanced range TPTK is '
        'usually a call.',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'catch_02',
    category: ScenarioCategory.bluffCatch,
    title: 'Fold Marginal Hand to River Overbet',
    situation:
        'You opened CO with Q♠J♦. BTN called. Flop: J♣8♥3♦. You '
        'bet twice, BTN called twice. River: 2♠. BTN bets 1.5x pot. Pot: 50BB.',
    options: [
      'Fold',
      'Call',
      'Raise to 3x',
      'Raise all-in',
    ],
    correctIndex: 0,
    explanation:
        'A river overbet from a passive caller usually represents a very '
        'strong hand. Top pair with QJ cannot call a 1.5x pot overbet '
        'profitably. Against most players\' range of overbets, you need '
        '~40% equity and QJ on J832 doesn\'t have it vs the overbet range '
        '(sets, two pair, and some bluffs).',
    difficulty: 2,
  ),

  DrillScenario(
    id: 'catch_03',
    category: ScenarioCategory.bluffCatch,
    title: 'Bluff Catch with Missed Draw Blocker',
    situation:
        'You opened HJ with A♣5♣. BTN called. Flop: 8♣6♣2♦. You check. '
        'BTN bets 2/3 pot, you call. Turn: T♠. Both check. River: 7♥. '
        'You check. BTN bets pot. Pot: 28BB.',
    options: [
      'Fold',
      'Call',
      'Raise to 3x',
      'Raise all-in',
    ],
    correctIndex: 1,
    explanation:
        'A♣5♣ has the nut flush blocker — villain cannot have the nut flush. '
        'The 7 on the river completes some straights (59, 9T). Your ace '
        'blocker reduces villain\'s nutted combos significantly. Against a '
        'pot bet you need 33% equity. Given the blockers and the number of '
        'bluffs on this board, calling is profitable.',
    difficulty: 3,
  ),

  DrillScenario(
    id: 'catch_04',
    category: ScenarioCategory.bluffCatch,
    title: 'Hero Call with Second Pair',
    situation:
        'You called BB with T♦9♦ vs BTN open. Flop: J♦T♠4♣. '
        'Turn: 2♥. River: K♠. You check-called flop. Turn and river both '
        'checked through until villain fires 2/3 pot on river. Pot: 22BB.',
    options: [
      'Fold',
      'Call',
      'Raise to 3x',
      'Raise all-in',
    ],
    correctIndex: 0,
    explanation:
        'Second pair (tens) on J-T-4-2-K board after villain checks turn and '
        'fires river. The king on the river is a scare card that villain '
        'could represent. Second pair is a bluff catcher but you can only '
        'beat a bluff. Against most villain ranges betting flop then checking '
        'turn then betting river is more value-heavy. Fold is correct here.',
    difficulty: 3,
  ),

  DrillScenario(
    id: 'catch_05',
    category: ScenarioCategory.bluffCatch,
    title: 'Overpair Call vs River Shove',
    situation:
        'You opened CO with K♠K♦. BTN called. Flop: 9♦7♦4♣. You bet '
        'twice, BTN called twice. River: 2♠. BTN shoves all-in for '
        '1.2x pot. Pot: 45BB.',
    options: [
      'Fold',
      'Call',
      'Raise',
      'Call only if pot odds justify',
    ],
    correctIndex: 1,
    explanation:
        'KK as an overpair on 9742 vs a river shove: this is a classic bluff '
        'catching spot. Villain called two streets on a low board and shoves '
        'the river. Their range includes sets (44, 77, 99), two pairs, '
        'straights but also pure bluffs with missed diamonds. At 1.2x pot '
        'you need 37% equity. KK is ahead of all bluffs — this is a call.',
    difficulty: 3,
  ),
];
