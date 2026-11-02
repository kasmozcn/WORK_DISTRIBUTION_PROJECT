import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../util/format.dart';
import '../util/turkish.dart';
import '../widgets/avatar.dart';
import '../widgets/common.dart';
import 'board_screen.dart';
import 'task_detail_screen.dart';

enum _Scope { all, tasks, projects, archive }

/// İşlerde, projelerde ve arşivde arama.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  _Scope _scope = _Scope.all;

  @override
  void initState() {
    super.initState();
    _query.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool _matches(String text, String q) => trLower(text).contains(q);

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (app.me == null) return const Scaffold();
    final q = trLower(_query.text.trim());

    final visibleProjectIds = app.activeProjects.map((p) => p.id).toSet();
    var tasks = <Task>[];
    var projects = <Project>[];
    var archived = <Task>[];
    if (q.isNotEmpty) {
      tasks = app.tasks
          .where((t) => !t.archived && visibleProjectIds.contains(t.projectId) && (_matches(t.title, q) || _matches(t.note, q)))
          .toList();
      projects = app.activeProjects.where((p) => _matches(p.name, q) || _matches(p.summary, q)).toList();
      archived = app.tasks
          .where((t) => t.archived && visibleProjectIds.contains(t.projectId) && (_matches(t.title, q) || _matches(t.note, q)))
          .toList();
    }
    final showTasks = _scope == _Scope.all || _scope == _Scope.tasks;
    final showProjects = _scope == _Scope.all || _scope == _Scope.projects;
    final showArchive = _scope == _Scope.all || _scope == _Scope.archive;
    final nothing = (!showTasks || tasks.isEmpty) && (!showProjects || projects.isEmpty) && (!showArchive || archived.isEmpty);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 10, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _query,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      style: AppText.b(16),
                      decoration: InputDecoration(
                        hintText: 'İş ya da proje ara',
                        hintStyle: AppText.b(16, color: AppColors.muted),
                        filled: true,
                        fillColor: Colors.white,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.ink),
                        suffixIcon: _query.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Temizle',
                                onPressed: _query.clear,
                                icon: const Icon(Icons.cancel_rounded, size: 20, color: AppColors.grey),
                              ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: const BorderSide(color: AppColors.ink, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: const BorderSide(color: AppColors.ink, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(26),
                          borderSide: const BorderSide(color: AppColors.ink, width: 2),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Vazgeç', style: AppText.b(15, weight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 58,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                children: hgap([
                  for (final s in _Scope.values)
                    ChoicePill(
                      label: _label(s),
                      selected: _scope == s,
                      background: Colors.white,
                      onTap: () => setState(() => _scope = s),
                    ),
                ], 8),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 40 + MediaQuery.of(context).padding.bottom),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  if (q.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text('İş adı, not ya da proje adıyla arayabilirsin.', style: AppText.b(15, color: AppColors.muted)),
                    )
                  else if (nothing)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text('“${_query.text.trim()}” için sonuç yok.', style: AppText.b(15, color: AppColors.muted)),
                    ),
                  if (showTasks && tasks.isNotEmpty) ...[
                    _section('İşler · ${tasks.length}'),
                    for (final t in tasks) _TaskResult(task: t, query: q),
                  ],
                  if (showProjects && projects.isNotEmpty) ...[
                    _section('Projeler · ${projects.length}'),
                    for (final p in projects) _ProjectResult(project: p, query: q),
                  ],
                  if (showArchive && archived.isNotEmpty) ...[
                    _section('Arşivde · ${archived.length}'),
                    for (final t in archived) _ArchivedResult(task: t, query: q),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: InfoNote('Arşivlenen işler de aramada çıkar; istersen geri alabilirsin.'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label(_Scope s) {
    if (s == _Scope.tasks) return 'İşler';
    if (s == _Scope.projects) return 'Projeler';
    if (s == _Scope.archive) return 'Arşiv';
    return 'Tümü';
  }

  Widget _section(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 8),
      child: Text(text, style: AppText.b(13, weight: FontWeight.w600, color: AppColors.muted)),
    );
  }
}

/// Aranan kelimeyi yeşil zeminle vurgular.
class _Highlighted extends StatelessWidget {
  const _Highlighted({required this.text, required this.query, required this.style});
  final String text;
  final String query;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: style);
    final lower = trLower(text);
    final spans = <TextSpan>[];
    var start = 0;
    while (true) {
      final i = lower.indexOf(query, start);
      if (i < 0) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (i > start) spans.add(TextSpan(text: text.substring(start, i)));
      spans.add(TextSpan(
        text: text.substring(i, i + query.length),
        style: const TextStyle(backgroundColor: AppColors.lime),
      ));
      start = i + query.length;
    }
    return Text.rich(TextSpan(style: style, children: spans));
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.child, required this.onTap, this.color = Colors.white});
  final Widget child;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _TaskResult extends StatelessWidget {
  const _TaskResult({required this.task, required this.query});
  final Task task;
  final String query;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final project = app.projectById(task.projectId);
    final column = project?.columnById(task.columnId);
    final done = column?.isDone ?? false;
    final label = dueLabelFor(task, done: done);
    final overdue = label?.tone == DueTone.overdue;
    final where = overdue || task.dueAt == null || done ? column?.name ?? '' : dueShort(task, DateTime.now());
    final assignee = app.userById(task.assigneeId);

    return _ResultCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => TaskDetailScreen(taskId: task.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Highlighted(text: task.title, query: query, style: AppText.b(16, weight: FontWeight.w500, height: 1.35)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${project?.name ?? ''} · ${trCapitalize(where)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.b(13, color: AppColors.muted),
                ),
              ),
              if (overdue && label != null)
                OverdueTag(label.text)
              else if (assignee != null)
                UserAvatar(user: assignee, size: 26),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectResult extends StatelessWidget {
  const _ProjectResult({required this.project, required this.query});
  final Project project;
  final String query;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return _ResultCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => BoardScreen(projectId: project.id)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Highlighted(text: project.name, query: query, style: AppText.d(18, weight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  '${app.membersOf(project).length} kişi · ${app.tasksOf(project).length} iş',
                  style: AppText.b(13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
        ],
      ),
    );
  }
}

class _ArchivedResult extends StatelessWidget {
  const _ArchivedResult({required this.task, required this.query});
  final Task task;
  final String query;

  @override
  Widget build(BuildContext context) {
    final AppState app = AppScope.of(context);
    final project = app.projectById(task.projectId);
    final canEdit = project != null && app.canEdit(project);
    final date = task.dueAt ?? task.createdAt;

    return _ResultCard(
      color: AppColors.tray,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => TaskDetailScreen(taskId: task.id)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Highlighted(
            text: task.title,
            query: query,
            style: AppText.b(16, weight: FontWeight.w500, color: AppColors.muted, height: 1.35),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${project?.name ?? ''} · ${dayMonth(date)}',
                  style: AppText.b(13, color: AppColors.muted),
                ),
              ),
              if (canEdit)
                Pill(
                  label: 'Geri al',
                  icon: Icons.undo_rounded,
                  height: 36,
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await app.setArchived(task, false);
                    showToastOn(messenger, 'İş panoya geri döndü.');
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
