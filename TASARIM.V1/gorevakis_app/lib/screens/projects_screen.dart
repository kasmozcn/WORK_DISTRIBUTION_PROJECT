import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../util/format.dart';
import '../widgets/avatar.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';
import 'board_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

/// Ana sayfa: seni bekleyen işler ve projelerin.
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final me = app.me;
    if (me == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final mine = app.myOpenTasks;
    final projects = app.activeProjects;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.only(top: 8, bottom: AppBottomNav.reservedHeight(context)),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: Text(longDate(now), style: AppText.b(14, color: AppColors.muted))),
                CircleButton(
                  icon: Icons.search_rounded,
                  tooltip: 'Ara',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
                  ),
                  child: UserAvatar(user: me, size: 40),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(waitingHeadline(mine.length), style: AppText.d(38, height: 1.02, spacing: -0.95)),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(waitingSentence(mine, now), style: AppText.b(15, color: AppColors.muted, height: 1.4)),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: Text('Projelerin', style: AppText.d(20, weight: FontWeight.w600))),
                Text('${projects.length} proje', style: AppText.b(14, color: AppColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (projects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Henüz bir projede değilsin. Yöneticin seni bir projeye ekleyince burada görünür.',
                style: AppText.b(15, color: AppColors.muted, height: 1.45),
              ),
            ),
          for (final p in projects)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _ProjectCard(project: p),
            ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final member = project.isMember(app.me!.id);
    final background = member ? Colors.white : AppColors.tray;

    final counts = <String>[];
    for (final c in project.columns) {
      final n = app.tasksInColumn(c).length;
      if (n > 0) counts.add('$n ${columnShortName(c.name)}');
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => BoardScreen(projectId: project.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.d(22, spacing: -0.4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  member
                      ? const Tag(label: 'Üyesin')
                      : const Tag(
                          label: 'İzleyicisin',
                          background: AppColors.paper,
                          foreground: AppColors.muted,
                          icon: Icons.visibility_outlined,
                        ),
                ],
              ),
              const SizedBox(height: 8),
              Text(project.summary, style: AppText.b(14, color: AppColors.muted, height: 1.4)),
              const SizedBox(height: 12),
              Row(
                children: [
                  AvatarStack(users: app.membersOf(project), background: background),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      counts.isEmpty ? 'Henüz iş yok' : counts.join(' · '),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.b(13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
