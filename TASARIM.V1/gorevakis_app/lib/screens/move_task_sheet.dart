import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/task_card.dart';

/// "Bu işle ne yapalım?" sayfasının sonucu.
enum MoveResult { moved, archived, deleted }

/// İş basılı tutulunca (ya da detaydaki sütun butonundan) açılır.
/// İş başka bir sütuna taşınır, arşivlenir ya da silinir.
Future<MoveResult?> showMoveSheet(BuildContext context, Task task) {
  return showAppSheet<MoveResult>(context, (_) => _MoveTaskSheet(taskId: task.id));
}

class _MoveTaskSheet extends StatefulWidget {
  const _MoveTaskSheet({required this.taskId});
  final String taskId;

  @override
  State<_MoveTaskSheet> createState() => _MoveTaskSheetState();
}

class _MoveTaskSheetState extends State<_MoveTaskSheet> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, MoveResult result, String message) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await action();
    navigator.pop(result);
    showToastOn(messenger, message);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final task = app.taskById(widget.taskId);
    final project = task == null ? null : app.projectById(task.projectId);
    if (task == null || project == null) return const SizedBox.shrink();

    final columns = project.columns;
    final media = MediaQuery.of(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Kaldırılmış kart
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 0, 42, 22),
            child: Transform.rotate(
              angle: -0.052,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(color: Color(0x4717211B), blurRadius: 44, offset: Offset(0, 22)),
                    BoxShadow(color: Color(0x1F17211B), blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: IgnorePointer(child: TaskCard(task: task)),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 18 + media.padding.bottom),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SheetHandle(),
                const SizedBox(height: 16),
                Text('Bu işle ne yapalım?', style: AppText.d(27, height: 1.1)),
                const SizedBox(height: 4),
                Text(
                  'Bir sütun seç ya da arşivle. Herkes anında görür.',
                  style: AppText.b(15, color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 168,
                  child: columns.length <= 3
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: hgap([
                            for (final c in columns) Expanded(child: _target(app, task, c)),
                          ], 8),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: columns.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(width: 108, child: _target(app, task, columns[i])),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Arşivle',
                        icon: Icons.archive_outlined,
                        background: AppColors.paper,
                        foreground: AppColors.ink,
                        onTap: () => _run(() => app.setArchived(task, true), MoveResult.archived, 'İş arşivlendi. Aramadan geri alabilirsin.'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: 'Sil',
                        icon: Icons.delete_outline_rounded,
                        background: AppColors.tomatoLight,
                        foreground: AppColors.tomato,
                        onTap: () async {
                          final ok = await confirm(
                            context,
                            title: 'İş silinsin mi?',
                            message: 'Bu işlem geri alınamaz. Sadece işi kaldırmak istiyorsan arşivle.',
                            confirmLabel: 'Sil',
                            destructive: true,
                          );
                          if (!ok || !mounted) return;
                          await _run(() => app.deleteTask(task), MoveResult.deleted, 'İş silindi.');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  child: Text('Vazgeç', style: AppText.b(15, weight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _target(AppState app, Task task, BoardColumn column) {
    final current = column.id == task.columnId;
    final background = Color(column.colorValue);
    final dark = background.computeLuminance() < 0.3;
    final fg = dark ? Colors.white : AppColors.ink;

    return Material(
      color: current ? AppColors.paper : background,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: current
            ? null
            : () => _run(() => app.moveTask(task, column.id), MoveResult.moved, 'İş “${column.name}” sütununa taşındı.'),
        child: Container(
          height: current ? 150 : 168,
          padding: const EdgeInsets.fromLTRB(10, 14, 9, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (current)
                Text('Şu an burada', style: AppText.b(12, color: AppColors.muted))
              else
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: dark ? AppColors.lime : AppColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    size: 18,
                    color: dark ? AppColors.ink : AppColors.lime,
                  ),
                ),
              Text(
                column.name,
                style: AppText.d(15, weight: FontWeight.w600, color: current ? AppColors.muted : fg, spacing: -0.3, height: 1.1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 8),
              Text(label, style: AppText.b(15, weight: FontWeight.w600, color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}
