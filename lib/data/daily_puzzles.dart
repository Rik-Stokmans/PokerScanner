// Daily puzzle data — 90 poker scenario puzzles across 9 categories.
// Selected by: allDailyPuzzles[DateTime.now().difference(DateTime(2026, 1, 1)).inDays % allDailyPuzzles.length]

class DailyPuzzle {
  final String id;
  final String title;
  final String situation;
  final List<String> holeCards;
  final List<String> communityCards;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String difficulty; // 'Beginner', 'Intermediate', 'Advanced', 'Expert'
  final String category;

  const DailyPuzzle({
    required this.id,
    required this.title,
    required this.situation,
    required this.holeCards,
    required this.communityCards,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
    required this.category,
  });
}

const List<DailyPuzzle> allDailyPuzzles = [
  // ─── Preflop Squeeze (10) ──────────────────────────────────────────────────

  DailyPuzzle(
    id: 'sq_01',
    title: 'Classic Squeeze Spot',
    situation:
        'Cash game 6-max \$1/\$2. UTG opens to \$6, CO calls \$6. You are on the BTN with AKs. Action is on you.',
    holeCards: ['A♠', 'K♠'],
    communityCards: [],
    options: [
      'Call \$6 — keep the pot small',
      '3-bet to \$22 — standard squeeze',
      '3-bet to \$28 — larger squeeze vs two players',
      'Fold — too many players in already',
    ],
    correctIndex: 2,
    explanation:
        'With AKs facing an open and a call, you have a premium squeeze candidate. Size up vs two players already in — around 3.5–4x the open plus the caller\'s call, i.e. ~\$28. This denies equity from both, builds a pot in position, and folds out dominated hands.',
    difficulty: 'Intermediate',
    category: 'Preflop Squeeze',
  ),

  DailyPuzzle(
    id: 'sq_02',
    title: 'Light Squeeze Bluff',
    situation:
        'Cash game 6-max \$1/\$2. MP opens to \$6, HJ calls. You are in the CO with 76s. Should you squeeze?',
    holeCards: ['7♥', '6♥'],
    communityCards: [],
    options: [
      'Fold — 76s is too weak to squeeze',
      'Call — play the hand in position',
      '3-bet to \$22 — squeeze bluff with good blockers',
      '3-bet to \$28 — must go large when squeezing',
    ],
    correctIndex: 2,
    explanation:
        '76s is an excellent light squeeze bluff: it has removal to straight-completing holdings, good playability when called, and can fold out a wide MP opening range plus a calling range. A standard 3x squeeze size works here. Flatting is fine too but misses the equity denial benefit.',
    difficulty: 'Advanced',
    category: 'Preflop Squeeze',
  ),

  DailyPuzzle(
    id: 'sq_03',
    title: 'SB Squeeze vs BTN Steal',
    situation:
        'Cash game 6-max \$1/\$2. BTN opens to \$6, BB calls. You are in the SB with QQ. What is your action?',
    holeCards: ['Q♦', 'Q♣'],
    communityCards: [],
    options: [
      'Call — play cautiously OOP with QQ',
      '3-bet to \$20 — build a pot with an overpair',
      '3-bet to \$26 — punish the wide BTN range and caller',
      '4-bet shove — QQ is too strong to just 3-bet',
    ],
    correctIndex: 2,
    explanation:
        'QQ is a mandatory squeeze here. Size up to 4–4.5x the open when there is already a caller (\$26–28). You are OOP so you want to thin the field and build a pot while you are likely ahead. Calling OOP vs two players is a mistake with a premium hand.',
    difficulty: 'Intermediate',
    category: 'Preflop Squeeze',
  ),

  DailyPuzzle(
    id: 'sq_04',
    title: 'Cold 4-Bet Squeeze',
    situation:
        'Cash game \$1/\$2. UTG opens \$6, BTN 3-bets to \$18, SB calls. You are in the BB with AA. Action on you.',
    holeCards: ['A♦', 'A♥'],
    communityCards: [],
    options: [
      'Call — disguise the aces and see a flop',
      '4-bet to \$56 — standard cold 4-bet',
      '4-bet to \$72 — larger sizing vs three players',
      'Fold — too much action, likely dominated',
    ],
    correctIndex: 1,
    explanation:
        'AA should 4-bet here, typically ~3x the 3-bet (\$54–58). The SB caller makes the pot larger so you need a slightly larger sizing. Never call with AA from the BB vs three players — you lose too much EV by letting everyone in with odds. Fold is clearly wrong.',
    difficulty: 'Beginner',
    category: 'Preflop Squeeze',
  ),

  DailyPuzzle(
    id: 'sq_05',
    title: 'Squeeze with Blocker',
    situation:
        'MTT. Blinds 100/200. UTG opens 450, MP calls. You are on the BTN with AJs. Effective stacks 18,000.',
    holeCards: ['A♦', 'J♠'],
    communityCards: [],
    options: [
      'Fold — not a premium enough hand',
      'Call — see a flop in position',
      '3-bet to 1,450 — squeeze and leverage the A blocker',
      '3-bet jam — maximise fold equity now',
    ],
    correctIndex: 2,
    explanation:
        'AJs is a good squeeze candidate: the A blocks AA/AK/AQ, your hand dominates calling ranges, and you are in position. 3-bet to about 3.2x the open plus the caller (~1,450–1,600). The A blocker makes this a higher-EV squeeze than hands like KQs.',
    difficulty: 'Intermediate',
    category: 'Preflop Squeeze',
  ),

  DailyPuzzle(
    id: 'sq_06',
    title: 'SB Squeeze vs Multiway',
    situation:
        'Cash game 6-max \$2/\$5. BTN opens \$15, BB calls. You are in the SB with KQo. Action on you.',
    holeCards: ['K♥', 'Q♦'],
    communityCards: [],
    options: [
      'Fold — KQo is dominated OOP',
      'Call — keep the pot small',
      '3-bet to \$52 — squeeze as a semi-bluff',
      '3-bet jam — max fold equity',
    ],
    correctIndex: 2,
    explanation:
        'KQo is a marginal squeeze candidate OOP. Squeezing here forces the BTN to call cold off a 3-bet or fold, and denies the BB their flat. Size to ~3.5x the open (~\$52). You block KK, QQ, KQ hands the BTN might continue with. Calling OOP creates a multiway pot which KQo plays poorly.',
    difficulty: 'Advanced',
    category: 'Preflop Squeeze',
  ),

  DailyPuzzle(
    id: 'sq_07',
    title: 'Squeeze from the Blinds',
    situation:
        'MTT. Blinds 200/400 ante 50. CO opens 900, BTN calls. You are in the BB with TT. Effective stacks 28,000.',
    holeCards: ['T♠', 'T♦'],
    communityCards: [],
    options: [
      'Call — pot is already multiway, play carefully',
      '3-bet to 2,900 — standard squeeze',
      '3-bet to 3,600 — larger sizing for multiway pot',
      'Fold — TT too vulnerable OOP',
    ],
    correctIndex: 2,
    explanation:
        'TT is a strong squeeze hand from the BB. In MTTs, 3-bet sizing should be slightly larger vs a caller (~4x + antes = ~3,400–3,800). You want to isolate one opponent or pick up the pot. Calling puts you OOP in a multiway pot where TT does not flop an overpair often enough.',
    difficulty: 'Intermediate',
    category: 'Preflop Squeeze',
  ),

  DailyPuzzle(
    id: 'sq_08',
    title: 'Squeeze or Flat with JJ?',
    situation:
        'Cash game 6-max \$2/\$5. UTG opens \$15, MP calls \$15. You are on the BTN with JJ.',
    holeCards: ['J♦', 'J♠'],
    communityCards: [],
    options: [
      'Fold — UTG range crushes JJ',
      'Call — play JJ in position',
      '3-bet to \$50 — squeeze to thin the field',
      '3-bet jam — must protect JJ',
    ],
    correctIndex: 2,
    explanation:
        'JJ should squeeze from the BTN. Calling in position is acceptable but the issue is you allow SB/BB to enter cheaply, creating multiway pots where JJ faces many overs. Squeezing to 3.3–3.5x isolates the opener or takes down the dead money. Fold is terrible with JJ.',
    difficulty: 'Intermediate',
    category: 'Preflop Squeeze',
  ),

  DailyPuzzle(
    id: 'sq_09',
    title: 'Re-squeeze in MTT',
    situation:
        'MTT bubble. Blinds 500/1000 ante 100. HJ opens 2,200. CO 3-bets to 5,600. You are on the BTN with KK. Effective stacks 60,000.',
    holeCards: ['K♣', 'K♥'],
    communityCards: [],
    options: [
      'Call — disguise the hand at the bubble',
      '4-bet to 13,500 — standard cold 4-bet',
      '4-bet jam — KK wants maximum fold equity',
      'Fold — too risky at the bubble',
    ],
    correctIndex: 1,
    explanation:
        'KK cold 4-bets here, typically to 2.2–2.5x the 3-bet (~13,000–14,000). Jamming is also defensible but leaves chips on the table if the 3-bettor folds. Calling gives every player dead money to call and creates a multiway pot. Never fold KK preflop except in extreme ICM spots (final table with >10:1 pay jumps).',
    difficulty: 'Advanced',
    category: 'Preflop Squeeze',
  ),

  DailyPuzzle(
    id: 'sq_10',
    title: 'Squeeze with Suited Connector',
    situation:
        'Cash game 6-max \$1/\$2. CO opens \$6, BTN calls. You are in the SB with 98s.',
    holeCards: ['9♠', '8♠'],
    communityCards: [],
    options: [
      'Fold — not worth squeezing OOP with a connector',
      'Call — great multiway hand',
      '3-bet to \$22 — squeeze bluff, good equity when called',
      '3-bet to \$30 — premium squeeze size',
    ],
    correctIndex: 2,
    explanation:
        '98s is a popular squeeze bluff from the SB: great equity post-flop if called, blocking some straight-making hands, and opponents have to call cold OOP. \$22 is the standard 3.5x the open + caller size. The hand plays well in a heads-up pot and folds to a 4-bet cleanly.',
    difficulty: 'Advanced',
    category: 'Preflop Squeeze',
  ),

  // ─── BB Defense (10) ──────────────────────────────────────────────────────

  DailyPuzzle(
    id: 'bbd_01',
    title: 'Defending vs BTN Steal',
    situation:
        'Cash game 6-max \$1/\$2. BTN opens to \$6 (common steal). You are in the BB with 96o. One SB has folded.',
    holeCards: ['9♦', '6♠'],
    communityCards: [],
    options: [
      'Fold — 96o is too weak',
      'Call — defend your BB with pot odds',
      '3-bet to \$18 — aggressive BB defense',
      '3-bet jam — max aggression',
    ],
    correctIndex: 1,
    explanation:
        'You have ~3:1 pot odds to call from the BB. 96o is a borderline but defensible call vs a wide BTN stealing range — you have position-adjusted pot odds and the hand has playability on low/mid connected boards. Folding here contributes to overfolding the BB, a common leak.',
    difficulty: 'Beginner',
    category: 'BB Defense',
  ),

  DailyPuzzle(
    id: 'bbd_02',
    title: 'BB vs CO Open',
    situation:
        'Cash game 6-max \$1/\$2. CO opens \$6. BTN folds, SB folds. You are in the BB with K5s.',
    holeCards: ['K♦', '5♦'],
    communityCards: [],
    options: [
      'Fold — K5s is not strong enough',
      'Call — straightforward BB defend',
      '3-bet to \$18 — K5s is a good 3-bet bluff with K blocker',
      '3-bet to \$22 — larger 3-bet size',
    ],
    correctIndex: 2,
    explanation:
        'K5s is the classic mixed-strategy BB 3-bet. The K blocks AA/KK/AK, making your 3-bet more profitable. Against CO opens (~18–22% range), 3-betting with K5s adds good balance to your BB range. Calling is acceptable but 3-betting is slightly +EV due to equity denial and blocker effects.',
    difficulty: 'Intermediate',
    category: 'BB Defense',
  ),

  DailyPuzzle(
    id: 'bbd_03',
    title: 'BB vs UTG Open',
    situation:
        'Cash game 6-max \$1/\$2. UTG opens \$6. All fold to BB. You hold Q7o.',
    holeCards: ['Q♥', '7♣'],
    communityCards: [],
    options: [
      'Fold — UTG range is too strong',
      'Call — pot odds make it profitable',
      '3-bet — Q7o is a good bluff candidate',
      'Fold — never defend Q7o',
    ],
    correctIndex: 0,
    explanation:
        'Q7o vs a UTG opening range (~12–15%) is a fold from the BB despite good pot odds. UTG\'s range is too tight and too strong for Q7o to be profitable heads-up OOP. The implied odds are negative because you will rarely make a strong enough hand to stack UTG.',
    difficulty: 'Beginner',
    category: 'BB Defense',
  ),

  DailyPuzzle(
    id: 'bbd_04',
    title: 'Facing a Large BB Steal',
    situation:
        'Cash game 6-max \$1/\$2. BTN opens to \$10 (large size). SB folds. You are in the BB with A4s.',
    holeCards: ['A♣', '4♣'],
    communityCards: [],
    options: [
      'Fold — A4s not worth calling large sizing',
      'Call — A4s has great playability',
      '3-bet to \$30 — use the A blocker and go semi-aggressive',
      '3-bet to \$36 — must 3-bet vs large sizing to not over-call',
    ],
    correctIndex: 2,
    explanation:
        'A4s is a strong 3-bet candidate here. The large BTN size (\$10) means calling OOP is tougher. A4s 3-bets well: Ace blocker attacks the top of BTN\'s range, the suited nut-flush draw adds equity, and you can profitably 5-bet jam or fold to a 4-bet. Sizing ~3x the open (\$30) works.',
    difficulty: 'Intermediate',
    category: 'BB Defense',
  ),

  DailyPuzzle(
    id: 'bbd_05',
    title: 'BB Facing a Min-Raise',
    situation:
        'Cash game 6-max \$1/\$2. BTN min-raises to \$4. SB folds. You are in the BB with 53s.',
    holeCards: ['5♥', '3♥'],
    communityCards: [],
    options: [
      'Fold — 53s is too weak even vs a min-raise',
      'Call — pot odds are excellent vs a min-raise',
      '3-bet to \$14 — attack the wide range that min-raises',
      '3-bet jam — 53s plays badly post-flop',
    ],
    correctIndex: 1,
    explanation:
        'A BTN min-raise gives you 3:1 pot odds and implies a very wide BTN range. 53s is an auto-call here: great pot odds, disguised hand, and strong implied odds when you flop a straight draw or two pair on low boards. 3-betting is possible but 53s benefits from multiway pots.',
    difficulty: 'Beginner',
    category: 'BB Defense',
  ),

  DailyPuzzle(
    id: 'bbd_06',
    title: 'BB vs SB Limp-Raise',
    situation:
        'Cash game 6-max \$1/\$2. SB completes (limps). You are in the BB with K8o. Do you check or raise?',
    holeCards: ['K♠', '8♥'],
    communityCards: [],
    options: [
      'Check — play the hand passively',
      'Raise to \$8 — attack SB limp range',
      'Raise to \$6 — small raise',
      'Raise to \$10 — large raise to win pot immediately',
    ],
    correctIndex: 1,
    explanation:
        'When SB limps, you should raise with a significant portion of your range in the BB to take the initiative. K8o is a value hand vs a SB limping range. Raising to 3–4x (\$6–8) denies equity and forces SB to call OOP. Checking gives SB a free flop with a wide range that can outdraw you.',
    difficulty: 'Beginner',
    category: 'BB Defense',
  ),

  DailyPuzzle(
    id: 'bbd_07',
    title: '3-Bet or Call from BB',
    situation:
        'Cash game 6-max \$1/\$2. BTN opens \$6, SB 3-bets to \$18. You are in the BB with TT.',
    holeCards: ['T♣', 'T♥'],
    communityCards: [],
    options: [
      'Fold — TT is dominated by SB 3-bet range',
      'Call — see a flop with implied odds',
      '4-bet to \$52 — put maximum pressure on SB',
      '4-bet to \$60 — go big to force folds',
    ],
    correctIndex: 2,
    explanation:
        'TT vs BTN open + SB 3-bet is a 4-bet or fold decision from the BB. Calling puts you OOP in a 3-way pot with a medium pair — not ideal. 4-betting to ~2.8–3x the 3-bet (\$50–56) forces the SB to commit or fold and protects your TT against overcards. Folding surrenders too much equity.',
    difficulty: 'Advanced',
    category: 'BB Defense',
  ),

  DailyPuzzle(
    id: 'bbd_08',
    title: 'BB Defense Frequency',
    situation:
        'Cash game 6-max \$1/\$2. BTN opens \$6, SB folds. You are in the BB. BTN opens this spot 55% of the time. With what hands should you 3-bet instead of call?',
    holeCards: ['J♠', '9♠'],
    communityCards: [],
    options: [
      'Always call with J9s, never 3-bet without nut hands',
      'Mix 3-bet J9s at ~30% frequency to balance your BB range',
      'Always 3-bet J9s, it is a premium semi-bluff',
      'Fold J9s — not worth defending',
    ],
    correctIndex: 1,
    explanation:
        'J9s is a mixed strategy hand in the BB vs a wide BTN opener. Against a 55% opening range you should be defending ~50%+ from the BB. J9s should be in your calling range primarily, with occasional 3-bets (~25–35%) to prevent BTN from exploiting a purely calling BB range. Always calling or always 3-betting is exploitable.',
    difficulty: 'Expert',
    category: 'BB Defense',
  ),

  DailyPuzzle(
    id: 'bbd_09',
    title: 'BB Defense with a Pair',
    situation:
        'MTT. Blinds 100/200. CO opens 500. BTN folds, SB folds. You are in the BB with 55.',
    holeCards: ['5♦', '5♠'],
    communityCards: [],
    options: [
      'Fold — small pairs are weak OOP',
      'Call — standard set-mining call with good implied odds',
      '3-bet to 1,400 — semi-bluff with 55',
      '3-bet jam — in MTTs small pairs need to go all in',
    ],
    correctIndex: 1,
    explanation:
        'In the BB with 55 vs a CO open, calling is standard. You have excellent pot odds (\$300 to win ~\$700), you will have position post-flop half the time (you are OOP but seeing a 4-card community). When you flop a set (~11.8% frequency), you have great implied odds to stack the opener. 3-betting is also fine but more risky.',
    difficulty: 'Beginner',
    category: 'BB Defense',
  ),

  DailyPuzzle(
    id: 'bbd_10',
    title: 'Facing a 4x Raise',
    situation:
        'Cash game \$1/\$2. EP opens to \$8 (4x). All fold to you in the BB with ATo.',
    holeCards: ['A♣', 'T♦'],
    communityCards: [],
    options: [
      'Fold — ATo OOP vs EP 4x is too tough',
      'Call — pot odds force a call',
      '3-bet to \$26 — attack the tighter EP range with the A blocker',
      '3-bet to \$32 — larger sizing vs a big open',
    ],
    correctIndex: 2,
    explanation:
        'ATo vs a large EP open is a marginal 3-bet candidate. The A blocker is valuable (blocks AA/AK/AQ). A 3-bet folds out all the dominated hands that are calling the 4x raise. If you call, you play OOP vs an EP tight range with a dominated hand often. 3-betting ~3.2x (\$26) is the aggressive but profitable play.',
    difficulty: 'Intermediate',
    category: 'BB Defense',
  ),

  // ─── Flop C-Bet Decision (15) ─────────────────────────────────────────────

  DailyPuzzle(
    id: 'fcb_01',
    title: 'C-Bet Dry Flop as PFR',
    situation:
        'Cash game 6-max \$1/\$2. You 3-bet BTN to \$18, BB calls. Flop: K♠7♦2♣ (rainbow). Pot \$37. BB checks.',
    holeCards: ['A♠', 'Q♦'],
    communityCards: ['K♠', '7♦', '2♣'],
    options: [
      'Check — you missed the board',
      'Bet \$15 — small c-bet on a dry board',
      'Bet \$24 — standard half-pot c-bet',
      'Bet \$37 — pot-size for maximum pressure',
    ],
    correctIndex: 1,
    explanation:
        'K72 rainbow is a dry, disconnected board that heavily favors the 3-bettor\'s range. A small c-bet (33–40% pot) is optimal: you represent a wide value range (KK, KQ, AK, QQ) and the BB cannot have many kings. AQ with a backdoor flush draw can continue with this bet and barrel many turn cards.',
    difficulty: 'Intermediate',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_02',
    title: 'C-Bet Wet Flop Multiway',
    situation:
        'Cash game \$1/\$2. You raised preflop to \$6 from CO, BTN calls, BB calls. Flop: J♥T♥9♦. Pot \$19. BB checks, you are first to act.',
    holeCards: ['A♠', 'K♦'],
    communityCards: ['J♥', 'T♥', '9♦'],
    options: [
      'Check — too many draws, c-bet is too risky',
      'Bet \$8 — small stab',
      'Bet \$14 — half pot c-bet',
      'Bet \$19 — pot-size bet for protection',
    ],
    correctIndex: 0,
    explanation:
        'JT9 is one of the worst c-bet boards for the preflop raiser in a multiway pot. You have AK with no pair and no draw on a fully connected, two-toned board. Checking keeps the pot manageable and might allow the field to bet into you with bluffs. C-betting here often builds a pot you cannot comfortably continue in.',
    difficulty: 'Advanced',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_03',
    title: 'C-Bet Decision with Top Pair',
    situation:
        'Cash game \$1/\$2. You raised to \$6 from BTN, BB calls. Flop: A♦8♣3♥. Pot \$13. BB checks.',
    holeCards: ['A♥', 'J♦'],
    communityCards: ['A♦', '8♣', '3♥'],
    options: [
      'Check — slow-play top pair',
      'Bet \$4 — very small to build pot',
      'Bet \$7 — half pot c-bet',
      'Bet \$13 — pot-size to protect',
    ],
    correctIndex: 1,
    explanation:
        'AJ on A83 rainbow should bet very small (25–33% pot). The board is dry, you have top pair good kicker, and BB has very few sets on this board. A small bet forces BB to call with worse aces, 88, 33, and draws. Larger bets just fold out the hands you dominate. Checking is also reasonable for deception.',
    difficulty: 'Beginner',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_04',
    title: 'Giving Up on a Scary Board',
    situation:
        'Cash game \$1/\$2. You 3-bet from CO to \$18, BTN calls. Flop: 8♥7♥6♠. Pot \$37. You are first to act.',
    holeCards: ['Q♣', 'Q♦'],
    communityCards: ['8♥', '7♥', '6♠'],
    options: [
      'Check — your hand is in bad shape, preserve equity',
      'Bet \$15 — thin value/protection c-bet',
      'Bet \$24 — commit to protecting QQ',
      'Bet \$37 — pot-size to fold out draws',
    ],
    correctIndex: 1,
    explanation:
        'QQ on 876 two-tone is a tricky spot. You have an overpair but the board is very connected and hits the BTN calling range well (56s, 79s, 89s). A small c-bet (~40% pot) probes and can fold out weaker pairs, while keeping the pot manageable if you are raised. Pot-size betting is overcommitting vs a board that crushes your range.',
    difficulty: 'Advanced',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_05',
    title: 'IP C-Bet vs OOP Check',
    situation:
        'Cash game \$1/\$2. BTN opens \$6, you call in CO. Flop: 5♠4♦2♣. BTN checks to you.',
    holeCards: ['T♦', 'T♠'],
    communityCards: ['5♠', '4♦', '2♣'],
    options: [
      'Check back — hand is good, no need to bet',
      'Bet \$5 — small probe on a missed BTN range board',
      'Bet \$9 — half pot c-bet',
      'Bet \$14 — pot-size for protection',
    ],
    correctIndex: 1,
    explanation:
        'TT on 542 rainbow and BTN checks in position is an unusual line. The BTN clearly missed the board (542 heavily favors CO caller\'s range). A small probe (~33% pot) extracts value from BTN\'s 6x, 8x, 9x hands, and can bet/fold to a raise. Checking back wastes the equity advantage you hold.',
    difficulty: 'Intermediate',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_06',
    title: 'Delayed C-Bet Strategy',
    situation:
        'Cash game \$1/\$2. You raised preflop, BB calls. Flop: Q♠J♥9♠. BB checks, you check back. Turn: 2♦. BB checks.',
    holeCards: ['A♣', 'K♣'],
    communityCards: ['Q♠', 'J♥', '9♠', '2♦'],
    options: [
      'Bet \$9 — delayed c-bet; board bricked for BB',
      'Check — give up, you have no equity',
      'Bet \$18 — aggressive delayed c-bet',
      'Bet pot — force BB off a paired board',
    ],
    correctIndex: 1,
    explanation:
        'AK on QJ9 missed and you checked the flop. The 2♦ turn is a complete blank but your hand has no pair and no draw. BB checked twice, which could mean a check-raise waiting or a genuine weak hand. With no equity to protect and a connected board, giving up (checking turn) is the right play. You still have a six-out gut-shot with any ten.',
    difficulty: 'Advanced',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_07',
    title: 'C-Bet Paired Board',
    situation:
        'Cash game \$1/\$2. You raised preflop BTN, BB calls. Flop: A♠A♦8♣. BB checks.',
    holeCards: ['K♥', 'Q♦'],
    communityCards: ['A♠', 'A♦', '8♣'],
    options: [
      'Check — AA board destroys your range, give up',
      'Bet \$5 — small bluff on Ace-paired dry board',
      'Bet \$10 — medium sized c-bet',
      'Bet \$20 — large c-bet to tell a strong story',
    ],
    correctIndex: 1,
    explanation:
        'A♠A♦8♣ heavily favors the BTN preflop raiser\'s range. As the BTN you have all the AA, AK, AQ hands here. BB called preflop but rarely has an ace. A very small c-bet (~33% pot) works as a pure bluff here with KQ — BB will fold most hands that don\'t have the 8 or a pocket pair, and you represent the ace very convincingly.',
    difficulty: 'Intermediate',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_08',
    title: 'Facing a Donk Lead',
    situation:
        'Cash game \$1/\$2. You raised to \$6 from CO, BTN and BB call. Flop: K♠7♣4♥. BB leads out \$10.',
    holeCards: ['A♦', 'K♦'],
    communityCards: ['K♠', '7♣', '4♥'],
    options: [
      'Fold — donk lead from BB usually means they have it',
      'Call — see what the turn brings',
      'Raise to \$28 — raise top pair top kicker for value',
      'Raise to \$40 — max raise to isolate',
    ],
    correctIndex: 2,
    explanation:
        'AK on K74 rainbow vs a donk lead is a raising hand. You have top pair top kicker, BTN still behind you, and the BB donk range is wide (bluffs, draws, worse kings, pairs). Raising to ~2.8x extracts value and folds out BTN. Calling is passive with a strong hand. Always raise for value here.',
    difficulty: 'Intermediate',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_09',
    title: 'C-Bet on Monotone Flop',
    situation:
        'Cash game \$1/\$2. You opened BTN to \$6, BB calls. Flop: K♣8♣5♣ (monotone). BB checks.',
    holeCards: ['A♣', 'Q♠'],
    communityCards: ['K♣', '8♣', '5♣'],
    options: [
      'Check — monotone flop kills c-bet equity',
      'Bet \$4 — very small probe',
      'Bet \$8 — half pot, represent the flush',
      'Bet \$13 — pot-size, powerful range advantage',
    ],
    correctIndex: 2,
    explanation:
        'K♣8♣5♣ monotone is an interesting spot. You have A♣ (nut flush draw) but no made hand. You hold the most important card on this board. A half-pot c-bet with the A♣ as your "blocker" is strong: you block the nut flush, semi-bluff with the draw, and force BB to fold many non-club hands. Full pot sizing is too much as BB can still have KxQc etc.',
    difficulty: 'Advanced',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_10',
    title: 'C-Bet with Middle Pair',
    situation:
        'Cash game \$1/\$2. You 3-bet SB to \$16, BB calls. Flop: A♠8♦3♣. BB checks.',
    holeCards: ['8♠', '8♣'],
    communityCards: ['A♠', '8♦', '3♣'],
    options: [
      'Check — slow-play the set on a scary ace board',
      'Bet \$8 — small value bet',
      'Bet \$14 — half pot',
      'Bet \$20 — large to protect against aces',
    ],
    correctIndex: 1,
    explanation:
        'You flopped a set of eights on an A83 rainbow board. 3-betting as SB your range has all the AA and AK here. BB checking likely means they don\'t have an Ace or are slow-playing something. A small c-bet (~33–40%) is optimal: it gets called by Ax hands (which will pay off on multiple streets), protects against runner-runner draws, and keeps the pot in proportion.',
    difficulty: 'Intermediate',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_11',
    title: 'C-Bet After 3-Bet with Air',
    situation:
        'Cash game \$1/\$2. You 3-bet BB to \$18, BTN calls. Flop: T♠9♣8♦. Pot \$37. You check.',
    holeCards: ['K♦', 'Q♠'],
    communityCards: ['T♠', '9♣', '8♦'],
    options: [
      'Check — abandon the hand entirely',
      'Bet \$12 — small probe with gutshot draw',
      'Bet \$20 — semi-bluff with the nut straight draw',
      'Bet \$37 — put maximum pressure',
    ],
    correctIndex: 2,
    explanation:
        'KQ on T98 gives you the K-high straight draw (need J). You have roughly 4 outs to the nuts and two overcards. A half-pot semi-bluff (~\$18–20) uses your equity draw to generate folds while you still have equity when called. Small is too weak on a board this connected; pot-size overcommits the stacks.',
    difficulty: 'Advanced',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_12',
    title: 'C-Bet vs a Check-Raise',
    situation:
        'Cash game \$1/\$2. You c-bet \$8 into a \$17 pot on A♠K♦7♣. Opponent check-raises to \$24. You hold QQ.',
    holeCards: ['Q♥', 'Q♠'],
    communityCards: ['A♠', 'K♦', '7♣'],
    options: [
      'Fold — QQ is almost never ahead here',
      'Call — pot odds, could be a bluff',
      '3-bet to \$64 — test opponent\'s resolve',
      '3-bet shove — all or nothing',
    ],
    correctIndex: 0,
    explanation:
        'QQ on AK7 vs a check-raise is a fold. Your hand is an underpair to both board cards, and the check-raise range from a BB caller strongly favors two pair (A7, K7, AK) and sets (77, AA, KK). The pot odds (calling \$16 to win ~\$49) require ~25% equity — QQ has roughly 3% vs this realistic value range.',
    difficulty: 'Advanced',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_13',
    title: 'C-Bet Size Selection',
    situation:
        'Cash game \$1/\$2. You 3-bet BTN to \$18, BB calls. Flop: 7♦4♠2♣ rainbow. Pot \$37. BB checks.',
    holeCards: ['A♠', 'A♣'],
    communityCards: ['7♦', '4♠', '2♣'],
    options: [
      'Check — slow-play aces on a dry board',
      'Bet \$10 — small bet to keep BB in',
      'Bet \$18 — half pot',
      'Bet \$30 — large bet to build the pot',
    ],
    correctIndex: 1,
    explanation:
        'AA on 742 rainbow should c-bet small (25–33%). The board completely misses the BB calling range. A small bet maximises the number of streets of value: BB calls with any pair or draw, and you can build the pot gradually. Large bets just fold hands you beat. Slow-playing aces in a 3-bet pot OOP is a common mistake.',
    difficulty: 'Beginner',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_14',
    title: 'Position Impacts C-Bet',
    situation:
        'Cash game \$1/\$2. You called CO from HJ, CO c-bets \$8 into \$17 on Q♦J♦8♠. You hold T♥9♣.',
    holeCards: ['T♥', '9♣'],
    communityCards: ['Q♦', 'J♦', '8♠'],
    options: [
      'Fold — marginal equity, fold to c-bet',
      'Call — you have an open-ended straight draw',
      'Raise to \$24 — semi-bluff raise with the nuts draw',
      'Raise jam — maximum equity pressure',
    ],
    correctIndex: 2,
    explanation:
        'T9 on QJ8 gives you an open-ended straight draw (7 or K completes the straight). This is a premium semi-bluff raise opportunity: raising forces CO to fold many better pairs and draws while you have 8+ outs. A raise to \$24 creates fold equity and if called, you have excellent equity to barrel the turn.',
    difficulty: 'Intermediate',
    category: 'Flop C-Bet Decision',
  ),

  DailyPuzzle(
    id: 'fcb_15',
    title: 'C-Bet or Slowplay',
    situation:
        'Cash game \$1/\$2. You raised CO to \$6, BTN calls. Flop: 9♥9♦3♣. BTN checks.',
    holeCards: ['9♠', '9♣'],
    communityCards: ['9♥', '9♦', '3♣'],
    options: [
      'Check — slow-play quads, let them catch up',
      'Bet \$3 — tiny bet to look like a steal',
      'Bet \$7 — standard half-pot c-bet',
      'Bet \$12 — big bet to build pot immediately',
    ],
    correctIndex: 0,
    explanation:
        'You flopped quads. Slow-playing is clearly correct here — this is one of the strongest hands possible. Betting on 99x flop with quads drives out all the weaker holdings that might catch something on future streets. Check, hope BTN bets, or check and call any bet to build the pot slowly. You have no need to protect here.',
    difficulty: 'Beginner',
    category: 'Flop C-Bet Decision',
  ),

  // ─── Turn Barrel or Give Up (15) ─────────────────────────────────────────

  DailyPuzzle(
    id: 'tbl_01',
    title: 'Double Barrel Dry Turn',
    situation:
        'Cash game \$1/\$2. You c-bet \$10 into \$20 on A♠K♦4♣. BB calls. Turn: 2♥. BB checks. Pot \$40.',
    holeCards: ['Q♣', 'J♦'],
    communityCards: ['A♠', 'K♦', '4♣', '2♥'],
    options: [
      'Check — give up, you have no equity',
      'Bet \$15 — second barrel on blank turn',
      'Bet \$28 — larger second barrel',
      'Bet \$40 — pot-size blast',
    ],
    correctIndex: 1,
    explanation:
        'QJ missed completely but the 2♥ turn is a complete blank. You represent AK/AA/KK from a CO/BTN raiser. A second barrel (~35–40% pot) on a dry turn forces BB to fold medium pairs and weak aces that will call flop but give up the turn. BB cannot have many aces since you 3-bet preflop.',
    difficulty: 'Advanced',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_02',
    title: 'Give Up When Called on Wet Turn',
    situation:
        'Cash game \$1/\$2. You c-bet \$8 into \$17 on 8♦7♣6♠. BB calls. Turn: 5♥ (four-to-straight on board). Pot \$33.',
    holeCards: ['A♠', 'Q♦'],
    communityCards: ['8♦', '7♣', '6♠', '5♥'],
    options: [
      'Bet \$12 — continue the aggression',
      'Bet \$20 — big bet to represent the made straight',
      'Check — give up, board is too dangerous',
      'Bet pot — all or nothing',
    ],
    correctIndex: 2,
    explanation:
        'With AQ on 8765 connected board, you have two backdoor overcards and the board just improved to a four-straight. You have essentially no equity vs any BB hand that called the flop. Barreling here charges you chips to bluff into a board that the caller loves. Check and fold to any bet is correct.',
    difficulty: 'Intermediate',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_03',
    title: 'Barrel a Flush Draw Turn',
    situation:
        'Cash game \$1/\$2. You 3-bet BTN to \$18, BB calls. Flop K♠8♣3♦, you c-bet \$14, BB calls. Turn: J♠. Pot \$64.',
    holeCards: ['A♠', '5♠'],
    communityCards: ['K♠', '8♣', '3♦', 'J♠'],
    options: [
      'Check — you picked up a draw but have no pair',
      'Bet \$28 — semi-bluff barrel with nut flush draw',
      'Bet \$48 — large barrel with strong draw',
      'Bet \$64 — pot jam for max equity pressure',
    ],
    correctIndex: 1,
    explanation:
        'The J♠ turn gave you the nut flush draw (A♠5♠ on K♠8♣3♦J♠). You now have 9 outs to the nuts. A semi-bluff barrel of ~40–45% pot is correct: it generates folds from non-flush hands, and when called you have strong equity to win on the river. This is a classic semi-bluff double-barrel spot.',
    difficulty: 'Intermediate',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_04',
    title: 'Turn Barrel with a Pair',
    situation:
        'Cash game \$1/\$2. You opened CO, BTN calls. Flop Q♣7♦3♠, you c-bet \$8 into \$17, BTN calls. Turn: J♦. Pot \$33.',
    holeCards: ['Q♥', 'T♦'],
    communityCards: ['Q♣', '7♦', '3♠', 'J♦'],
    options: [
      'Check — protect top pair by pot controlling',
      'Bet \$12 — thin value bet on a changed board',
      'Bet \$20 — standard turn barrel with top pair',
      'Bet \$33 — pot-size to protect',
    ],
    correctIndex: 1,
    explanation:
        'QT on QJ7 rainbow: you have top pair but the Jack improves many BTN hands (KJ, JT, J9) to pairs or two-pair. This is a pot control situation — checking is reasonable, but a small thin value bet (\$12–15) can extract value from 7x, 3x, and worse queens while keeping the pot manageable. Pot-size is too much given the jack changes things.',
    difficulty: 'Intermediate',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_05',
    title: 'Give Up on a Paired Turn',
    situation:
        'Cash game \$1/\$2. You c-bet \$10 into \$20 on 9♠8♦5♣. BB calls. Turn: 8♥ (pairs the board). Pot \$40.',
    holeCards: ['K♦', 'Q♥'],
    communityCards: ['9♠', '8♦', '5♣', '8♥'],
    options: [
      'Bet \$14 — bluff the paired board',
      'Bet \$25 — large second barrel',
      'Check — give up with no equity on a paired board',
      'Check/call — probe for information',
    ],
    correctIndex: 2,
    explanation:
        'KQ with no pair on 9858 is a clear give-up. A paired board benefits the calling range (they could have any 8, or a boat). You have no equity, your bluffs are ineffective (BB can hero-call with 9x or any pair), and the paired 8 actually weakens the case for continuing. Check and fold to any bet.',
    difficulty: 'Beginner',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_06',
    title: 'Triple Barrel Setup',
    situation:
        'Cash game \$1/\$2. You 3-bet to \$18, BB calls. Flop A♥3♣2♦ — c-bet \$14, call. Turn T♠ — barrel \$28, call. River: 7♦. Pot \$120.',
    holeCards: ['K♠', 'J♦'],
    communityCards: ['A♥', '3♣', '2♦', 'T♠', '7♦'],
    options: [
      'Check — give up after two barrels',
      'Bet \$40 — small river bluff',
      'Bet \$80 — large river bluff to represent the nut',
      'Bet \$120 — pot jam — complete the story',
    ],
    correctIndex: 2,
    explanation:
        'After two barrels on A32-T-7, you need to decide whether to complete the triple barrel. The river 7 is a blank. You have represented AK or AA through two streets. A river barrel of \$80 (2/3 pot) is preferred — it represents the nuts and puts maximum pressure while not losing too much if called. Pot-jamming is a bit much vs a BB who called two barrels.',
    difficulty: 'Expert',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_07',
    title: 'Turn Card Changes Everything',
    situation:
        'Cash game \$1/\$2. You c-bet \$10 into \$20 on T♠9♣4♥. BTN calls. Turn: Q♠. BB checks.',
    holeCards: ['J♥', 'J♦'],
    communityCards: ['T♠', '9♣', '4♥', 'Q♠'],
    options: [
      'Check — QJ completes straight for BTN',
      'Bet \$12 — probe bet, keeping pot small',
      'Bet \$22 — half pot, protect JJ',
      'Bet \$36 — large bet for maximum fold equity',
    ],
    correctIndex: 1,
    explanation:
        'JJ vs BTN on T94 and the Q falls. You are now in a marginal spot: the Q helps some BTN hands (KJ, KQ, QJ) but your JJ still has value. A small probe (~30% pot) maintains some value extraction while controlling pot size. A check is also viable for pot control. Betting large is dangerous since BTN might have KJ for a straight.',
    difficulty: 'Intermediate',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_08',
    title: 'Barrel with Backdoor Equity',
    situation:
        'Cash game \$1/\$2. You c-bet \$8 into \$17 on 9♦8♠2♥. BTN calls. Turn: K♣. Pot \$33.',
    holeCards: ['A♦', 'K♦'],
    communityCards: ['9♦', '8♠', '2♥', 'K♣'],
    options: [
      'Check — you picked up a pair but it is a scary card',
      'Bet \$12 — value bet top pair',
      'Bet \$20 — strong value bet',
      'Bet \$33 — pot-size protection',
    ],
    correctIndex: 2,
    explanation:
        'AK on 982K — you hit top pair top kicker on the turn. Now you want to value bet for protection and extraction. The K is a good card for your range (you raised preflop with AK, KQ, KJ), and the board is still two-tone. A half-to-two-thirds pot bet (\$18–22) gets value from 9x, 8x, and sets while protecting your hand.',
    difficulty: 'Intermediate',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_09',
    title: 'Turn Bet Sizing vs Draws',
    situation:
        'Cash game \$1/\$2. You raised preflop, BB called. Flop Q♣J♥4♠, c-bet \$10 into \$20, call. Turn: T♣ (flush draw arrives). Pot \$40.',
    holeCards: ['Q♥', 'Q♦'],
    communityCards: ['Q♣', 'J♥', '4♠', 'T♣'],
    options: [
      'Check — protect your hand by pot controlling',
      'Bet \$15 — half pot, comfortable bet',
      'Bet \$28 — 70% pot for protection',
      'Bet \$40 — pot-size to fold out all draws',
    ],
    correctIndex: 2,
    explanation:
        'QQ on QJ4T with a flush draw is a spot where you want to size up. You have top set but the board is now QJT with a flush draw — opponent could have a straight (K9, A9, 89), a flush draw, or both. Betting 65–75% pot (\$26–28) charges draws the maximum while still getting value from Jx and Tx. This prevents the board from running out badly.',
    difficulty: 'Advanced',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_10',
    title: 'Turn Float and Bet',
    situation:
        'Cash game \$1/\$2. You called BTN c-bet of \$8 on J♠7♦2♣. You are OOP. Turn: 3♥. You check, BTN checks back.',
    holeCards: ['8♠', '8♦'],
    communityCards: ['J♠', '7♦', '2♣', '3♥'],
    options: [
      'Check river — play passively with a mid pair',
      'Bet river when it comes — take initiative',
      'Bet now on turn — BTN checked back, showing weakness',
      'Fold river — your hand is likely behind',
    ],
    correctIndex: 2,
    explanation:
        'BTN c-bet the flop and checked back the turn — a sign of weakness or pot control with a medium hand. With 88 in this spot, the turn check-back is your opportunity to lead. Wait — re-read: you are on the turn and BTN just checked. This means you should lead the river when it comes, as 88 is likely good vs a BTN who checked twice. Lead river for thin value.',
    difficulty: 'Intermediate',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_11',
    title: 'Give Up After Flop Raise Call',
    situation:
        'Cash game \$1/\$2. You c-bet \$10, opponent raised to \$28, you called. Turn: 4♦ (blank). Pot \$77.',
    holeCards: ['A♠', 'Q♦'],
    communityCards: ['K♣', '8♥', '3♦', '4♦'],
    options: [
      'Lead \$30 — take the lead on a blank turn',
      'Check-fold — you should have given up on flop',
      'Check-call — opponent likely has draws',
      'Check-raise jam — put maximum pressure',
    ],
    correctIndex: 1,
    explanation:
        'AQ on K83 vs a flop raise is already a marginal call. The 4♦ is a complete blank. Check-folding is correct: you called the flop raise hoping to catch the ace or queen, and neither came. Your opponent who raised the flop is not bluffing often enough to justify calling again with two overcards. Cut your losses.',
    difficulty: 'Advanced',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_12',
    title: 'Turn Value Sizing',
    situation:
        'Cash game \$1/\$2. You raised preflop, BB called. Flop A♠K♦3♥, bet \$10, called. Turn: A♥. BB checks.',
    holeCards: ['A♦', 'K♠'],
    communityCards: ['A♠', 'K♦', '3♥', 'A♥'],
    options: [
      'Check — slow-play the full house',
      'Bet \$8 — small to induce',
      'Bet \$20 — extract value',
      'Bet \$35 — large bet to build the pot for the river',
    ],
    correctIndex: 1,
    explanation:
        'You have AK on AKKA board — the nuts (full house). Slow-playing is ideal here. If you bet large, BB folds all the weaker hands. A tiny value bet (\$8) or check induces BB to bluff or call with a king, ace, or any two pair. The check is also great because the river might give BB a hand. Small bet or check.',
    difficulty: 'Intermediate',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_13',
    title: 'Turn Decision in 3-Way Pot',
    situation:
        'Cash game \$1/\$2. You raised UTG, two callers. Flop Q♦T♠4♣, you c-bet \$12 into \$25, BTN calls, CO folds. Turn: J♦. Pot \$49.',
    holeCards: ['Q♠', 'Q♣'],
    communityCards: ['Q♦', 'T♠', '4♣', 'J♦'],
    options: [
      'Check — QJT board with flush draw is scary',
      'Bet \$20 — probe bet top set',
      'Bet \$35 — strong value bet',
      'Bet \$49 — pot jam, protect top set',
    ],
    correctIndex: 2,
    explanation:
        'QQQ on QJT with a flush draw arriving — you have top set but the board is now QJT with a flush draw. This is a protection/value spot that requires a strong size (65–80% pot). Opponent could have AK (straight), KQ (open-ended), or a flush draw. \$35 is about right — gets value from pairs/two-pair while charging draws heavily.',
    difficulty: 'Advanced',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_14',
    title: 'Turn Blocker Bet',
    situation:
        'Cash game \$1/\$2. You called BTN on the flop. Turn brick. BTN checked. You are OOP with a medium-strength hand.',
    holeCards: ['K♦', 'J♠'],
    communityCards: ['K♥', '8♣', '3♦', '2♠'],
    options: [
      'Check — keep pot small with KJ top pair',
      'Lead \$10 — blocker bet to control sizing',
      'Lead \$20 — standard value lead',
      'Check-raise if BTN bets — trap',
    ],
    correctIndex: 1,
    explanation:
        'KJ top pair on K832 with BTN showing weakness (checked back turn) is a spot for a blocker/value lead. Leading small (\$10–12) prevents BTN from checking behind again and getting a free river, while also controlling the bet size you face. This is classic "blocking bet" territory with a medium-strength one pair hand.',
    difficulty: 'Intermediate',
    category: 'Turn Barrel or Give Up',
  ),

  DailyPuzzle(
    id: 'tbl_15',
    title: 'Turn Probe Bluff',
    situation:
        'Cash game \$1/\$2. You called BTN open from HJ. Flop: 6♠5♦2♠. BTN c-bets \$8, you call. Turn: K♥. BTN checks.',
    holeCards: ['A♥', 'Q♣'],
    communityCards: ['6♠', '5♦', '2♠', 'K♥'],
    options: [
      'Check — no pair, no draw, just check',
      'Bet \$14 — probe bluff, BTN showed weakness',
      'Bet \$22 — large probe representing the K',
      'Bet \$35 — pot-size probe',
    ],
    correctIndex: 1,
    explanation:
        'BTN c-bet a low board and you called. The K on the turn is often good for the HJ caller\'s range (KQ, KJ, KT) but when BTN checks the turn, they have given up on the hand or have a medium pair that doesn\'t want to barrel. A probe lead (\$14 ~40%) representing KQ etc. is a good turn bluff that should work at decent frequency.',
    difficulty: 'Advanced',
    category: 'Turn Barrel or Give Up',
  ),

  // ─── River Value vs Bluff (15) ────────────────────────────────────────────

  DailyPuzzle(
    id: 'rvb_01',
    title: 'Thin River Value',
    situation:
        'Cash game \$1/\$2. Three streets on A♠K♦8♣-2♥-5♦. Pot \$80. You have been betting and opponent called each time. River checks to you.',
    holeCards: ['A♦', 'J♠'],
    communityCards: ['A♠', 'K♦', '8♣', '2♥', '5♦'],
    options: [
      'Check behind — top pair is not a big hand',
      'Bet \$20 — thin value bet',
      'Bet \$45 — larger value bet',
      'Bet \$80 — pot jam for maximum value',
    ],
    correctIndex: 1,
    explanation:
        'AJ on AK825 — you have top pair with the second kicker. The board is dry and your opponent called three streets. Their range contains KQ, KJ, and various draws that missed. A thin value bet (~25% pot) extracts from Kx and weaker aces. Going large risks a check-raise bluff or call-down by two pair+ holdings.',
    difficulty: 'Intermediate',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_02',
    title: 'River Bluff on Missed Draw',
    situation:
        'Cash game \$1/\$2. You called a CO raise from BTN. Board ran out 9♣8♣3♦-K♥-2♠. Pot \$60. CO checks river.',
    holeCards: ['7♣', '6♣'],
    communityCards: ['9♣', '8♣', '3♦', 'K♥', '2♠'],
    options: [
      'Check — you missed your flush draw, just check',
      'Bluff \$20 — small river bluff',
      'Bluff \$40 — near-pot bluff to represent the K',
      'Bluff \$60 — pot-size for maximum fold equity',
    ],
    correctIndex: 2,
    explanation:
        '76cc missed the flush. CO checked the river after calling two streets. A 2/3 pot bluff (~\$40) can get folds from medium pairs (88, 99) that can\'t call three streets. You should represent the K (a card that hits your BTN range). Checking has zero EV with a busted draw. Small bluffs get called by too many hands.',
    difficulty: 'Advanced',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_03',
    title: 'Value Bet the River Nuts',
    situation:
        'Cash game \$1/\$2. Board: Q♠J♠T♦-A♦-2♣. You held KQ and made the broadway straight. Pot \$55. Opponent checks.',
    holeCards: ['K♦', 'Q♥'],
    communityCards: ['Q♠', 'J♠', 'T♦', 'A♦', '2♣'],
    options: [
      'Check — slowplay the nuts',
      'Bet \$20 — medium value bet',
      'Bet \$40 — near-pot value bet',
      'Bet \$55 — pot-size value bet',
    ],
    correctIndex: 3,
    explanation:
        'AKQJT — you have the broadway straight (the nuts on this board). You must bet pot here. The board has a flush draw that missed (A♦ helped draw buyers), so opponent may call with flushes that missed, two pair, or sets. You cannot be beaten on this board. Pot-size value bet maximises EV with the absolute nuts.',
    difficulty: 'Beginner',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_04',
    title: 'Overbet River Bluff',
    situation:
        'Cash game \$1/\$2. Board: K♠Q♦4♣-9♥-3♣. You barreled twice, opponent called. Pot \$120. You check, opponent checks.',
    holeCards: ['J♠', 'T♠'],
    communityCards: ['K♠', 'Q♦', '4♣', '9♥', '3♣'],
    options: [
      'Check behind — you bluffed twice, cut your losses',
      'Bet \$40 — small river bluff',
      'Bet \$80 — standard river bluff',
      'Bet \$150 — overbet river bluff to represent a set',
    ],
    correctIndex: 0,
    explanation:
        'JT on KQ49 3 — you have an open-ended draw that missed. You checked the river meaning there was no river bet triggered; the prompt says "you check, opponent checks" — this is a check-behind spot. You have already put in two barrels and missed. If opponent checked the river, they are pot-controlling (sets, two pair). Bluffing into checked-down hands risks losing more unnecessarily.',
    difficulty: 'Expert',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_05',
    title: 'River Blocking Bet',
    situation:
        'Cash game \$1/\$2. You are OOP. Board: J♦T♠8♣-5♦-2♥. You called two streets. River: opponent action is on you.',
    holeCards: ['J♠', '9♥'],
    communityCards: ['J♦', 'T♠', '8♣', '5♦', '2♥'],
    options: [
      'Check — pot control with top pair no kicker',
      'Lead \$12 — blocker bet',
      'Lead \$30 — strong lead for value',
      'Lead \$55 — pot-size lead',
    ],
    correctIndex: 1,
    explanation:
        'J9 top pair on JT852 rainbow — you have top pair no kicker. If you check, the IP player may bet large with hands you beat or bluff large. A blocker lead (\$12, ~20% pot) converts the hand to a "showdown hand" efficiently: opponent folds bluffs and calls with worse. Checking then calling is OK but loses more when opponent bets big with a better hand.',
    difficulty: 'Intermediate',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_06',
    title: 'River Overbet for Value',
    situation:
        'Cash game \$1/\$2. Board: A♠A♦K♣-Q♥-J♣. You 3-bet preflop. Pot \$90. Opponent checks. You have AA.',
    holeCards: ['A♣', 'A♥'],
    communityCards: ['A♠', 'A♦', 'K♣', 'Q♥', 'J♣'],
    options: [
      'Check — let opponent bet',
      'Bet \$30 — small value bet',
      'Bet \$80 — large value bet',
      'Bet \$150 — overbet with quad aces',
    ],
    correctIndex: 3,
    explanation:
        'Quad aces on AAKQJ — you have the absolute nuts. Overbet for maximum value. Opponent can have KK, QQ, JJ, KQ, KJ, QJ for full houses that cannot fold. The pot is \$90 and you should be betting 1.5–2x pot (\$130–180). Opponent with a full house will always call an overbet. Never go small or check with quads when you can extract maximum value.',
    difficulty: 'Beginner',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_07',
    title: 'River Decision: Value or Bluff?',
    situation:
        'Cash game \$1/\$2. Pot \$75. Board: 8♦7♣6♠-A♣-K♠. You checked the turn, opponent checked. River is K♠. Opponent checks.',
    holeCards: ['5♠', '4♠'],
    communityCards: ['8♦', '7♣', '6♠', 'A♣', 'K♠'],
    options: [
      'Check — you have a straight, slow-play',
      'Bet \$25 — small value bet for the straight',
      'Bet \$50 — standard river value bet',
      'Bet \$75 — pot-size value with the nuts',
    ],
    correctIndex: 3,
    explanation:
        '54 on 87654 — you flopped a straight! Missed the board? No: 87654 contains a 5-high straight (45678). Actually 8♦7♣6♠ with 5♠4♠ means you flopped the straight. On the river K♠ board, your straight is the nuts (no flush possible). Pot-size bet with the nuts on a 5-high straight river for maximum extraction from any two-pair or set.',
    difficulty: 'Intermediate',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_08',
    title: 'Under-Betting for Value',
    situation:
        'Cash game \$1/\$2. Board: T♠9♣2♦-7♥-3♦. You have a set and checked the flop. Bet turn, called. Pot \$70.',
    holeCards: ['T♦', 'T♥'],
    communityCards: ['T♠', '9♣', '2♦', '7♥', '3♦'],
    options: [
      'Check — induce a bluff',
      'Bet \$18 — small underbet for value',
      'Bet \$40 — standard river value',
      'Bet \$70 — pot jam with the set',
    ],
    correctIndex: 1,
    explanation:
        'TT on T9273 rainbow with a set of tens is a strong hand. The board ran out without completing straight draws. An underbet (\$18–20, ~25% pot) achieves two things: (1) keeps worse hands in (99, 22, 77 for boats but you beat them; 87, 89 for missed draws; Tx) and (2) looks like a blocker bet, inviting raises. Pot-size often folds the weaker value hands you want to call.',
    difficulty: 'Advanced',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_09',
    title: 'River Bluff With Equity Story',
    situation:
        'Cash game \$1/\$2. Board: A♦K♠Q♣-J♦-T♠. You played passively all streets. Pot \$60. Opponent checks.',
    holeCards: ['9♣', '8♦'],
    communityCards: ['A♦', 'K♠', 'Q♣', 'J♦', 'T♠'],
    options: [
      'Check — you have the board straight, no action needed',
      'Bet \$20 — value bet',
      'Bet \$40 — large value bet',
      'Bet \$60 — pot-size with broadway straight',
    ],
    correctIndex: 3,
    explanation:
        '98 on AKQJT — the board has made a broadway straight (AKQJT). This means EVERY hand has the same straight. You need to chop (or win with best kicker on side card — but there are no side cards). Bet pot here as everyone chops and any bet will just be called or raised and still chop. Actually in this spot, check is also rational since no hand beats the board straight. Knowing when to check is part of advanced play.',
    difficulty: 'Expert',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_10',
    title: 'River Sizing on Flush Completing Card',
    situation:
        'Cash game \$1/\$2. You raised preflop, BB called. Board: K♥J♣4♦-9♦-Q♦. Pot \$60. BB checks.',
    holeCards: ['A♦', 'T♦'],
    communityCards: ['K♥', 'J♣', '4♦', '9♦', 'Q♦'],
    options: [
      'Check — you have the nuts, slow-play',
      'Bet \$20 — small bet',
      'Bet \$45 — large value bet',
      'Bet \$80 — overbet with nut flush',
    ],
    correctIndex: 3,
    explanation:
        'AT suited on KJ4-9-Q of diamonds — you flopped the nut flush draw and hit it. You also have the broadway nut straight draw. You now have the nut flush on a board with a flush draw completing on the river. Overbet for value (\$80, 1.3x pot): anyone with KQ, QJ, a smaller flush, or a straight will call. You have the absolute nuts and should extract maximum.',
    difficulty: 'Intermediate',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_11',
    title: 'River Call or Fold?',
    situation:
        'Cash game \$1/\$2. Board: A♠Q♦8♣-T♥-5♦. You checked river. Opponent bets \$50 into \$70 pot. You have AK.',
    holeCards: ['A♣', 'K♦'],
    communityCards: ['A♠', 'Q♦', '8♣', 'T♥', '5♦'],
    options: [
      'Fold — too many two-pair and straight combinations beat you',
      'Call — top pair top kicker is strong enough',
      'Raise — you likely have the best hand, put pressure on',
      'Raise jam — go for value',
    ],
    correctIndex: 1,
    explanation:
        'AK on AQ8T5 vs a 70% pot bet on the river. You have top pair top kicker. The board is A-high with a middle straight completing. Opponent\'s range includes bluffs (missed draws), value (two pair: AQ, AT, QT; straights; sets). AK is a call here: you beat all bluffs and some thin value bets. The pot odds (1.7:1) require 37% equity — AK has more than that.',
    difficulty: 'Advanced',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_12',
    title: 'River Merge Bet',
    situation:
        'Cash game \$1/\$2. Board: Q♣J♦T♠-3♥-3♣. You have been the aggressor. Pot \$80. Opponent checks river.',
    holeCards: ['K♠', 'Q♦'],
    communityCards: ['Q♣', 'J♦', 'T♠', '3♥', '3♣'],
    options: [
      'Check — QK is marginal, pot control',
      'Bet \$25 — thin value, top pair good kicker',
      'Bet \$50 — standard river value',
      'Bet \$80 — pot-size',
    ],
    correctIndex: 1,
    explanation:
        'KQ on QJT33 — you have top pair good kicker. The board has a lot of straight completes (AK, KQ, K9 for straights on QJT). Your hand could be behind many straights and two-pair. A thin value bet (~30% pot) extracts from Jx, Tx, and busted flush draws while keeping the bet size you can call off if raised is manageable.',
    difficulty: 'Intermediate',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_13',
    title: 'River Bluff-Raise',
    situation:
        'Cash game \$1/\$2. You called preflop and called two streets. River: 7♠ (board is K♦Q♠J♣-A♦-7♠). You check. Opponent bets \$40 into \$70.',
    holeCards: ['T♠', '9♠'],
    communityCards: ['K♦', 'Q♠', 'J♣', 'A♦', '7♠'],
    options: [
      'Fold — you have missed your draws',
      'Call — you might have some showdown value',
      'Raise to \$120 — you rivered a spade flush! Raise for value',
      'Raise jam — maximum value with the flush',
    ],
    correctIndex: 2,
    explanation:
        'T9 spades on KQJA7 with three spades on board: K♦Q♠J♣A♦7♠. The Q♠J♣7♠ gives you a flush draw, but wait — you have T♠9♠ and there are only 3 spades on board: Q♠, J♣(not spades), 7♠. Two spades Q♠ and 7♠. You have three spades total? No — T♠9♠ + Q♠ + 7♠ = four spades, completing the flush. Raise to \$120 for value with a made flush.',
    difficulty: 'Advanced',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_14',
    title: 'River Spot Check',
    situation:
        'Cash game \$1/\$2. You bet flop, checked turn. River: A♦ (board: T♠8♣4♦-Q♥-A♦). Pot \$45. Opponent checks.',
    holeCards: ['T♣', '9♦'],
    communityCards: ['T♠', '8♣', '4♦', 'Q♥', 'A♦'],
    options: [
      'Check — your middle pair weakened with an A on river',
      'Bet \$12 — thin value still possible',
      'Bet \$22 — half pot probe',
      'Bluff \$45 — you represent an Ace perfectly',
    ],
    correctIndex: 3,
    explanation:
        'T9 on T84QA — you have middle pair that is marginal. The Ace on the river is a great bluff card: you raised preflop so your range has AK, AQ, AT, etc. Opponent checked twice including the river. A near-pot bluff here represents the Ace convincingly. Your range representation is very strong for the A here, making this a high-EV bluff.',
    difficulty: 'Expert',
    category: 'River Value vs Bluff',
  ),

  DailyPuzzle(
    id: 'rvb_15',
    title: 'River Sizing with Second Nut Flush',
    situation:
        'Cash game \$1/\$2. Board: J♥8♥5♣-2♥-K♥ (four hearts). Pot \$55. You are IP. Opponent leads for \$20.',
    holeCards: ['Q♥', '9♦'],
    communityCards: ['J♥', '8♥', '5♣', '2♥', 'K♥'],
    options: [
      'Fold — opponent leads into a four-flush board, they likely have A♥',
      'Call — second nut flush is strong enough to call',
      'Raise to \$65 — value raise with second nut flush',
      'Raise jam — go for maximum value with strong flush',
    ],
    correctIndex: 1,
    explanation:
        'Q♥ on J♥8♥5♣2♥K♥ — you have the queen-high flush (second nuts). Opponent leads for \$20 into \$55. This is a call: you have the second nuts but when opponent leads into a four-flush board, their range is heavy on the A♥ or other strong hearts. Raising gets called only by better flushes. Call and accept the result.',
    difficulty: 'Advanced',
    category: 'River Value vs Bluff',
  ),

  // ─── Bluff Catch on River (10) ────────────────────────────────────────────

  DailyPuzzle(
    id: 'blc_01',
    title: 'Hero Call on Missed Draw Board',
    situation:
        'Cash game \$1/\$2. Board: K♠Q♦J♣-T♥-2♠. All draws missed. Pot \$80. Opponent fires \$55.',
    holeCards: ['K♦', '8♦'],
    communityCards: ['K♠', 'Q♦', 'J♣', 'T♥', '2♠'],
    options: [
      'Fold — opponent\'s bet sizing screams value',
      'Call — all draws missed, bluff-catch with top pair',
      'Raise — test if they are bluffing',
      'Fold — KJ, KQ, or straights beat you here',
    ],
    correctIndex: 1,
    explanation:
        'K8 top pair on KQJT2 vs a 70% pot river bet. The board completed a broadway straight (AKQJT) for any Ace. Draws on the flop were 9x (straight), flush (no flush draw available here). Opponent\'s range includes busted flush-type hands... wait, there is no flush draw. They could have A9 for the straight or be pure bluffing. K8 is a bluff-catch here — medium call.',
    difficulty: 'Advanced',
    category: 'Bluff Catch on River',
  ),

  DailyPuzzle(
    id: 'blc_02',
    title: 'Blocking the Nuts',
    situation:
        'Cash game \$1/\$2. Board: A♠K♦Q♣-J♥-T♦. Opponent bets pot (\$100). You hold AK.',
    holeCards: ['A♦', 'K♠'],
    communityCards: ['A♠', 'K♦', 'Q♣', 'J♥', 'T♦'],
    options: [
      'Fold — AKQJT board, any player with a single J or 9 has a straight that ties',
      'Call — AKQJT is the board straight — everyone ties',
      'Raise — you have two pair but the board beats you',
      'Fold — AK pot bet always means they have the straight',
    ],
    correctIndex: 1,
    explanation:
        'AKQJT is the board — the whole board is the broadway straight. Every player in the hand plays the board! AK is irrelevant here. The pot splits. Since you know you chop, calling is technically OK (you do not lose), though betting back or folding accomplishes nothing. In live poker you just call to "win" your share back.',
    difficulty: 'Beginner',
    category: 'Bluff Catch on River',
  ),

  DailyPuzzle(
    id: 'blc_03',
    title: 'Catch a Missed Flush Draw',
    situation:
        'Cash game \$1/\$2. Board: A♥9♠4♣-T♠-2♦ (no flush possible). You have top pair. Pot \$70. Villain fires \$60.',
    holeCards: ['A♠', '5♣'],
    communityCards: ['A♥', '9♠', '4♣', 'T♠', '2♦'],
    options: [
      'Fold — A5 top pair weak kicker',
      'Call — bluff-catch with top pair',
      'Raise to \$150 — test villain\'s resolve',
      'Fold — two pair or sets are too common here',
    ],
    correctIndex: 1,
    explanation:
        'A5 on A94T2 rainbow — you have top pair, weak kicker. Villain fires a large bet (\$85% pot). The board is dry: no flush, no obvious straight. What does villain bet here for value? Two pair (AT, A9, T9) or sets. But villain\'s bluffing range includes missed hands on draw-heavy flops. Call here — the pot odds (1.85:1) require ~35% equity and you have more than that vs a balanced villain range.',
    difficulty: 'Intermediate',
    category: 'Bluff Catch on River',
  ),

  DailyPuzzle(
    id: 'blc_04',
    title: 'River Spot with Pot Odds',
    situation:
        'Cash game \$1/\$2. Board: Q♦J♠9♥-6♣-2♠. Pot \$100. Villain jams \$80 into the pot.',
    holeCards: ['J♦', 'T♦'],
    communityCards: ['Q♦', 'J♠', '9♥', '6♣', '2♠'],
    options: [
      'Fold — JT is a middle pair with a lot of hands ahead',
      'Call — JT with a straight draw missed, but pot odds',
      'Call — you have second pair and pot odds (2.25:1)',
      'Raise — put villain all in to find out where you are',
    ],
    correctIndex: 2,
    explanation:
        'JT on QJ962 vs an \$80 into \$100 shove. You need to call \$80 to win \$180 = 2.25:1 = need 31% equity. You have second pair (Js) and your T is a blocker to some straights. Villain\'s range: value (QQ, JJ, 99, QJ, Q9) and bluffs (KT, T8, flush missed). With 31% equity needed and second pair on a board with limited draw-completing, this is a tight call/fold but lean call.',
    difficulty: 'Advanced',
    category: 'Bluff Catch on River',
  ),

  DailyPuzzle(
    id: 'blc_05',
    title: 'Catch or Release?',
    situation:
        'Cash game \$1/\$2. You 3-bet, opponent called. Board: K♦7♣2♠-8♥-5♣. You c-bet twice, checked river. Villain bets \$60 into \$90.',
    holeCards: ['A♠', 'Q♦'],
    communityCards: ['K♦', '7♣', '2♠', '8♥', '5♣'],
    options: [
      'Fold — AQ on K7285 with two missed barreling spots, villain is rarely bluffing',
      'Call — AQ unblocks bluffs',
      'Raise — villain is clearly bluffing',
      'Call — two overcards always have value',
    ],
    correctIndex: 0,
    explanation:
        'AQ missed completely on K7285. You c-bet twice showing strength, then checked river (giving up). Villain checked two streets and now fires river into a hand that showed down strength. This screams value: villain has a K, two pair, or the 8-high straight (67 of some suit through the board). AQ has no showdown value and should fold to this river bet.',
    difficulty: 'Advanced',
    category: 'Bluff Catch on River',
  ),

  DailyPuzzle(
    id: 'blc_06',
    title: 'Large River Bet Catch',
    situation:
        'MTT. Board: 9♠8♦7♣-A♥-4♠. Villain fires 3x pot river bet (overbet). You have top set from the flop.',
    holeCards: ['9♦', '9♥'],
    communityCards: ['9♠', '8♦', '7♣', 'A♥', '4♠'],
    options: [
      'Fold — set is beaten by straights and overbets signal strength',
      'Call — pot odds dictate a call even vs a tight range',
      'Raise — can never fold a set here',
      'Call — you beat bluffs and some thin value; let them hang themselves',
    ],
    correctIndex: 3,
    explanation:
        'Set of 9s on 9874A — villain fires a 3x overbet. An overbet on a connected board can be polarised: either the straight (65, T6, JT on this board) or a bluff. Your set beats all bluffs and loses only to straights. Pot odds (need ~25% equity) and the frequency of bluffs in a polarized overbet range means calling is superior to raising (you do not want to fold out bluffs by raising).',
    difficulty: 'Expert',
    category: 'Bluff Catch on River',
  ),

  DailyPuzzle(
    id: 'blc_07',
    title: 'River Decision with a Weak Hand',
    situation:
        'Cash game \$1/\$2. Board: A♣K♦T♣-9♠-6♦. You called three streets. Pot \$120. Villain checks river.',
    holeCards: ['T♠', '8♠'],
    communityCards: ['A♣', 'K♦', 'T♣', '9♠', '6♦'],
    options: [
      'Check behind — middle pair is a showdown hand',
      'Lead small — thin value bet',
      'Lead medium — \$40 to extract value',
      'Lead \$60 — strong lead for value/information',
    ],
    correctIndex: 0,
    explanation:
        'T8 middle pair on AKT96 after calling three streets. Villain checks the river. You should check behind: T8 is purely a showdown hand here. Leading with middle pair risks getting raised off a hand that is often best vs a passive villain who just showed weakness. The river check behind gets to showdown cheaply and wins against AK missed, flush draws, etc.',
    difficulty: 'Intermediate',
    category: 'Bluff Catch on River',
  ),

  DailyPuzzle(
    id: 'blc_08',
    title: 'Underpair River Catch',
    situation:
        'Cash game \$1/\$2. Board: K♠9♦4♣-2♥-7♣. You called preflop and called flop c-bet. Turn and river checked. Villain fires \$25 into \$50 on the river.',
    holeCards: ['5♣', '5♦'],
    communityCards: ['K♠', '9♦', '4♣', '2♥', '7♣'],
    options: [
      'Fold — 55 is just an underpair with a scary board',
      'Call — low pair in a well-priced spot',
      'Raise — villain is almost certainly bluffing',
      'Fold — never call with 55 when K is on board',
    ],
    correctIndex: 1,
    explanation:
        '55 on K9427 — you have a pair of 5s. Villain c-bet flop, checked turn and river, then fires river. This line (c-bet, check, check, bet) is often a blocker/bluff. 55 beats all bluffs and some thin value. Pot odds (3:1) require 25% equity; 55 has more than that vs a polarised range. Call and see it come down.',
    difficulty: 'Intermediate',
    category: 'Bluff Catch on River',
  ),

  DailyPuzzle(
    id: 'blc_09',
    title: 'Polarised Opponent Range',
    situation:
        'Cash game \$1/\$2. Board: Q♠J♦5♥-A♣-8♠. All spade draws completed. Villain bet pot (\$100) on river.',
    holeCards: ['Q♥', 'Q♦'],
    communityCards: ['Q♠', 'J♦', '5♥', 'A♣', '8♠'],
    options: [
      'Fold — top set loses to straights and flushes',
      'Call — set of queens is too strong to fold',
      'Raise — never fold top set at river',
      'Fold — the spade flush completes and pot size bet is pure value',
    ],
    correctIndex: 1,
    explanation:
        'QQ (set) on QJ5A8 — you have top set. Villain bets pot. Their range: spade flush (various combos), KT for straight, two pair, and bluffs. You beat two-pair and all bluffs. You lose to flushes and straights. With pot odds (2:1 = need 33%) and the frequency of bluffs+thin value in pot-bet range, calling is optimal. Raising is also reasonable but call is cleaner.',
    difficulty: 'Advanced',
    category: 'Bluff Catch on River',
  ),

  DailyPuzzle(
    id: 'blc_10',
    title: 'Blocking Bet River Call',
    situation:
        'Cash game \$1/\$2. You are IP. Board: J♠T♦4♣-K♠-2♥. OOP villain leads for \$15 into \$55.',
    holeCards: ['J♦', 'J♣'],
    communityCards: ['J♠', 'T♦', '4♣', 'K♠', '2♥'],
    options: [
      'Call — middle set, villain is blocking with a medium hand',
      'Raise to \$45 — extract value with set of jacks',
      'Raise to \$60 — go big with set',
      'Fold — JT42K board has many two pairs and straights over sets',
    ],
    correctIndex: 1,
    explanation:
        'JJ on JT4K2 — you have middle set. Villain leads small (\$15) into \$55. This screams a blocking bet with a medium-strength hand (KT, KJ, TT). Raising to \$40–50 extracts value and allows villain to continue with their blocking hand. You should raise here — middle set is very strong vs a blocking bet range.',
    difficulty: 'Advanced',
    category: 'Bluff Catch on River',
  ),

  // ─── Set Mining Odds (5) ─────────────────────────────────────────────────

  DailyPuzzle(
    id: 'set_01',
    title: 'Set Mining in Position',
    situation:
        'Cash game 6-max \$1/\$2. CO opens to \$6. You are on the BTN with 44. Effective stacks: \$300.',
    holeCards: ['4♦', '4♣'],
    communityCards: [],
    options: [
      'Fold — 44 is too weak to call',
      'Call — you meet the 10:1 implied odds rule with \$300 stacks',
      'Raise — attack CO\'s range with 44',
      'Fold — 44 should only be played in late position raises',
    ],
    correctIndex: 1,
    explanation:
        '44 set mining: rule of thumb is you need ~10:1 implied odds (call \$6, stack \$300 means 50:1 implied!). You will hit your set ~11.8% of flops. At 50:1 implied you are far exceeding the minimum. Calling is clear. You will stack off with sets enough of the time to make this highly profitable.',
    difficulty: 'Beginner',
    category: 'Set Mining Odds',
  ),

  DailyPuzzle(
    id: 'set_02',
    title: 'Set Mining vs a 3-Bet',
    situation:
        'Cash game \$1/\$2. You opened UTG to \$6, opponent 3-bets to \$20. You have 33. Effective stacks \$150.',
    holeCards: ['3♠', '3♥'],
    communityCards: [],
    options: [
      'Call — implied odds work here',
      'Fold — 33 vs a 3-bet is not profitable set mining',
      '4-bet — take the initiative',
      'Call — 33 always has set mining odds',
    ],
    correctIndex: 1,
    explanation:
        '33 vs a 3-bet with 150 stacks: you need to call \$14 more (you already put in \$6) — total \$20. Implied odds needed: \$20 × 10 = \$200. But effective stacks are only \$150. You do NOT have the implied odds. Fold 33 here — you cannot extract enough when you hit your set to justify the call vs a 3-bet range.',
    difficulty: 'Intermediate',
    category: 'Set Mining Odds',
  ),

  DailyPuzzle(
    id: 'set_03',
    title: 'Deep Stack Set Mining',
    situation:
        'Cash game \$1/\$2 deep. UTG opens to \$7. You are on the CO with 77. Both stacks are \$600.',
    holeCards: ['7♦', '7♣'],
    communityCards: [],
    options: [
      'Fold — 77 is too risky vs UTG',
      'Call — implied odds are excellent at 600BB effective',
      '3-bet — 77 can profitably 3-bet here',
      'Call or 3-bet — both are fine plays',
    ],
    correctIndex: 3,
    explanation:
        '77 at 300BB effective (\$600): you need ~10:1 implied (\$70 to justify \$7 call — you have ~85:1!). Both calling and 3-betting are excellent options. 3-betting is also good because 77 can fold out weaker pairs and take down the blinds. At deep stacks, 77 is strong enough to be played as either a set-mine or a value 3-bet.',
    difficulty: 'Intermediate',
    category: 'Set Mining Odds',
  ),

  DailyPuzzle(
    id: 'set_04',
    title: 'Set Mining Short Stack',
    situation:
        'MTT. Blinds 100/200. UTG raises 500. You are on the BTN with 55. You have 2,500 chips.',
    holeCards: ['5♣', '5♠'],
    communityCards: [],
    options: [
      'Fold — not enough stack depth for set mining',
      'Call — 55 always plays',
      '3-bet jam — 55 is better as a shove here',
      'Fold — only call with 55 in cash games',
    ],
    correctIndex: 2,
    explanation:
        'With 2,500 chips (12.5BB) and 55, set mining is not viable — you need 10:1 implied and you only have 5:1. However, 55 has strong enough raw equity to 3-bet shove here as a semi-bluff: you have ~45–50% equity vs overcards and fold equity against UTG\'s tighter range. Jamming is correct at this stack size.',
    difficulty: 'Advanced',
    category: 'Set Mining Odds',
  ),

  DailyPuzzle(
    id: 'set_05',
    title: 'Multiway Set Mining',
    situation:
        'Cash game \$1/\$2. UTG raises to \$6, MP calls. You are on the BTN with 22. Effective stacks \$200.',
    holeCards: ['2♥', '2♦'],
    communityCards: [],
    options: [
      'Fold — 22 is too weak multiway',
      'Call — two players in means better implied odds',
      'Raise — attack both players',
      'Fold — multiway pots make sets harder to extract value',
    ],
    correctIndex: 1,
    explanation:
        '22 multiway: you need to call \$6. Implied odds at \$200 effective = 33:1. Multiway pots actually improve implied odds (two players to stack off against) while the risk stays at \$6. 22 is a clear call. However, be aware that sets in multiway pots can be counterfeited by straights/flushes — but the improved implied odds compensate.',
    difficulty: 'Intermediate',
    category: 'Set Mining Odds',
  ),

  // ─── Tournament ICM Spot (5) ──────────────────────────────────────────────

  DailyPuzzle(
    id: 'icm_01',
    title: 'ICM Bubble Spot',
    situation:
        'MTT. 11 players left, 10 make the money. You are the chip leader with 200,000. Blinds 2000/4000. SB (60,000 chips) shoves. BB (10,000) is all in. You are in the CO with AQo and 60,000.',
    holeCards: ['A♦', 'Q♠'],
    communityCards: [],
    options: [
      'Call — AQ is a premium hand, maximise chip EV',
      'Fold — ICM pressure is too high at the bubble',
      'Call — you are chip leader, you can afford it',
      'Fold — the short stack BB being all in changes the math',
    ],
    correctIndex: 1,
    explanation:
        'ICM bubble: the BB is at risk (10k) and may bust to give everyone else a pay jump. You have 60k and SB has 60k — calling off your stack on the bubble risks elimination. Despite AQo being a 55-45% favorite vs most ranges, the ICM cost of losing far outweighs the chip EV gain. Fold and let the BB bust to guarantee your cash.',
    difficulty: 'Advanced',
    category: 'Tournament ICM Spot',
  ),

  DailyPuzzle(
    id: 'icm_02',
    title: 'ICM Final Table Push/Fold',
    situation:
        'MTT final table, 5 players. Blinds 5000/10000. You have 50,000 (5BB). Payouts are heavily weighted to top 2. UTG folds, HJ folds, you are on the CO with K8o.',
    holeCards: ['K♣', '8♥'],
    communityCards: [],
    options: [
      'Fold — K8o is not strong enough to jam here',
      'Shove — at 5BB you must push K8o from CO',
      'Limp — play post-flop',
      'Fold — wait for a better spot at the final table',
    ],
    correctIndex: 1,
    explanation:
        'At 5BB with K8o from the CO, you must shove. ICM does reduce calling ranges at final tables but K8o from CO is clearly a shove — you are calling off roughly 50BB worth to get 1BB back if you fold. Any ace, any king, any broadway card, and suited connectors shove here. Waiting results in blinding down to 2–3BB which is much worse ICM-wise.',
    difficulty: 'Intermediate',
    category: 'Tournament ICM Spot',
  ),

  DailyPuzzle(
    id: 'icm_03',
    title: 'ICM Final 3 Bubble',
    situation:
        'MTT. 3 players remain. 2nd and 3rd pay significantly differently. You have equal chips (\$100k each, blinds 5k/10k). BTN shoves. You are SB with 99.',
    holeCards: ['9♣', '9♦'],
    communityCards: [],
    options: [
      'Fold — ICM risk is extreme with pay gap',
      'Call — 99 is strong enough to risk it',
      'Call — you have enough chips to absorb a loss',
      'Fold — you need a premium hand to call a shove 3-handed',
    ],
    correctIndex: 1,
    explanation:
        '99 at a 3-way final table vs a shove from BTN. 99 is a strong hand here. Even with ICM implications, 99 has ~60–70% equity vs a wide BTN shove range. The ICM cost of folding and losing chips to antes/blinds is also significant. 99 is a standard call in most ICM scenarios unless pay jumps are extreme (like 1st pays 10x 2nd).',
    difficulty: 'Expert',
    category: 'Tournament ICM Spot',
  ),

  DailyPuzzle(
    id: 'icm_04',
    title: 'Chip Leader ICM Mistake',
    situation:
        'MTT. 12 players, 10 cash. Chip leader (400k) shoves from UTG. You have 120k from BB with JJ. Average stack is 100k. Blinds 3k/6k.',
    holeCards: ['J♥', 'J♣'],
    communityCards: [],
    options: [
      'Fold — chip leader range is narrow, JJ is flipping or behind',
      'Call — JJ is strong enough to call any shove',
      'Call — you must take spots to win the tournament',
      'Fold — ICM pressure near the bubble makes this a fold',
    ],
    correctIndex: 3,
    explanation:
        'JJ vs a UTG chip-leader shove on the bubble is a fold. The chip leader has a tight UTG shoving range (QQ+, AK) vs which JJ is a 35–40% dog (vs QQ–AA) or a coin flip (vs AK). The ICM cost of losing 120k chips near the bubble is enormous. Fold JJ and maintain your comfortable stack.',
    difficulty: 'Expert',
    category: 'Tournament ICM Spot',
  ),

  DailyPuzzle(
    id: 'icm_05',
    title: 'Push-Fold ICM with AA',
    situation:
        'MTT. 15 players, 12 cash. 3 from bubble. You have 8BB. Any position. You pick up AA.',
    holeCards: ['A♠', 'A♥'],
    communityCards: [],
    options: [
      'Limp — disguise AA and encourage callers',
      'Raise to 2.5BB — standard open',
      'Shove — 8BB you must shove AA',
      'Fold — AA is so valuable, wait for the money bubble',
    ],
    correctIndex: 2,
    explanation:
        'AA at 8BB: shove every time. Even near the bubble, AA is the strongest possible hand and you must get chips in. Limping or min-raising with 8BB risks getting a hand that reduces your stack without eliminating anyone. ICM does NOT make you fold AA. The worst case is the best hand folds and you collect blinds — still a profit.',
    difficulty: 'Beginner',
    category: 'Tournament ICM Spot',
  ),

  // ─── Pot Odds Edge Case (5) ───────────────────────────────────────────────

  DailyPuzzle(
    id: 'pot_01',
    title: 'Pot Odds with a Flush Draw',
    situation:
        'Cash game \$1/\$2. Pot \$50. Opponent bets \$20. You are on the turn with a flush draw (9 outs to win).',
    holeCards: ['T♥', '8♥'],
    communityCards: ['A♥', '7♥', '3♣', '2♦'],
    options: [
      'Fold — 9 outs is not enough odds here',
      'Call — pot odds are 3.5:1 and you need ~4.5:1 for 9 outs on the turn',
      'Call — fold equity plus draw equity make this a call',
      'Fold — without implied odds the call is not profitable',
    ],
    correctIndex: 3,
    explanation:
        'Pot odds: you pay \$20 to win \$70 (pot+bet) = 3.5:1. You need to win ~22% of the time. 9 outs on the turn = ~18% (one card). The call is slightly -EV on pure pot odds. However, implied odds (opponent has more chips) make this a close call/fold depending on the opponent. The pure pot odds do not justify the call — you need implied odds of ~\$5–10 more.',
    difficulty: 'Advanced',
    category: 'Pot Odds Edge Case',
  ),

  DailyPuzzle(
    id: 'pot_02',
    title: 'Drawing to an Open-Ender',
    situation:
        'Cash game \$1/\$2. Pot \$40. Opponent bets \$40 on the turn. You have an open-ended straight draw (8 outs).',
    holeCards: ['J♠', 'T♣'],
    communityCards: ['Q♦', '9♠', '3♥', '2♣'],
    options: [
      'Fold — 2:1 pot odds do not cover 8 outs on the turn',
      'Call — 8 outs is approximately 17% — close to 2:1 required',
      'Call with implied odds — adding implied equity justifies the call',
      'Raise — semi-bluff raise to generate fold equity',
    ],
    correctIndex: 3,
    explanation:
        'Pot odds: \$40 to win \$80 = 2:1. 8 outs on turn = ~17% = need ~5:1 odds! Pure pot odds are terrible here. However, semi-bluff raising generates fold equity: if opponent folds, you win \$80. If called, you have 17% equity. A raise works better here than a call — raises can generate ~40–60% folds from some player types.',
    difficulty: 'Expert',
    category: 'Pot Odds Edge Case',
  ),

  DailyPuzzle(
    id: 'pot_03',
    title: 'Backdoor Draw Pot Odds',
    situation:
        'Cash game \$1/\$2. Pot \$30. Opponent bets \$20 on the flop. You have a backdoor flush draw and two overcards.',
    holeCards: ['K♥', 'Q♥'],
    communityCards: ['8♥', '5♣', '2♦'],
    options: [
      'Fold — backdoor draws have minimal value',
      'Call — backdoor flush + overcards give ~20% equity',
      'Call — KQ always has implied odds',
      'Raise — represent a strong hand on a dry board',
    ],
    correctIndex: 1,
    explanation:
        'KQ on 852 with a backdoor flush and two overcards: you have ~20% equity (6 outs to pair × 2 for turn+river rough estimate, plus ~4% backdoor flush). Pot odds: \$20 to win \$50 = 2.5:1 (need 29% equity). Technically a fold by pure odds, but with implied odds if you pair KQ, you can extract more. This is a close spot — borderline call vs straightforward folds.',
    difficulty: 'Intermediate',
    category: 'Pot Odds Edge Case',
  ),

  DailyPuzzle(
    id: 'pot_04',
    title: 'Correct Equity Calculation',
    situation:
        'Cash game \$1/\$2. Pot \$60. Opponent bets \$30. You are on the flop with a combo draw: flush draw + open-ended straight = 15 outs.',
    holeCards: ['J♠', 'T♠'],
    communityCards: ['9♠', '8♠', '2♣'],
    options: [
      'Call — 15 outs is great but pot odds are not right',
      'Raise — with 15 outs you are ahead — go all in',
      'Call — you are a slight equity favourite with 15 outs on the flop',
      'Raise jam — never just call with a monster draw',
    ],
    correctIndex: 1,
    explanation:
        'JT on 982 with 15 outs (flush + open-ender): with two cards to come, 15 outs = ~54% equity. You are actually a favourite! This is a must-raise/shove spot. Pot odds: you need 33% equity and you have 54%. Raise or shove to realise your equity and generate fold equity simultaneously. Calling invites bad beats; jamming wins more EV.',
    difficulty: 'Intermediate',
    category: 'Pot Odds Edge Case',
  ),

  DailyPuzzle(
    id: 'pot_05',
    title: 'Reverse Implied Odds',
    situation:
        'Cash game \$1/\$2. Pot \$50. Opponent bets \$20 on the flop. You hold KJ with middle pair (J high board: J♠6♣3♦). Opponent is tight.',
    holeCards: ['K♣', 'J♦'],
    communityCards: ['J♠', '6♣', '3♦'],
    options: [
      'Call — KJ top pair is a strong hand vs any range',
      'Call — pot odds justify the call with top pair',
      'Fold — reverse implied odds against a tight range mean you will lose more when behind',
      'Raise — top pair needs protection',
    ],
    correctIndex: 3,
    explanation:
        'KJ on J63 vs a tight opponent: raising for value/protection is optimal here. Against a tight opponent who bets into this dry board, their range is narrow (KK, QQ, JJ, KJ, 66, 33). KJ has ~50%+ equity vs this range. The reverse implied odds argument applies when you hold a dominated hand (KJ vs AJ), but KJ here is not dominated vs a tight value range on a dry board.',
    difficulty: 'Advanced',
    category: 'Pot Odds Edge Case',
  ),
];

/// Returns today's daily puzzle based on days elapsed since the epoch start date.
DailyPuzzle get todaysPuzzle {
  final epoch = DateTime(2026, 1, 1);
  final daysElapsed = DateTime.now().difference(epoch).inDays;
  return allDailyPuzzles[daysElapsed % allDailyPuzzles.length];
}
