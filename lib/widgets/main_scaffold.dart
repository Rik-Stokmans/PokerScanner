import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/lobby')) return 0;
    if (location.startsWith('/table')) return 1;
    if (location.startsWith('/history')) return 2;
    if (location.startsWith('/analysis')) return 3;
    if (location.startsWith('/learn')) return 4;
    return 0;
  }

  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/lobby');
        break;
      case 1:
        context.go('/table');
        break;
      case 2:
        context.go('/history');
        break;
      case 3:
        context.go('/analysis');
        break;
      case 4:
        context.go('/learn');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _locationToIndex(location);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          border: Border(
            top: BorderSide(
              color: AppColors.outlineVariant.withOpacity(0.15),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'LOBBY',
                  isSelected: selectedIndex == 0,
                  onTap: () => _onTabTapped(context, 0),
                ),
                _NavItem(
                  icon: Icons.casino_outlined,
                  activeIcon: Icons.casino,
                  label: 'TABLE',
                  isSelected: selectedIndex == 1,
                  onTap: () => _onTabTapped(context, 1),
                ),
                _NavItem(
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: 'HISTORY',
                  isSelected: selectedIndex == 2,
                  onTap: () => _onTabTapped(context, 2),
                ),
                _NavItem(
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics,
                  label: 'ANALYSIS',
                  isSelected: selectedIndex == 3,
                  onTap: () => _onTabTapped(context, 3),
                ),
                _NavItem(
                  icon: Icons.school_outlined,
                  activeIcon: Icons.school,
                  label: 'LEARN',
                  isSelected: selectedIndex == 4,
                  onTap: () => _onTabTapped(context, 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
