# PokerScanner Bluetooth Integration TODOs

The scanner hardware sends opaque raw chip IDs — it has no knowledge of card ranks or suits. The app builds the rank↔ID mapping via a one-time deck registration walk-through, stores the named deck in Firestore, and resolves raw IDs to cards at runtime during gameplay. Only the table organiser can select or change the active deck for a table.

---

- [x] when the user wants to invite people to the table present a page where all friends can be seen filtered by online and offline with a search bar at the top, also add a button to add/request new friends
- [x] i got the below error in the app, please fix the error
ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception: [cloud_firestore/not-found] Some requested document was not found.
#0      FirebaseFirestoreHostApi.documentReferenceUpdate (package:cloud_firestore_platform_interface/src/pigeon/messages.pigeon.dart:1059:7)
<asynchronous suspension>
#1      MethodChannelDocumentReference.update (package:cloud_firestore_platform_interface/src/method_channel/method_channel_document_reference.dart:55:7)
<asynchronous suspension>
#2      FirestoreService._resolveHand (package:poker_scanner/services/firestore_service.dart:389:5)
<asynchronous suspension>
#3      FirestoreService._showdown (package:poker_scanner/services/firestore_service.dart:336:7)
<asynchronous suspension>
#4      FirestoreService._advanceRound (package:poker_scanner/services/firestore_service.dart:302:9)
<asynchronous suspension>
#5      FirestoreService._advanceTurn (package:poker_scanner/services/firestore_service.dart:267:7)
<asynchronous suspension>
#6      FirestoreService.playerBet (package:poker_scanner/services/firestore_service.dart:223:5)
<asynchronous suspension>
#7      BotService._act (package:poker_sca
- [x] when i open the bluetooth menu in the lobby page again after i allready connected a scanner it does not show me that a scanner is connected and the status in the top goes from scanner active to scanner offline. can you show the device as connected when it is
- [x] when i put 2 cards on the scanner only 1 of the 2 rfid readers detects a card and when i switch the 2 cards to the other scanner the other one gets scanned.
- [x] the icon in the top of the table tab that displays how many players are in the game should be clickable and open the invite to table page
- [x] in the table setup page the host should be able to remove people/bots from the table
- [x] when opening the invitations tab i get this error
flutter: Error loading invitations: [cloud_firestore/failed-precondition] The query requires an index. You can create it here: https://console.firebase.google.com/v1/r/project/pokerscanner-96e1c/firestore/indexes?create_composite=ClZwcm9qZWN0cy9wb2tlcnNjYW5uZXItOTZlMWMvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2ludml0YXRpb25zL2luZGV4ZXMvXxABGgoKBnN0YXR1cxABGgwKCHRvVXNlcklkEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg
flutter: #0      EventChannelExtension.receiveGuardedBroadcastStream (package:_flutterfire_internals/src/exception.dart:67:43)
flutter: #1      MethodChannelQuery.snapshots.<anonymous closure> (package:cloud_firestore_platform_interface/src/method_channel/method_channel_query.dart:183:18)
- [x] the your hand section in the table tab should be more centered and i would like it to look more like the design i added here (i like the action layour in the bottom so keep that the same although make sure they are sticky to the bottom because there is a lot of empty space below the buttons now). design: /Users/rikstokmans/Claude/PokerScanner/stitch_poker_scanner

---

## History Page Overhaul

### Data model

- [x] **Create `HandActionModel`** — a new model at `lib/models/hand_action_model.dart` with fields: `playerId`, `playerName`, `actionType` (enum: fold, call, raise, check, allIn, smallBlind, bigBlind), `amount` (nullable double), `bettingRound` (preflop/flop/turn/river), `timestamp`. Serialize/deserialize with `toMap` / `fromMap`.

- [x] **Add `actions` field to `HandModel`** — embed a `List<HandActionModel>` in `HandModel`. Update `toMap`, `fromMap`, and the constructor. Existing hands without actions will default to an empty list.

- [x] **Add `favoritedBy` field to `HandModel`** — a `List<String>` of user IDs who hearted this hand. Default empty. Update `toMap` and `fromMap`.

- [x] **Add `handDurationSeconds` field to `HandModel`** — an `int?` representing how long the hand took in seconds (derived from first action to resolution). Update `toMap` and `fromMap`.

- [x] **Add `winCondition` field to `HandModel`** — a `String` enum value: `'showdown'`, `'everyone_folded'`, or `'uncontested'` (only one player). Update `toMap`, `fromMap`.

### Firestore / service layer

- [x] **Record actions in `FirestoreService`** — whenever `playerBet`, `playerFold`, `playerCheck`, or blinds are posted, append a `HandActionModel` to a running action log on the active game document (e.g. `currentHandActions` list). On hand resolution copy that list into the archived `HandModel` and clear it from the game document.

- [x] **Add `FirestoreService.toggleFavoriteHand(gameId, handId, uid)`** — toggle the user's UID in the `favoritedBy` array using Firestore `arrayUnion` / `arrayRemove`.

- [x] **Add `FirestoreService.setHandWinCondition(gameId, handId, condition)`** — write the `winCondition` string when resolving a hand (call from `_resolveHand`).

### Providers

- [x] **Add `handFavoritesProvider(handId)`** — a `StreamProvider` that streams whether the current user has favorited a specific hand (derived from `favoritedBy` field).

- [x] **Add `historyFilterProvider`** — a `StateProvider<HistoryFilter>` for tracking the active filter (all, favorites, won, showdowns).

### UI — hand card expansion

- [x] **Make `_HandCard` expandable** — convert it to an `ExpansionTile`-style widget with a smooth expand/collapse animation. The collapsed view keeps the existing summary (hand number, winner, pot, cards). The expanded view shows the action log and win condition.

- [x] **Action timeline in expanded section** — list each `HandActionModel` in chronological order, grouped by betting round (Pre-Flop / Flop / Turn / River as section headers). Show player name, action type (fold, raise €X, call, check, all-in), and the round label. Color-code actions: fold = muted grey, raise/all-in = amber, call/check = subdued white.

- [x] **Win condition banner in expanded section** — below the action log show a highlighted row: e.g. "Won at showdown with Full House" or "Won uncontested — everyone folded". If `wasShowdown` is true, show all revealed hole cards side by side.

- [x] **Hand duration chip in expanded section** — small label "⏱ 3m 42s" using `handDurationSeconds`. Only show if value is present.

### UI — heart / favorite

- [x] **Heart button on each hand card** — add an `IconButton` (Icons.favorite / Icons.favorite_border) to the top-right of each `_HandCard`. Tapping calls `toggleFavoriteHand`. Animate the transition with a brief scale pop using `AnimationController`.

- [x] **Hearted hands are highlighted** — when `favoritedBy` contains the current user, add a thin amber border or a small amber "❤" badge to the collapsed card.

### UI — filter bar

- [x] **Filter chips below the "Recent Hands" subtitle** — a horizontal scrollable row of chips: All · Favorites · My Wins · Showdowns. Tapping a chip updates `historyFilterProvider` and re-filters the list client-side.

- [x] **Apply filter in `GameHistoryScreen`** — read `historyFilterProvider` and filter the `hands` list accordingly before passing to `ListView`.

### UI — session stats bar

- [x] **Stats summary row above the hand list** — a row of 3 mini-stat tiles showing: total hands played, your net gain/loss this session (sum of potAmount won minus blinds posted), and biggest pot of the session. Pull these from the existing `activeGameHandsProvider` data without extra Firestore reads.

### Nice-to-have future features

- [ ] **Fix sharing in history tab** — `share_plus` was upgraded to v10 which removed the old `Share.share(text)` static API. Both call sites in `lib/screens/game_history_screen.dart` need to be updated to the new API: `SharePlus.instance.share(ShareParams(text: ..., subject: ...))`. Affected lines: `_exportHands` (line ~57) and the "Share hand" `GestureDetector` in `_ExpandedSection` (line ~660). Also update the import if needed (`SharePlus` and `ShareParams` come from the same `package:share_plus/share_plus.dart` import).

- [x] **Share a hand** — long-press or button in expanded view to generate a text summary of the hand ("Hand #12 · Alice won €4.20 with a Flush after a raise war on the river") and trigger the native share sheet.

- [x] **Search by player name** — a search bar that filters the hand list to only hands where a specific player participated or won.

- [x] **Stack change sparkline** — a small mini chart (using `fl_chart` or a custom painter) next to the session stats showing your stack over time across all recorded hands.

- [x] **Pagination / load more** — if a session has > 30 hands, lazy-load older hands in batches of 20 using Firestore cursor-based pagination to keep the list fast.

- [x] **Export hand history** — a button in the top-right filter menu to export all hands in the current session as a plain-text or CSV file and share it.

---

## Analysis Page Improvements

### Stats & Metrics

- [x] **Win rate % display** — add a prominent win rate percentage (wins / total hands) to the Session P&L card alongside bb/100, using the same `_MiniStat` widget.

- [x] **Showdown vs. non-showdown win rate** — add a `SessionStats` breakdown of `showdownWins` / `showdownHands` vs `nonShowdownWins` / `nonShowdownHands`. Display as two `_MiniStat`-style tiles in a new "Win Breakdown" card. Flag if non-showdown win rate is unusually high (>70%) or low (<30%).

- [x] **Biggest pots won vs. lost** — replace "Recent Winners" with a two-tab "Notable Hands" section (Won / Lost). The Losses tab shows the 3 biggest losing hands derived from `playerStacksBefore` delta or pot amount when the user did not win. Use the existing `_ErrorCard` widget with `isWin: false`.

- [x] **Hand rank frequency** — add a "Hand Strength" section showing how often you won with each `handRank` (pair, two pair, flush, etc.). Display as a scrollable row of pill/badge widgets, each showing the rank label and count, coloured by rarity.

### Leak Detection & Insights

- [x] **VPIP approximation** — compute VPIP from hands where the user's `playerStacksBefore` decreased by more than the big blind amount (indicating voluntary money in pot). Add to `SessionStats` as `vpip` (double 0–1). Display as a `_MiniStat` with a warning colour if > 0.30.

- [x] **Leak detector alerts** — add a `List<String> leakWarnings` field to `SessionStats`. Populate with rule-based alerts computed in `sessionAnalysisProvider`:
  - Lost 4+ of the last 5 hands
  - Won 0 showdowns in the last 8 showdown hands
  - Net loss from BB position exceeds 3× the big blind
  Display each warning as a red-bordered alert card below the AI Insight box (reuse the insight card style with `AppColors.error` accent).

- [x] **Upgrade AI Insight to be dynamic** — replace the hardcoded two-branch string with a multi-condition function in `SessionStats` that selects the most relevant insight based on win rate, bb/100, VPIP, and leak warnings. Return a plain `String get aiInsight`.

### Visualisation

- [x] **Stack trajectory mini-chart** — add a simple line chart below the Session P&L card showing cumulative P&L over hand number. Compute the series in `sessionAnalysisProvider` as `List<({int hand, double pnl})> stackSeries`. Use `fl_chart` (already in `pubspec.yaml` if present, otherwise add it) with a `LineChart` widget; style it to match the dark theme.

- [x] **Positional edge bar visualisation** — replace the plain text list in "Positional Edge" with a horizontal bar chart row per position. Each bar fills proportionally to the largest absolute value; positive bars use `AppColors.primary`, negative use `AppColors.error`.

### Cross-session & Opponent Data

- [x] **Opponent tendencies card** — add an "Opponents" section using `playerNames` from `activeGameHandsProvider`. For each opponent compute win rate this session and sort descending. Display as a compact list card (opponent name, wins/hands, win%). Helps identify who is running hot.

- [x] **Multi-session comparison** — use `userRecentHandsProvider` (already exists) to compute all-time average bb/100 and win rate. Show a "vs. your average" delta badge next to the current session bb/100 (`_MiniStat` subtext or small coloured arrow).

### Interactivity

- [x] **Tappable hand rank items** — make each item in the hand rank frequency row tappable; navigate to a filtered history view showing only hands of that rank.

- [x] **Wire up "Start Training Drill" button** — decide on a target screen (e.g. hand replayer or a quiz flow) and connect `GradientButton` `onPressed` to navigate there via `go_router`.

---

## Learn Page — Full Implementation

The learn page becomes a fully interactive poker training hub. It is split into four tabs: **For You** (personalised coaching from session data), **Drills** (interactive practice), **Study** (concept library), and **Progress** (XP, badges, streak). All drill results and progress are persisted in Firestore under `users/{uid}/learningProgress`.

---

### Architecture & Navigation

- [ ] **Redesign `LearnScreen` with a tab layout** — convert `lib/screens/learn_screen.dart` to a `StatefulWidget` using a `DefaultTabController` with 4 tabs: For You, Drills, Study, Progress. Each tab renders a separate child widget. Keep the "LEARN" header and school icon. Use `TabBar` with custom tab styling matching the dark theme (selected tab text uses `AppColors.primary`, indicator is a short underline in primary colour).

- [ ] **Add learn sub-routes in `lib/router.dart`** — add the following named routes as children of `/learn` (or as top-level routes without a bottom nav bar):
  - `/learn/range-trainer` → `RangeTrainerScreen`
  - `/learn/pot-odds` → `PotOddsDrillScreen`
  - `/learn/scenarios` → `ScenarioDrillScreen`
  - `/learn/board-texture` → `BoardTextureDrillScreen`
  - `/learn/hand-review` → `HandReviewQuizScreen`
  - `/learn/concept/:id` → `ConceptDetailScreen`
  All sub-routes hide the bottom navigation bar (use a `ShellRoute` or pass a `hideBottomNav` flag via extra).

---

### Feature 1: Gamification & Progress System

This is the foundation for all drills. Drill completions award XP; XP unlocks levels; streaks award bonus XP.

#### Data model

- [ ] **Create `LearningProgressModel`** at `lib/models/learning_progress_model.dart`:
  - `userId: String`
  - `xp: int` — total accumulated XP
  - `level: String` — computed from XP: Fish (0–499), Regular (500–1499), Grinder (1500–2999), Shark (3000–5999), Crusher (6000–9999), GTO Wizard (10000+)
  - `streakDays: int` — consecutive days with at least one drill completed
  - `lastDrillDate: DateTime?` — date of most recent drill; used to compute streak continuation
  - `earnedBadges: List<String>` — badge IDs (e.g. `'range_master'`, `'pot_odds_pro'`, `'study_streak_7'`)
  - `drillStats: Map<String, DrillStat>` — keyed by drill ID; value is a `DrillStat` with fields `attempts: int`, `correct: int`, `bestStreak: int`
  - `conceptsRead: List<String>` — concept IDs the user has marked as read
  - Include `toMap()` / `fromMap()` for Firestore, and a `static LearningProgressModel empty(String userId)` factory.
  - Add a `DrillStat` value-class in the same file with `attempts`, `correct`, `bestStreak`, `toMap()`, `fromMap()`.

#### Service

- [ ] **Create `LearningService`** at `lib/services/learning_service.dart`:
  - `static Future<LearningProgressModel> getProgress(String userId)` — load from `users/{userId}/learningProgress/main` (single document). Return `LearningProgressModel.empty(userId)` if not found.
  - `static Future<void> saveProgress(LearningProgressModel progress)` — upsert the document at the same path.
  - `static Stream<LearningProgressModel> streamProgress(String userId)` — live stream of the document.
  - `static Future<void> recordDrillResult({required String userId, required String drillId, required bool correct})` — increment `drillStats[drillId].attempts`, optionally increment `correct`, update streak (if `lastDrillDate` is yesterday or today, continue/maintain streak; otherwise reset to 1), add XP (correct answer = +10 XP, attempt = +2 XP regardless), update `lastDrillDate` to today, recompute `level` from XP thresholds. Write back to Firestore using a transaction to avoid race conditions.
  - `static Future<void> markConceptRead(String userId, String conceptId)` — add `conceptId` to `conceptsRead` using `arrayUnion`, award +5 XP.
  - `static Future<void> awardBadge(String userId, String badgeId)` — add to `earnedBadges` using `arrayUnion` if not already present. Called from drill/study logic when badge conditions are met.
  - Badge unlock conditions to check inside `recordDrillResult` / `markConceptRead`:
    - `'first_drill'` — first ever drill attempt
    - `'pot_odds_pro'` — 20 correct pot-odds answers
    - `'range_master'` — 10 range trainer sessions completed
    - `'study_streak_7'` — streakDays reaches 7
    - `'study_streak_30'` — streakDays reaches 30
    - `'concept_graduate'` — 20 concepts marked as read
    - `'scenario_shark'` — 50 correct scenario drill answers

#### Providers

- [ ] **Add `learningProgressProvider`** in `lib/providers/providers.dart` — a `StreamProvider<LearningProgressModel>` that watches `currentUserProvider` and calls `LearningService.streamProgress(user.id)`. Fall back to `LearningProgressModel.empty(user.id)` on loading/error.

---

### Feature 2: Learn Screen – For You Tab

Personalised coaching tab that surfaces the most relevant content based on the user's current session data and learning history.

- [ ] **Create `_ForYouTab` widget** inside `lib/screens/learn_screen.dart` (or extract to `lib/screens/learn/for_you_tab.dart`). It is a `ConsumerWidget` that reads `sessionAnalysisProvider`, `learningProgressProvider`, and `currentUserProvider`.

- [ ] **Level & XP banner** — at the top of the For You tab show a card with the user's current level name (e.g. "Grinder") and a linear progress bar filling from current XP to next level threshold. Show numeric XP (e.g. "1,842 / 3,000 XP"). Use `LinearProgressIndicator` with `AppColors.primary` fill on a dark track.

- [ ] **Daily streak chip** — next to the level banner show a small chip: flame icon + "5 day streak" in amber if streak > 0, or "Start your streak today" in muted text if streak is 0. Chip uses `AppColors.primary.withOpacity(0.15)` background.

- [ ] **Personalised drill recommendations** — read `sessionAnalysisProvider.leakWarnings` and map each leak to a recommended drill:
  - `'Lost 4+ of last 5 hands'` → recommend **Decision Scenarios** drill with label "Fix Your Tilt Spots"
  - `'Won 0 showdowns in last 8 hands'` → recommend **Hand Strength Quiz** (use Hand Review drill) with label "Improve Your Showdown Hands"
  - `'Net loss from BB position'` → recommend **Scenario Drill** filtered to BB defense category with label "Master Big Blind Defense"
  - If no leaks: recommend the drill with the lowest accuracy in `drillStats`, or **Range Trainer** if no history exists.
  Show 1–3 recommendation cards, each with drill name, description, estimated time ("~5 min"), and a `GradientButton` "Start" that navigates to the drill screen via `context.go(...)`.

- [ ] **Session insight card** — if `sessionAnalysisProvider` has data, show the `aiInsight` string in a card styled identically to the existing AI Mistake Analysis card (green-tinted border, brain/lightbulb icon). If no session is active, show a placeholder: "Play a session to get personalised insights."

- [ ] **Resume last drill card** — read `learningProgressProvider.drillStats`. Find the drill with the most recent activity (use a `lastAttemptDate` field to be added to `DrillStat`; add `lastAttemptDate: DateTime?` to `DrillStat` and update in `recordDrillResult`). Show a "Continue" card for that drill with its accuracy % and a "Resume" button.

---

### Feature 3: Preflop Range Trainer

A 13×13 hand matrix drill where the user selects which hands to open/3-bet from a given position and gets scored against embedded GTO ranges.

#### Data

- [ ] **Create `lib/data/gto_ranges.dart`** — a Dart file exporting a `const Map<String, Map<String, Set<String>>> gtoRanges` structured as `position → scenario → Set<handCode>`. Hand codes are two-character strings: rank1 + rank2 + 's'/'o' for suited/offsuit, or rank + rank for pairs (e.g. `'AKs'`, `'AKo'`, `'AA'`). Positions: `'UTG'`, `'MP'`, `'CO'`, `'BTN'`, `'SB'`, `'BB'`. Scenarios: `'open'`, `'3bet'`, `'call'`.
  Embed accurate 6-max GTO opening ranges:
  - **BTN open**: all pairs, AXs, KQs–K9s, QJs–QTs, JTs, T9s, 98s, 87s, 76s, 65s, AKo–ATo, KQo–KJo, QJo, JTo — approximately 45% of hands
  - **CO open**: tighter — pairs 22+, AXs, KJs+, QJs, JTs, T9s, 98s, AKo–AJo, KQo–KJo — approximately 30% of hands
  - **MP open**: tighter — pairs 44+, AJs+, KQs, AKo–AQo, KQo — approximately 20%
  - **UTG open**: tight — pairs 77+, AQs+, KQs, AKo — approximately 13%
  - **SB open**: similar to BTN (wide), adjusted for being OOP post
  - **BB**: no open (can only 3-bet or call)
  Include 3-bet ranges for each position (approximately 8–12% of the open range).

- [ ] **Create `lib/models/poker_range.dart`** — a `PokerRange` class wrapping a `Set<String>` of hand codes. Add:
  - `bool contains(String handCode)` — check if a hand is in the range
  - `static List<String> allHands` — all 169 unique hand codes in standard order (AA, AKs, AKo … 22)
  - `static String handCode(String rank1, String rank2, bool suited)` — helper to build a hand code string
  - `double get size` — number of combos in the range (pairs = 6 combos, suited = 4, offsuit = 12)
  - `double get percentage` — size as % of 1326 total starting hand combos

#### Screen

- [ ] **Create `lib/screens/learn/range_trainer_screen.dart`** as a `StatefulWidget`:
  - **Position selector**: horizontal row of 6 pill buttons (UTG, MP, CO, BTN, SB, BB). Selected position stored in local `_position` state.
  - **Scenario selector**: below position, 3 toggle buttons: Open / 3-Bet / Call vs Open. Selected scenario stored in `_scenario` state.
  - **Hand grid**: 13×13 `GridView` where rows/columns represent ranks in order A K Q J T 9 8 7 6 5 4 3 2. Each cell shows the 2-letter hand code (e.g. "AKs", "AKo", "AA"). Cells above the diagonal = suited hands, below = offsuit, diagonal = pairs. Cell colours: default = `AppColors.surfaceContainer`; user-selected = amber with 60% opacity; GTO-correct selection = `AppColors.primary` with 70% opacity; GTO-missed = red with 40% opacity (only shown after "Check" is pressed). Tapping a cell toggles selection.
  - **Action bar**: a sticky bottom bar with two buttons: "Check" (compare selection to GTO range and show score) and "Reset" (clear selection). After checking, show per-cell colouring and a score card: "You matched X% of the correct range — Y hands correct, Z missed, W false positives."
  - **Score card**: after checking, show a summary card with the score %, a brief tip (e.g. "You're opening too wide from UTG — tighten to 77+ and AQs+"), and a `GradientButton` "Next Position" that moves to the next position with lowest historical accuracy from `learningProgressProvider`.
  - On "Check", call `LearningService.recordDrillResult(drillId: 'range_trainer_${position}_${scenario}', correct: score > 70%)`.
  - The screen's `AppBar` shows "Range Trainer" with a back arrow.

---

### Feature 4: Pot Odds & EV Calculator Drill

An interactive math training drill that presents randomised hand scenarios and asks the player to make mathematically correct decisions.

#### Logic

- [ ] **Create `lib/data/pot_odds_scenarios.dart`** — a `PotOddsScenario` class with fields: `pot: double`, `betSize: double`, `equityPercent: double`, `description: String`, `correctAction: String` (either `'call'` or `'fold'`), `explanation: String`. The `correctAction` is `'call'` when `equityPercent > betSize / (pot + betSize + betSize) * 100` (i.e. equity > pot odds needed). Include a `PotOddsScenarioGenerator` class with a `static PotOddsScenario generate()` method that creates random scenarios:
  - Random pot sizes: 10–200 (round to nearest 5)
  - Random bet: 20–150% of pot (round to nearest 5)
  - Random draw type: flush draw (36%), open-ended straight draw (32%), gutshot (16%), two overcards (24%), combo draw (54%) — pick one randomly and set `equityPercent` accordingly
  - Set `description` to a natural language string: "The pot is $\{pot\}. Villain bets $\{bet\}. You hold a flush draw (36% to hit by the river)."
  - Set `explanation` to show the math: "Pot odds: you need \{needed\}% equity to call. You have \{equityPercent\}%, so \{call/fold\} is correct."

#### Screen

- [ ] **Create `lib/screens/learn/pot_odds_drill_screen.dart`** as a `StatefulWidget`:
  - **Header**: "Pot Odds" title, current question number / streak ("Question 7 · Streak: 3").
  - **Scenario card**: show the `description` text in a large readable card (Manrope 18px). Below it, show three key numbers in `_MiniStat`-style tiles: Pot size, Bet size, Your equity %.
  - **Decision buttons**: two large buttons: "CALL" (green) and "FOLD" (red), built as `ElevatedButton` widgets with appropriate colours from `AppColors`.
  - **Feedback overlay**: after tapping, show an inline feedback section below the buttons (do NOT navigate away). If correct: green tick icon + "Correct!" + `explanation`. If wrong: red X icon + "Incorrect" + `explanation`. Show the math: "Pot odds required: X%. Your equity: Y%. \{Call/Fold\} is correct."
  - **Next button**: appears after answer, labeled "Next Scenario →". Generates a new scenario via `PotOddsScenarioGenerator.generate()` and resets state.
  - **Difficulty toggle**: a segmented control at the top (Easy / Medium / Hard). Easy uses obvious spots (equity clearly > or < needed by 10%+). Hard uses close spots within 5% of breakeven. Adjust generation range accordingly.
  - On each answer, call `LearningService.recordDrillResult(drillId: 'pot_odds', correct: wasCorrect)`.
  - Show a session summary card after every 10 questions: "Session complete: 8/10 correct (80%)".

---

### Feature 5: Decision Scenario Drills

Curated hand situations across preflop and postflop streets with multiple-choice answers and GTO-grounded explanations.

#### Data

- [ ] **Create `lib/data/drill_scenarios.dart`** — define a `DrillScenario` class with fields: `id: String`, `category: ScenarioCategory` (enum: preflop, flopCbet, turnBarrel, riverSpot, bbDefense, bluffCatch), `title: String`, `situation: String` (full hand description, e.g. "UTG raises 3bb. You are on the BTN with A♥K♣. Action is on you."), `options: List<String>` (4 choices), `correctIndex: int`, `explanation: String`, `difficulty: int` (1–3). Include at minimum 60 curated scenarios spread across all categories:
  - **Preflop (15 scenarios)**: standard open/fold/3-bet decisions from each position
  - **BB Defense (10 scenarios)**: call/fold/3-bet decisions from the BB vs various open sizes
  - **Flop C-Bet (12 scenarios)**: bet or check on various boards with various hands (value, bluff, give-up)
  - **Turn Barrel (10 scenarios)**: continue or give up barreling on turns
  - **River Spot (8 scenarios)**: value bet, bluff, or check on rivers; bluff-catch situations
  - **Bluff Catch (5 scenarios)**: call/fold decisions against suspected bluffs on rivers

#### Screen

- [ ] **Create `lib/screens/learn/scenario_drill_screen.dart`** as a `StatefulWidget`:
  - **Category filter**: a horizontal scrollable `FilterChip` row at the top: All / Preflop / BB Defense / Flop / Turn / River / Bluff Catch. Filtering updates `_filteredScenarios` list.
  - **Progress indicator**: "Question 3 of 12" using a `LinearProgressIndicator` showing position in current filtered list.
  - **Scenario card**: full situation text (Manrope 16px). Below it show community cards if relevant as `CardModel` widgets (reuse existing card rendering from poker table screen).
  - **Option buttons**: 4 vertically stacked `OutlinedButton` widgets with the option text. After tapping: correct option gets a green fill, wrong option gets red, others remain neutral. Show a lock so user cannot change answer.
  - **Explanation panel**: slides in from bottom after selection (use `AnimatedContainer`). Shows correct answer label, then `explanation` text, then "Continue →" button.
  - **Session summary**: after completing all scenarios in the filter, show a results card: "Preflop: 9/12 correct (75%) — Your weakest category was River Spots (2/4). Recommended: review 'Polarization & River Betting' in Study."
  - On each answer: `LearningService.recordDrillResult(drillId: 'scenarios_${category.name}', correct: wasCorrect)`.

---

### Feature 6: Board Texture Trainer

Trains players to quickly read postflop board textures and understand who has the range advantage, what draws exist, and what c-bet strategy to apply.

#### Data

- [ ] **Create `lib/data/board_texture_data.dart`** — define a `BoardQuestion` class with fields: `id: String`, `cards: List<String>` (3-card flop as card codes, e.g. `['Kh', '7c', '2d']`), `questions: List<BoardSubQuestion>`, where `BoardSubQuestion` has: `question: String`, `options: List<String>`, `correctIndex: int`, `explanation: String`. Include at least 30 flops covering: dry paired boards (Kxx paired), dry unconnected boards (K72 rainbow), wet connected boards (JT9, 987 two-tone), monotone boards, ace-high boards, low connected boards. Each flop has 3 sub-questions covering: texture classification (wet/dry/semi-wet), range advantage (preflop raiser / caller / neutral), and optimal c-bet size (33% / 50% / 75% / overbet / check).

#### Screen

- [ ] **Create `lib/screens/learn/board_texture_screen.dart`** as a `StatefulWidget`:
  - **Board display**: render the 3 flop cards in a horizontal row using card widgets (same style as poker table screen's community cards). Use `CardModel` to parse the string codes.
  - **Question carousel**: one sub-question at a time. Show question text, then 3–4 `OutlinedButton` options.
  - After selecting an option: highlight correct/wrong, show explanation in an `AnimatedContainer` that slides down.
  - "Next Question →" advances to the next sub-question; after the 3rd, shows "New Board →" which picks the next board from the shuffled list.
  - **Score bar**: persistent at the top showing current session accuracy (e.g. "7/9 correct").
  - On each answer: `LearningService.recordDrillResult(drillId: 'board_texture', correct: wasCorrect)`.

---

### Feature 7: Hand History Review Quiz

Uses the player's own recorded hands (from Firebase) to create personalised quizzes. Picks key decision points from real hands and asks "what would you do?"

#### Logic

- [ ] **Create `lib/services/hand_review_service.dart`** — a service that extracts quiz questions from real `HandModel` data:
  - `static List<HandReviewQuestion> extractQuestions(List<HandModel> hands, String userId)` — iterate through hands, find hands where the userId was present (check `playerCards[userId]` is not null) and had meaningful decisions (hand has at least 3 `actions`, pot > bigBlind * 4). For each qualifying hand, identify the most interesting decision point: the action immediately before a large bet or raise (amount > 50% pot). Return up to 20 `HandReviewQuestion` objects.
  - `HandReviewQuestion` class (define in this file or in `lib/models/`): `handId: String`, `handNumber: int`, `holeCards: List<CardModel>`, `communityCards: List<CardModel>` (cards shown up to that decision street), `pot: double`, `betToCall: double`, `description: String` (narrative of the situation), `whatPlayerDid: String` (the actual action they took), `correctAction: String` (heuristic: if player won hand and took this action = correct; if player lost and folded early = possibly a mistake), `explanation: String`.

- [ ] **Add `userRecentHandsForReviewProvider`** in `lib/providers/providers.dart` — a `FutureProvider<List<HandModel>>` that loads the user's 50 most recent hands across all games using `FirestoreService.getUserRecentHands(userId, limit: 50)`. Add `getUserRecentHands(String userId, {int limit = 50})` to `FirestoreService` if it doesn't already exist (it may; check `userRecentHandsProvider` implementation).

#### Screen

- [ ] **Create `lib/screens/learn/hand_review_screen.dart`** as a `ConsumerStatefulWidget`:
  - On load, read `userRecentHandsForReviewProvider`, pass hands + userId to `HandReviewService.extractQuestions()`, store result in `_questions` list.
  - **Loading state**: show a `CircularProgressIndicator` with text "Analysing your hands…".
  - **Empty state**: if fewer than 5 qualifying hands found, show "Play more hands to unlock personalised reviews — you need at least 5 hands with action data."
  - **Question card**: show narrative description, hole cards (2 card widgets), community cards (3 card widgets), pot and bet-to-call in `_MiniStat` tiles. Below: 3 action buttons: "Fold", "Call", "Raise".
  - **Reveal**: after choosing, show what the player actually did, whether the outcome was good, and the `explanation`.
  - **Navigation**: "Next Hand →" button; show total reviewed / total available ("3 of 12 hands reviewed").
  - On each answer: `LearningService.recordDrillResult(drillId: 'hand_review', correct: wasCorrect)`.

---

### Feature 8: Concept Library (Study Tab)

A searchable, categorised library of poker concepts. Each concept has a card in the list and a detail screen with full explanation. Reading a concept awards XP.

#### Data

- [ ] **Create `lib/data/concept_library.dart`** — define a `PokerConcept` class with fields: `id: String`, `title: String`, `category: ConceptCategory` (enum: fundamentals, preflop, postflop, math, psychology, advanced), `summary: String` (1–2 sentences for list card), `body: String` (full explanation, 150–400 words), `keyPoints: List<String>` (3–5 bullet points), `difficulty: int` (1–3). Include at minimum 30 concepts:
  - **Fundamentals (6)**: Position, Pot Odds, Implied Odds, Hand Rankings, VPIP & PFR, Bankroll Management
  - **Preflop (6)**: Opening Ranges by Position, 3-Bet Ranges, 4-Bet Bluffing, Blind Stealing, Squeeze Play, Limping vs Raising
  - **Postflop (7)**: C-Bet Strategy, Board Texture, Barreling (Double & Triple), Check-Raise, Donk Betting, Protection Bets, Thin Value Betting
  - **Math (5)**: EV Calculation, Combinatorics & Blockers, Minimum Defence Frequency (MDF), Break-Even Percentage, ICM (tournament)
  - **Psychology (3)**: Tilt Control, Table Image, Reading Timing Tells
  - **Advanced (3)**: GTO vs Exploitative, Range Advantage, Polarisation & Merged Ranges
  Write realistic, accurate content for each concept body. The `body` field is a plain multi-line string with no HTML.

#### Screen — Concept List

- [ ] **Create `_StudyTab` widget** in the learn screen (or `lib/screens/learn/study_tab.dart`) as a `ConsumerWidget`:
  - **Search bar**: a `TextField` with search icon that filters concepts by title or summary text. Update a local `_query` state variable.
  - **Category filter**: horizontally scrollable `FilterChip` row: All / Fundamentals / Preflop / Postflop / Math / Psychology / Advanced.
  - **Concept list**: a `ListView` of `_ConceptCard` widgets. Each card shows: category colour-coded left border, concept title (Manrope 15px bold), summary (Inter 13px muted), difficulty dots (1–3 filled circles), and a green checkmark icon if `conceptsRead` contains this concept's id.
  - **Section headers**: group concepts by category with a sticky section header (category name in caps, small, muted).

#### Screen — Concept Detail

- [ ] **Create `lib/screens/learn/concept_detail_screen.dart`** as a `ConsumerStatefulWidget`:
  - Receives a `PokerConcept` (or concept `id`) as a constructor parameter.
  - **Header**: concept title (Manrope 24px), category chip (coloured), difficulty dots.
  - **Body text**: `SelectableText` widget with Inter 15px, line height 1.6, good paragraph spacing.
  - **Key Points section**: a column of bullet points each prefixed with a primary-colour dot.
  - **Mark as Read button**: a `GradientButton` at the bottom. On tap, call `LearningService.markConceptRead(userId, concept.id)`. If already read, show "Read ✓" in a muted style instead. After marking read, show a snackbar "+5 XP — concept mastered!"
  - Navigate here from the concept list via `context.go('/learn/concept/${concept.id}')`.

---

### Feature 9: Progress Tab

Visual dashboard showing the user's learning journey, XP, badges, and skill breakdown.

- [ ] **Create `_ProgressTab` widget** in the learn screen (or `lib/screens/learn/progress_tab.dart`) as a `ConsumerWidget` reading `learningProgressProvider`:

- [ ] **Level card** — a prominent card at the top showing: level name in large Manrope bold, XP progress bar (current / next threshold), numeric XP. Use a gradient border matching the level tier (green for all levels, could use different shades as a nice touch).

- [ ] **Streak display** — a row with a flame icon, streak count in large text ("12"), and label "day streak". If streak is 0, show "Start your streak — complete a drill today." Below: a 7-day calendar row (Mon–Sun) with filled circles for days where `lastDrillDate` falls within the past week; grey circles for days with no activity.

- [ ] **Skill breakdown chart** — a vertical list of skill categories, each with a label and a `LinearProgressIndicator` showing accuracy in that drill category. Compute accuracy as `drillStats[drillId].correct / drillStats[drillId].attempts` for all drill IDs in that category. Categories: Preflop Ranges, Pot Odds, Decision Making, Board Texture, Hand Reading. Show "No data yet" in muted text for categories with 0 attempts.

- [ ] **Badges section** — a `Wrap` of badge chips. Each badge has an icon, a name, and a description (shown in a `Tooltip` or bottom sheet on long press). Earned badges are bright; unearned badges are greyed out with a lock icon. Show all possible badges so users know what to unlock. Badge list:
  - First Drill (play icon) — Complete your first drill
  - Pot Odds Pro (calculator icon) — 20 correct pot odds answers
  - Range Master (grid icon) — 10 range trainer sessions
  - Study Streak 7 (flame icon) — 7-day study streak
  - Study Streak 30 (fire icon) — 30-day study streak
  - Concept Graduate (book icon) — Read 20 concepts
  - Scenario Shark (cards icon) — 50 correct scenario answers

- [ ] **Recent activity feed** — a short list (last 5 entries) of recent XP events: "Completed Pot Odds Drill +10 XP", "Read 'C-Bet Strategy' +5 XP". Store these as a `List<Map>` in the Firestore learning progress document: `recentActivity: [{type, label, xp, timestamp}]`. Append to this list in `LearningService.recordDrillResult` and `markConceptRead`, keeping only the last 20 entries.

---

### Feature 10: Drills Tab (Drill Hub)

A catalogue of all available drills with description, current accuracy, and time estimate.

- [ ] **Create `_DrillsTab` widget** in the learn screen (or `lib/screens/learn/drills_tab.dart`) as a `ConsumerWidget` reading `learningProgressProvider`:

- [ ] **Drill cards** — display 5 drill cards in a `ListView`. Each `_DrillCard` widget shows:
  - Drill name (Manrope 16px bold)
  - Short description (Inter 13px, 2 lines)
  - Estimated time (e.g. "~5 min")
  - Accuracy badge: if `drillStats` contains this drill's data, show "XX% accuracy" in a coloured chip (green ≥70%, amber 50–70%, red <50%). Otherwise show "Not started" in muted text.
  - A right-arrow `IconButton` that navigates to the drill screen.
  Drills: Range Trainer (`/learn/range-trainer`), Pot Odds (`/learn/pot-odds`), Scenarios (`/learn/scenarios`), Board Texture (`/learn/board-texture`), Hand Review (`/learn/hand-review`).

- [ ] **Daily recommended drill** — a highlighted card at the top of the Drills tab (above the catalogue). Labelled "Today's Focus". Pick the drill with the lowest accuracy from `drillStats`, or `scenarios` if no data. Show it with a primary-colour gradient border and a "Start Now" `GradientButton`.

---

## System-Wide XP & Level System

XP is earned from two sources: learning activities in the Learn page, and good decisions made during real poker hands. After each hand (or at session end), the app evaluates the player's choices and surfaces an XP summary. Levels are shared across both sources — the `LearningProgressModel` is the single source of truth.

---

### Feature 11: In-Game Decision Evaluation & Post-Hand XP

After each hand resolves, the app silently scores the player's key decisions and stores XP events. The player sees a summary at the end of the session (not hand-by-hand, to avoid disrupting flow).

#### Decision evaluation logic

- [ ] **Create `lib/services/decision_evaluator.dart`** — a pure Dart class `DecisionEvaluator` with a static method `static List<XpEvent> evaluateHand(HandModel hand, String userId, double bigBlind)`. It returns a list of `XpEvent` objects (define `XpEvent` in the same file: `label: String`, `xp: int`, `isPositive: bool`). The evaluation rules are heuristics based on available `HandActionModel` data:

  **Preflop decisions (+XP for good choices):**
  - Player raised preflop and won without a showdown (opponent folded): `+8 XP` — "Successful preflop steal"
  - Player 3-bet preflop (detected: second raise in preflop actions) and won the pot: `+10 XP` — "3-bet paid off"
  - Player folded preflop after a 3-bet (detected: player raised, then faced a re-raise, then folded): `+5 XP` — "Disciplined fold vs 3-bet" (folding when 3-bet OOP is often correct)
  - Player limped preflop (posted non-blind call of exactly bigBlind before any raise): `0 XP` (no penalty, but flag as a neutral/weak line for the session summary note)

  **Postflop decisions (+XP for good choices):**
  - Player was the preflop raiser and made a c-bet on the flop (placed a bet on flop street as the last preflop raiser): `+5 XP` — "C-bet executed" (reward the aggression, not the outcome)
  - Player won at showdown with top pair or better (use `HandEvaluator` to evaluate the winning hand from `hand.playerCards[userId]` + `hand.communityCards`): `+8 XP` — "Value bet rewarded"
  - Player check-raised on any street (check followed immediately by a raise in the same street in `actions`): `+10 XP` — "Check-raise executed"
  - Player bet the river with a strong hand (top two pair or better, won at showdown): `+12 XP` — "River value bet"

  **Session-level milestones (computed at session end, not per-hand — call from session summary):**
  - Session VPIP was between 15% and 30%: `+15 XP` — "Disciplined preflop ranges"
  - Positive bb/100 for the session (bb/100 > 0): `+20 XP` — "Profitable session"
  - Won 2+ showdowns in the session: `+10 XP` — "Showdown winner"
  - No tilt detected (did not lose 4+ consecutive hands): `+10 XP` — "Stayed composed"

- [ ] **Attach evaluation to hand resolution in `FirestoreService`** — after writing the archived `HandModel` in `_resolveHand`, call `DecisionEvaluator.evaluateHand(hand, winnerId, game.bigBlind)` and append the resulting `XpEvent` list to a `pendingXpEvents` field on the game document (`List<Map>` with keys: userId, label, xp, isPositive, handNumber). This accumulates all XP events for the session without awarding them immediately.

- [ ] **Add `pendingXpEvents` field to `GameModel`** — add `pendingXpEvents: List<Map<String, dynamic>>` (defaults to empty list) to `GameModel`. Serialize/deserialize in `toMap` / `fromMap`. The field is appended to (not overwritten) after each hand.

#### Post-session XP summary screen / sheet

- [ ] **Create `lib/screens/learn/session_xp_summary_sheet.dart`** — a `DraggableScrollableSheet` (bottom sheet) that shows the XP earned in the just-completed session. It is shown by navigating to the Analysis tab or tapping a prompt in the lobby after a game ends.

  Display sections:
  - **Header**: "Session Complete — You earned X XP" in Manrope 22px with a star icon
  - **XP event list**: each `XpEvent` as a row: `isPositive ? AppColors.primary : AppColors.error` icon (thumb up / thumb down), label text, `+X XP` or notation. Group positive events first, then neutral notes.
  - **Session-level bonuses**: compute the 4 session-level milestone XP items (VPIP, bb/100, showdowns, tilt) here using `SessionStats` from `sessionAnalysisProvider`. Show them in a separate "Session Bonuses" section.
  - **Level progress**: at the bottom, show the XP bar before and after this session's gains with an animation (old fill → new fill over 1.5 seconds using `Tween<double>`). If the user leveled up, show a celebration overlay (confetti or a large level-up text in primary colour with a brief `ScaleTransition`).
  - **"Claim XP" button**: a `GradientButton` at the bottom. On tap, call `LearningService.awardSessionXp(userId, events)` which sums all XP events and calls the existing `recordDrillResult` flow (or a new `awardXp(int amount)` method). Then clear `pendingXpEvents` from the game document. Dismiss the sheet.

- [ ] **Add `LearningService.awardXp(String userId, int xp, String reason)`** — a simpler XP award method (no drill stat tracking) for ad-hoc awards (session bonuses, puzzle completion). Increments `xp` in Firestore and recomputes `level` string. Appends to `recentActivity`.

- [ ] **Show XP prompt in lobby after game ends** — in `LobbyScreen`, watch `activeGameProvider`. When the game status transitions from `active` to `completed` for a game the user was in, show a `SnackBar` or floating banner: "Session ended — tap to claim your XP →". Tapping navigates to `/learn` and triggers the session XP summary sheet. Use a `StateProvider<bool> showXpClaimProvider` to track whether the claim is pending.

---

### Feature 12: Daily Puzzle

A single hand scenario shown once per day, the same for all users (deterministic by date). Solving it correctly awards bonus XP and extends a separate "puzzle streak" counter.

#### Data

- [ ] **Create `lib/data/daily_puzzles.dart`** — define a `DailyPuzzle` class with fields: `id: String` (e.g. `'puzzle_001'`), `title: String`, `situation: String` (full hand narrative, 3–5 sentences describing position, stack sizes, action so far), `holeCards: List<String>` (2 card codes), `communityCards: List<String>` (3–5 card codes), `options: List<String>` (4 choices), `correctIndex: int`, `explanation: String` (3–6 sentences justifying the correct answer with math/reasoning), `difficulty: int` (1–3), `category: String` (e.g. `'preflop'`, `'river_bluff'`, `'turn_barrel'`). Create a `const List<DailyPuzzle> allDailyPuzzles` with at least 90 puzzles (a unique puzzle per day for 3 months). The daily puzzle is selected by: `allDailyPuzzles[DateTime.now().difference(DateTime(2026, 1, 1)).inDays % allDailyPuzzles.length]`.

  Puzzle categories to cover: preflop squeeze (10), BB defense (10), flop c-bet decision (15), turn barrel or give-up (15), river value vs bluff (15), bluff catch on river (10), set mining odds (5), tournament ICM spot (5), pot odds edge case (5).

- [ ] **Add puzzle streak fields to `LearningProgressModel`** — add:
  - `puzzleStreakDays: int` — consecutive days with puzzle solved (not just attempted)
  - `lastPuzzleDate: DateTime?` — date of last puzzle solve
  - `puzzleSolvedIds: List<String>` — IDs of all puzzles ever solved correctly (prevents re-awarding)
  - `totalPuzzlesSolved: int` — cumulative counter
  Update `toMap` / `fromMap` accordingly.

#### Screen

- [ ] **Create `lib/screens/learn/daily_puzzle_screen.dart`** as a `ConsumerStatefulWidget` reading `learningProgressProvider` and `currentUserProvider`:

  **States:**
  1. **Today's puzzle not yet attempted**: show full puzzle UI
  2. **Already solved today**: show "Come back tomorrow!" with next puzzle unlock countdown (time until midnight), the explanation of today's puzzle, and the current streak.
  3. **Already attempted but got it wrong**: show "Better luck tomorrow!" with today's explanation and correct answer highlighted.

  **Puzzle UI:**
  - **Header**: "Daily Puzzle" title, date (e.g. "April 23"), a flame icon + "5-day streak" if `puzzleStreakDays > 0`.
  - **Difficulty badge**: pill chip (Easy / Medium / Hard) coloured green / amber / red.
  - **Situation text**: full narrative in Inter 15px, good line height.
  - **Card display**: hole cards (2 card widgets) and community cards (3–5 card widgets) in horizontal rows, same card rendering as table screen.
  - **Options**: 4 `OutlinedButton` widgets, full width, stacked vertically.
  - **Timer**: a subtle countdown timer showing time remaining to solve (reset to midnight). Pure cosmetic — no time limit, just creates urgency feel.

  **After answering:**
  - Correct: green overlay on chosen option, confetti burst (`ConfettiController` from `confetti` package or custom `CustomPainter` particle burst), "+25 XP" badge animates in. Show explanation. Update puzzle streak, award XP via `LearningService.awardXp(userId, 25, 'Daily puzzle solved')`. Update `lastPuzzleDate`, `puzzleStreakDays`, `puzzleSolvedIds`, `totalPuzzlesSolved` in Firestore.
  - Wrong: red overlay on chosen option, correct option turns green. Show explanation. Award +5 XP for attempting: `LearningService.awardXp(userId, 5, 'Daily puzzle attempted')`. No streak increment. Mark as attempted in Firestore so user cannot re-try today (`puzzleAttemptedIds: List<String>` field, add to model).

  - **Share result button**: after completing (either outcome), show "Share" icon button that uses the native share sheet to post: "I solved today's poker puzzle on PokerScanner! Streak: 5 days 🃏"

#### Integration

- [ ] **Add Daily Puzzle entry point to For You tab** — in `_ForYouTab`, add a prominent card at the very top (above the level banner) when the user has not yet solved today's puzzle. Card shows: puzzle flame icon, "Daily Puzzle — Day \{puzzleStreakDays + 1\}", difficulty badge, estimated time "~3 min", and a `GradientButton` "Solve Today's Puzzle" navigating to `/learn/daily-puzzle`. If already solved today, show a compact "Puzzle complete ✓" chip with the streak count.

- [ ] **Add `/learn/daily-puzzle` route in `lib/router.dart`** — top-level route (no bottom nav bar) pointing to `DailyPuzzleScreen`.

- [ ] **Add puzzle streak badge** to badge system in `LearningService.awardBadge` checks:
  - `'puzzle_streak_3'` — puzzleStreakDays reaches 3
  - `'puzzle_streak_7'` — puzzleStreakDays reaches 7
  - `'puzzle_streak_30'` — puzzleStreakDays reaches 30
  - `'puzzle_master'` — totalPuzzlesSolved reaches 30
  Also add these 4 badge definitions to the `_ProgressTab` badge display grid.
