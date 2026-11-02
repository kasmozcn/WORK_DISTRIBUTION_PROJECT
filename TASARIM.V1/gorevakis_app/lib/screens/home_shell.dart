import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../widgets/bottom_nav.dart';
import 'notifications_screen.dart';
import 'projects_screen.dart';
import 'task_editor_sheet.dart';
import 'team_screen.dart';

/// Girişten sonraki ana iskelet: Projeler, Bildirimler, Ekip sekmeleri.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (app.me == null) return const Scaffold();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(
              index: app.tab.index,
              children: const [
                ProjectsScreen(),
                NotificationsScreen(),
                TeamScreen(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              active: app.tab,
              onSelect: app.setTab,
              onAdd: () => openTaskEditor(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Alt menüden bir sekmeye geçer; açık alt sayfaları kapatıp ana iskelete döner.
void goToTab(BuildContext context, HomeTab tab) {
  AppScope.read(context).setTab(tab);
  Navigator.of(context).popUntil((route) => route.isFirst);
}
