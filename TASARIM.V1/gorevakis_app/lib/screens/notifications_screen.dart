import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../util/format.dart';
import '../widgets/avatar.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';
import 'task_detail_screen.dart';

/// Bildirimler: sana verilen işler ve yaklaşan teslim saatleri.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (app.me == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final list = List<AppNotification>.of(app.notifications)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final unread = app.unreadCount;

    final today = <AppNotification>[];
    final week = <AppNotification>[];
    final older = <AppNotification>[];
    for (final n in list) {
      final d = daysFrom(n.createdAt, now);
      if (d == 0) {
        today.add(n);
      } else if (d > -7) {
        week.add(n);
      } else {
        older.add(n);
      }
    }

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.only(top: 14, bottom: AppBottomNav.reservedHeight(context)),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Text('Bildirimler', style: AppText.d(34, height: 1.05, spacing: -0.85))),
                if (unread > 0) LinkText('Hepsini okudum', onTap: app.markAllRead),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              unread > 0 ? '$unread yeni' : 'Yeni bildirim yok',
              style: AppText.b(15, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 14),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('Henüz bildirimin yok.', style: AppText.b(15, color: AppColors.muted)),
            ),
          ..._group(context, 'Bugün', today, now),
          ..._group(context, 'Bu hafta', week, now),
          ..._group(context, 'Daha önce', older, now),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 10, 22, 0),
            child: InfoNote(
              'Sadece sana verilen işler ve teslim saatleri için haber veririz. '
              'Bildirimleri profilinden sessize alabilirsin.',
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _group(BuildContext context, String title, List<AppNotification> items, DateTime now) {
    if (items.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 8),
        child: Text(title, style: AppText.b(13, weight: FontWeight.w600, color: AppColors.muted)),
      ),
      for (final n in items)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _NotificationTile(notification: n, now: now),
        ),
      const SizedBox(height: 8),
    ];
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.now});
  final AppNotification notification;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final n = notification;
    final task = app.taskById(n.taskId);
    final project = task == null ? null : app.projectById(task.projectId);
    final from = app.userById(n.fromUserId);
    final done = task != null && app.isDone(task);

    Widget leading = const SizedBox(width: 40, height: 40);
    String top = '';
    Color topColor = AppColors.muted;
    FontWeight topWeight = FontWeight.w400;
    final details = <String>[stamp(n.createdAt, now)];
    if (project != null) details.add(project.name);

    switch (n.kind) {
      case NotificationKind.assigned:
        leading = UserAvatar(user: from, size: 40);
        top = '${from?.shortName ?? 'Biri'} sana yeni bir iş verdi';
        if (task != null && task.dueAt != null) details.add(dueShort(task, now));
        break;
      case NotificationKind.dueTomorrow:
        leading = const _IconBadge(icon: Icons.schedule_rounded, background: AppColors.tomatoLight, foreground: AppColors.tomato);
        top = 'Yarın teslim';
        topColor = AppColors.tomato;
        topWeight = FontWeight.w600;
        if (task != null && task.dueAt != null) details.add(dueShort(task, now));
        break;
      case NotificationKind.dueToday:
        leading = done
            ? const _IconBadge(icon: Icons.check_rounded, background: AppColors.tray, foreground: AppColors.ink)
            : const _IconBadge(icon: Icons.schedule_rounded, background: AppColors.tomatoLight, foreground: AppColors.tomato);
        top = 'Bugün teslim';
        if (done) details.add('tamamlandı');
        break;
    }

    return Material(
      color: n.read ? Colors.transparent : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: n.read ? const BorderSide(color: AppColors.line2) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          await app.markRead(n);
          if (task == null) {
            showToastOn(messenger, 'Bu iş artık yok.');
            return;
          }
          navigator.push(MaterialPageRoute<void>(builder: (_) => TaskDetailScreen(taskId: task.id)));
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(top, style: AppText.b(13, weight: topWeight, color: topColor)),
                    const SizedBox(height: 3),
                    Text(
                      task?.title ?? 'Silinmiş iş',
                      style: AppText.b(15, weight: FontWeight.w600, height: 1.35),
                    ),
                    const SizedBox(height: 4),
                    Text(details.join(' · '), style: AppText.b(12, color: AppColors.muted)),
                  ],
                ),
              ),
              if (!n.read)
                Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.only(left: 8, top: 6),
                  decoration: const BoxDecoration(color: AppColors.badge, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.background, required this.foreground});
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: foreground),
    );
  }
}
