import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar.dart';
import '../widgets/common.dart';

/// Proje bilgisi: amaç, sorumlular ve görev alanları, sütunlar, notlar.
class ProjectInfoScreen extends StatelessWidget {
  const ProjectInfoScreen({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final me = app.me;
    final project = app.projectById(projectId);
    if (me == null) return const Scaffold();
    if (project == null || project.archived) {
      return Scaffold(
        body: Center(child: Text('Bu proje artık yok.', style: AppText.b(16, color: AppColors.muted))),
      );
    }
    final canEdit = app.canEdit(project);
    final member = project.isMember(me.id);
    final members = app.membersOf(project);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(top: 8, bottom: 40 + MediaQuery.of(context).padding.bottom),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  CircleButton(
                    icon: Icons.chevron_left_rounded,
                    tooltip: 'Geri',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Proje bilgisi', style: AppText.b(15, weight: FontWeight.w600))),
                  if (canEdit)
                    Pill(label: 'Düzenle', icon: Icons.edit_outlined, onTap: () => _editTexts(context, project)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  member
                      ? const Tag(label: 'Üyesin')
                      : const Tag(
                          label: 'İzleyicisin',
                          background: Colors.white,
                          foreground: AppColors.muted,
                          icon: Icons.visibility_outlined,
                        ),
                  const SizedBox(height: 8),
                  Text(project.name, style: AppText.d(34, height: 1.05, spacing: -0.85)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: vgap([
                  SectionCard(
                    title: 'Amaç ve konu',
                    children: [
                      Text(
                        project.purpose.isEmpty ? 'Henüz yazılmamış.' : project.purpose,
                        style: AppText.b(15, color: AppColors.text2, height: 1.5),
                      ),
                    ],
                  ),
                  SectionCard(
                    title: 'Sorumlular ve görev alanları',
                    gap: 6,
                    children: [
                      for (var i = 0; i < members.length; i++) ...[
                        if (i > 0) const RowDivider(),
                        _PersonRow(
                          user: members[i],
                          isMe: members[i].id == me.id,
                          duty: project.duties[members[i].id] ?? '',
                          onEditDuty: canEdit ? () => _editDuty(context, project, members[i]) : null,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Projeye kişi atamayı yönetici yapar. Atanmayanlar projeyi sadece izler.',
                        style: AppText.b(13, color: AppColors.muted, height: 1.45),
                      ),
                    ],
                  ),
                  SectionCard(
                    title: 'Sütunlar',
                    trailing: canEdit ? Text('Sırayı değiştirmek için sürükle', style: AppText.b(13, color: AppColors.muted)) : null,
                    gap: 4,
                    children: [
                      _ColumnList(project: project, canEdit: canEdit),
                      if (canEdit)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => _addColumn(context, project),
                            style: TextButton.styleFrom(foregroundColor: AppColors.ink, padding: EdgeInsets.zero),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: Text('Sütun ekle', style: AppText.b(14, weight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                  SectionCard(
                    title: 'Notlar',
                    children: [
                      Text(
                        project.notes.isEmpty ? 'Not yok.' : project.notes,
                        style: AppText.b(15, color: project.notes.isEmpty ? AppColors.muted : AppColors.text2, height: 1.5),
                      ),
                      const WarningBox(
                        'Şifre ve erişim anahtarlarını buraya yazmayın. Bunlar için şirketin parola yöneticisini kullanın.',
                      ),
                    ],
                  ),
                  Center(
                    child: TextButton.icon(
                      onPressed: app.isManager ? () => _archive(context, project) : null,
                      style: TextButton.styleFrom(foregroundColor: AppColors.ink),
                      icon: const Icon(Icons.archive_outlined, size: 18, color: AppColors.muted),
                      label: Text.rich(
                        TextSpan(
                          style: AppText.b(14, weight: FontWeight.w600, color: app.isManager ? AppColors.ink : AppColors.grey),
                          children: const [
                            TextSpan(text: 'Projeyi arşivle'),
                            TextSpan(text: ' · Sadece yönetici', style: TextStyle(fontWeight: FontWeight.w400, color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ], 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTexts(BuildContext context, Project project) {
    return showAppSheet<void>(context, (_) => _ProjectTextEditor(project: project));
  }

  Future<void> _editDuty(BuildContext context, Project project, AppUser user) async {
    final app = AppScope.read(context);
    final value = await askText(
      context,
      title: '${user.fullName} · görev alanı',
      initial: project.duties[user.id] ?? '',
      hint: 'ör. Raporlama ve veritabanı',
    );
    if (value == null) return;
    final duties = Map<String, String>.of(project.duties)..[user.id] = value;
    await app.updateProject(project.copyWith(duties: duties));
  }

  Future<void> _addColumn(BuildContext context, Project project) async {
    final app = AppScope.read(context);
    final name = await askText(context, title: 'Yeni sütun', hint: 'ör. Test', confirmLabel: 'Ekle');
    if (name == null || name.isEmpty) return;
    final columns = List<BoardColumn>.of(project.columns);
    // Yeni sütun "bitti" sütunundan önce eklenir.
    var index = columns.indexWhere((c) => c.isDone);
    if (index < 0) index = columns.length;
    columns.insert(
      index,
      BoardColumn(id: 'col-${DateTime.now().microsecondsSinceEpoch}', name: name, colorValue: 0xFFEADFC8),
    );
    await app.updateProject(project.copyWith(columns: columns));
  }

  Future<void> _archive(BuildContext context, Project project) async {
    final app = AppScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirm(
      context,
      title: 'Proje arşivlensin mi?',
      message: 'Proje listeden kalkar, işleri silinmez. Gerekirse geri açılabilir.',
      confirmLabel: 'Arşivle',
      destructive: true,
    );
    if (!ok) return;
    await app.updateProject(project.copyWith(archived: true));
    navigator.popUntil((route) => route.isFirst);
    showToastOn(messenger, '“${project.name}” arşivlendi.');
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.user, required this.isMe, required this.duty, this.onEditDuty});
  final AppUser user;
  final bool isMe;
  final String duty;
  final VoidCallback? onEditDuty;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEditDuty,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            UserAvatar(user: user, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isMe ? '${user.fullName} (sen)' : user.fullName, style: AppText.b(15, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    duty.isEmpty ? 'Görev alanı yazılmamış' : duty,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.b(13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sürükleyerek sırası değiştirilebilen sütun listesi.
class _ColumnList extends StatelessWidget {
  const _ColumnList({required this.project, required this.canEdit});
  final Project project;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final columns = project.columns;
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      padding: EdgeInsets.zero,
      onReorder: (oldIndex, newIndex) {
        if (!canEdit) return;
        final list = List<BoardColumn>.of(columns);
        if (newIndex > oldIndex) newIndex -= 1;
        final item = list.removeAt(oldIndex);
        list.insert(newIndex, item);
        app.updateProject(project.copyWith(columns: list));
      },
      children: [
        for (var i = 0; i < columns.length; i++)
          _ColumnRow(
            key: ValueKey(columns[i].id),
            index: i,
            column: columns[i],
            count: app.tasksInColumn(columns[i]).length,
            canEdit: canEdit,
            onRemove: app.isManager && !columns[i].isDone && app.tasksInColumn(columns[i]).isEmpty && columns.length > 1
                ? () => _remove(context, app, columns[i])
                : null,
            showDivider: i > 0,
          ),
      ],
    );
  }

  Future<void> _remove(BuildContext context, AppState app, BoardColumn column) async {
    final ok = await confirm(
      context,
      title: 'Sütun kaldırılsın mı?',
      message: '“${column.name}” sütununda iş yok. Kaldırınca panoda görünmez.',
      confirmLabel: 'Kaldır',
      destructive: true,
    );
    if (!ok) return;
    final list = project.columns.where((c) => c.id != column.id).toList();
    await app.updateProject(project.copyWith(columns: list));
  }
}

class _ColumnRow extends StatelessWidget {
  const _ColumnRow({
    super.key,
    required this.index,
    required this.column,
    required this.count,
    required this.canEdit,
    required this.showDivider,
    this.onRemove,
  });

  final int index;
  final BoardColumn column;
  final int count;
  final bool canEdit;
  final bool showDivider;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        border: showDivider ? const Border(top: BorderSide(color: AppColors.line)) : null,
      ),
      child: Row(
        children: [
          if (canEdit)
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Icon(Icons.drag_indicator_rounded, size: 20, color: AppColors.grey),
              ),
            ),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Color(column.colorValue),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.outline),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(column.name, style: AppText.b(15, weight: FontWeight.w500))),
          Text('$count iş', style: AppText.b(13, color: AppColors.muted)),
          if (onRemove != null)
            IconButton(
              tooltip: 'Sütunu kaldır',
              onPressed: onRemove,
              icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.muted),
            ),
        ],
      ),
    );
    return row;
  }
}

/// "Amaç ve konu" ve "Notlar" düzenleme sayfası.
class _ProjectTextEditor extends StatefulWidget {
  const _ProjectTextEditor({required this.project});
  final Project project;

  @override
  State<_ProjectTextEditor> createState() => _ProjectTextEditorState();
}

class _ProjectTextEditorState extends State<_ProjectTextEditor> {
  late final _purpose = TextEditingController(text: widget.project.purpose);
  late final _notes = TextEditingController(text: widget.project.notes);
  bool _busy = false;

  @override
  void dispose() {
    _purpose.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    final app = AppScope.read(context);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final latest = app.projectById(widget.project.id) ?? widget.project;
    await app.updateProject(latest.copyWith(purpose: _purpose.text.trim(), notes: _notes.text.trim()));
    navigator.pop();
    showToastOn(messenger, 'Proje bilgisi kaydedildi.');
  }

  @override
  Widget build(BuildContext context) {
    return SheetBody(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          const SizedBox(height: 16),
          Text('Proje bilgisini düzenle', style: AppText.d(24, weight: FontWeight.w600)),
          const SizedBox(height: 14),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Amaç ve konu', style: AppText.b(13, weight: FontWeight.w600, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  AppTextField(controller: _purpose, maxLines: 4),
                  const SizedBox(height: 16),
                  Text('Notlar', style: AppText.b(13, weight: FontWeight.w600, color: AppColors.muted)),
                  const SizedBox(height: 8),
                  AppTextField(controller: _notes, maxLines: 4),
                  const SizedBox(height: 10),
                  const WarningBox('Şifre ve erişim anahtarlarını buraya yazmayın.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Kaydet', busy: _busy, onTap: _save),
        ],
      ),
    );
  }
}
