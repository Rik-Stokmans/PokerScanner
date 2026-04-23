# PokerScanner Bluetooth Integration TODOs

The scanner hardware sends opaque raw chip IDs — it has no knowledge of card ranks or suits. The app builds the rank↔ID mapping via a one-time deck registration walk-through, stores the named deck in Firestore, and resolves raw IDs to cards at runtime during gameplay. Only the table organizer can select or change the active deck for a table.

---

- [ ] when the user wants to invite people to the table present a page where all friends can be seen filtered by online and offline with a search bar at the top, also add a button to add/request new friends
- [ ] i got the below error in the app, please fix the error
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
- [ ] when i open the bluetooth menu in the lobby page again after i allready connected a scanner it does not show me that a scanner is connected and the status in the top goes from scanner active to scanner offline. can you show the device as connected when it is