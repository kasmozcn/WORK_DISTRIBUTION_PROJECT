import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../util/format.dart';
import '../widgets/avatar.dart';
import '../widgets/common.dart';

/// Yeni iş ekleme ya da var olan işi düzenleme sayfasını açar.
///
/// [projectId] verilmezse kişinin iş ekleyebildiği ilk proje seçilir.
Future<void> openTaskEditor(BuildContext context, {String? projectId, String? taskId}) async {
  final app = AppScope.read(context);
  var id = projectId;
  if (id == null) {
    for (final p in app.activeProjects) {
      if (app.canEdit(p)) {
        id = p.id;
        break;
      }
    }
  }
  if (id == null) {
    showToast(context, 'İş ekleyebileceğin bir proje yok.');
    return;
  }
  final selectedProject = id;
  await showAppSheet<void>(
    context,
    (_) => _TaskEditorSheet(projectId: selectedProject, taskId: taskId),
  );
}

class _TaskEditorSheet extends StatefulWidget {
  const _TaskEditorSheet({required this.projectId, this.taskId});
  final String projectId;
  final String? taskId;

  @override
  State<_TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<_TaskEditorSheet> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  bool _showNote = false;
  String? _assigneeId;
  DateTime? _day;
  TimeOfDay? _time;
  String? _columnId;
  bool _busy = false;
  Task? _editing;

  @override
  void initState() {
    super.initState();
    final app = AppScope.read(context);
    final project = app.projectById(widget.projectId);
    final taskId = widget.taskId;
    final task = taskId == null ? null : app.taskById(taskId);
    _editing = task;
    if (task != null) {
      _title.text = task.title;
      _note.text = task.note;
      _showNote = task.note.isNotEmpty;
      _assigneeId = task.assigneeId;
      final due = task.dueAt;
      if (due != null) {
        _day = dateOnly(due);
        if (task.dueHasTime) _time = TimeOfDay(hour: due.hour, minute: due.minute);
      }
      _columnId = task.columnId;
    } else {
      final me = app.me;
      if (me != null && project != null && project.isMember(me.id)) _assigneeId = me.id;
      if (project != null && project.columns.isNotEmpty) _columnId = project.columns.first.id;
    }
    _title.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  DateTime? get _dueAt {
    final day = _day;
    if (day == null) return null;
    final time = _time;
    if (time == null) return day;
    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final columnId = _columnId;
    if (title.isEmpty || columnId == null || _busy) return;
    setState(() => _busy = true);
    final app = AppScope.read(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final editing = _editing;
    if (editing == null) {
      await app.createTask(TaskDraft(
        projectId: widget.projectId,
        title: title,
        note: _note.text.trim(),
        columnId: columnId,
        assigneeId: _assigneeId,
        dueAt: _dueAt,
        dueHasTime: _day != null && _time != null,
      ));
      navigator.pop();
      showToastOn(messenger, 'İş eklendi.');
    } else {
      await app.updateTask(editing.copyWith(
        title: title,
        note: _note.text.trim(),
        columnId: columnId,
        assigneeId: _assigneeId,
        dueAt: _dueAt,
        dueHasTime: _day != null && _time != null,
      ));
      navigator.pop();
      showToastOn(messenger, 'Değişiklikler kaydedildi.');
    }
  }

  Future<void> _pickDay() async {
    final today = dateOnly(DateTime.now());
    final initial = _day ?? today;
    final first = today.subtract(const Duration(days: 365));
    final last = today.add(const Duration(days: 730));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial.isBefore(first) ? initial : first,
      lastDate: initial.isAfter(last) ? initial : last,
      helpText: 'Son tarih',
      cancelText: 'Vazgeç',
      confirmText: 'Seç',
    );
    if (!mounted || picked == null) return;
    setState(() => _day = dateOnly(picked));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 17, minute: 0),
      helpText: 'Saat',
      cancelText: 'Vazgeç',
      confirmText: 'Seç',
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (!mounted || picked == null) return;
    setState(() => _time = picked);
  }

  String _notice(AppUser? assignee, AppUser? me) {
    final remind = _dueAt == null ? '' : ' Son tarihten bir gün önce de hatırlatılır.';
    if (assignee == null) return 'İş sahipsiz eklenecek; ekipten biri "Ben alırım" diyebilir.';
    if (assignee.id == me?.id) return 'İş sana verilecek.$remind';
    return 'Haber verilecek: ${assignee.fullName}.$remind';
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final project = app.projectById(widget.projectId);
    final me = app.me;
    if (project == null || me == null) return const SizedBox.shrink();

    final today = dateOnly(DateTime.now());
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final third = DateTime(today.year, today.month, today.day + 2);
    final day = _day;
    final isPreset = day != null && (day == today || day == tomorrow || day == third);
    final time = _time;
    const presetTimes = [TimeOfDay(hour: 9, minute: 0), TimeOfDay(hour: 12, minute: 0), TimeOfDay(hour: 17, minute: 0)];
    final isPresetTime = time != null && presetTimes.any((t) => t.hour == time.hour && t.minute == time.minute);

    final others = app.membersOf(project).where((u) => u.id != me.id).toList();
    final assignee = app.userById(_assigneeId);
    final editing = _editing != null;

    return SheetBody(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: AppText.b(14, weight: FontWeight.w600),
                    children: [
                      TextSpan(text: editing ? 'İşi düzenle' : 'Yeni iş'),
                      TextSpan(
                        text: ' · ${project.name}',
                        style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CircleButton(
                icon: Icons.close_rounded,
                size: 40,
                background: AppColors.paper,
                tooltip: 'Kapat',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _title,
                    autofocus: !editing,
                    minLines: 1,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppText.d(26, weight: FontWeight.w700, height: 1.15, spacing: -0.6),
                    decoration: InputDecoration(
                      hintText: 'Ne yapılacak?',
                      hintStyle: AppText.d(26, weight: FontWeight.w700, color: AppColors.grey, spacing: -0.6),
                      isDense: true,
                      contentPadding: const EdgeInsets.only(bottom: 8),
                      border: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ink, width: 2)),
                      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ink, width: 2)),
                      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.ink, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_showNote)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: AppTextField(controller: _note, hint: 'Not (isteğe bağlı)', maxLines: 4),
                    )
                  else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _showNote = true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.muted, padding: EdgeInsets.zero),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text('Not ekle', style: AppText.b(14, weight: FontWeight.w500, color: AppColors.muted)),
                      ),
                    ),
                  const SizedBox(height: 14),
                  _question('Kime?'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: hgap([
                        for (final u in others)
                          _PersonOption(
                            label: u.initials,
                            selected: _assigneeId == u.id,
                            onTap: () => setState(() => _assigneeId = u.id),
                            child: UserAvatar(user: u, size: 44),
                          ),
                        if (project.isMember(me.id))
                          _PersonOption(
                            label: 'Ben',
                            selected: _assigneeId == me.id,
                            onTap: () => setState(() => _assigneeId = me.id),
                            child: UserAvatar(user: me, size: 44),
                          ),
                        _PersonOption(
                          label: 'Sonra',
                          selected: _assigneeId == null,
                          onTap: () => setState(() => _assigneeId = null),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.grey, width: 1.5),
                            ),
                            child: const Icon(Icons.schedule_rounded, size: 20, color: AppColors.muted),
                          ),
                        ),
                      ], 10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _question('Ne zamana?'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoicePill(
                        label: 'Bugün',
                        selected: day == today,
                        onTap: () => setState(() => _day = day == today ? null : today),
                      ),
                      ChoicePill(
                        label: 'Yarın',
                        selected: day == tomorrow,
                        onTap: () => setState(() => _day = day == tomorrow ? null : tomorrow),
                      ),
                      ChoicePill(
                        label: weekdays[third.weekday - 1],
                        selected: day == third,
                        onTap: () => setState(() => _day = day == third ? null : third),
                      ),
                      ChoicePill(
                        label: day != null && !isPreset ? dayMonth(day) : 'Başka',
                        icon: Icons.calendar_today_outlined,
                        selected: day != null && !isPreset,
                        onTap: _pickDay,
                      ),
                    ],
                  ),
                  if (day != null) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in presetTimes)
                          ChoicePill(
                            label: '${two(t.hour)}.${two(t.minute)}',
                            selected: time != null && time.hour == t.hour && time.minute == t.minute,
                            onTap: () => setState(() {
                              final same = time != null && time.hour == t.hour && time.minute == t.minute;
                              _time = same ? null : t;
                            }),
                          ),
                        ChoicePill(
                          label: time != null && !isPresetTime ? '${two(time.hour)}.${two(time.minute)}' : 'Saat seç',
                          icon: Icons.schedule_rounded,
                          selected: time != null && !isPresetTime,
                          onTap: _pickTime,
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  _question('Hangi sütun?'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in project.columns)
                        _ColumnOption(
                          label: c.name,
                          selected: _columnId == c.id,
                          onTap: () => setState(() => _columnId = c.id),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          InfoNote(_notice(assignee, me), icon: Icons.notifications_none_rounded),
          const SizedBox(height: 14),
          PrimaryButton(
            label: editing ? 'Kaydet' : 'İşi ekle',
            background: AppColors.ink,
            foreground: Colors.white,
            arrowColor: AppColors.lime,
            busy: _busy,
            onTap: _title.text.trim().isEmpty ? null : _save,
          ),
        ],
      ),
    );
  }

  Widget _question(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: AppText.b(13, weight: FontWeight.w600, color: AppColors.muted)),
    );
  }
}

class _PersonOption extends StatelessWidget {
  const _PersonOption({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.ink : Colors.transparent, width: 2),
              ),
              child: child,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppText.b(12, weight: selected ? FontWeight.w700 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColumnOption extends StatelessWidget {
  const _ColumnOption({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.tray : AppColors.paper,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? AppColors.ink : Colors.transparent, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check_rounded, size: 16, color: AppColors.ink),
                const SizedBox(width: 6),
              ],
              Text(label, style: AppText.b(14, weight: selected ? FontWeight.w700 : FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
