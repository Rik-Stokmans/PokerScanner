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