import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../providers/providers.dart';
import '../services/firestore_service.dart';
import '../models/friendship_model.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final friends = ref.watch(acceptedFriendsProvider);
    final pending = ref.watch(pendingFriendRequestsProvider);

    final onlineFriends = friends
        .where((f) => f.friendStatus == 'online' || f.friendStatus == 'in_game')
        .toList();
    final inGameFriends =
        friends.where((f) => f.friendStatus == 'in_game').toList();

    final displayedFriends = switch (_selectedTab) {
      1 => onlineFriends,
      2 => inGameFriends,
      _ => friends,
    };

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: AppColors.onSurface, size: 20),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SILENT TABLE',
                              style: GoogleFonts.manrope(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: AppColors.onSurface, letterSpacing: 2,
                              )),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_search,
                        color: AppColors.onSurfaceVariant),
                    onPressed: () => _showAddFriendDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Pending requests
              if (pending.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pending Requests',
                        style: GoogleFonts.manrope(
                          fontSize: 16, fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        )),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${pending.length} Notifications',
                          style: GoogleFonts.inter(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          )),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...pending.map((req) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              req.userUsername.isNotEmpty
                                  ? req.userUsername[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.manrope(
                                fontSize: 16, fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(req.userUsername,
                                  style: GoogleFonts.inter(
                                    fontSize: 14, fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  )),
                              Text('Wants to be friends',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.onSurfaceVariant,
                                  )),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => FirestoreService
                                  .respondToFriendRequest(req.id, 'declined'),
                              child: Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.close,
                                    size: 16,
                                    color: AppColors.onSurfaceVariant),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => FirestoreService
                                  .respondToFriendRequest(req.id, 'accepted'),
                              child: Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.check,
                                    size: 16, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 16),
              ],

              // Tab chips
              Row(
                children: [
                  _TabChip(
                    label: 'All (${friends.length})',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                  ),
                  const SizedBox(width: 8),
                  _TabChip(
                    label: 'Online (${onlineFriends.length})',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                  ),
                  const SizedBox(width: 8),
                  _TabChip(
                    label: 'In-Game (${inGameFriends.length})',
                    isSelected: _selectedTab == 2,
                    onTap: () => setState(() => _selectedTab = 2),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Friends list
              Expanded(
                child: displayedFriends.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline, size: 48,
                                color: AppColors.onSurfaceVariant
                                    .withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text(
                              _selectedTab == 0
                                  ? 'No friends yet — add someone!'
                                  : 'None in this category',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: displayedFriends.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final f = displayedFriends[index];
                          final uid = user?.id ?? '';
                          return _FriendCard(
                            friendship: f,
                            currentUserId: uid,
                            onRemove: () =>
                                FirestoreService.removeFriend(f.id),
                            onInvite: () async {
                              final game =
                                  ref.read(activeGameProvider).value;
                              if (game == null || user == null) return;
                              await FirestoreService.sendInvitation(
                                fromUserId: user.id,
                                fromUsername: user.username,
                                toUserId: f.otherUserId(uid),
                                gameId: game.id,
                                gameName: game.name,
                                smallBlind: game.smallBlind,
                                bigBlind: game.bigBlind,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Invitation sent!')),
                                );
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLow,
        title: Text('Add Friend',
            style: GoogleFonts.manrope(
                color: AppColors.onSurface, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          style: GoogleFonts.inter(color: AppColors.onSurface),
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon:
                Icon(Icons.person_search, color: AppColors.onSurfaceVariant),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final users = await FirestoreService.searchUsers(
                  controller.text.trim());
              if (users.isEmpty || !mounted) return;
              final user = ref.read(currentUserProvider).value;
              if (user == null) return;
              await FirestoreService.sendFriendRequest(
                fromId: user.id,
                fromUsername: user.username,
                toId: users.first.id,
                toUsername: users.first.username,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Friend request sent!')),
                );
              }
            },
            child: Text('Send Request',
                style: GoogleFonts.inter(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: AppColors.primary.withOpacity(0.3))
              : null,
        ),
        child: Text(label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              letterSpacing: 0.3,
            )),
      ),
    );
  }
}

class _FriendCard extends StatelessWidget {
  final FriendshipModel friendship;
  final String currentUserId;
  final VoidCallback onRemove;
  final VoidCallback onInvite;

  const _FriendCard({
    required this.friendship,
    required this.currentUserId,
    required this.onRemove,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final username = friendship.otherUsername(currentUserId);
    final status = friendship.friendStatus;
    final isInGame = status == 'in_game';
    final isOnline = status == 'online';

    final statusColor = isInGame
        ? AppColors.primary
        : isOnline
            ? const Color(0xFF9AD4A5)
            : AppColors.onSurfaceVariant;

    final statusLabel = isInGame
        ? 'In a Game'
        : isOnline
            ? 'Online'
            : 'Offline';

    final actionLabel = isInGame ? 'Spectate' : isOnline ? 'Invite' : 'Remove';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44, height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: GoogleFonts.manrope(
                      fontSize: 17, fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0, bottom: 0,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.surfaceContainerHigh, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username,
                    style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    )),
                Text('$statusLabel${isInGame && friendship.friendCurrentGameId != null ? ' · In a game' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.onSurfaceVariant,
                    )),
              ],
            ),
          ),
          GestureDetector(
            onTap: actionLabel == 'Remove' ? onRemove : onInvite,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(actionLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant, letterSpacing: 0.3,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
