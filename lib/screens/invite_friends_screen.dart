import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../providers/providers.dart';
import '../services/firestore_service.dart';
import '../models/friendship_model.dart';

/// A full-page screen for inviting friends to the active table.
/// Shown when the host taps "Invite Player" in the lobby.
class InviteFriendsScreen extends ConsumerStatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  ConsumerState<InviteFriendsScreen> createState() =>
      _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends ConsumerState<InviteFriendsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  // 0 = All, 1 = Online, 2 = Offline
  int _selectedTab = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).value;
    final friends = ref.watch(acceptedFriendsProvider);
    final uid = user?.id ?? '';

    final onlineFriends =
        friends.where((f) => f.friendStatus == 'online' || f.friendStatus == 'in_game').toList();
    final offlineFriends =
        friends.where((f) => f.friendStatus == 'offline').toList();

    List<FriendshipModel> tabFiltered;
    switch (_selectedTab) {
      case 1:
        tabFiltered = onlineFriends;
        break;
      case 2:
        tabFiltered = offlineFriends;
        break;
      default:
        tabFiltered = friends;
    }

    final displayed = _searchQuery.isEmpty
        ? tabFiltered
        : tabFiltered
            .where((f) => f
                .otherUsername(uid)
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.onSurface, size: 20),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Invite to Table',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  // Add friend button
                  IconButton(
                    icon: const Icon(Icons.person_add_outlined,
                        color: AppColors.primary),
                    tooltip: 'Add friend',
                    onPressed: () => _showAddFriendDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.inter(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search friends...',
                  hintStyle: GoogleFonts.inter(
                      color: AppColors.onSurfaceVariant, fontSize: 14),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.onSurfaceVariant, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              color: AppColors.onSurfaceVariant, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tab chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
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
                    label: 'Offline (${offlineFriends.length})',
                    isSelected: _selectedTab == 2,
                    onTap: () => setState(() => _selectedTab = 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Friend list
            Expanded(
              child: displayed.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline,
                              size: 48,
                              color:
                                  AppColors.onSurfaceVariant.withOpacity(0.4)),
                          const SizedBox(height: 12),
                          Text(
                            friends.isEmpty
                                ? 'No friends yet.\nTap + to send a friend request.'
                                : 'No friends match your search.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          if (friends.isEmpty) ...[
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: () => _showAddFriendDialog(context),
                              icon: const Icon(Icons.person_add_outlined,
                                  color: AppColors.primary, size: 18),
                              label: Text(
                                'Add a Friend',
                                style: GoogleFonts.inter(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: displayed.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final f = displayed[index];
                        return _InviteFriendCard(
                          friendship: f,
                          currentUserId: uid,
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
                                SnackBar(
                                  content: Text(
                                      'Invitation sent to ${f.otherUsername(uid)}!'),
                                ),
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
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLow,
        title: Text(
          'Add Friend',
          style: GoogleFonts.manrope(
              color: AppColors.onSurface, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.inter(color: AppColors.onSurface),
          decoration: const InputDecoration(
            labelText: 'Username',
            prefixIcon: Icon(Icons.person_search,
                color: AppColors.onSurfaceVariant),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style:
                    GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () async {
              final username = controller.text.trim();
              Navigator.pop(ctx);
              if (username.isEmpty) return;
              final users =
                  await FirestoreService.searchUsers(username);
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
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _InviteFriendCard extends StatefulWidget {
  final FriendshipModel friendship;
  final String currentUserId;
  final VoidCallback onInvite;

  const _InviteFriendCard({
    required this.friendship,
    required this.currentUserId,
    required this.onInvite,
  });

  @override
  State<_InviteFriendCard> createState() => _InviteFriendCardState();
}

class _InviteFriendCardState extends State<_InviteFriendCard> {
  bool _invited = false;

  @override
  Widget build(BuildContext context) {
    final username =
        widget.friendship.otherUsername(widget.currentUserId);
    final status = widget.friendship.friendStatus;
    final isOnline =
        status == 'online' || status == 'in_game';

    final statusColor = status == 'in_game'
        ? AppColors.primary
        : isOnline
            ? const Color(0xFF9AD4A5)
            : AppColors.onSurfaceVariant;

    final statusLabel = status == 'in_game'
        ? 'In a Game'
        : isOnline
            ? 'Online'
            : 'Offline';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Avatar with status dot
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: GoogleFonts.manrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
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
          // Name + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          // Invite button
          GestureDetector(
            onTap: _invited
                ? null
                : () {
                    setState(() => _invited = true);
                    widget.onInvite();
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _invited
                    ? AppColors.surfaceContainerHighest
                    : AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: _invited
                    ? null
                    : Border.all(
                        color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Text(
                _invited ? 'Invited' : 'Invite',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _invited
                      ? AppColors.onSurfaceVariant
                      : AppColors.primary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
