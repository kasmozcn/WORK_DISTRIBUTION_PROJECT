import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../util/format.dart';
import 'avatar.dart';
import 'common.dart';

/// Panodaki iş kartı.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onLongPress,
    this.onTake,
  });

  final Task task;
  final VoidCallback? onTap;

  /// Basılı tutunca "Bu işle ne yapalım?" sayfası açılır.
  final VoidCallback? onLongPress;

  /// Sahipsiz işte "Ben alırım" butonu. null ise buton gösterilmez.
  final VoidCallback? onTake;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final done = app.isDone(task);
    final label = dueLabelFor(task, done: done);
    final assignee = app.userById(task.assigneeId);

    final extras = <String>[
      if (task.comments.isNotEmpty) '${task.comments.length} yorum',
      if (task.assigneeId == null) 'Sahibi yok',
    ];

    Widget? due;
    if (label != null) {
      due = label.tone == DueTone.overdue
          ? OverdueTag(label.text)
          : Text(
              label.text,
              style: AppText.b(
                13,
                weight: label.tone == DueTone.soon ? FontWeight.w600 : FontWeight.w400,
                color: label.tone == DueTone.soon ? AppColors.tomato : AppColors.muted,
              ),
            );
    }

    Widget trailing = const SizedBox.shrink();
    if (assignee != null) {
      trailing = UserAvatar(user: assignee, size: 28);
    } else if (onTake != null) {
      trailing = _TakeButton(onTap: onTake!);
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: AppText.b(16, weight: FontWeight.w500, height: 1.35),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 28),
                child: Row(
                  children: [
                    if (due != null) due,
                    if (extras.isNotEmpty)
                      Flexible(
                        child: Text(
                          (due != null ? ' · ' : '') + extras.join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.b(13, color: AppColors.muted),
                        ),
                      ),
                    const Spacer(),
                    trailing,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TakeButton extends StatelessWidget {
  const _TakeButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(side: BorderSide(color: AppColors.ink, width: 1.5)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text('Ben alırım', style: AppText.b(14, weight: FontWeight.w600)),
        ),
      ),
    );
  }
}
