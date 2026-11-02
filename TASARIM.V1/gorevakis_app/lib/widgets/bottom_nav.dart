import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Alttaki koyu menü ve yeşil "+" butonu.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.active,
    required this.onSelect,
    this.onAdd,
  });

  final HomeTab active;
  final ValueChanged<HomeTab> onSelect;

  /// null ise "+" butonu gösterilmez (ör. izleyici olunan projede).
  final VoidCallback? onAdd;

  /// İçeriğin menünün altında kalmaması için listelerin alt boşluğu.
  static double reservedHeight(BuildContext context) => 120 + MediaQuery.of(context).padding.bottom;

  @override
  Widget build(BuildContext context) {
    final unread = AppScope.of(context).unreadCount;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 22),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 66,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(33),
                boxShadow: const [
                  BoxShadow(color: Color(0x2917211B), blurRadius: 24, offset: Offset(0, 10)),
                ],
              ),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.view_week_outlined,
                    label: 'Projeler',
                    active: active == HomeTab.projects,
                    onTap: () => onSelect(HomeTab.projects),
                  ),
                  _NavItem(
                    icon: Icons.notifications_none_rounded,
                    label: 'Bildirimler',
                    active: active == HomeTab.notifications,
                    badge: unread,
                    onTap: () => onSelect(HomeTab.notifications),
                  ),
                  _NavItem(
                    icon: Icons.group_outlined,
                    label: 'Ekip',
                    active: active == HomeTab.team,
                    onTap: () => onSelect(HomeTab.team),
                  ),
                ],
              ),
            ),
          ),
          if (onAdd != null) ...[
            const SizedBox(width: 10),
            Material(
              color: AppColors.lime,
              shape: const CircleBorder(),
              elevation: 0,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onAdd,
                child: const SizedBox(
                  width: 66,
                  height: 66,
                  child: Icon(Icons.add_rounded, size: 30, color: AppColors.ink, semanticLabel: 'Yeni iş ekle'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.lime : AppColors.menuMuted;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: SizedBox(
          height: 66,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, size: 24, color: color),
                  if (badge > 0)
                    Positioned(
                      left: 16,
                      top: -6,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 18),
                        height: 18,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: AppColors.badge, borderRadius: BorderRadius.circular(9)),
                        child: Text('$badge', style: AppText.b(11, weight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppText.b(12, weight: active ? FontWeight.w600 : FontWeight.w500, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
