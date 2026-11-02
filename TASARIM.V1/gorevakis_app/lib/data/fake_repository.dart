import 'models.dart';
import 'repository.dart';

/// Örnek verilerle çalışan, her şeyi bellekte tutan repository.
///
/// Uygulama kapanınca değişiklikler kaybolur. Sunum ve geliştirme içindir.
/// Deneme hesapları (şifre hepsinde 123456):
///   yonetici@ahsatech.test  (Mehmet Akif, yönetici)
///   y1@ahsatech.test, y2@ahsatech.test, y3@ahsatech.test (üyeler)
class FakeRepository implements GorevRepository {
  FakeRepository({DateTime? now}) {
    _seed(now ?? DateTime.now());
  }

  static const _password = '123456';

  final List<AppUser> _users = [];
  final List<Project> _projects = [];
  final List<Task> _tasks = [];
  final List<AppNotification> _notifications = [];
  final Map<String, String> _passwords = {};
  final Map<String, NotificationSettings> _settings = {};
  final List<String> _invites = [];
  String? _currentUserId;
  int _seq = 100;

  String _newId(String prefix) => '$prefix${_seq++}';

  String get _me {
    final id = _currentUserId;
    if (id == null) throw const AuthException('Oturum kapalı. Tekrar giriş yap.');
    return id;
  }

  // --- Oturum ---------------------------------------------------------------

  @override
  Future<AppUser> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final normalized = email.trim().toLowerCase();
    for (final u in _users) {
      if (u.email == normalized) {
        if (_passwords[u.id] == password) {
          _currentUserId = u.id;
          return u;
        }
        break;
      }
    }
    throw const AuthException('E-posta ya da şifre hatalı.');
  }

  @override
  Future<void> signOut() async {
    _currentUserId = null;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<void> changePassword({required String current, required String next}) async {
    final id = _me;
    if (_passwords[id] != current) {
      throw const AuthException('Şu anki şifren doğru değil.');
    }
    _passwords[id] = next;
  }

  // --- Okuma ----------------------------------------------------------------

  @override
  Future<List<AppUser>> fetchUsers() async => List.of(_users);

  @override
  Future<List<Project>> fetchProjects() async => List.of(_projects);

  @override
  Future<List<Task>> fetchTasks() async => List.of(_tasks);

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final id = _me;
    return _notifications.where((n) => n.userId == id).toList();
  }

  @override
  Future<NotificationSettings> fetchNotificationSettings() async {
    return _settings[_me] ?? const NotificationSettings();
  }

  // --- Yazma ----------------------------------------------------------------

  @override
  Future<Task> createTask(TaskDraft draft) async {
    final me = _me;
    final task = Task(
      id: _newId('t'),
      projectId: draft.projectId,
      title: draft.title,
      note: draft.note,
      columnId: draft.columnId,
      assigneeId: draft.assigneeId,
      dueAt: draft.dueAt,
      dueHasTime: draft.dueHasTime,
      createdBy: me,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    _notifyAssignee(task, previousAssignee: null);
    return task;
  }

  @override
  Future<void> updateTask(Task task) async {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i < 0) return;
    final previous = _tasks[i].assigneeId;
    _tasks[i] = task;
    _notifyAssignee(task, previousAssignee: previous);
  }

  void _notifyAssignee(Task task, {required String? previousAssignee}) {
    final to = task.assigneeId;
    if (to == null || to == previousAssignee || to == _currentUserId) return;
    _notifications.add(AppNotification(
      id: _newId('n'),
      userId: to,
      kind: NotificationKind.assigned,
      taskId: task.id,
      createdAt: DateTime.now(),
      fromUserId: _currentUserId,
    ));
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    _notifications.removeWhere((n) => n.taskId == taskId);
  }

  @override
  Future<void> addComment(String taskId, String text) async {
    final i = _tasks.indexWhere((t) => t.id == taskId);
    if (i < 0) return;
    final task = _tasks[i];
    final comment = Comment(
      id: _newId('c'),
      authorId: _me,
      text: text,
      createdAt: DateTime.now(),
    );
    _tasks[i] = task.copyWith(comments: [...task.comments, comment]);
  }

  @override
  Future<void> updateProject(Project project) async {
    final i = _projects.indexWhere((p) => p.id == project.id);
    if (i >= 0) _projects[i] = project;
  }

  @override
  Future<void> updateUser(AppUser user) async {
    final i = _users.indexWhere((u) => u.id == user.id);
    if (i >= 0) _users[i] = user;
  }

  @override
  Future<void> inviteUser(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _invites.add(email.trim().toLowerCase());
  }

  @override
  Future<void> markNotificationsRead(List<String> ids) async {
    for (var i = 0; i < _notifications.length; i++) {
      if (ids.contains(_notifications[i].id)) {
        _notifications[i] = _notifications[i].copyWith(read: true);
      }
    }
  }

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    _settings[_me] = settings;
  }

  // --- Örnek veriler ----------------------------------------------------------

  void _seed(DateTime now) {
    // Tarihler bugüne göre hesaplanır; böylece "yarın", "2 gün gecikti" gibi
    // etiketler uygulama her açıldığında doğru görünür.
    DateTime day(int offset, [int hour = 0, int minute = 0]) =>
        DateTime(now.year, now.month, now.day + offset, hour, minute);

    const ma = 'u-ma', y1 = 'u-y1', y2 = 'u-y2', y3 = 'u-y3';
    _users.addAll(const [
      AppUser(
        id: ma,
        displayName: 'Mehmet Akif Akdöl',
        firstName: 'Mehmet Akif',
        lastName: 'Akdöl',
        initials: 'MA',
        colorValue: 0xFF2E5E4E,
        email: 'yonetici@ahsatech.test',
        isManager: true,
      ),
      AppUser(
        id: y1,
        displayName: 'Yazılımcı 1',
        initials: 'Y1',
        colorValue: 0xFF9A5B1E,
        email: 'y1@ahsatech.test',
      ),
      AppUser(
        id: y2,
        displayName: 'Yazılımcı 2',
        initials: 'Y2',
        colorValue: 0xFF2F5577,
        email: 'y2@ahsatech.test',
      ),
      AppUser(
        id: y3,
        displayName: 'Yazılımcı 3',
        initials: 'Y3',
        colorValue: 0xFF7B3F63,
        email: 'y3@ahsatech.test',
      ),
    ]);
    for (final u in _users) {
      _passwords[u.id] = _password;
    }

    List<BoardColumn> columns(String p) => [
          BoardColumn(id: '$p-todo', name: 'Yapılacak', colorValue: 0xFFE0E4DA),
          BoardColumn(id: '$p-doing', name: 'Devam Ediyor', colorValue: 0xFFD3F26A),
          BoardColumn(id: '$p-done', name: 'Tamamlandı', colorValue: 0xFF1F3A2C, isDone: true),
        ];

    _projects.addAll([
      Project(
        id: 'p-destek',
        name: 'Destek ve Bakım',
        summary: 'Müşteri destek, bakım ve raporlama işleri',
        purpose: 'Müşterilere verilen destek, bakım ve raporlama işlerini tek '
            'yerden takip etmek. Aylık raporlar ve sunucu bakımı bu projede yürür.',
        memberIds: const [ma, y1, y2, y3],
        duties: const {
          ma: 'Koordinasyon, müşteri iletişimi',
          y1: 'Arayüz düzeltmeleri',
          y2: 'Raporlama ve veritabanı',
          y3: 'Sunucu ve mobil hatalar',
        },
        notes: 'Aylık rapor şablonu ortak klasörde. Bakım çalışmaları Salı ve '
            'Perşembe 22.00 sonrası yapılır.',
        columns: columns('p-destek'),
      ),
      Project(
        id: 'p-web',
        name: 'Müşteri A Web Paneli',
        summary: 'Müşteri A için yönetim paneli geliştirme',
        purpose: 'Müşteri A’nın ürün ve sipariş yönetimi için web paneli geliştirmek.',
        memberIds: const [ma, y1, y3],
        duties: const {
          ma: 'Koordinasyon',
          y1: 'Arayüz',
          y3: 'Sunucu tarafı',
        },
        columns: columns('p-web'),
      ),
      Project(
        id: 'p-mobil',
        name: 'Mobil Uygulama 2.0',
        summary: 'Mobil uygulamanın yeni sürümü',
        purpose: 'Mobil uygulamanın yeni sürümünü, tasarım yenilemesiyle birlikte '
            'mağazalara çıkarmak.',
        memberIds: const [ma, y2],
        duties: const {
          ma: 'Koordinasyon, mağaza süreçleri',
          y2: 'Uygulama geliştirme',
        },
        notes: 'Mağaza hesaplarının bilgileri yöneticide.',
        columns: columns('p-mobil'),
      ),
    ]);

    Task t(
      String id,
      String project,
      String column,
      String title, {
      String? who,
      DateTime? due,
      bool time = false,
      String note = '',
      String by = ma,
      DateTime? created,
      List<Comment> comments = const [],
      bool archived = false,
    }) {
      return Task(
        id: id,
        projectId: project,
        columnId: '$project-$column',
        title: title,
        assigneeId: who,
        dueAt: due,
        dueHasTime: time,
        note: note,
        createdBy: by,
        createdAt: created ?? day(-10, 9),
        comments: comments,
        archived: archived,
      );
    }

    _tasks.addAll([
      // Destek ve Bakım: 4 yapılacak, 2 devam, 2 bitti (+1 arşivde)
      t('t1', 'p-destek', 'todo', 'Müşteri A için demo ortamı kur',
          who: y3, due: day(4, 17), time: true, created: day(0, 10, 42)),
      t('t2', 'p-destek', 'todo', 'Mobil girişte oturum düşme hatasını incele',
          who: y3,
          due: day(1, 12),
          time: true,
          note: 'Uygulama arka plana alınıp tekrar açılınca oturum kapanıyor. '
              'Müşteri B iki kez bildirdi.',
          created: day(-7, 9, 30),
          comments: [
            Comment(id: 'c1', authorId: ma, text: 'Müşterinin ekran kaydı ortak klasörde.', createdAt: day(-7, 11, 5)),
            Comment(id: 'c2', authorId: y3, text: 'Tekrarladım, ayara bakıyorum.', createdAt: day(0, 9, 15)),
          ]),
      t('t3', 'p-destek', 'todo', 'Sunucu yedeklerini kontrol et', who: ma, due: day(-2)),
      t('t4', 'p-destek', 'todo', 'Kasım bakım takvimini hazırla', due: day(2)),
      t('t5', 'p-destek', 'doing', 'Ekim ayı müşteri raporu',
          who: y2,
          due: day(3),
          comments: [
            Comment(id: 'c3', authorId: ma, text: 'Geçen ayın şablonunu kullanalım.', createdAt: day(-4, 10)),
            Comment(id: 'c4', authorId: y2, text: 'Tamam, grafikleri ekliyorum.', createdAt: day(-4, 10, 20)),
            Comment(id: 'c5', authorId: ma, text: 'Müşteri B kısmı eksik kalmasın.', createdAt: day(-1, 16)),
          ]),
      t('t6', 'p-destek', 'doing', 'Müşteri B için SSS sayfasını güncelle', who: y1, due: day(5)),
      t('t7', 'p-destek', 'done', 'SSL sertifikasını yenile', who: y3, due: day(-2)),
      t('t8', 'p-destek', 'done', 'Ekim bakım notlarını yayınla', who: y1, due: day(-3)),
      t('t9', 'p-destek', 'done', 'Eylül yedek raporu', who: y2, due: day(-32), archived: true),

      // Müşteri A Web Paneli: 6 yapılacak, 1 devam
      t('t10', 'p-web', 'todo', 'Giriş sayfasını müşteri logosuyla güncelle', who: y1, due: day(6)),
      t('t11', 'p-web', 'todo', 'Sipariş listesine tarih filtresi ekle', who: y3, due: day(8)),
      t('t12', 'p-web', 'todo', 'Ürün görsellerini sıkıştır', who: y1),
      t('t13', 'p-web', 'todo', 'Yetki ekranının metinlerini müşteriye onaylat', who: ma, due: day(5)),
      t('t14', 'p-web', 'todo', 'Excel dışa aktarma hatasını düzelt', who: y3, due: day(9)),
      t('t15', 'p-web', 'todo', 'Panel için kullanım kılavuzu taslağı'),
      t('t16', 'p-web', 'doing', 'Sipariş detay sayfası', who: y1, due: day(3)),

      // Mobil Uygulama 2.0: Yazılımcı 3 bu projede izleyici
      t('t17', 'p-mobil', 'todo', 'Giriş ekranını yeni tasarıma geçir', who: y2, due: day(3, 17), time: true),
      t('t18', 'p-mobil', 'todo', 'Bildirim izinleri metnini yaz',
          who: ma,
          due: day(4),
          comments: [Comment(id: 'c6', authorId: y2, text: 'Taslağı nota ekledim.', createdAt: day(-1, 14))]),
      t('t19', 'p-mobil', 'todo', 'Mağaza ekran görüntülerini hazırla', who: y2, due: day(6)),
      t('t20', 'p-mobil', 'todo', 'Karanlık tema renklerini belirle', due: day(9)),
      t('t21', 'p-mobil', 'doing', 'Çevrimdışı mod denemesi',
          who: y2,
          due: day(5),
          comments: [
            Comment(id: 'c7', authorId: ma, text: 'Senkronizasyon çakışmalarına da bakalım.', createdAt: day(-2, 11)),
            Comment(id: 'c8', authorId: y2, text: 'Çakışmada son kaydı tutuyorum şimdilik.', createdAt: day(-2, 12)),
          ]),
      t('t22', 'p-mobil', 'doing', 'Uygulama içi arama', who: y2, due: day(7)),
      t('t23', 'p-mobil', 'done', 'Yeni ikon setini ekle', who: y2, due: day(-6)),
      t('t24', 'p-mobil', 'done', 'Açılış ekranı animasyonu', who: y2, due: day(-5)),
      t('t25', 'p-mobil', 'done', 'Test cihazı listesini çıkar', who: ma, due: day(-9)),
      t('t26', 'p-mobil', 'done', 'Çökme raporlarını incele', who: y2, due: day(-4)),
      t('t27', 'p-mobil', 'done', 'Sürüm notları şablonu', who: ma, due: day(-8)),
      t('t28', 'p-mobil', 'done', 'Beta kullanıcılarına anket gönder', who: ma, due: day(-3)),
    ]);

    _notifications.addAll([
      AppNotification(id: 'n1', userId: y3, kind: NotificationKind.assigned, taskId: 't1', fromUserId: ma, createdAt: day(0, 10, 42)),
      AppNotification(id: 'n2', userId: y3, kind: NotificationKind.dueTomorrow, taskId: 't2', createdAt: day(0, 9)),
      AppNotification(id: 'n3', userId: y3, kind: NotificationKind.assigned, taskId: 't2', fromUserId: ma, createdAt: day(-3, 9, 30), read: true),
      AppNotification(id: 'n4', userId: y3, kind: NotificationKind.dueToday, taskId: 't7', createdAt: day(-2, 9), read: true),
      AppNotification(id: 'n5', userId: y1, kind: NotificationKind.assigned, taskId: 't6', fromUserId: ma, createdAt: day(-1, 15)),
      AppNotification(id: 'n6', userId: y2, kind: NotificationKind.assigned, taskId: 't5', fromUserId: ma, createdAt: day(-4, 10)),
      AppNotification(id: 'n7', userId: ma, kind: NotificationKind.dueToday, taskId: 't3', createdAt: day(-2, 9)),
    ]);
  }
}
