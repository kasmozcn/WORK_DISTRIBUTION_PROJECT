import 'models.dart';

/// Uygulamanın veriye eriştiği TEK yer.
///
/// Ekranlar veritabanını hiç bilmez; sadece bu arayüzü kullanır.
/// Şu an [FakeRepository] (örnek veriler) bağlı. Veritabanı / sunucu hazır
/// olunca bu arayüzü uygulayan yeni bir sınıf yazılıp `main.dart` içinde
/// FakeRepository yerine verilmesi yeterli; ekranlarda değişiklik gerekmez.
///
/// Kurallar:
/// * Oturum bilgisi (hangi kullanıcının girdiği) repository içinde tutulur.
/// * Giriş ve şifre hataları [AuthException] olarak fırlatılır; mesajı
///   doğrudan kullanıcıya gösterilir, bu yüzden Türkçe yazılmalı.
abstract class GorevRepository {
  // --- Oturum ---------------------------------------------------------------

  /// E-posta ve şifreyle giriş. Hatalıysa [AuthException] fırlatır.
  Future<AppUser> signIn(String email, String password);
  Future<void> signOut();
  Future<void> requestPasswordReset(String email);
  Future<void> changePassword({required String current, required String next});

  // --- Okuma ----------------------------------------------------------------

  /// Şirketteki tüm kişiler.
  Future<List<AppUser>> fetchUsers();

  /// Arşivlenenler dahil tüm projeler.
  Future<List<Project>> fetchProjects();

  /// Arşivlenenler dahil tüm işler (yorumlarıyla birlikte).
  Future<List<Task>> fetchTasks();

  /// Giriş yapan kişinin bildirimleri.
  Future<List<AppNotification>> fetchNotifications();
  Future<NotificationSettings> fetchNotificationSettings();

  // --- Yazma ----------------------------------------------------------------

  /// İşi ekler. İş başkasına verildiyse ona bildirim oluşturulmalı.
  Future<Task> createTask(TaskDraft draft);

  /// Taşıma, arşivleme, düzenleme, "Ben alırım" hep bununla yapılır.
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<void> addComment(String taskId, String text);

  /// Proje bilgileri, üyeler ve sütun sırası.
  Future<void> updateProject(Project project);

  /// Profil bilgileri ve (yönetici için) rol değişikliği.
  Future<void> updateUser(AppUser user);

  /// Sadece yönetici. Kişiye davet e-postası gönderilir.
  Future<void> inviteUser(String email);
  Future<void> markNotificationsRead(List<String> ids);
  Future<void> saveNotificationSettings(NotificationSettings settings);
}
