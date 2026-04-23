import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/scanner_setup_screen.dart';
import 'screens/poker_table_screen.dart';
import 'screens/invitations_screen.dart';
import 'screens/game_history_screen.dart';
import 'screens/session_analysis_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/invite_friends_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/learn/range_trainer_screen.dart';
import 'screens/learn/hand_review_screen.dart';
import 'screens/deck_management_screen.dart';
import 'screens/deck_registration_screen.dart';
import 'screens/range_trainer_screen.dart';
import 'screens/pot_odds_drill_screen.dart';
import 'screens/scenario_drill_screen.dart';
import 'screens/board_texture_drill_screen.dart';
import 'screens/hand_review_quiz_screen.dart';
import 'screens/concept_detail_screen.dart';
import 'widgets/main_scaffold.dart';

// Bridges Firebase auth state to go_router's refreshListenable
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((_) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthChangeNotifier();

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      if (user == null && !isAuth) return '/login';
      if (user != null && isAuth) return '/lobby';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/lobby',
            builder: (context, state) => const LobbyScreen(),
          ),
          GoRoute(
            path: '/table',
            builder: (context, state) => const PokerTableScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const GameHistoryScreen(),
          ),
          GoRoute(
            path: '/analysis',
            builder: (context, state) => const SessionAnalysisScreen(),
          ),
          GoRoute(
            path: '/learn',
            builder: (context, state) => const LearnScreen(),
          ),
          GoRoute(
            path: '/learn/range-trainer',
            builder: (context, state) => const RangeTrainerScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/hand-review',
        builder: (context, state) => const HandReviewScreen(),
      ),
      GoRoute(
        path: '/scanner-setup',
        builder: (context, state) => const ScannerSetupScreen(),
      ),
      GoRoute(
        path: '/invitations',
        builder: (context, state) => const InvitationsScreen(),
      ),
      GoRoute(
        path: '/friends',
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: '/invite-friends',
        builder: (context, state) => const InviteFriendsScreen(),
      ),
      GoRoute(
        path: '/decks',
        builder: (context, state) => const DeckManagementScreen(),
      ),
      GoRoute(
        path: '/decks/register',
        builder: (context, state) {
          final deckId = state.uri.queryParameters['deckId'];
          return DeckRegistrationScreen(deckId: deckId);
        },
      ),
      // ─── Learn sub-routes (no bottom nav) ──────────────────────────────
      GoRoute(
        path: '/learn/range-trainer',
        builder: (context, state) => const RangeTrainerScreen(),
      ),
      GoRoute(
        path: '/learn/pot-odds',
        builder: (context, state) => const PotOddsDrillScreen(),
      ),
      GoRoute(
        path: '/learn/scenarios',
        builder: (context, state) => const ScenarioDrillScreen(),
      ),
      GoRoute(
        path: '/learn/board-texture',
        builder: (context, state) => const BoardTextureDrillScreen(),
      ),
      GoRoute(
        path: '/learn/hand-review',
        builder: (context, state) => const HandReviewQuizScreen(),
      ),
      GoRoute(
        path: '/learn/concept/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ConceptDetailScreen(conceptId: id);
        },
      ),
    ],
  );
});
