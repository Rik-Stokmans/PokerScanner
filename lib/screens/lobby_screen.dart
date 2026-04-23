import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/scanner_status_badge.dart';
import '../widgets/gradient_button.dart';
import '../providers/providers.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({super.key});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  Future<void> _endSession() async {
    final game = ref.read(activeGameProvider).value;
    final user = ref.read(currentUserProvider).value;
    if (game == null || user == null) return;
    await FirestoreService.endGame(game.id, user.id);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final gameAsync = ref.watch(activeGameProvider);

    final user = userAsync.value;
    final game = gameAsync.value;
    final hasActiveGame = game != null && game.isActive;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOBBY',
                        style: GoogleFonts.manrope(
                          fontSize: 26, fontWeight: FontWeight.w800,
                          color: AppColors.onSurface, letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const ScannerStatusBadge(),
                    ],
                  ),
                  Row(
                    children: [
                      if (user != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                user.initial,
                                style: GoogleFonts.manrope(
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined,
                            color: AppColors.onSurfaceVariant),
                        onPressed: () => context.push('/invitations'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_outline,
                            color: AppColors.onSurfaceVariant),
                        onPressed: () => context.push('/friends'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatItem(
                        value: '${game?.playerCount ?? 0}',
                        label: 'Players\nConnected',
                      ),
                    ),
                    Container(width: 1, height: 40,
                        color: AppColors.outlineVariant.withOpacity(0.15)),
                    Expanded(
                      child: _StatItem(
                        value: hasActiveGame ? '1' : '0',
                        label: 'Scanner\nActive',
                        valueColor: hasActiveGame ? AppColors.primary : null,
                      ),
                    ),
                    Container(width: 1, height: 40,
                        color: AppColors.outlineVariant.withOpacity(0.15)),
                    Expanded(
                      child: _StatItem(
                        value: '${game?.maxPlayers ?? 9}',
                        label: 'Max\nSeats',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hasActiveGame ? 'At the Table' : 'Players',
                    style: GoogleFonts.manrope(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/scanner-setup'),
                    icon: const Icon(Icons.bluetooth_searching,
                        color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (hasActiveGame && game.playerNames.isNotEmpty)
                ...game.playerNames.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PlayerCard(
                    name: entry.value,
                    seat: 'Seat ${game.playerIds.indexOf(entry.key) + 1}',
                    initial: entry.value.isNotEmpty ? entry.value[0].toUpperCase() : '?',
                    status: entry.key == game.hostId ? 'Host' : 'Joined',
                    statusColor: entry.key == game.hostId
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ))
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      'Start a session to deal in players',
                      style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              if (hasActiveGame)
                GestureDetector(
                  onTap: () => context.push('/invite-friends'),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.outlineVariant.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add,
                            color: AppColors.primary.withOpacity(0.8), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Invite Player',
                          style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: AppColors.primary.withOpacity(0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              if (hasActiveGame) ...[
                GradientButton(
                  label: 'RESUME SESSION',
                  icon: Icons.play_arrow,
                  onPressed: () => context.go('/table'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _endSession,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: Text(
                    'END SESSION',
                    style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.8,
                    ),
                  ),
                ),
              ] else ...[
                GradientButton(
                  label: 'JOIN TABLE',
                  icon: Icons.play_arrow,
                  onPressed: () => context.go('/table'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/scanner-setup'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bluetooth_searching, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'SETUP SCANNER',
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.push('/decks'),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.style_outlined,
                            color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Decks',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              'Rename, delete or register decks',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 14, color: AppColors.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await AuthService.signOut();
                  if (mounted) context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: Text(
                  'SIGN OUT',
                  style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.8,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _StatItem({required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.manrope(
              fontSize: 28, fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.onSurface,
            )),
        const SizedBox(height: 4),
        Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant, letterSpacing: 0.5,
            )),
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final String name;
  final String seat;
  final String initial;
  final String status;
  final Color statusColor;

  const _PlayerCard({
    required this.name, required this.seat, required this.initial,
    required this.status, required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(initial,
                  style: GoogleFonts.manrope(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  )),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    )),
                const SizedBox(height: 2),
                Text(seat,
                    style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.onSurfaceVariant,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status,
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: statusColor, letterSpacing: 0.3,
                )),
          ),
        ],
      ),
    );
  }
}
