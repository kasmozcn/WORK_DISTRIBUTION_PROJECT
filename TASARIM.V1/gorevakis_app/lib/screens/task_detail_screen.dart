import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../util/format.dart';
import '../widgets/avatar.dart';
import '../widgets/common.dart';
import 'move_task_sheet.dart';
import 'task_editor_sheet.dart';

/// İş detayı: not, bilgiler ve iş üzerindeki konuşma.
class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key, required this.taskId});
  final String taskId;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _comment = TextEditingController();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _comment.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _send(Task task) async {
    final text = _comment.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    await AppScope.read(context).addComment(task, text);
    if (!mounted) return;
    _comment.clear();
    setState(() => _sending = false);
  }

  Future<void> _openMove(Task task) async {
    final result = await showMoveSheet(context, task);
    if (!mounted) return;
    if (result == MoveResult.archived || result == MoveResult.deleted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final me = app.me;
    final task = app.taskById(widget.taskId);
    final project = task == null ? null : app.projectById(task.projectId);
    if (me == null) return const Scaffold();
    if (task == null || project == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: CircleButton(icon: Icons.chevron_left_rounded, onTap: () => Navigator.of(context).pop()),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Text('Bu iş artık yok.', style: AppText.b(16, color: AppColors.muted)),
              ),
            ],
          ),
        ),
      );
    }

    final canEdit = app.canEdit(project);
    final column = project.columnById(task.columnId);
    final done = column?.isDone ?? false;
    final assignee = app.userById(task.assigneeId);
    final creator = app.userById(task.createdBy);
    final label = dueLabelFor(task, done: done);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.tray,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Row(
                children: [
                  CircleButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Geri',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Pill(
                        label: column?.name ?? '',
                        trailingIcon: canEdit ? Icons.keyboard_arrow_down_rounded : null,
                        onTap: canEdit ? () => _openMove(task) : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (canEdit) ...[
                    Pill(
                      label: 'Düzenle',
                      icon: Icons.edit_outlined,
                      onTap: () => openTaskEditor(context, projectId: project.id, taskId: task.id),
                    ),
                    const SizedBox(width: 8),
                    CircleButton(
                      icon: Icons.more_horiz_rounded,
                      tooltip: 'Diğer işlemler',
                      onTap: () => _openMove(task),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.title, style: AppText.d(29, height: 1.08, spacing: -0.7)),
                          const SizedBox(height: 16),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10,
                            runSpacing: 8,
                            children: [
                              UserAvatar(user: assignee, size: 32),
                              Text(
                                assignee == null
                                    ? 'Sahibi yok'
                                    : assignee.id == me.id
                                        ? 'Senin işin'
                                        : assignee.fullName,
                                style: AppText.b(14),
                              ),
                              if (label != null)
                                label.tone == DueTone.normal
                                    ? Tag(
                                        label: label.text,
                                        background: Colors.white,
                                        foreground: AppColors.ink,
                                        radius: 10,
                                        fontSize: 14,
                                        weight: FontWeight.w600,
                                      )
                                    : Tag(
                                        label: label.text,
                                        background: AppColors.tomatoLight,
                                        foreground: AppColors.tomato,
                                        radius: 10,
                                        fontSize: 14,
                                        weight: FontWeight.w600,
                                      ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(22, 24, 22, 28),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _heading('Not'),
                          const SizedBox(height: 6),
                          if (task.note.isEmpty)
                            Text('Not eklenmemiş.', style: AppText.b(15, color: AppColors.muted))
                          else
                            Text.rich(
                              TextSpan(
                                style: AppText.b(15, color: AppColors.text2, height: 1.55),
                                children: [
                                  TextSpan(text: '${task.note} '),
                                  TextSpan(
                                    text: '${creator?.shortName ?? ''}, ${dayMonth(task.createdAt)}',
                                    style: const TextStyle(color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 22),
                          _heading('Bilgiler'),
                          const SizedBox(height: 4),
                          _InfoRow(
                            label: 'Sorumlu',
                            onTap: canEdit ? () => openTaskEditor(context, projectId: project.id, taskId: task.id) : null,
                            child: Row(
                              children: [
                                UserAvatar(user: assignee, size: 26),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    assignee == null
                                        ? 'Sahibi yok'
                                        : assignee.id == me.id
                                            ? '${assignee.fullName} (sen)'
                                            : assignee.fullName,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.b(15, weight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const RowDivider(),
                          _InfoRow(
                            label: 'Son tarih',
                            onTap: canEdit ? () => openTaskEditor(context, projectId: project.id, taskId: task.id) : null,
                            child: Text(dueLong(task), style: AppText.b(15, weight: FontWeight.w500)),
                          ),
                          const RowDivider(),
                          _InfoRow(
                            label: 'Sütun',
                            onTap: canEdit ? () => _openMove(task) : null,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Color(column?.colorValue ?? 0xFFE0E4DA),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.outline),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(column?.name ?? '', style: AppText.b(15, weight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          _heading('Konuşma'),
                          const SizedBox(height: 10),
                          if (task.comments.isEmpty)
                            Text(
                              canEdit ? 'Henüz yorum yok. İlk yazan sen ol.' : 'Henüz yorum yok.',
                              style: AppText.b(15, color: AppColors.muted),
                            ),
                          for (final c in task.comments)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CommentBubble(
                                comment: c,
                                author: app.userById(c.authorId),
                                mine: c.authorId == me.id,
                                now: now,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (canEdit)
              Container(
                padding: EdgeInsets.fromLTRB(14, 12, 14, 12 + MediaQuery.of(context).padding.bottom),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.line)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _comment,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(task),
                        style: AppText.b(15),
                        decoration: InputDecoration(
                          hintText: 'Bir şey yaz…',
                          hintStyle: AppText.b(15, color: AppColors.muted),
                          filled: true,
                          fillColor: AppColors.paper,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleButton(
                      icon: Icons.arrow_forward_rounded,
                      size: 48,
                      tooltip: 'Gönder',
                      background: _comment.text.trim().isEmpty ? AppColors.line2 : AppColors.ink,
                      foreground: _comment.text.trim().isEmpty ? AppColors.grey : AppColors.lime,
                      onTap: _sending ? null : () => _send(task),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _heading(String text) => Text(text, style: AppText.d(18, weight: FontWeight.w600, spacing: -0.2));
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.child, this.onTap});
  final String label;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            SizedBox(width: 88, child: Text(label, style: AppText.b(14, color: AppColors.muted))),
            Expanded(child: child),
            if (onTap != null) const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.grey),
          ],
        ),
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  const _CommentBubble({
    required this.comment,
    required this.author,
    required this.mine,
    required this.now,
  });

  final Comment comment;
  final AppUser? author;
  final bool mine;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final time = stamp(comment.createdAt, now);
    if (mine) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Container(
            padding: const EdgeInsets.fromLTRB(13, 9, 13, 9),
            decoration: const BoxDecoration(
              color: AppColors.lime,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(comment.text, style: AppText.b(14, height: 1.4)),
                const SizedBox(height: 2),
                Text(time, style: AppText.b(11, color: const Color(0xFF3A4A2A))),
              ],
            ),
          ),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        UserAvatar(user: author, size: 28),
        const SizedBox(width: 8),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 270),
            child: Container(
              padding: const EdgeInsets.fromLTRB(13, 9, 13, 9),
              decoration: const BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(author?.shortName ?? 'Silinmiş kişi', style: AppText.b(12, weight: FontWeight.w700, color: AppColors.pine)),
                  const SizedBox(height: 2),
                  Text(comment.text, style: AppText.b(14, height: 1.4)),
                  const SizedBox(height: 2),
                  Text(time, style: AppText.b(11, color: AppColors.muted)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }
}
