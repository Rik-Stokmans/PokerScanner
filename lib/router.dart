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
import 'screens/learn_screen.dart';
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
        ],
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
    ],
  );
});
