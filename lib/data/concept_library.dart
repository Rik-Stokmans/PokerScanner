/// Poker concept library — 30+ concepts across 6 categories.
library concept_library;

enum ConceptCategory {
  fundamentals,
  preflop,
  postflop,
  math,
  psychology,
  advanced,
}

extension ConceptCategoryLabel on ConceptCategory {
  String get label {
    switch (this) {
      case ConceptCategory.fundamentals:
        return 'Fundamentals';
      case ConceptCategory.preflop:
        return 'Pre-Flop';
      case ConceptCategory.postflop:
        return 'Post-Flop';
      case ConceptCategory.math:
        return 'Math';
      case ConceptCategory.psychology:
        return 'Psychology';
      case ConceptCategory.advanced:
        return 'Advanced';
    }
  }
}

class PokerConcept {
  final String id;
  final String title;
  final ConceptCategory category;
  final String summary;
  final String body;
  final List<String> keyPoints;

  /// 1 = beginner, 2 = intermediate, 3 = advanced
  final int difficulty;

  const PokerConcept({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.body,
    required this.keyPoints,
    required this.difficulty,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Fundamentals (6)
// ─────────────────────────────────────────────────────────────────────────────

const _fundamentals = <PokerConcept>[
  PokerConcept(
    id: 'f01',
    title: 'Position: The Invisible Chip Stack',
    category: ConceptCategory.fundamentals,
    difficulty: 1,
    summary:
        'Acting last in a betting round is a massive structural advantage that compounds every street.',
    body: '''Position is one of the most fundamental concepts in No-Limit Hold\'em. When you act after your opponent, you possess an informational edge: you see their bet or check before you must decide. This means you can adjust every decision you make based on the new data they have revealed.

Consider a simple example: you hold a middle-pair hand on a dry flop. Out of position, you are forced to either lead into the unknown or check and face an uncertain response. In position, your opponent\'s check tells you the hand looks weak enough to bet for value or as a bluff, while their bet tells you the pot is getting expensive — and you can fold cheaply or raise if you believe you have the best hand.

Position compounds across streets. A player who has position on the flop maintains that advantage on the turn and the river. This is why experienced players devote so much study to pre-flop positional ranges: the premium you pay to play marginal hands from early position isn\'t just the chips in the pot, it\'s every future street where you will be forced to act blind.

In practical terms: open wider from the BTN than from UTG, three-bet lighter when you have position on a cold caller, and be willing to float a C-bet in position with hands that would be an easy fold out of position.''',
    keyPoints: [
      'Acting last gives you free information every betting round.',
      'Position is preserved across all streets of the same hand.',
      'Tighten your early position (UTG, UTG+1) opening range significantly.',
      'Wide BTN opens are profitable precisely because of positional advantage.',
      'Use position to control pot size: call flops you would fold OOP.',
    ],
  ),
  PokerConcept(
    id: 'f02',
    title: 'Hand Ranges vs. Specific Hands',
    category: ConceptCategory.fundamentals,
    difficulty: 1,
    summary:
        'Elite players never put opponents on a single hand — they assign a weighted range and update it continuously.',
    body: '''Beginners think in terms of specific hands: "he has Kings." Advanced players think in ranges: "he has a range that includes big pairs, AK, and some bluff combinations, weighted toward the top end given the pre-flop action."

Thinking in ranges changes how you play. When you check-raise the flop and your opponent calls, you should no longer be asking "does he have a set?" You should be asking "how has his range changed after calling my check-raise?" Most weak hands fold to a check-raise, so his continuing range is polarised toward strong made hands and draws. Your turn bet must be sized to extract value from both while applying maximum pressure on draws.

Constructing ranges requires understanding the incentives at each decision point. A player who 3-bets pre-flop from the small blind when the original raiser is in the cut-off has a different range than one who 3-bets from the big blind against a BTN open. Position, stack depth, table image, and history all shape ranges.

Update your range assumptions on every street. The flop texture, bet sizing, and the speed of an opponent\'s action all provide information. Fast calls on wet boards often indicate draws; slow calls often indicate showdown-worthy marginal hands. Build a habit of narrating each opponent\'s range aloud in your head as each action occurs.''',
    keyPoints: [
      'Assign a probability-weighted range, not a single hand, to opponents.',
      'Update the range after every action using Bayesian reasoning.',
      'Bet sizing and speed of action are both informative range signals.',
      'Your own range must be balanced: bluffs and value hands at all sizings.',
      'Range advantage on a board texture drives most continuation bet decisions.',
    ],
  ),
  PokerConcept(
    id: 'f03',
    title: 'Pot Odds and Break-Even Equity',
    category: ConceptCategory.fundamentals,
    difficulty: 1,
    summary:
        'A call is correct whenever your hand\'s equity exceeds the fraction of the total pot you must invest.',
    body: '''Pot odds tell you how often your hand needs to be best — or needs to improve — to make a call mathematically profitable. The formula is simple: divide what you must call by the total pot after your call. If you must call \$50 into a \$150 pot (making the total pot \$200), your break-even equity is 50/200 = 25%.

This means if you hold a flush draw (roughly 19% on the turn, 35% with two cards to come), calling a large bet on the flop is only correct if the full two-card equity exceeds the required percentage, and if you expect to realise that equity — i.e., you won\'t be bet out of the pot on the turn even if you miss.

Implied odds adjust pot odds for the chips you can win on future streets if you hit your hand. Conversely, reverse implied odds account for times you hit but still lose — for example, completing a flush when your opponent holds a higher flush. Implied odds are higher with deeper stacks, in position, and against calling stations who pay off when you hit.

Memorise a few key break-even percentages: a pot-sized bet requires 33% equity; a half-pot bet requires 25%; a quarter-pot bet requires only 17%. These thresholds let you make instant decisions even under time pressure at the table.''',
    keyPoints: [
      'Break-even equity = call amount ÷ total pot after the call.',
      'Pot-sized bet requires 33% equity; half-pot requires 25%.',
      'Implied odds increase your effective equity when deep-stacked.',
      'Reverse implied odds reduce your effective equity on drawing hands.',
      'Always factor in whether you can realise your equity over future streets.',
    ],
  ),
  PokerConcept(
    id: 'f04',
    title: 'Expected Value (EV) Thinking',
    category: ConceptCategory.fundamentals,
    difficulty: 1,
    summary:
        'Every decision has an expected value; consistently choosing the highest-EV action is the definition of winning poker.',
    body: '''Expected Value is the average dollar amount you win or lose over many repetitions of a given situation. Poker is a game played in a single session but judged over thousands of hands, so your goal is always to maximise EV — not to win the current hand.

The EV of a bet is calculated as: (probability of fold × pot won) + (probability of call × equity when called × pot size) − (probability of call × 1-equity × bet size). While you won\'t run this exact formula at the table, the intuition matters: each time you bet, you earn EV from folds and from times you get called with the best hand, but you lose EV from times you get called with the worst hand.

EV thinking reframes bad beats. When you get your money in with 80% equity and lose, you did not make a mistake — you made the maximum EV play. Bad beats are noise; your equity edge is signal. Over 10,000 hands that same 80%-equity spot will profit enormously.

Conversely, EV thinking highlights hidden leaks. Calling a river bet with a bluff-catcher when the pot is laying you 4:1 seems safe, but if your opponent is bluffing only 10% of the time you need 20% equity (call ÷ pot+call). You\'re losing money on every call even though you "only" need to be right once in five attempts.''',
    keyPoints: [
      'EV = sum of (probability × outcome) for all possible outcomes.',
      'Maximise EV every decision, regardless of short-term results.',
      'Bad beats don\'t represent mistakes if you had the highest EV play.',
      'Small EV edges compound massively over thousands of hands.',
      'Use EV thinking to diagnose leaks, not just to make individual decisions.',
    ],
  ),
  PokerConcept(
    id: 'f05',
    title: 'Table Image and Meta-Game',
    category: ConceptCategory.fundamentals,
    difficulty: 2,
    summary:
        'How opponents perceive your play style determines how they respond to your bets — managing that perception is a skill in itself.',
    body: '''Table image is the aggregate perception your opponents form about your playing style based on your observed actions. If you have been caught bluffing twice in an hour, opponents will call you down more lightly — which makes your value bets incredibly profitable, but your bluffs almost worthless. Conversely, if you have only shown down strong hands, your bluffs are more credible but your value bets get less action.

Managing your image means intentionally thinking two steps ahead. Sometimes you show a bluff knowing it will get you paid off on your next big value hand. Sometimes you deliberately play a premium hand passively to appear weak before a planned squeeze.

Meta-game goes further: it\'s the battle of adjustments and counter-adjustments between two players who both know they are each trying to exploit the other. If you notice a competent opponent adjusting to your style, you must adjust back — or at least signal that you can.

At lower stakes, table image matters less because opponents don\'t pay sufficient attention. Focus first on fundamental strategy; add image management once you are consistently beat-the-rake winning. The biggest immediate gain from awareness of table image is simply recognising when yours has gone negative (many recent bluffs or lost showdowns) and tightening up value range accordingly.''',
    keyPoints: [
      'Your image is the range opponents assign you based on recent history.',
      'A "loose" image makes value bets more profitable and bluffs cheaper.',
      'A "tight" image makes bluffs more credible but value gets less action.',
      'Show bluffs strategically only when it sets up future value extraction.',
      'Meta-game matters most at high stakes; focus on fundamentals first.',
    ],
  ),
  PokerConcept(
    id: 'f06',
    title: 'Bankroll Management',
    category: ConceptCategory.fundamentals,
    difficulty: 1,
    summary:
        'Proper bankroll management ensures short-term variance can\'t end your poker career.',
    body: '''Bankroll management is the discipline of only risking a small fraction of your total playing funds in any single game or tournament. Even the best poker player in the world will face swings of 20–30 buy-ins in No-Limit Hold\'em due to variance. Without a sufficient bankroll, even correct play leads to ruin.

The standard advice for cash games: keep at least 20–30 buy-ins for your stake level. For tournaments, the variance is higher and 100 buy-ins is more appropriate for serious players. These numbers assume you are a winning player; if you are still developing, add a safety buffer.

Moving down in stakes is not a failure — it is a tactical retreat to protect your ability to play. Many great players have moved down after downswings and rebuilt. The ability to move down requires ego discipline that separates long-term winners from those who go broke.

Tracking your results is inseparable from good bankroll management. Log every session with date, stake, hours played, and result. After 10,000 hands you will have meaningful data about your win rate and standard deviation. This data drives smart decisions about moving up or down in stakes.''',
    keyPoints: [
      'Maintain 20–30 buy-ins for cash games; ~100 for tournaments.',
      'Variance will cause 20+ buy-in downswings even for winning players.',
      'Move down stakes to preserve capital — it is a strategic decision, not failure.',
      'Track every session to build statistically meaningful win-rate data.',
      'Never play with money you cannot afford to lose.',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Pre-Flop (6)
// ─────────────────────────────────────────────────────────────────────────────

const _preflop = <PokerConcept>[
  PokerConcept(
    id: 'p01',
    title: 'Opening Ranges by Position',
    category: ConceptCategory.preflop,
    difficulty: 1,
    summary:
        'Your opening range should widen progressively from UTG to the BTN as the number of players left to act decreases.',
    body: '''Pre-flop range construction is driven by two primary factors: position and stack depth. From UTG at a 9-handed table, you have eight players behind who could wake up with a premium hand. Only the top ~12–14% of hands have enough equity and post-flop playability to open profitably here. That means primarily big pairs (AA–99), Broadway combinations (AK, AQ, AJ, KQ, KJs), and a small selection of suited connectors.

From the CO and BTN you face fewer players, and your positional advantage post-flop is at its maximum. BTN opening ranges in GTO play extend to roughly 40–50% of hands, including all pocket pairs, many suited hands, and off-suit Broadway combinations that aren\'t viable from earlier seats.

Suited hands get a significant bonus because of their flush and backdoor flush potential. A hand like 76s adds equity through both the straight draw and flush draw potential; 76o has much weaker playability and should be restricted to late position opens if at all.

Memorising exact GTO ranges isn\'t practical for most players. Instead, learn the shape: very tight from early position, progressively looser moving left, with suited connectors and small pocket pairs entering the range from MP/CO and aggressively from BTN/SB steals.''',
    keyPoints: [
      'UTG range: ~12–14% — big pairs, strong Broadway, select suited connectors.',
      'CO range: ~22–25%; BTN range: ~40–50% of all hands.',
      'Suitedness adds significant equity; prioritise suited hands over off-suit equivalents.',
      'Avoid limping; open or fold from all positions for a clean range structure.',
      'Adjust range based on the tendencies of players yet to act behind you.',
    ],
  ),
  PokerConcept(
    id: 'p02',
    title: '3-Betting: Value and Bluffs',
    category: ConceptCategory.preflop,
    difficulty: 2,
    summary:
        'A balanced 3-bet range mixes premium value hands with well-selected bluffs that have good removal and playability.',
    body: '''A 3-bet is the third bet in a sequence (open, re-raise). Value 3-bets are straightforward: AA, KK, QQ, AK in most spots. The art of 3-betting is selecting the correct bluff hands to include, so that your overall range is balanced and cannot be exploited.

The ideal 3-bet bluff candidate has blocker value (it makes it less likely your opponent holds a premium hand) and good playability when called. Hands like A5s or A4s are excellent: the Ace in your hand removes one combination of AA and AK from your opponent\'s range, and the suited nature gives you post-flop equity when called. Conversely, a hand like 72o has no blocker value and terrible playability — it is a poor bluff candidate.

Sizing matters. A 3-bet from in position (BTN vs. CO) typically goes to 2.5–3x the open. Out of position you must go larger — 3.5–4x — to charge callers for the positional disadvantage they will enjoy on every street. In both cases, your bluffs and value hands should be 3-bet to the same size so that opponents cannot exploit your sizing tells.

Against aggressive opponents who open wide and fold to 3-bets, increase your bluffing frequency. Against tight players who only continue with premiums, stick to thin value and avoid bluffs entirely. 3-bet ranges are one of the most exploitable aspects of many players\' games.''',
    keyPoints: [
      'Value 3-bets: AA, KK, QQ, JJ (sometimes), AK, and possibly AQs.',
      'Bluff candidates: A5s, A4s, A3s for their Ace blocker and suitedness.',
      'Use the same sizing for bluffs and value to remain unexploitable.',
      '3-bet bigger OOP than IP; 3.5–4x vs. 2.5–3x.',
      'Increase bluff frequency against opponents who fold often to 3-bets.',
    ],
  ),
  PokerConcept(
    id: 'p03',
    title: 'Big Blind Defense',
    category: ConceptCategory.preflop,
    difficulty: 2,
    summary:
        'The BB is the most expensive seat on the table; defending too wide wastes money while folding too much gifts equity to stealers.',
    body: '''The Big Blind is unique: you have already invested one blind, which means you get better pot odds to call than any other player. Against a BTN open of 3bb, you are calling 2bb more into a 4.5bb pot (2bb blind + 0.5 SB + 3bb open = 5.5bb total after your call, paying 2bb), giving you roughly 2:5.5 ≈ 36% required equity. This means you can profitably defend a very wide range.

The mistake most players make is over-folding. GTO solvers defend the BB with 45–55% of hands against most position opens. Your defending range should include many suited hands, any pair, and connected hands with reasonable equity, even if those same hands would be a fold from an earlier position.

You will often be out of position for the entire hand, which is a significant downside. This is why the BB defense range should weight toward hands that play well for their equity: pairs (which hit sets), suited connectors (which hit two-pair+ and strong draws), and suited Broadway hands that flop strong draws or top pair with a good kicker.

Calling a 4-bet from the BB requires a much stronger hand. When you have already called a 3-bet and face a 4-bet, the pot odds are worse and the range you face is narrower. Tighten significantly: KK, AA, AKs, QQ are the main defending hands.''',
    keyPoints: [
      'BB pot odds justify defending ~50% of hands vs. standard BTN opens.',
      'Over-folding from the BB is a common and costly leak.',
      'Weight defends toward suited, connected, or pair hands for post-flop playability.',
      'Check-raising is a critical weapon; use it to counter frequent C-bets.',
      'Against 4-bets from the BB, narrow to KK+, AKs, QQ.',
    ],
  ),
  PokerConcept(
    id: 'p04',
    title: 'Squeezing',
    category: ConceptCategory.preflop,
    difficulty: 2,
    summary:
        'A squeeze play 3-bets after an open and one or more cold calls, exploiting the callers\' wide, capped ranges.',
    body: '''A squeeze is a 3-bet made when there has been an open and at least one cold caller before the action reaches you. The cold caller has a capped range — they didn\'t 3-bet, which removes the top of their range — and they are stuck between you and the original opener. Both players face a difficult call/fold decision.

Squeezes are profitable even as pure bluffs when the cold callers fold frequently, because you win the already-inflated pot without seeing a flop. The optimal sizing for a squeeze is larger than a standard 3-bet to account for the dead money: typically 4–5x the open when there is one caller, and 5–6x with two callers.

Value squeezes should include all your normal 3-bet value range (AA, KK, QQ, AK). Bluff squeezes should prioritise hands with blocker value, particularly Ace-x suited hands that remove combinations of AK and AA from the openers\' ranges.

Position matters even in squeezes. Squeezing from the BTN is the strongest spot — you have position post-flop if called. Squeezing from the SB or BB is effective but means you will be out of position; compensate with a larger sizing and restrict your bluffing range to hands with strong equity when called.''',
    keyPoints: [
      'Squeeze 3-bets are effective because callers have capped, wide ranges.',
      'Go larger than a standard 3-bet — typically 4–6x depending on callers.',
      'Bluff squeezes with blockers: A5s, A3s, A4s are ideal candidates.',
      'Squeezes from position are most profitable; from blinds use larger sizing.',
      'The more callers, the more dead money — making even pure bluffs correct.',
    ],
  ),
  PokerConcept(
    id: 'p05',
    title: 'Calling 3-Bets IP vs. OOP',
    category: ConceptCategory.preflop,
    difficulty: 2,
    summary:
        'Calling 3-bets in position is far more profitable than OOP — your defending ranges should reflect this asymmetry.',
    body: '''When you face a 3-bet, you have three options: fold, call (flat), or 4-bet. The correct choice depends on your hand strength, position, and opponent tendencies. This concept focuses on the flat-call option and when it is appropriate versus a fold.

Calling a 3-bet in position gives you all the benefits of post-flop positional advantage we discussed in earlier concepts. Hands that lack the pure strength to 4-bet but have too much equity to fold — pairs, suited connectors, suited Broadway — make excellent flat-call candidates when you have position. Against a 3-bet of 10bb, calling with 77 in the CO after opening from the BTN is correct; you flop a set ~11% of the time and have a concealed hand that can outplay opponents post-flop.

Out of position, calling 3-bets becomes very expensive over time. You are forced to act first on every street without knowing what your opponent will do. Even strong hands like AQ lose significant value OOP because you can\'t control pot size or see free cards. The fundamental principle: 4-bet or fold OOP more often, call IP more often.

Against aggressive opponents who 3-bet wide, calling down with medium-strength hands in position is extremely profitable. Against nitty opponents whose 3-bets represent only premiums, fold weak hands and 4-bet your own premiums.''',
    keyPoints: [
      'Calling 3-bets IP preserves all positional advantages on future streets.',
      'Calling 3-bets OOP is expensive; prefer 4-bet or fold OOP.',
      'Pairs and suited connectors make ideal flat 3-bet calls IP.',
      'AQ and below often lose significant value when called OOP vs. a 3-bet.',
      'Increase your 3-bet flat frequency against loose, wide 3-bettors IP.',
    ],
  ),
  PokerConcept(
    id: 'p06',
    title: 'Stack-to-Pot Ratio (SPR) and Pre-Flop Commitment',
    category: ConceptCategory.preflop,
    difficulty: 2,
    summary:
        'SPR determines how committed you are to a pot and should influence both pre-flop sizing and post-flop decisions.',
    body: '''Stack-to-Pot Ratio is the ratio of effective stacks to the pot size at the start of any post-flop street. A SPR of 1 means each player has exactly one pot-sized bet remaining; a SPR of 10 means they have ten pot-sized bets. SPR profoundly shapes the correct post-flop strategy.

Low SPR (1–3) means you are highly committed. With SPR of 1, getting all-in with top pair, good kicker is typically mandatory — there is not enough room to outmanoeuvre. High SPR (10+) means strong hands like top pair are vulnerable; you want two pair or better to be confident committing.

Pre-flop actions create SPR. A 3-bet and call going into a flop of 30bb with 200bb stacks produces SPR = 170/30 ≈ 5.7. That means a large overpair should be willing to put most chips in, but top pair/medium kicker should be cautious about inflating the pot further. A single raise to 3bb with 100bb stacks produces SPR = 97/6.5 ≈ 15, meaning even sets should extract carefully to avoid a fold.

Thinking about SPR pre-flop helps you size your opens and 3-bets strategically. With hands that play well in low-SPR situations (AA, KK), consider slightly larger pre-flop sizing to reduce SPR. With speculative hands that need to flop a big hand (low pairs, small suited connectors), prefer smaller sizes to preserve SPR.''',
    keyPoints: [
      'SPR = effective stack ÷ pot size at the start of any post-flop street.',
      'Low SPR (1–3): committed with top pair or better; high SPR (10+): need two-pair+.',
      'Pre-flop sizing directly determines post-flop SPR.',
      'Value hands (AA, KK) can inflate pots pre-flop to reduce SPR profitably.',
      'Speculative hands (suited connectors) prefer large SPR for implied odds.',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Post-Flop (7)
// ─────────────────────────────────────────────────────────────────────────────

const _postflop = <PokerConcept>[
  PokerConcept(
    id: 'pf01',
    title: 'Continuation Betting Strategy',
    category: ConceptCategory.postflop,
    difficulty: 2,
    summary:
        'A C-bet is most profitable when your range has a structural advantage on the board texture you face.',
    body: '''A continuation bet (C-bet) is a bet made by the pre-flop aggressor on the flop. It has two sources of profit: opponents fold hands with equity (fold equity), and it builds the pot when you hold a strong hand (value). The mistake many players make is treating C-betting as automatic rather than board-dependent.

Range advantage is the key concept. On a board like K72 rainbow, a pre-flop raiser from early position has many more combinations of Kings and top-pair hands in their range than the caller; they have strong range advantage and should bet with high frequency at a small size (25–33% pot). On a board like 876 two-tone, the pre-flop caller is equally likely to have connected with the board — or more so — and the raiser\'s C-bet frequency should decrease and size should increase when betting.

Bet sizing also signals intention. Small bets (25–33%) encourage folds from weak hands while extracting thin value and work best on dry, non-connecting boards where the raiser has strong range advantage. Large bets (66–100%) work on boards where your range is polarised — you either have a strong hand or air — and you want maximum fold equity or to build a pot for later streets.

Avoid the automatic C-bet with no equity and no fold equity. If the board connects well with calling ranges and you hold complete air, a check is often the highest EV option, allowing you to bluff profitably on later streets with a better equity backup (runner-runner, for example).''',
    keyPoints: [
      'C-bet when your range has board texture advantage, not automatically.',
      'Small bets (25–33%) work best on dry boards where you dominate the range.',
      'Large bets (66–100%) signal polarization on connected or wet boards.',
      'Check with air when fold equity is low; preserve bluffing credibility.',
      'Consider opponent tendencies: bet less against calling stations.',
    ],
  ),
  PokerConcept(
    id: 'pf02',
    title: 'Wet vs. Dry Board Textures',
    category: ConceptCategory.postflop,
    difficulty: 1,
    summary:
        'Board texture determines how many strong draws exist, which drives optimal bet sizing and frequency for both players.',
    body: '''Board texture describes how connected and suited the community cards are. A "dry" board like K72 rainbow has almost no straight draw possibilities and no flush draws. A "wet" board like 8♣7♦6♣ has maximum draw potential: open-ended straight draws, flush draws, combo draws, and many two-pair/set combinations.

On dry boards, strong hands like top pair are relatively safe; drawing hands are rare and weak. The pre-flop aggressor can bet frequently at a small size to extract thin value and deny the rare equity that backdoor draws hold. The out-of-position player faces an easy check-fold or check-call with weak holdings.

On wet boards, the situation is reversed. Draws are common, equity differences between hands are smaller, and the gap between the best and worst hands in both ranges narrows. The in-position player should be careful about building large pots with marginal made hands; a one-pair hand on 8♣7♦6♣ is often in much worse shape than it appears when the board fills out.

Semi-wet boards — one flush draw, one overcard to a paired board — represent the middle ground. Here, C-bet frequency should be medium, and bet sizing should be calibrated to charge draws without bloating the pot too much with weak made hands.

Reading board texture quickly is a trained skill. Practice identifying immediately: (1) are there flush draws? (2) are there straight draws? (3) does the board pair? (4) who is more likely to have connected?''',
    keyPoints: [
      'Dry boards (K72r): bet frequently small; draws are rare and weak.',
      'Wet boards (876 two-tone): reduce C-bet frequency; draws are very common.',
      'On wet boards, protect equity but don\'t over-inflate pot with one pair.',
      'Semi-wet boards require medium frequency and medium sizing adjustments.',
      'Practice the four-question board-read: flushes, straights, pairs, range fit.',
    ],
  ),
  PokerConcept(
    id: 'pf03',
    title: 'Check-Raising for Value and as Bluff',
    category: ConceptCategory.postflop,
    difficulty: 2,
    summary:
        'The check-raise is the most aggressive weapon available to out-of-position players and must be used at the right frequency.',
    body: '''A check-raise is the act of checking the action to your opponent, allowing them to bet, then raising that bet. It is one of the most powerful moves in poker because it denies any free showdown and forces opponents to commit significantly more chips with marginal hands.

From out of position, check-raising is your primary method of denying positional advantage. By check-raising the flop, you take the aggressor role and force the in-position player to react, reversing the natural dynamic. A check-raise to 3x the C-bet immediately puts enormous pressure on any hand that doesn\'t have strong equity.

Value check-raises require hands strong enough to want multiple streets of betting: sets, top two pair, and strong draws on wet boards. A top-pair-top-kicker check-raise is usually too thin on a wet board but can be correct on a dry board in position against a known serial C-bettor.

Check-raise bluffs work best when you have equity backup (draws, overcards) so you aren\'t completely dead if called. A check-raise bluff with a flush draw on 8♣7♣2♦ is excellent: you have significant equity against calling ranges and a believable range that includes sets and two-pair.

Balance is critical: if you only check-raise with the nuts, your opponent will simply fold everything except premiums and you gain nothing. Maintain check-raises with ~1/3 draws alongside ~2/3 value hands for a balanced range.''',
    keyPoints: [
      'Check-raises reverse positional advantage by seizing the aggressor role.',
      'Value check-raises: sets, two-pair, strong draws on wet boards.',
      'Bluff check-raises: include a flush or straight draw for equity backup.',
      'Balance check-raise range: ~1/3 bluffs to ~2/3 value.',
      'Sizing: raise to 2.5–3.5x the C-bet on most textures.',
    ],
  ),
  PokerConcept(
    id: 'pf04',
    title: 'Turn Play: Barrel or Give Up?',
    category: ConceptCategory.postflop,
    difficulty: 2,
    summary:
        'The turn is where ranges narrow dramatically — only hands with genuine equity or strong fold equity should double-barrel.',
    body: '''The turn is the most critical street in No-Limit Hold\'em. By now, ranges have been significantly narrowed by flop action, and the pot is large enough that large turn bets represent a massive commitment of chips. A poor turn decision is far more expensive than a poor flop decision.

Double-barrelling (betting the flop and the turn) should be reserved for three hand types: strong value hands that want to build the pot, semi-bluffs with significant equity (flush draws, open-ended straight draws), and total air when a specific card has meaningfully improved your perceived range (turn cards that "hit" your pre-flop range).

Turn cards that improve your range are called "good turn cards" for the aggressor. A pre-flop raiser who C-bet a K72 flop and faces a call should fire again on a J, Q, or T turn — these cards hit strong opening ranges (KJ, KQ, JJ, QQ) while hitting calling ranges minimally. An 8 or 9 turn on that same board is a "bad" turn card — it doesn\'t improve the raiser\'s range and may have helped a backdoor draw.

Giving up the turn is correct when: the turn card is bad for your range, you have no equity with your bluff hand, and your opponent\'s calling range is too strong. A disciplined give-up now allows a river bluff later if you acquire equity or the right card falls.''',
    keyPoints: [
      'Double-barrel with value, semi-bluffs, or range-improving turn cards.',
      'Identify "good" turn cards — those that connect with your pre-flop range.',
      'Give up bluffs when the turn is bad for your range and you have no equity.',
      'Turn bets should be larger than flop bets: 60–80% pot is standard.',
      'A check-turn is not weakness if followed by a credible river bet.',
    ],
  ),
  PokerConcept(
    id: 'pf05',
    title: 'River Decisions: Value Betting Thin',
    category: ConceptCategory.postflop,
    difficulty: 3,
    summary:
        'Thin value bets on the river extract chips from weaker hands while navigating the risk of being raised by stronger ones.',
    body: '''River play is where the biggest edges in No-Limit Hold\'em are found or lost. On the river there is no more equity to realise — every hand is its final value. This makes correct bet/check and call/fold decisions purely about exploiting range imbalances.

Thin value betting means betting with hands that are "good enough" to value bet, expecting to be called by some weaker hands, but not by so many stronger hands that the bet becomes unprofitable. Classic thin value bets include second pair with a good kicker, top pair with a medium kicker when the board was dry, and bluff-catchers that are the top of your bluff-catching range.

The rule of thumb: bet for value if you believe you will be called by worse hands more than 50% of the time. If your top pair on a safe board will get called by second pair, weak top pair, and missed draws that "give up and call" — it is a value bet. If the board texture suggests your opponent has only very strong hands or missed draws (a polarised range), bet large and expect to win big or fold out weakness.

River raises are very strong in typical games. Most recreational players don\'t raise the river with less than two pair. If your thin value bet gets raised, the most common correct response is a fold with anything below top pair, top kicker.''',
    keyPoints: [
      'Bet for value when weaker hands call more than 50% of the time.',
      'Thin value is safe on dry, uncoordinated rivers where ranges are broad.',
      'River polarized boards justify large sizing with strong hands or air.',
      'River raises from typical opponents are almost always very strong hands.',
      'Checking back marginal hands against aggressive players avoids costly raises.',
    ],
  ),
  PokerConcept(
    id: 'pf06',
    title: 'Pot Control and Equity Protection',
    category: ConceptCategory.postflop,
    difficulty: 2,
    summary:
        'Managing pot size with medium-strength hands maximises their expected value by extracting thin streets while limiting exposure.',
    body: '''Pot control is the art of keeping the pot small when you have a medium-strength hand that wants to reach showdown cheaply. The classic situation: you hold top pair with a medium kicker in a single-raised pot. This hand is good enough to win at showdown a meaningful percentage of the time but loses badly to two-pair, sets, and straights.

The pot-control line typically involves: betting small on an early street (or checking), calling a bet rather than raising, and not building the pot beyond 3–4x the original raise. The goal is to reach showdown without investing more than your equity justifies.

A related concept is equity protection: betting with a hand that is currently best but is vulnerable to being outdrawn. For example, an overpair on a wet board like 8♣7♦5♣ is currently best but faces numerous draws. Checking gives draws free cards; betting charges them properly. This is not pot building for value — it is bet-to-deny-equity.

The balance between pot control and equity protection is dynamic. On wet boards, equity protection usually wins: bet to deny draws even with medium-strength hands. On dry boards, pot control often wins: check with non-nut hands to avoid inflating the pot against stronger holdings. Learning when to apply each principle is a large part of post-flop mastery.''',
    keyPoints: [
      'Pot control: keep pot small with medium-strength, vulnerable hands.',
      'Equity protection: bet to deny free cards to drawing hands.',
      'Wet boards favour equity protection; dry boards favour pot control.',
      'Avoid check-raising medium-strength hands — it inflates the pot dangerously.',
      'A check-back in position often achieves both goals on safe turn cards.',
    ],
  ),
  PokerConcept(
    id: 'pf07',
    title: 'Blockers and Card Removal Effects',
    category: ConceptCategory.postflop,
    difficulty: 3,
    summary:
        'Holding specific cards reduces the probability that opponents can have certain hands, creating bluffing and calling advantages.',
    body: '''Card removal (blockers) refers to the statistical effect of holding a card that cannot exist in an opponent\'s hand. The most powerful example: holding an Ace when the board is A-high. You hold one of only four Aces in the deck, meaning the probability that your opponent has top pair (Ace in their hand) is reduced by approximately 25%.

This concept is most relevant on the river when constructing bluffing ranges. An ideal river bluff candidate holds cards that reduce the probability of opponent having strong hands. Holding K♦ when you\'re bluffing a board like A♦Q♦5♦ 2♣ J♣ reduces the chance your opponent has the nut flush (A♦X) — this makes your bluff more likely to work.

Blockers also inform calling decisions. If the board is monotone and you hold the Ace of that suit, your opponent cannot have the nut flush, which makes calling a river bet much stronger even with a weaker hand.

In pre-flop play, blockers explain the preference for A-x suited 3-bet bluffs: holding an Ace reduces combinations of AA and AK in your opponent\'s value 3-bet range, making your bluff more likely to succeed.

The key caveat: blockers matter more at high frequencies of the blocked hand. Blocking a very rare hand provides minimal benefit; blocking a common hand (like top pair on an Ace-high board) is very valuable.''',
    keyPoints: [
      'Holding a card removes its duplicate from all opponent ranges.',
      'Ace blocker reduces opponent combinations of AA, AK, and top pair.',
      'Use blockers to select river bluff candidates with maximum removal value.',
      'Nut flush blockers make river calls more profitable on monotone boards.',
      'Blockers matter most when the blocked combination is common in opponent ranges.',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Math (5)
// ─────────────────────────────────────────────────────────────────────────────

const _math = <PokerConcept>[
  PokerConcept(
    id: 'm01',
    title: 'Counting Outs and Equity',
    category: ConceptCategory.math,
    difficulty: 1,
    summary:
        'Counting outs lets you estimate your probability of improving on the next card using the simple rule-of-2-and-4.',
    body: '''An "out" is any card remaining in the deck that will improve your hand to what you believe is the best hand. Accurately counting outs is the foundation of draw decisions. Standard draw types and their outs: flush draw = 9 outs; open-ended straight draw (OESD) = 8 outs; gutshot straight draw = 4 outs; over-cards to a likely one-pair = 6 outs.

The Rule of 2 and 4 is the simplest equity approximation in poker. On the flop (two cards to come), multiply your outs by 4 to get your approximate percentage equity. On the turn (one card to come), multiply by 2. A flush draw on the flop = 9 × 4 = 36% equity. The same draw on the turn = 9 × 2 = 18%.

These are approximations — the true equity is slightly lower because you can hit an out that improves your opponent even more — but they are accurate within 1–2% for most draws and are perfectly usable for in-game decisions.

Combo draws have combined outs. A flush draw plus an open-ended straight draw on 8♣7♣2♦ with J♣9♣ in your hand = 9 flush outs + 8 straight outs − 2 overlap cards (the J♣ and 9♣ are already in your hand) = 15 outs. That\'s approximately 60% equity on the flop — often a favourite over even a strong made hand.

When counting outs, subtract "dirty outs" — cards that improve your draw but might give your opponent a stronger hand.''',
    keyPoints: [
      'Flush draw = 9 outs; OESD = 8 outs; gutshot = 4 outs.',
      'Rule of 2 and 4: multiply outs × 4 on flop, × 2 on turn.',
      'Combo draws can be 15+ outs — often a coin-flip or better against made hands.',
      'Subtract "dirty outs" that improve your draw but also help your opponent.',
      'These approximations are within 1–2% of true equity — accurate enough for play.',
    ],
  ),
  PokerConcept(
    id: 'm02',
    title: 'Minimum Defence Frequency (MDF)',
    category: ConceptCategory.math,
    difficulty: 2,
    summary:
        'MDF is the fraction of your range you must continue with to prevent an opponent\'s pure bluffs from being automatically profitable.',
    body: '''Minimum Defence Frequency (MDF) answers the question: "How often must I call or raise to make my opponent\'s bluffs unprofitable?" The formula is: MDF = pot / (pot + bet).

If your opponent bets pot size, MDF = pot / (pot + pot) = 50%. You must continue with 50% of your range. If they bet half-pot, MDF = pot / (pot + 0.5pot) ≈ 67%.

This has two implications: first, if you fold more often than the MDF dictates, all bluffs — regardless of the hand used to bluff — become instantly profitable. Your opponent can exploit you simply by betting with any two cards. Second, if you always call at MDF, your opponent\'s bluffs break even and only their value bets profit — which is the correct game-theory-optimal outcome.

In practice, MDF should guide your overall fold-to-bet statistics rather than individual decisions. Seeing your "fold to C-bet" stat as 60% against half-pot C-bets (where MDF is 67%) means you\'re folding too much. Adjust by defending wider on boards that connect with your range.

MDF is not a rigid rule for individual hands but a calibration tool for your overall frequencies. Against a specific opponent who never bluffs, you can fold below MDF with impunity.''',
    keyPoints: [
      'MDF = pot ÷ (pot + bet); the minimum fraction of your range to continue.',
      'Bet pot-size: MDF = 50%. Bet half-pot: MDF ≈ 67%.',
      'Folding below MDF makes all bluffs profitable regardless of hand quality.',
      'Use your fold-to-bet stats to check if you\'re meeting MDF over many hands.',
      'Against known non-bluffors, folding below MDF is still correct.',
    ],
  ),
  PokerConcept(
    id: 'm03',
    title: 'Combinatorics: Counting Hand Combinations',
    category: ConceptCategory.math,
    difficulty: 2,
    summary:
        'Understanding hand combinations lets you precisely weight ranges and identify when opponents are far more likely to be bluffing or value-betting.',
    body: '''Combinatorics is the mathematics of counting how many distinct ways a particular hand can be formed from a 52-card deck. Understanding combinations is what separates approximate range thinking from precise range analysis.

Starting with the basics: unpaired hands (like AK) have 16 combinations — 4 Aces × 4 Kings. Pocket pairs (like AA) have 6 combinations — C(4,2) = 6. Suited hands have 4 combinations; off-suit hands have 12 combinations. So AKs has 4 combos and AKo has 12 combos, for 16 total.

Where combinatorics becomes powerful is in the "blocker" analysis we discussed earlier. On a board of A♠K♦7♣, you hold Q♠Q♥. Your opponent bets large. How likely is it they have AK? There are 3 Aces left × 3 Kings left = 9 AK combinations remaining (not 16, because the board uses one Ace and one King). Compare that to the 2 AA combinations left (4-1=3 Aces, choose 2 = 3, but one Ace is on the board = C(3,2)=3) — actually AK is by far the most common strong hand.

This type of analysis, done quickly in your head, lets you make more accurate read decisions. If your opponent would only bet this way with AK or sets, and there are 9 AK combos vs. 3 set combos (7,7 = 3 left), AK is three times more likely.''',
    keyPoints: [
      'Pocket pairs have 6 combinations; unpaired hands have 16 (4s/12o).',
      'Board cards reduce combinations by removing available cards.',
      'Blocker effects reduce combinations of blocked hands (e.g., holding an Ace).',
      'Use combination counting to weight ranges and assess bluff-to-value ratios.',
      'Suited combos = 4; off-suit = 12 for any specific two-card combination.',
    ],
  ),
  PokerConcept(
    id: 'm04',
    title: 'ICM: Independent Chip Model',
    category: ConceptCategory.math,
    difficulty: 3,
    summary:
        'ICM converts chip stacks into monetary equity, showing that chips have diminishing marginal value in tournament pay structures.',
    body: '''In cash games, chips have a direct dollar value. In tournaments, a chip\'s monetary worth depends on the payout structure. The Independent Chip Model (ICM) calculates each player\'s monetary equity by estimating their probability of finishing in each paid position.

The key insight of ICM: doubling your chip stack in a tournament does not double your prize equity. If you have 50% of the chips in a winner-take-all event, you should win 50% of the prize pool. But in a typical top-3 payout, having 50% of the chips gives you far less than 50% of the prize pool, because your opponents can still win second and third place.

This creates what is called an "ICM tax" — the premium for chip preservation near the money. This means calling off your stack as a slight chip-EV favourite is often an ICM mistake, because survival has positive monetary EV you\'re giving up.

Practical consequences: near the bubble, tight players can be exploited by the chip leader who can bust anyone else profitably. The chip leader should steal aggressively since they risk minimal ICM while applying maximum ICM pressure on shorter stacks. Short stacks should shove wide, not fold-and-wait, as their ICM per chip deteriorates rapidly.

Understanding ICM transforms your tournament strategy from "maximise chip EV" to "maximise dollar EV" — a critical distinction.''',
    keyPoints: [
      'ICM converts chip stacks to dollar equity based on payout structures.',
      'Doubling chips in a tournament never doubles prize equity due to ICM.',
      'ICM tax means preservation near the money is worth calling less often.',
      'Chip leaders should steal aggressively near the bubble.',
      'Short stacks should shove wide — waiting worsens ICM equity per chip.',
    ],
  ),
  PokerConcept(
    id: 'm05',
    title: 'Calculating Bluff Break-Even Percentages',
    category: ConceptCategory.math,
    difficulty: 2,
    summary:
        'A bluff is profitable whenever your opponent folds more often than the fraction of the pot you risk — a simple but powerful calculation.',
    body: '''Every bluff has a break-even fold percentage: the minimum frequency at which your opponent must fold for the bluff to profit, ignoring any equity you hold. The formula is: required fold% = bet / (pot + bet).

Betting pot size: fold % = pot / (pot + pot) = 50%. You need a fold half the time. Betting half pot: fold % = 0.5 / 1.5 ≈ 33%. You only need to fold one in three times. This is why smaller bluffs are more common — they require lower fold frequency to profit.

If your bluff hand has additional equity (a draw), the required fold percentage drops further. With a 30% equity draw bluffing half pot, the bluff is profitable even if called approximately 60% of the time: bluff EV = (0.33 × pot) + (0.67 × 0.30 × pot) − (0.67 × 0.5 × pot) = +0.33pot + 0.20pot − 0.34pot = +0.19pot. You profit even when called most of the time.

Use this calculation to identify profitable bluff opportunities. A spot where opponents fold 60% to a half-pot bluff (which only needs 33% folds) is an enormous leak to exploit. Conversely, a spot where opponents fold only 20% to a pot-sized bluff (needing 50%) is a clear bluff-to-fold situation.

Track your bluff success rates and compare them to break-even percentages to identify your most and least profitable bluffing spots.''',
    keyPoints: [
      'Break-even fold% = bet ÷ (pot + bet).',
      'Pot-sized bet needs 50% folds; half-pot bet needs only 33%.',
      'Equity backup (draws) reduces the required fold% dramatically.',
      'Identify bluffing spots by comparing opponent fold rates to break-even.',
      'Small bets require lower fold rates — often more profitable for pure bluffs.',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Psychology (3)
// ─────────────────────────────────────────────────────────────────────────────

const _psychology = <PokerConcept>[
  PokerConcept(
    id: 'ps01',
    title: 'Tilt: Recognition and Recovery',
    category: ConceptCategory.psychology,
    difficulty: 1,
    summary:
        'Tilt is emotional decision-making that directly costs money; recognising your tilt triggers is the first step to controlling it.',
    body: '''Tilt is a state of emotionally compromised decision-making triggered by bad outcomes, bad luck, or perceived injustice at the table. When on tilt, players make far larger bets, call with weaker hands, bluff in bad spots, and generally abandon the disciplined strategy that makes them winners.

Every poker player tilts. The difference between professionals and recreational players is not the absence of tilt emotions but the ability to recognise and manage them. There are multiple types of tilt: loss tilt (playing badly after a big loss), win-tilt (overconfidence after winning), injustice-tilt (steaming after a bad beat), and boredom-tilt (playing too many hands out of restlessness).

Recognition is the critical first skill. Identify your personal tilt signals: heart rate increasing, thoughts about getting even, taking shortcuts in decision-making, feeling impatient for action. Once you recognise these signals in the moment, you can implement coping strategies.

Common tilt management strategies include: taking a mandatory break after a big loss; practising pre-session mental rituals; setting a stop-loss limit (quit at -3 buy-ins regardless); reviewing the mathematical expectation of your decisions rather than results; using deep-breathing techniques between hands. The goal is not to feel nothing — it is to prevent emotional state from influencing decision-making.''',
    keyPoints: [
      'Tilt is emotionally compromised decision-making that costs real money.',
      'Common types: loss tilt, win tilt, injustice tilt, boredom tilt.',
      'Learn your personal tilt signals: heart rate, thoughts, impatience.',
      'Set a stop-loss limit (e.g., -3 buy-ins) and enforce it without exception.',
      'Focus on decision quality (EV), not results, to reduce tilt triggers.',
    ],
  ),
  PokerConcept(
    id: 'ps02',
    title: 'Reading Physical and Behavioural Tells',
    category: ConceptCategory.psychology,
    difficulty: 2,
    summary:
        'Tells are unconscious behavioural signals that reveal hand strength; they\'re more reliable in live games and less relevant online.',
    body: '''A tell is any unconscious or habitual behaviour that provides information about a player\'s hand strength. In live poker, tells are an important supplementary information source — though they should never override strong mathematical reasoning.

The most reliable tells are behavioural consistencies: players who bet strong hands quickly and weak hands slowly (or vice versa); players who act relaxed and chatty with strong hands but tense and quiet with bluffs; players who look away from the board when they have hit it strongly (to appear uninterested).

Classic physical tells include: trembling hands (almost always a very strong hand — the adrenaline response is involuntary); staring at chips after seeing a flop (sizing up a bet — usually a strong hand); exaggerated sighs or expressions of disappointment (often strength — they are trying to induce a call or raise).

Online tells are more subtle: bet timing (fast bets often mean weakness or strong draws; long pauses before a large bet can mean a big hand or a carefully constructed bluff), sizing patterns (players often use different sizings for bluffs vs. value), and frequency patterns (how often do they C-bet? 3-bet? fold to raises?).

Do not over-rely on tells. A single tell should shift your estimate of their range probability by 5–15% at most. Never deviate dramatically from mathematical correct play based on a single observed behaviour.''',
    keyPoints: [
      'Trembling hands are almost always a sign of extreme strength.',
      'Staring at chips after the flop typically indicates a strong hand.',
      'Exaggerated disappointment (sighs) is often a reverse tell — they\'re strong.',
      'Online: use timing patterns, sizing tells, and frequency statistics.',
      'Tells shift range estimates by 5–15%; never override math completely.',
    ],
  ),
  PokerConcept(
    id: 'ps03',
    title: 'The Long Game: Variance and Mindset',
    category: ConceptCategory.psychology,
    difficulty: 1,
    summary:
        'Accepting variance as inherent to poker and evaluating your performance on decision quality rather than results is the foundation of long-term success.',
    body: '''Poker variance is the mathematical fact that even perfectly played hands lose a significant fraction of the time. A player who gets all their chips in with 80% equity will lose one in five times — and variance means they may lose five in a row in a single unlucky session.

The most common psychological mistake is results-oriented thinking: judging decisions as good or bad based on whether they won. This leads to "results tilt" — reinforcing bad decisions when they happen to win and abandoning good decisions when they happen to lose. Over time this creates a fragmented, inconsistent strategy that is easily exploited.

The correct framework is process-oriented thinking: judge every decision on whether it was the highest-EV action given the information available at the time. A perfect bluff that gets called by an opponent making a terrible call is still a good bluff. A loose call that happens to be correct because your opponent had air is still a bad call.

Building this mindset requires: studying hand history after sessions (not during, when you\'re emotional); maintaining session notes focused on decisions rather than results; reading or reviewing coaching content regularly to reinforce the right frameworks; and seeking honest feedback from peers.

Accepting variance doesn\'t mean being passive about improvement. But it does mean recognising that over fewer than 10,000 hands, your results are largely noise. Your true win rate emerges in the long run.''',
    keyPoints: [
      'Variance means correct plays lose frequently in the short term — accept this.',
      'Avoid results-oriented thinking; judge decisions on EV, not outcomes.',
      'Review hands after sessions, focused on decision quality, not luck.',
      'Seek peer feedback and coaching to build accurate self-assessment.',
      'True win rate emerges over 10,000+ hands; short-term results are noise.',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Advanced (3)
// ─────────────────────────────────────────────────────────────────────────────

const _advanced = <PokerConcept>[
  PokerConcept(
    id: 'a01',
    title: 'GTO vs. Exploitative Play',
    category: ConceptCategory.advanced,
    difficulty: 3,
    summary:
        'GTO is an unexploitable baseline; exploitative play deviates from GTO to maximally punish specific opponent mistakes.',
    body: '''Game Theory Optimal (GTO) poker refers to a Nash Equilibrium strategy that cannot be exploited by any opponent — meaning if they deviate from their own optimal strategy, they lose money, while you do not. A perfect GTO player would be unbeatable in the long run regardless of what opponents did.

Exploitative play takes the opposite approach: identify a specific mistake your opponent makes and maximise your profit from that mistake, even at the cost of becoming exploitable yourself. For example, if an opponent folds to C-bets 70% of the time, the exploitative strategy is to C-bet with nearly 100% of your range. This deviates from GTO (which mixes checks and bets) but is far more profitable against that specific opponent.

At most real-world poker games, pure exploitation is more profitable than GTO. The reason is simple: your opponents are not playing GTO, and the deviations in their game are large. A player who folds too much to 3-bets is costing themselves enormous amounts, and the exploitative counter (3-bet aggressively) extracts that equity.

However, exploitation has a risk: a competent opponent will recognise your exploit and counter-adjust. If you 3-bet light against someone who folds to 3-bets and they adjust to 4-betting light, you\'re now in a pure bluff war that favours the deeper-thinking player. GTO protects you from being counter-exploited.

The practical strategy: use GTO as your default baseline, deviate exploitatively against confirmed tendencies, and stay alert to adjustments.''',
    keyPoints: [
      'GTO = unexploitable Nash Equilibrium strategy; provides a safe baseline.',
      'Exploitative play deviates from GTO to maximally punish opponent mistakes.',
      'Most live games reward exploitation over GTO due to large opponent errors.',
      'Risk of exploitation: a competent player will counter-adjust if you deviate.',
      'Strategy: default to GTO, deviate exploitatively against confirmed patterns.',
    ],
  ),
  PokerConcept(
    id: 'a02',
    title: 'Range Polarization and Merging',
    category: ConceptCategory.advanced,
    difficulty: 3,
    summary:
        'Polarized ranges bet with the best hands and pure bluffs; merged ranges bet with medium-strength hands for thin value in safe spots.',
    body: '''A polarized betting range consists of two extremes: very strong hands (nuts and near-nuts) and pure bluffs (air). There are no medium-strength hands in a polarized range; they are checking behind or calling. Polarized ranges call for large bet sizes because opponents who call are paying maximum price for bluff-catching, and strong hands want the maximum pot.

A merged (or "linear") betting range includes medium-strength hands alongside strong hands. The classic situation: a dry K72 rainbow board where the pre-flop raiser opens small and has range advantage. Betting top pair, second pair, and even some over-pairs all as a "value bet" against weaker ranges that missed entirely — this is a merged range strategy.

The choice between polarized and merged ranges depends on board texture and position. Dry boards with range advantage favour merged small bets (you have too many hands with thin value to leave them all unchecked). Wet boards with less range advantage favour polarized large bets (only bet when you\'re strong or have strong bluffing equity).

The danger of a merged range is getting check-raised or called by a stronger merged hand. If you bet second pair into someone else with top pair, both players are "merged" but you\'re losing. This is why merged strategies require accurate range advantage assessment.''',
    keyPoints: [
      'Polarized range: very strong hands + pure bluffs; bet large.',
      'Merged (linear) range: value hands of varying strength; bet small.',
      'Dry boards with range advantage suit merged small-bet strategies.',
      'Wet boards suit polarized large-bet strategies.',
      'Merging risks losing to stronger merged hands; requires accurate range reading.',
    ],
  ),
  PokerConcept(
    id: 'a03',
    title: 'Multi-Street Planning and Tree Navigation',
    category: ConceptCategory.advanced,
    difficulty: 3,
    summary:
        'Elite players mentally construct the full game tree before acting on the flop, planning their response to every possible turn and river card.',
    body: '''Multi-street planning is the practice of thinking three streets ahead before you make the flop decision. When you decide to C-bet the flop, you should simultaneously be asking: "What do I do on the turn if called? What turn cards are good for my range? What turn cards are bad? What river action completes my story?"

The concept comes from game tree analysis. Every flop decision starts a branch: C-bet or check. Each choice leads to more branches on the turn. A player who thinks only one street at a time will often find themselves committed to a line that doesn\'t make sense — bluffing on a bad turn card after a flop C-bet, or failing to value bet the river after a passive flop and turn.

Classic planning scenarios: Holding a semi-bluff flush draw, you C-bet the flop planning to: (a) check-fold on a bad turn if the draw misses and the board connects with calling ranges; (b) bet large on the turn if the flush completes or a good bluff card arrives; (c) give up on the river if nothing improves. This three-street plan means you never face surprise decisions.

Constructing balanced plans also means thinking about what your range looks like to your opponent across all possible runouts. If you always C-bet the flop and always give up the turn on certain card types, observant opponents can exploit that pattern.''',
    keyPoints: [
      'Plan all three streets before acting on the flop — don\'t improvise.',
      'Identify "good" and "bad" turn cards for your hand and range before betting.',
      'Construct bluff plans with natural exit points to avoid throwing chips away.',
      'Multi-street planning makes your range look balanced and hard to exploit.',
      'When plans change mid-hand, re-evaluate from scratch rather than auto-pilot.',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Public list
// ─────────────────────────────────────────────────────────────────────────────

/// All 30 poker concepts, ordered by category then by id.
const List<PokerConcept> allConcepts = [
  ..._fundamentals,
  ..._preflop,
  ..._postflop,
  ..._math,
  ..._psychology,
  ..._advanced,
];
