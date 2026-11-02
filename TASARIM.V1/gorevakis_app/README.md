# GörevAkış: Flutter uygulaması

AhsaTech için iş takip uygulaması (BZ 313 Yazılım Mühendisliği, Ekip 9). Tasarımdaki 12 ekranın hepsi çalışır hâlde. Şimdilik **örnek verilerle** çalışıyor; veritabanı bağlanınca ekranlarda değişiklik gerekmiyor (aşağıda "Veritabanını bağlamak").

Tasarım dosyaları: [`../docs/tasarim`](../docs/tasarim)

## Çalıştırma

Bilgisayarda Flutter kurulu olmalı (`flutter doctor` hatasız çıkmalı).

```bash
cd gorevakis_app

# Sadece ilk sefer: android/ ve ios/ klasörlerini oluşturur.
# Bizim yazdığımız dosyaların üzerine yazmaz.
flutter create --project-name gorevakis --org com.ahsatech --platforms android,ios .

flutter pub get
flutter run
```

Testler: `flutter test`

## Deneme hesapları

Şifre hepsinde `123456`.

| E-posta | Kim | Ne görür |
|---|---|---|
| `y3@ahsatech.test` | Yazılımcı 3 (üye) | Tasarımdaki görünüm. "Mobil Uygulama 2.0" projesinde izleyici. |
| `yonetici@ahsatech.test` | Mehmet Akif (yönetici) | Ekip ekranında davet, rol verme ve projeye atama. |
| `y1@ahsatech.test`, `y2@ahsatech.test` | Üyeler | Kendi işleri ve bildirimleri. |

Tarihler uygulamanın açıldığı güne göre hesaplanır ("yarın 12.00", "2 gün gecikti" her zaman doğru görünür). Uygulama kapanınca yapılan değişiklikler sıfırlanır.

## Ekranlar

| Ekran | Dosya |
|---|---|
| Giriş | `lib/screens/login_screen.dart` |
| Projeler (ana sayfa) | `lib/screens/projects_screen.dart` |
| Proje panosu, izleyici görünümü dahil | `lib/screens/board_screen.dart` |
| İşi taşıma / arşivleme / silme | `lib/screens/move_task_sheet.dart` |
| İş detayı ve konuşma | `lib/screens/task_detail_screen.dart` |
| Yeni iş / işi düzenleme | `lib/screens/task_editor_sheet.dart` |
| Proje bilgisi | `lib/screens/project_info_screen.dart` |
| Arama | `lib/screens/search_screen.dart` |
| Bildirimler | `lib/screens/notifications_screen.dart` |
| Profil | `lib/screens/profile_screen.dart` |
| Ekip | `lib/screens/team_screen.dart` |

Ekranlar arası geçiş:
- Bir işe **dokununca** iş detayı açılır.
- Bir işi **basılı tutunca** "Bu işle ne yapalım?" sayfası açılır: sütun değiştirme, arşivleme, silme.

## Klasör yapısı

```
lib/
├── main.dart                 Uygulamanın başladığı yer (repository burada seçilir)
├── app.dart                  MaterialApp, tema, Türkçe dil ayarı
├── data/
│   ├── models.dart           AppUser, Project, BoardColumn, Task, Comment, AppNotification
│   ├── repository.dart       GorevRepository: veriye erişen TEK arayüz
│   └── fake_repository.dart  Örnek verilerle çalışan hâli
├── state/
│   ├── app_state.dart        Ekranların okuduğu ortak durum
│   └── app_scope.dart        Durumu ekranlara ulaştıran widget
├── theme/app_theme.dart      Renkler ve yazı stilleri (tasarımla aynı)
├── util/                     Tarih metinleri, Türkçe harf ve ek yardımcıları
├── widgets/                  Ortak parçalar: avatar, iş kartı, alt menü, butonlar
└── screens/                  Ekranlar
assets/fonts/                 Bricolage Grotesque, Instrument Sans (OFL lisanslı)
```

Ek paket kullanılmadı; sadece Flutter'ın kendi paketleri var.

## Veritabanını bağlamak

Ekranlar veritabanını hiç bilmez. Veriye sadece `lib/data/repository.dart` içindeki `GorevRepository` arayüzü üzerinden erişilir. Veritabanını bağlayan kişinin yapacağı iş:

1. `GorevRepository`'yi uygulayan yeni bir sınıf yazmak, ör. `lib/data/api_repository.dart` içinde `class ApiRepository implements GorevRepository`. Sunucuya HTTP isteği atabilir, Firebase kullanabilir; ekranlar için fark etmez.
2. `lib/main.dart` içinde `FakeRepository()` yerine `ApiRepository()` vermek.

Bilinmesi gerekenler:
- **Örnek davranış:** `FakeRepository` doğru davranışın örneği. Her metodun ne yapması gerektiği orada çalışır hâlde duruyor; ör. iş başkasına verilince ona bildirim oluşturmak.
- **Hatalar:** Giriş ve şifre hataları `AuthException('...')` olarak fırlatılmalı. Mesaj olduğu gibi kullanıcıya gösterilir, bu yüzden Türkçe yazılmalı.
- **Arşivlenenler:** `fetchProjects` ve `fetchTasks` arşivlenenleri de döndürmeli; ekranlar kendisi ayıklıyor.
- **"Bitti" sütunu:** Hangi sütunun "bitti" sayılacağı `BoardColumn.isDone` ile belirlenir.
- **Tablolar:** Modellerin alanları veritabanı tablolarına doğrudan karşılık gelecek şekilde tutuldu. Önerilen tablolar: `users`, `projects`, `project_members`, `columns`, `tasks`, `comments`, `notifications`.

## Şimdilik olmayanlar

- Gerçek veritabanı ve sunucu (yukarıdaki adımla bağlanacak)
- Telefona gelen anlık bildirim (push). Uygulama içi bildirim listesi var.
- Davet ve şifre sıfırlama e-postalarının gerçekten gönderilmesi (sunucu tarafı)
- İşler sürükle-bırakla değil, basılı tutup sütun seçerek taşınıyor.
