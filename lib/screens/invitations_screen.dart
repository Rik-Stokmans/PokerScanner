import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/scanner_status_badge.dart';
import '../providers/providers.dart';
import '../services/firestore_service.dart';
import '../models/invitation_model.dart';

class InvitationsScreen extends ConsumerWidget {
  const InvitationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitationsAsync = ref.watch(invitationsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.onSurface, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('INVITATIONS',
                          style: GoogleFonts.manrope(
                            fontSize: 22, fontWeight: FontWeight.w800,
                            color: AppColors.onSurface, letterSpacing: 2,
                          )),
                      const ScannerStatusBadge(),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              invitationsAsync.when(
                loading: () => const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (e, stack) {
                  debugPrint('Error loading invitations: $e\n$stack');
                  return Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48,
                              color: AppColors.onSurfaceVariant.withOpacity(0.6)),
                          const SizedBox(height: 12),
                          Text('Error loading invitations',
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              )),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              e.toString(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () => ref.invalidate(invitationsProvider),
                            icon: const Icon(Icons.refresh,
                                color: AppColors.primary),
                            label: Text('Retry',
                                style: GoogleFonts.inter(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                data: (invitations) {
                  if (invitations.isEmpty) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mail_outline, size: 48,
                                color: AppColors.onSurfaceVariant.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text('No pending invitations',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.onSurfaceVariant,
                                )),
                          ],
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Pending',
                                style: GoogleFonts.manrope(
                                  fontSize: 18, fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                )),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('${invitations.length} Requests',
                                  style: GoogleFonts.inter(
                                    fontSize: 12, fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Recent',
                            style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.onSurfaceVariant,
                              letterSpacing: 0.5,
                            )),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.separated(
                            itemCount: invitations.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final inv = invitations[index];
                              return _InvitationCard(
                                invitation: inv,
                                onAccept: () async {
                                  final user =
                                      ref.read(currentUserProvider).value;
                                  if (user == null) return;
                                  try {
                                    await FirestoreService.respondToInvitation(
                                        inv.id, 'accepted', user.id);
                                    if (context.mounted) {
                                      context.go('/table');
                                    }
                                  } catch (e) {
                                    debugPrint('Failed to accept invitation: $e');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to accept invitation: $e',
                                            style: GoogleFonts.inter(
                                                color: AppColors.onSurface),
                                          ),
                                          backgroundColor:
                                              AppColors.surfaceContainerHigh,
                                        ),
                                      );
                                    }
                                  }
                                },
                                onDecline: () async {
                                  final user =
                                      ref.read(currentUserProvider).value;
                                  if (user == null) return;
                                  try {
                                    await FirestoreService.respondToInvitation(
                                        inv.id, 'declined', user.id);
                                  } catch (e) {
                                    debugPrint('Failed to decline invitation: $e');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to decline invitation: $e',
                                            style: GoogleFonts.inter(
                                                color: AppColors.onSurface),
                                          ),
                                          backgroundColor:
                                              AppColors.surfaceContainerHigh,
                                        ),
                                      );
                                    }
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final InvitationModel invitation;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _InvitationCard({
    required this.invitation,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final initial = invitation.fromUsername.isNotEmpty
        ? invitation.fromUsername[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(initial,
                      style: GoogleFonts.manrope(
                        fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      )),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invited by ${invitation.fromUsername}',
                        style: GoogleFonts.inter(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        )),
                    Text(invitation.timeAgo,
                        style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(invitation.gameName,
              style: GoogleFonts.manrope(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              )),
          const SizedBox(height: 4),
          Text(invitation.gameDescription,
              style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.onSurfaceVariant,
              )),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(invitation.stakes,
                    style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    )),
              ),
              const SizedBox(width: 8),
              Text(invitation.detail,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant.withOpacity(0.7),
                  )),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onDecline,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('DECLINE',
                          style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant, letterSpacing: 0.8,
                          )),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: onAccept,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryContainer],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('ACCEPT',
                          style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: AppColors.onPrimary, letterSpacing: 0.8,
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
