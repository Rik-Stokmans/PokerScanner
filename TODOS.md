# PokerScanner Bluetooth Integration TODOs

The scanner hardware sends opaque raw chip IDs — it has no knowledge of card ranks or suits. The app builds the rank↔ID mapping via a one-time deck registration walk-through, stores the named deck in Firestore, and resolves raw IDs to cards at runtime during gameplay. Only the table organizer can select or change the active deck for a table.

---

- [x] **Platform & dependency setup** — Wire in `flutter_blue_plus` and `permission_handler`, then configure all required Bluetooth and location permissions across Android manifests and iOS plist entries so the app is authorised to scan and connect on both platforms.

- [x] **BLE protocol definition** — Hardware contract confirmed from firmware (`Poker_RFID_Reader.ino`):
  - Device name: `"RFID Scanner"` (ESP32-C3, MAC `58:8c:81:b0:90:1c`)
  - Service UUID: `4fafc201-1fb5-459e-8fcc-c5c9c331914b`
  - RFID characteristic: `beb5483e-36e1-4688-b7f5-ea07361b26a8` — READ | WRITE | NOTIFY; payload is an ASCII string `"R1: XX XX XX XX"` or `"R2: XX XX XX XX"` (reader prefix + space-separated hex bytes)
  - Battery characteristic: `6e400002-b5a3-f393-e0a9-e50e24dcca9e` — READ | NOTIFY; payload is ASCII `"BAT: XX%"`
  - Scan cycle: readers polled every 5 s; RFID and battery notifications are only sent when a card is present **and** a client is connected
  - No card-removed or idle events; absence of notifications implies no card
  - Two readers: `R1` and `R2` can fire independently in the same scan cycle

- [x] **Core data models** — Introduce a `DeckModel` that maps raw chip IDs to card identifiers, add a `deckId` reference to `GameModel`, and create a lightweight `ScannerDevice` model that wraps discovery results with human-readable signal strength.

- [x] **Firestore deck collection** — Build out full CRUD for decks including live streaming of a user's deck list, atomic per-card mapping writes that are safe to call during registration, and a host-only method for assigning a deck to a table — backed by security rules that restrict writes to the deck owner.

- [x] **BLE scanner service** — Build a singleton service that handles the full device lifecycle: scanning, connecting, subscribing to chip notifications, converting raw bytes to hex IDs on a stream, auto-reconnecting on unexpected drops, and persisting the last paired device for startup reconnection.

- [x] **State management** — Expose the scanner and deck layer to the UI through Riverpod providers covering connection state, discovered devices, the raw chip ID stream, the user's deck list, and the active deck for the current table.

- [x] **Deck registration screen** — Create a guided flow where the organizer connects the scanner then presents each physical card to the device one at a time; the app prompts which card to scan next, records the mapping live to Firestore as each chip is read, shows progress across all 52 cards, and ends with a naming step before saving the completed deck.

- [x] **Deck management screen** — Give users a place to view all their registered decks, resume incomplete registrations, rename or delete decks, and kick off new registrations — with the scanner connection gating access to anything that requires hardware.

- [x] **Scanner setup screen** — Replace the hardcoded placeholder UI with a live BLE scan that populates real devices sorted by signal strength, a genuine connect flow with loading and error states, and a path into deck management once connected.

- [x] **Scanner status badge** — Convert the badge from a static prop to a live consumer of connection state so it accurately reflects connected, reconnecting, and offline conditions across every screen it appears on.

- [x] **Poker table integration** — Pipe incoming chip IDs through the active deck's lookup at the table screen, routing resolved cards into hole hands or community cards based on the current betting round, guarding deck selection behind the host role, and providing a manual entry fallback when the scanner is offline.

- [x] **Startup auto-reconnect** — On launch, silently attempt to restore the last paired device connection before the user reaches the lobby, suppressing the attempt only if they previously disconnected intentionally.

- [x] **Permission handling** — Add a runtime permission request flow before any scan is initiated, with graceful degradation to a settings-redirect dialog if permissions are permanently denied and a Bluetooth-off prompt when the adapter is disabled.

- [x] **Testing & validation** — Cover deck resolution logic, BLE reconnect behaviour, and raw byte parsing with unit tests, then validate the full registration and gameplay flows end-to-end on physical hardware across both Android and iOS.

---

# Friend Invitations Bug Fixes

- [x] **Add Firestore composite index for invitations query** — The `getInvitationsStream` query in `firestore_service.dart:452` chains `.where('toUserId')` + `.where('status')` + `.orderBy('createdAt')`, which requires a composite index. Without it Firestore throws and the screen shows "Error loading invitations". Add the index to `firestore.indexes.json` or follow the auto-generated link in the Firebase console error.

- [x] **Add try-catch to onAccept and onDecline callbacks** — In `invitations_screen.dart:125-141` both callbacks call `respondToInvitation()` with no error handling; `onAccept` navigates to `/table` even if the call throws. Wrap each in try-catch, show a SnackBar on error, and only navigate on success.

- [x] **Fix unsafe null assertion in `respondToInvitation`** — In `firestore_service.dart:494`, `inv.data()!` crashes if the document was deleted between the status update and the re-fetch. Replace with a null-safe check and guard the `gameId` cast on line 495.

- [x] **Wrap `respondToInvitation` writes in a Firestore batch/transaction** — In `firestore_service.dart:489-503`, three separate writes (update invitation status, update game `playerIds`, update user `currentGameId`) are not atomic. If the second or third write fails, data is left inconsistent. Use a `WriteBatch` or transaction so all three succeed or all fail together.

- [x] **Improve error state UI in InvitationsScreen** — In `invitations_screen.dart:54-60`, the error state shows a plain "Error loading invitations" with no way to retry. Replace with a widget that displays the error message, a Retry button calling `ref.invalidate(invitationsProvider)`, and error logging.
