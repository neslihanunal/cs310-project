import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/routes.dart';

class BottomNav extends StatelessWidget {
  final String active;
  final String role;
  final void Function(String route) onNav;

  const BottomNav({super.key, required this.active, required this.role, required this.onNav});

  @override
  Widget build(BuildContext context) {
    final tabs = <_NavTab>[
      _NavTab(route: AppRoutes.dashboard, icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Board'),
      _NavTab(route: AppRoutes.map,       icon: Icons.location_on_outlined, activeIcon: Icons.location_on, label: 'Map'),
      if (role == 'admin')
        _NavTab(route: AppRoutes.createEvent, icon: Icons.add, label: 'New', isSpecial: true),
      _NavTab(route: AppRoutes.calendar,  icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today, label: 'Calendar'),
      _NavTab(route: AppRoutes.settings,  icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 24, left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((t) {
          final isActive = active == t.route;
          if (t.isSpecial) {
            return GestureDetector(
              onTap: () => onNav(t.route),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.add, color: AppColors.bg, size: 18),
              ),
            );
          }
          return GestureDetector(
            onTap: () => onNav(t.route),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isActive ? (t.activeIcon ?? t.icon) : t.icon,
                    color: isActive ? AppColors.accent : AppColors.textDim,
                    size: 20,
                  ),
                  if (isActive)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4, height: 4,
                      decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NavTab {
  final String route;
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isSpecial;
  const _NavTab({required this.route, required this.icon, this.activeIcon, required this.label, this.isSpecial = false});
}
