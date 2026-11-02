// Uygulamanın veri modelleri.
//
// Bu dosya Flutter'a bağlı değildir; veritabanı / sunucu tarafını yazan kişi
// aynı sınıfları JSON'a çevirip kullanabilir.

/// copyWith içinde "bu alanı değiştirme" ile "bu alanı null yap" ayrımı için.
const Object _unset = Object();

class AppUser {
  const AppUser({
    required this.id,
    required this.displayName,
    required this.initials,
    required this.colorValue,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.isManager = false,
  });

  final String id;

  /// Ad soyad girilmemişse gösterilen ad (ör. "Yazılımcı 3").
  final String displayName;
  final String initials;

  /// Avatar rengi, 0xAARRGGBB biçiminde.
  final int colorValue;
  final String email;
  final String firstName;
  final String lastName;
  final String phone;

  /// Şirket genelinde yönetici mi? Yönetici kişi ekler, projeye atar, rol verir.
  final bool isManager;

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? displayName : name;
  }

  /// Bildirim ve notlarda kullanılan kısa ad (ör. "Mehmet Akif").
  String get shortName => firstName.isNotEmpty ? firstName : displayName;

  AppUser copyWith({
    String? displayName,
    String? initials,
    String? firstName,
    String? lastName,
    String? phone,
    bool? isManager,
  }) {
    return AppUser(
      id: id,
      displayName: displayName ?? this.displayName,
      initials: initials ?? this.initials,
      colorValue: colorValue,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      isManager: isManager ?? this.isManager,
    );
  }
}

/// Panodaki bir sütun (Yapılacak, Devam Ediyor, Tamamlandı...).
class BoardColumn {
  const BoardColumn({
    required this.id,
    required this.name,
    required this.colorValue,
    this.isDone = false,
  });

  final String id;
  final String name;
  final int colorValue;

  /// Bu sütundaki işler bitmiş sayılır (gecikme gösterilmez).
  final bool isDone;

  BoardColumn copyWith({String? name, int? colorValue, bool? isDone}) {
    return BoardColumn(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      isDone: isDone ?? this.isDone,
    );
  }
}

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.summary,
    required this.purpose,
    required this.memberIds,
    required this.duties,
    required this.columns,
    this.notes = '',
    this.archived = false,
  });

  final String id;
  final String name;

  /// Proje kartında görünen tek satırlık açıklama.
  final String summary;

  /// "Amaç ve konu" metni.
  final String purpose;

  /// Projeye atanan kişiler. Atanmayanlar projeyi sadece izler.
  final List<String> memberIds;

  /// Kişi id'si -> görev alanı (ör. "Raporlama ve veritabanı").
  final Map<String, String> duties;
  final List<BoardColumn> columns;
  final String notes;
  final bool archived;

  bool isMember(String userId) => memberIds.contains(userId);

  BoardColumn? columnById(String id) {
    for (final c in columns) {
      if (c.id == id) return c;
    }
    return null;
  }

  Project copyWith({
    String? name,
    String? summary,
    String? purpose,
    List<String>? memberIds,
    Map<String, String>? duties,
    List<BoardColumn>? columns,
    String? notes,
    bool? archived,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      summary: summary ?? this.summary,
      purpose: purpose ?? this.purpose,
      memberIds: memberIds ?? this.memberIds,
      duties: duties ?? this.duties,
      columns: columns ?? this.columns,
      notes: notes ?? this.notes,
      archived: archived ?? this.archived,
    );
  }
}

class Comment {
  const Comment({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String authorId;
  final String text;
  final DateTime createdAt;
}

/// Panodaki bir iş.
class Task {
  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.columnId,
    required this.createdBy,
    required this.createdAt,
    this.note = '',
    this.assigneeId,
    this.dueAt,
    this.dueHasTime = false,
    this.archived = false,
    this.comments = const [],
  });

  final String id;
  final String projectId;
  final String title;
  final String columnId;
  final String createdBy;
  final DateTime createdAt;
  final String note;

  /// null ise işin sahibi yoktur ("Ben alırım" ile biri üstlenebilir).
  final String? assigneeId;
  final DateTime? dueAt;

  /// false ise sadece gün seçilmiştir, saat gösterilmez.
  final bool dueHasTime;
  final bool archived;
  final List<Comment> comments;

  Task copyWith({
    String? title,
    String? note,
    String? columnId,
    Object? assigneeId = _unset,
    Object? dueAt = _unset,
    bool? dueHasTime,
    bool? archived,
    List<Comment>? comments,
  }) {
    return Task(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      columnId: columnId ?? this.columnId,
      createdBy: createdBy,
      createdAt: createdAt,
      note: note ?? this.note,
      assigneeId:
          identical(assigneeId, _unset) ? this.assigneeId : assigneeId as String?,
      dueAt: identical(dueAt, _unset) ? this.dueAt : dueAt as DateTime?,
      dueHasTime: dueHasTime ?? this.dueHasTime,
      archived: archived ?? this.archived,
      comments: comments ?? this.comments,
    );
  }
}

/// Yeni iş eklerken sunucuya giden bilgiler.
class TaskDraft {
  const TaskDraft({
    required this.projectId,
    required this.title,
    required this.columnId,
    this.note = '',
    this.assigneeId,
    this.dueAt,
    this.dueHasTime = false,
  });

  final String projectId;
  final String title;
  final String columnId;
  final String note;
  final String? assigneeId;
  final DateTime? dueAt;
  final bool dueHasTime;
}

enum NotificationKind {
  /// Biri sana iş verdi.
  assigned,

  /// İşin teslimi yarın.
  dueTomorrow,

  /// İşin teslimi bugün.
  dueToday,
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.kind,
    required this.taskId,
    required this.createdAt,
    this.fromUserId,
    this.read = false,
  });

  final String id;

  /// Bildirimin gittiği kişi.
  final String userId;
  final NotificationKind kind;
  final String taskId;
  final DateTime createdAt;
  final String? fromUserId;
  final bool read;

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      userId: userId,
      kind: kind,
      taskId: taskId,
      createdAt: createdAt,
      fromUserId: fromUserId,
      read: read ?? this.read,
    );
  }
}

enum MuteOption { off, oneHour, untilMorning }

class NotificationSettings {
  const NotificationSettings({
    this.onAssigned = true,
    this.onDueSoon = true,
    this.mute = MuteOption.off,
  });

  final bool onAssigned;
  final bool onDueSoon;
  final MuteOption mute;

  NotificationSettings copyWith({bool? onAssigned, bool? onDueSoon, MuteOption? mute}) {
    return NotificationSettings(
      onAssigned: onAssigned ?? this.onAssigned,
      onDueSoon: onDueSoon ?? this.onDueSoon,
      mute: mute ?? this.mute,
    );
  }
}

/// Giriş ve şifre işlemlerinde kullanıcıya gösterilecek hata.
class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
