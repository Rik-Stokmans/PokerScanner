import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/deck_model.dart';
import '../providers/providers.dart';
import '../services/firestore_service.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_button.dart';
import '../widgets/scanner_status_badge.dart';

final _decksProvider = StreamProvider.autoDispose<List<DeckModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value([]);
  return FirestoreService.getUserDecksStream(user.id);
});

class DeckManagementScreen extends ConsumerStatefulWidget {
  const DeckManagementScreen({super.key});

  @override
  ConsumerState<DeckManagementScreen> createState() =>
      _DeckManagementScreenState();
}

class _DeckManagementScreenState extends ConsumerState<DeckManagementScreen> {
  // In production this would come from a BLE provider; toggled false when no
  // scanner is paired.
  bool _scannerConnected = true;

  void _showScannerRequired() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          'Scanner required',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        content: Text(
          'You need to connect a scanner before registering a new deck.',
          style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/scanner-setup');
            },
            child: Text('Connect',
                style: GoogleFonts.inter(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(_decksProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.onSurface, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SILENT TABLE',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.onSurface,
                          letterSpacing: 2,
                        ),
                      ),
                      ScannerStatusBadge(isActive: _scannerConnected),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'My Decks',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage your registered card decks.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Deck list
              Expanded(
                child: decksAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Failed to load decks.',
                      style: GoogleFonts.inter(
                          color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  data: (decks) {
                    if (decks.isEmpty) {
                      return _EmptyState(
                          scannerConnected: _scannerConnected);
                    }
                    return ListView.separated(
                      itemCount: decks.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) => _DeckTile(
                        deck: decks[index],
                        scannerConnected: _scannerConnected,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // New registration CTA
              GradientButton(
                label: 'REGISTER NEW DECK',
                icon: Icons.add,
                onPressed: _scannerConnected
                    ? () => context.push('/decks/register')
                    : _showScannerRequired,
              ),

              if (!_scannerConnected) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/scanner-setup'),
                    child: Text(
                      'Connect scanner first',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool scannerConnected;
  const _EmptyState({required this.scannerConnected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.style_outlined,
              color: AppColors.onSurfaceVariant.withOpacity(0.4), size: 60),
          const SizedBox(height: 16),
          Text(
            'No decks yet',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scannerConnected
                ? 'Register your first deck to get started.'
                : 'Connect a scanner, then register your first deck.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Deck tile ──────────────────────────────────────────────────────────────

class _DeckTile extends ConsumerWidget {
  final DeckModel deck;
  final bool scannerConnected;

  const _DeckTile({required this.deck, required this.scannerConnected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInUse = deck.assignedTableId != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: isInUse
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.25), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isInUse
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isInUse ? Icons.link : Icons.style_outlined,
              color: isInUse
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deck.name,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                if (isInUse)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'In use at table',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else
                  Text(
                    'Available',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (!isInUse)
            _OverflowMenu(
              deck: deck,
              scannerConnected: scannerConnected,
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ── Overflow menu (rename / delete) ───────────────────────────────────────

class _OverflowMenu extends ConsumerWidget {
  final DeckModel deck;
  final bool scannerConnected;

  const _OverflowMenu(
      {required this.deck, required this.scannerConnected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<_DeckAction>(
      icon: const Icon(Icons.more_vert,
          color: AppColors.onSurfaceVariant, size: 20),
      color: AppColors.surfaceContainerHighest,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (action) => _onAction(context, ref, action),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _DeckAction.rename,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined,
                  color: AppColors.onSurface, size: 18),
              const SizedBox(width: 10),
              Text('Rename',
                  style: GoogleFonts.inter(color: AppColors.onSurface)),
            ],
          ),
        ),
        PopupMenuItem(
          value: _DeckAction.delete,
          child: Row(
            children: [
              const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 18),
              const SizedBox(width: 10),
              Text('Delete',
                  style: GoogleFonts.inter(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _onAction(
      BuildContext context, WidgetRef ref, _DeckAction action) async {
    switch (action) {
      case _DeckAction.rename:
        await _showRenameDialog(context);
        break;
      case _DeckAction.delete:
        await _showDeleteDialog(context);
        break;
    }
  }

  Future<void> _showRenameDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDeckDialog(initialName: deck.name),
    );
    if (result != null && result.isNotEmpty) {
      await FirestoreService.updateDeckName(deck.id, result);
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text(
          'Delete deck?',
          style: GoogleFonts.manrope(
              fontWeight: FontWeight.w700, color: AppColors.onSurface),
        ),
        content: Text(
          'This will permanently delete "${deck.name}" and all its card mappings.',
          style:
              GoogleFonts.inter(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete',
                style: GoogleFonts.inter(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await FirestoreService.deleteDeck(deck.id);
    }
  }
}

enum _DeckAction { rename, delete }

// ── Rename dialog — owns its own TextEditingController lifecycle ───────────

class _RenameDeckDialog extends StatefulWidget {
  final String initialName;
  const _RenameDeckDialog({required this.initialName});

  @override
  State<_RenameDeckDialog> createState() => _RenameDeckDialogState();
}

class _RenameDeckDialogState extends State<_RenameDeckDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerHigh,
      title: Text(
        'Rename deck',
        style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700, color: AppColors.onSurface),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: GoogleFonts.inter(fontSize: 16, color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: 'Deck name',
          hintStyle:
              GoogleFonts.inter(fontSize: 16, color: AppColors.onSurfaceVariant),
          filled: true,
          fillColor: AppColors.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.6), width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel',
              style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(_controller.text.trim()),
          child:
              Text('Save', style: GoogleFonts.inter(color: AppColors.primary)),
        ),
      ],
    );
  }
}
