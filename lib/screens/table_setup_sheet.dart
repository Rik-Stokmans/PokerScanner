import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_model.dart';
import '../services/bot_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';

class TableSetupSheet extends StatefulWidget {
  final GameModel game;
  const TableSetupSheet({super.key, required this.game});

  @override
  State<TableSetupSheet> createState() => _TableSetupSheetState();
}

class _TableSetupSheetState extends State<TableSetupSheet> {
  late int _seatCount;
  /// seat index (int) → player ID
  late Map<int, String> _assignments;
  late String? _dealerPlayerId;
  /// Player selected from the pool, ready to be placed in a seat.
  String? _selectedPlayerId;

  @override
  void initState() {
    super.initState();
    _seatCount = widget.game.maxPlayers;
    _assignments = widget.game.seatAssignments
        .map((k, v) => MapEntry(int.tryParse(k) ?? 0, v));
    _dealerPlayerId = widget.game.dealerPlayerId;
  }

  List<String> get _assignedIds => _assignments.values.toList();

  List<String> get _unassignedPlayers => widget.game.playerIds
      .where((id) => !_assignedIds.contains(id))
      .toList();

  Future<void> _removePlayer(String playerId) async {
    // Do not allow removing the host
    if (playerId == widget.game.hostId) return;
    final name = widget.game.playerNames[playerId] ?? playerId;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLow,
        title: Text(
          'Remove player?',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        content: Text(
          'Remove "$name" from the game?',
          style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remove',
                style: GoogleFonts.inter(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() {
      _assignments.removeWhere((_, v) => v == playerId);
      if (_dealerPlayerId == playerId) _dealerPlayerId = null;
      if (_selectedPlayerId == playerId) _selectedPlayerId = null;
    });
    await FirestoreService.removePlayerFromGame(widget.game.id, playerId);
  }

  Future<void> _persist() async {
    await FirestoreService.updateTableSetup(
      gameId: widget.game.id,
      seatCount: _seatCount,
      seatAssignments: _assignments.map((k, v) => MapEntry('$k', v)),
      dealerPlayerId: _dealerPlayerId,
    );
  }

  void _changeSeatCount(int delta) {
    final next = (_seatCount + delta).clamp(2, 9);
    if (next == _seatCount) return;
    setState(() {
      _seatCount = next;
      // unassign players whose seat index no longer exists
      _assignments.removeWhere((k, _) => k >= next);
    });
    _persist();
  }

  void _onSeatTap(int seatIndex) {
    final occupant = _assignments[seatIndex];
    setState(() {
      if (_selectedPlayerId != null) {
        // Move selected player to this seat (remove from any prior seat first)
        _assignments.removeWhere((_, v) => v == _selectedPlayerId);
        if (occupant != null) {
          // Evicted player goes back to the pool (no action needed, just remove)
        }
        _assignments[seatIndex] = _selectedPlayerId!;
        _selectedPlayerId = null;
      } else if (occupant != null) {
        // Tap an occupied seat with nothing selected → remove player from seat
        _assignments.remove(seatIndex);
      }
    });
    _persist();
  }

  void _onPlayerTap(String playerId) {
    setState(() {
      _selectedPlayerId = _selectedPlayerId == playerId ? null : playerId;
    });
  }

  Future<void> _onSeatLongPress(String occupantId) async {
    final isHost = occupantId == widget.game.hostId;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.casino_outlined, color: Colors.amber),
              title: Text(
                'Set as Dealer',
                style: GoogleFonts.inter(
                    color: AppColors.onSurface, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _setDealer(occupantId);
              },
            ),
            if (!isHost)
              ListTile(
                leading: const Icon(Icons.person_remove_outlined,
                    color: Colors.redAccent),
                title: Text(
                  'Remove from game',
                  style: GoogleFonts.inter(
                      color: Colors.redAccent, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _removePlayer(occupantId);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _setDealer(String playerId) {
    setState(() {
      _dealerPlayerId = _dealerPlayerId == playerId ? null : playerId;
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.88),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 12, 0),
            child: Row(
              children: [
                Text(
                  'TABLE SETUP',
                  style: GoogleFonts.manrope(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppColors.onSurface, letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.onSurfaceVariant, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Seat count row
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
            child: Row(
              children: [
                Text(
                  'SEATS',
                  style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant, letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                _StepButton(
                  icon: Icons.remove,
                  onTap: () => _changeSeatCount(-1),
                ),
                SizedBox(
                  width: 44,
                  child: Center(
                    child: Text(
                      '$_seatCount',
                      style: GoogleFonts.manrope(
                        fontSize: 22, fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                _StepButton(
                  icon: Icons.add,
                  onTap: () => _changeSeatCount(1),
                ),
              ],
            ),
          ),

          // Visual table
          _TableCanvas(
            seatCount: _seatCount,
            assignments: _assignments,
            dealerPlayerId: _dealerPlayerId,
            selectedPlayerId: _selectedPlayerId,
            playerNames: widget.game.playerNames,
            onSeatTap: _onSeatTap,
            onSeatLongPress: (occupantId) => _onSeatLongPress(occupantId),
          ),

          const SizedBox(height: 20),

          // Dealer hint
          if (_assignments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 20, height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.amber, shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('D',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w900,
                              color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _dealerPlayerId != null
                        ? 'Dealer: ${widget.game.playerNames[_dealerPlayerId] ?? _dealerPlayerId}'
                        : 'Long-press a seat to assign dealer button',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Unassigned players pool
          if (_unassignedPlayers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'UNASSIGNED',
                    style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant, letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedPlayerId != null
                        ? '— tap a seat to place'
                        : '— tap to select, hold to remove',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: _unassignedPlayers.map((uid) {
                  final name = widget.game.playerNames[uid] ?? uid;
                  final isSelected = _selectedPlayerId == uid;
                  final isRemovable = uid != widget.game.hostId;
                  return GestureDetector(
                    onTap: () => _onPlayerTap(uid),
                    onLongPress: isRemovable ? () => _removePlayer(uid) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.14)
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.5)
                              : AppColors.outlineVariant.withValues(alpha: 0.2),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _PlayerAvatar(
                            name: name,
                            isSelected: isSelected,
                            isBot: BotService.isBot(uid),
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _shortName(name),
                            style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'All players have been seated.',
                style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.onSurfaceVariant,
                ),
              ),
            ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Visual oval table with seats positioned around the perimeter
// ─────────────────────────────────────────────────────────────────────────────

class _TableCanvas extends StatelessWidget {
  final int seatCount;
  final Map<int, String> assignments;
  final String? dealerPlayerId;
  final String? selectedPlayerId;
  final Map<String, String> playerNames;
  final void Function(int seatIndex) onSeatTap;
  final void Function(String occupantId) onSeatLongPress;

  const _TableCanvas({
    required this.seatCount,
    required this.assignments,
    required this.dealerPlayerId,
    required this.selectedPlayerId,
    required this.playerNames,
    required this.onSeatTap,
    required this.onSeatLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth - 48;
      final feltH = w * 0.48;
      const seatR = 28.0;
      const labelH = 18.0;
      const padding = 4.0;
      final totalH = feltH + seatR * 2 + labelH + padding * 2;

      // Table oval center in the Stack
      final cx = w / 2;
      final cy = seatR + padding + feltH / 2;

      // Radii for seat placement (seat centers on this ellipse)
      final rx = w / 2 - seatR - 4;
      final ry = feltH / 2 - seatR + 6;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: w,
          height: totalH,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Table felt
              Positioned(
                top: seatR + padding,
                left: 0, right: 0,
                child: Container(
                  height: feltH,
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [Color(0xFF2E7D42), Color(0xFF1B5E20)],
                      radius: 0.85,
                    ),
                    borderRadius: BorderRadius.circular(feltH / 2),
                    border: Border.all(
                      color: const Color(0xFF6D4C41), width: 7,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '♠  ♥  ♣  ♦',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.08),
                        letterSpacing: 6,
                      ),
                    ),
                  ),
                ),
              ),

              // Seats
              for (int i = 0; i < seatCount; i++)
                _buildSeat(i, cx, cy, rx, ry, seatR),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSeat(
      int index, double cx, double cy, double rx, double ry, double seatR) {
    // Start at top (−π/2), go clockwise
    final angle = (2 * pi * index / seatCount) - pi / 2;
    final x = cx + rx * cos(angle);
    final y = cy + ry * sin(angle);

    final occupantId = assignments[index];
    final name = occupantId != null ? (playerNames[occupantId] ?? occupantId) : null;
    final isDealer = occupantId != null && occupantId == dealerPlayerId;
    final isBot = occupantId != null && BotService.isBot(occupantId);
    final isHighlighted = occupantId == null && selectedPlayerId != null;

    final diameter = seatR * 2;

    return Positioned(
      left: x - seatR,
      top: y - seatR,
      child: GestureDetector(
        onTap: () => onSeatTap(index),
        onLongPress: occupantId != null ? () => onSeatLongPress(occupantId) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Seat circle
                Container(
                  width: diameter, height: diameter,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: occupantId != null
                        ? (isBot
                            ? AppColors.surfaceContainerHighest
                            : AppColors.primary.withValues(alpha: 0.85))
                        : AppColors.surfaceContainerHigh.withValues(alpha: 0.75),
                    border: Border.all(
                      color: isHighlighted
                          ? AppColors.primary
                          : isDealer
                              ? Colors.amber
                              : AppColors.outlineVariant.withValues(alpha: 0.35),
                      width: isHighlighted || isDealer ? 2.5 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: occupantId != null
                        ? _PlayerAvatar(
                            name: name!,
                            isBot: isBot,
                            size: diameter,
                            textOnly: true,
                          )
                        : Text(
                            '${index + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                  ),
                ),

                // Dealer chip
                if (isDealer)
                  Positioned(
                    right: -5, top: -5,
                    child: Container(
                      width: 20, height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 3,
                              offset: Offset(0, 1)),
                        ],
                      ),
                      child: const Center(
                        child: Text('D',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.black)),
                      ),
                    ),
                  ),
              ],
            ),

            // Name label
            if (name != null)
              Container(
                margin: const EdgeInsets.only(top: 3),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _shortName(name),
                  style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

String _shortName(String name) {
  final first = name.split(' ').first;
  return first.length > 8 ? '${first.substring(0, 7)}…' : first;
}

class _PlayerAvatar extends StatelessWidget {
  final String name;
  final bool isBot;
  final double size;
  final bool isSelected;
  final bool textOnly;

  const _PlayerAvatar({
    required this.name,
    required this.isBot,
    required this.size,
    this.isSelected = false,
    this.textOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final fg = textOnly
        ? (isBot ? AppColors.primary : AppColors.onPrimary)
        : (isSelected ? AppColors.onPrimary : AppColors.primary);

    if (textOnly) {
      return Text(
        initial,
        style: GoogleFonts.manrope(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      );
    }

    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary : AppColors.surfaceContainerHighest,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.manrope(
            fontSize: size * 0.44,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Icon(icon, size: 17, color: AppColors.onSurface),
      ),
    );
  }
}
