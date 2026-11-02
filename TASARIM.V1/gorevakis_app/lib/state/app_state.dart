import 'package:flutter/foundation.dart';

import '../data/models.dart';
import '../data/repository.dart';
import '../util/turkish.dart';

enum HomeTab { projects, notifications, team }

/// Ekranların okuduğu ortak durum.
///
/// Ekranlar veriyi buradan okur ve değişiklikleri buradaki metotlarla yapar.
/// Her değişiklikten sonra veriler repository'den yeniden okunur ve ekranlar
/// kendiliğinden güncellenir.
class AppState extends ChangeNotifier {
  AppState(this.repository);

  final GorevRepository repository;

  AppUser? me;
  List<AppUser> users = const [];
  List<Project> projects = const [];
  List<Task> tasks = const [];
  List<AppNotification> notifications = const [];
  NotificationSettings settings = const NotificationSettings();
  HomeTab tab = HomeTab.projects;

  bool get isManager => me?.isManager ?? false;

  // --- Oturum ---------------------------------------------------------------

  Future<void> signIn(String email, String password) async {
    me = await repository.signIn(email.trim(), password);
    tab = HomeTab.projects;
    await refresh();
  }

  Future<void> signOut() async {
    await repository.signOut();
    me = null;
    users = const [];
    projects = const [];
    tasks = const [];
    notifications = const [];
    tab = HomeTab.projects;
    notifyListeners();
  }

  /// Tüm verileri repository'den yeniden okur.
  Future<void> refresh() async {
    users = await repository.fetchUsers();
    projects = await repository.fetchProjects();
    tasks = await repository.fetchTasks();
    notifications = await repository.fetchNotifications();
    settings = await repository.fetchNotificationSettings();
    final id = me?.id;
    if (id != null) me = userById(id) ?? me;
    notifyListeners();
  }

  void setTab(HomeTab value) {
    if (tab == value) return;
    tab = value;
    notifyListeners();
  }

  // --- Okuma yardımcıları -----------------------------------------------------

  AppUser? userById(String? id) {
    if (id == null) return null;
    for (final u in users) {
      if (u.id == id) return u;
    }
    return null;
  }

  Project? projectById(String id) {
    for (final p in projects) {
      if (p.id == id) return p;
    }
    return null;
  }

  Task? taskById(String id) {
    for (final t in tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Arşivlenmemiş projeler; üyesi olunanlar önce.
  List<Project> get activeProjects {
    final list = projects.where((p) => !p.archived).toList();
    final id = me?.id;
    if (id != null) {
      list.sort((a, b) {
        final am = a.isMember(id) ? 0 : 1;
        final bm = b.isMember(id) ? 0 : 1;
        return am.compareTo(bm);
      });
    }
    return list;
  }

  /// Bu projede değişiklik yapabilir mi? (Üye ya da yönetici)
  bool canEdit(Project project) {
    final id = me?.id;
    if (id == null) return false;
    return isManager || project.isMember(id);
  }

  List<AppUser> membersOf(Project project) {
    return project.memberIds.map(userById).whereType<AppUser>().toList();
  }

  /// Projedeki arşivlenmemiş işler.
  List<Task> tasksOf(Project project) {
    return tasks.where((t) => t.projectId == project.id && !t.archived).toList();
  }

  List<Task> tasksInColumn(BoardColumn column) {
    return tasks.where((t) => t.columnId == column.id && !t.archived).toList();
  }

  bool isDone(Task task) {
    final column = projectById(task.projectId)?.columnById(task.columnId);
    return column?.isDone ?? false;
  }

  /// Bana verilmiş, bitmemiş işler; son tarihi yakın olan önce.
  List<Task> get myOpenTasks {
    final id = me?.id;
    if (id == null) return const [];
    final list = tasks.where((t) {
      if (t.archived || t.assigneeId != id || isDone(t)) return false;
      final p = projectById(t.projectId);
      return p != null && !p.archived;
    }).toList();
    list.sort((a, b) {
      final ad = a.dueAt, bd = b.dueAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });
    return list;
  }

  int get unreadCount => notifications.where((n) => !n.read).length;

  // --- İşler ----------------------------------------------------------------

  Future<Task> createTask(TaskDraft draft) async {
    final task = await repository.createTask(draft);
    await refresh();
    return task;
  }

  Future<void> updateTask(Task task) async {
    await repository.updateTask(task);
    await refresh();
  }

  Future<void> moveTask(Task task, String columnId) => updateTask(task.copyWith(columnId: columnId));

  Future<void> setArchived(Task task, bool archived) => updateTask(task.copyWith(archived: archived));

  Future<void> takeTask(Task task) => updateTask(task.copyWith(assigneeId: me?.id));

  Future<void> deleteTask(Task task) async {
    await repository.deleteTask(task.id);
    await refresh();
  }

  Future<void> addComment(Task task, String text) async {
    await repository.addComment(task.id, text);
    await refresh();
  }

  // --- Projeler ve kişiler --------------------------------------------------

  Future<void> updateProject(Project project) async {
    await repository.updateProject(project);
    await refresh();
  }

  Future<void> setMembership(Project project, String userId, bool member) {
    final ids = List<String>.of(project.memberIds);
    if (member && !ids.contains(userId)) ids.add(userId);
    if (!member) ids.remove(userId);
    return updateProject(project.copyWith(memberIds: ids));
  }

  /// Profilde ad, soyad, telefon değişince baş harfler de güncellenir.
  Future<void> updateProfile({String? firstName, String? lastName, String? phone}) async {
    final current = me;
    if (current == null) return;
    var updated = current.copyWith(firstName: firstName, lastName: lastName, phone: phone);
    if (updated.firstName.isNotEmpty && updated.lastName.isNotEmpty) {
      updated = updated.copyWith(
        initials: trUpper(updated.firstName.substring(0, 1)) + trUpper(updated.lastName.substring(0, 1)),
      );
    }
    await repository.updateUser(updated);
    await refresh();
  }

  Future<void> setManager(AppUser user, bool manager) async {
    await repository.updateUser(user.copyWith(isManager: manager));
    await refresh();
  }

  Future<void> invite(String email) => repository.inviteUser(email);

  Future<void> changePassword({required String current, required String next}) {
    return repository.changePassword(current: current, next: next);
  }

  // --- Bildirimler ----------------------------------------------------------

  Future<void> markRead(AppNotification notification) async {
    if (notification.read) return;
    await repository.markNotificationsRead([notification.id]);
    await refresh();
  }

  Future<void> markAllRead() async {
    final ids = notifications.where((n) => !n.read).map((n) => n.id).toList();
    if (ids.isEmpty) return;
    await repository.markNotificationsRead(ids);
    await refresh();
  }

  Future<void> saveSettings(NotificationSettings value) async {
    settings = value;
    notifyListeners();
    await repository.saveNotificationSettings(value);
  }
}
