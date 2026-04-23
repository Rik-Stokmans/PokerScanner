# PokerScanner Bluetooth Integration TODOs

The scanner hardware sends opaque raw chip IDs — it has no knowledge of card ranks or suits. The app builds the rank↔ID mapping via a one-time deck registration walk-through, stores the named deck in Firestore, and resolves raw IDs to cards at runtime during gameplay. Only the table organizer can select or change the active deck for a table.

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

- [x] **Share a hand** — long-press or button in expanded view to generate a text summary of the hand ("Hand #12 · Alice won €4.20 with a Flush after a raise war on the river") and trigger the native share sheet.

- [x] **Search by player name** — a search bar that filters the hand list to only hands where a specific player participated or won.

- [x] **Stack change sparkline** — a small mini chart (using `fl_chart` or a custom painter) next to the session stats showing your stack over time across all recorded hands.

- [x] **Pagination / load more** — if a session has > 30 hands, lazy-load older hands in batches of 20 using Firestore cursor-based pagination to keep the list fast.

- [x] **Export hand history** — a button in the top-right filter menu to export all hands in the current session as a plain-text or CSV file and share it.

---

## Analysis Page Improvements

### Stats & Metrics

- [ ] **Win rate % display** — add a prominent win rate percentage (wins / total hands) to the Session P&L card alongside bb/100, using the same `_MiniStat` widget.

- [ ] **Showdown vs. non-showdown win rate** — add a `SessionStats` breakdown of `showdownWins` / `showdownHands` vs `nonShowdownWins` / `nonShowdownHands`. Display as two `_MiniStat`-style tiles in a new "Win Breakdown" card. Flag if non-showdown win rate is unusually high (>70%) or low (<30%).

- [ ] **Biggest pots won vs. lost** — replace "Recent Winners" with a two-tab "Notable Hands" section (Won / Lost). The Losses tab shows the 3 biggest losing hands derived from `playerStacksBefore` delta or pot amount when the user did not win. Use the existing `_ErrorCard` widget with `isWin: false`.

- [ ] **Hand rank frequency** — add a "Hand Strength" section showing how often you won with each `handRank` (pair, two pair, flush, etc.). Display as a scrollable row of pill/badge widgets, each showing the rank label and count, coloured by rarity.

### Leak Detection & Insights

- [ ] **VPIP approximation** — compute VPIP from hands where the user's `playerStacksBefore` decreased by more than the big blind amount (indicating voluntary money in pot). Add to `SessionStats` as `vpip` (double 0–1). Display as a `_MiniStat` with a warning colour if > 0.30.

- [ ] **Leak detector alerts** — add a `List<String> leakWarnings` field to `SessionStats`. Populate with rule-based alerts computed in `sessionAnalysisProvider`:
  - Lost 4+ of the last 5 hands
  - Won 0 showdowns in the last 8 showdown hands
  - Net loss from BB position exceeds 3× the big blind
  Display each warning as a red-bordered alert card below the AI Insight box (reuse the insight card style with `AppColors.error` accent).

- [ ] **Upgrade AI Insight to be dynamic** — replace the hardcoded two-branch string with a multi-condition function in `SessionStats` that selects the most relevant insight based on win rate, bb/100, VPIP, and leak warnings. Return a plain `String get aiInsight`.

### Visualisation

- [ ] **Stack trajectory mini-chart** — add a simple line chart below the Session P&L card showing cumulative P&L over hand number. Compute the series in `sessionAnalysisProvider` as `List<({int hand, double pnl})> stackSeries`. Use `fl_chart` (already in `pubspec.yaml` if present, otherwise add it) with a `LineChart` widget; style it to match the dark theme.

- [ ] **Positional edge bar visualisation** — replace the plain text list in "Positional Edge" with a horizontal bar chart row per position. Each bar fills proportionally to the largest absolute value; positive bars use `AppColors.primary`, negative use `AppColors.error`.

### Cross-session & Opponent Data

- [ ] **Opponent tendencies card** — add an "Opponents" section using `playerNames` from `activeGameHandsProvider`. For each opponent compute win rate this session and sort descending. Display as a compact list card (opponent name, wins/hands, win%). Helps identify who is running hot.

- [ ] **Multi-session comparison** — use `userRecentHandsProvider` (already exists) to compute all-time average bb/100 and win rate. Show a "vs. your average" delta badge next to the current session bb/100 (`_MiniStat` subtext or small coloured arrow).

### Interactivity

- [ ] **Tappable hand rank items** — make each item in the hand rank frequency row tappable; navigate to a filtered history view showing only hands of that rank.

- [ ] **Wire up "Start Training Drill" button** — decide on a target screen (e.g. hand replayer or a quiz flow) and connect `GradientButton` `onPressed` to navigate there via `go_router`.