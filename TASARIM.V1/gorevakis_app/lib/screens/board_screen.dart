import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/common.dart';
import '../widgets/task_card.dart';
import 'home_shell.dart';
import 'move_task_sheet.dart';
import 'profile_screen.dart';
import 'project_info_screen.dart';
import 'search_screen.dart';
import 'task_detail_screen.dart';
import 'task_editor_sheet.dart';

/// Proje panosu: sütunlar yan yana, içlerinde işler.
///
/// Projeye atanmamış kişi panoyu izleyici olarak görür: iş ekleyemez,
/// taşıyamaz, "Ben alırım" diyemez.
class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key, required this.projectId});
  final String projectId;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  /// null: herkesin işleri; değilse sadece o kişinin işleri.
  String? _filterUserId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final me = app.me;
    final project = app.projectById(widget.projectId);
    if (me == null) return const Scaffold();
    if (project == null || project.archived) {
      return Scaffold(
        body: Center(child: Text('Bu proje artık yok.', style: AppText.b(16, color: AppColors.muted))),
      );
    }

    final canEdit = app.canEdit(project);
    final members = app.membersOf(project);
    final others = members.where((u) => u.id != me.id).toList();
    final iAmMember = project.isMember(me.id);
    final total = app.tasksOf(project).length;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    children: [
                      Pill(
                        label: 'Projeler',
                        icon: Icons.chevron_left_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
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
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _switchProject(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            project.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.d(34, height: 1.05, spacing: -0.85),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 30, color: AppColors.ink),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text('${members.length} kişi · $total iş', style: AppText.b(14, color: AppColors.muted)),
                      const SizedBox(width: 12),
                      LinkText(
                        'Proje bilgisi',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => ProjectInfoScreen(projectId: project.id)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Kimin işleri?', style: AppText.b(13, weight: FontWeight.w600, color: AppColors.muted)),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: hgap([
                      Center(
                        child: ChoicePill(
                          label: 'Herkes',
                          selected: _filterUserId == null,
                          horizontalPadding: 18,
                          background: Colors.white,
                          onTap: () => setState(() => _filterUserId = null),
                        ),
                      ),
                      for (final u in others)
                        Center(
                          child: GestureDetector(
                            onTap: () => setState(() => _filterUserId = _filterUserId == u.id ? null : u.id),
                            child: Tooltip(
                              message: u.fullName,
                              child: UserAvatar(
                                user: u,
                                size: _filterUserId == u.id ? 40 : 44,
                                selected: _filterUserId == u.id,
                              ),
                            ),
                          ),
                        ),
                      if (iAmMember)
                        Center(
                          child: _MeChip(
                            selected: _filterUserId == me.id,
                            onTap: () => setState(() => _filterUserId = _filterUserId == me.id ? null : me.id),
                          ),
                        ),
                    ], 8),
                  ),
                ),
                if (!canEdit)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: const InfoNote(
                        'İzleyicisin. Bu projede değişiklik yapamazsın; katılmak için yöneticine yaz.',
                        icon: Icons.visibility_outlined,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(20, 18, 20, AppBottomNav.reservedHeight(context) - 14),
                    itemCount: project.columns.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final column = project.columns[i];
                      var tasks = app.tasksInColumn(column);
                      if (_filterUserId != null) {
                        tasks = tasks.where((t) => t.assigneeId == _filterUserId).toList();
                      }
                      return Align(
                        alignment: Alignment.topCenter,
                        child: ColumnTray(
                          project: project,
                          column: column,
                          tasks: tasks,
                          canEdit: canEdit,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(
              active: HomeTab.projects,
              onSelect: (tab) => goToTab(context, tab),
              onAdd: canEdit ? () => openTaskEditor(context, projectId: project.id) : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _switchProject(BuildContext context) async {
    final app = AppScope.read(context);
    final selected = await showAppSheet<String>(
      context,
      (sheetContext) => SheetBody(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            const SizedBox(height: 16),
            Text('Projeye geç', style: AppText.d(24, weight: FontWeight.w600)),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final p in app.activeProjects)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(p.name, style: AppText.b(16, weight: FontWeight.w600)),
                      subtitle: Text(
                        p.isMember(app.me!.id) ? 'Üyesin' : 'İzleyicisin',
                        style: AppText.b(13, color: AppColors.muted),
                      ),
                      trailing: p.id == widget.projectId
                          ? const Icon(Icons.check_rounded, color: AppColors.forest)
                          : const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
                      onTap: () => Navigator.of(sheetContext).pop(p.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (selected == null || selected == widget.projectId || !context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => BoardScreen(projectId: selected)),
    );
  }
}

class _MeChip extends StatelessWidget {
  const _MeChip({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final me = AppScope.of(context).me;
    return Material(
      color: selected ? AppColors.ink : Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? AppColors.ink : AppColors.outline, width: 1.5),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.only(left: 4, right: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(user: me, size: 34),
              const SizedBox(width: 8),
              Text(
                'Ben',
                style: AppText.b(14, weight: FontWeight.w500, color: selected ? Colors.white : AppColors.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Panodaki bir sütun (tepsi).
class ColumnTray extends StatelessWidget {
  const ColumnTray({
    super.key,
    required this.project,
    required this.column,
    required this.tasks,
    required this.canEdit,
  });

  final Project project;
  final BoardColumn column;
  final List<Task> tasks;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final background = Color(column.colorValue);
    final dark = background.computeLuminance() < 0.3;
    final titleColor = dark ? Colors.white : AppColors.ink;
    final countColor = dark ? AppColors.sage : (column.colorValue == 0xFFE0E4DA ? AppColors.muted : AppColors.ink);

    return Container(
      width: 316,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(28)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    column.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.d(24, weight: FontWeight.w600, color: titleColor, spacing: -0.5),
                  ),
                ),
                Text('${tasks.length}', style: AppText.d(24, weight: FontWeight.w400, color: countColor)),
              ],
            ),
          ),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
              child: Text(
                'Bu sütunda iş yok.',
                style: AppText.b(14, color: dark ? AppColors.sage : AppColors.muted),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final task = tasks[i];
                  return TaskCard(
                    task: task,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => TaskDetailScreen(taskId: task.id)),
                    ),
                    onLongPress: canEdit ? () => showMoveSheet(context, task) : null,
                    onTake: canEdit && task.assigneeId == null
                        ? () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await app.takeTask(task);
                            showToastOn(messenger, 'İş artık sende.');
                          }
                        : null,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
