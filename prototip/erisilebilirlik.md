# Erişilebilirlik: plan ve beş kontrol

Slayt 25 ve 37. Kontrol edilen: repodaki Flutter uygulaması (`TASARIM.V1/gorevakis_app`, commit `6d6614b`), 24 Kasım 2026. Geçici bir kopyada çalıştırıldı, repoda hiçbir şey değiştirilmedi. Bu, tam bir WCAG denetimi değildir.

**Ortam:** Flutter 3.41.2; Chrome (web derlemesi, 390 × 844) ve `flutter test`. Klavye adımları `flutter test` ile Tab/Enter/Esc gönderilerek, giriş adımı ayrıca Chrome'da denendi. Windows Anlatıcı kullanılmadı; onun yerine Anlatıcı'nın okuyacağı erişilebilirlik adları okundu. Anlatıcı denemesi ekipte.

## Sonuç

| Kural | Sonuç | Bulunan |
|---|---|---|
| Renk karşıtlığı | Büyük ölçüde geçti | Görünen metinlerin en düşüğü 4,86:1. İstisna: 07'deki "Ne yapılacak?" yer tutucusu 2,55:1 (26 px kalın, sınır 3:1) |
| Klavye kullanımı | **Kaldı** | Yeni işte "Kime?" seçimi, panodaki kişi filtresi (MA, Y1, Y2), profil resmi ve bildirim anahtarları Tab ile odaklanmıyor |
| Görsele metin karşılığı | Kısmen | Simge düğmelerinin adı var (Ara, Geri, Kapat, Gönder). 07'de kişiler "Y1 / Y1" okunuyor, ad yok (03'te ipucunda ad var). Profildeki iki anahtarın adı yok |
| Etiketli form alanı | **Kaldı** | 01'de E-posta ve Şifre alanına yazınca erişilebilirlik adı boşalıyor. 07'deki başlığın görünür etiketi yok, yalnızca yer tutucu |
| Renk tek işaret olmasın | Görünüşte geçti | Gri tonda "2 gün gecikti", "Sahibi yok" ve seçili öğeler ayırt ediliyor. Seçili durum ekran okuyucuya bildirilmiyor |

Kanıt: [gri tonlu pano](erisilebilirlik-kanit/03-pano-gri.jpg), [gri tonlu yeni iş](erisilebilirlik-kanit/07-yeni-is-gri.jpg), [klavyeyle "Giriş yap" odağı](erisilebilirlik-kanit/01-klavye-odak.jpg).

## Ölçümler

**Karşıtlık** (4× çizimde, ekranda görünen her metin; sınır 4,5:1, büyük metinde 3:1):

| Ekran | Metin | Kalan | En düşük geçen |
|---|--:|--:|--:|
| 01 Giriş | 9 | 0 | 6,38 |
| 01 Giriş (hatalı) | 10 | 0 | 5,97 |
| 02 Projeler | 30 | 0 | 4,95 |
| 03 Proje panosu | 36 | 0 | 4,86 |
| 05 İşi taşıma | 9 | 0 | 4,86 |
| 06 İş detayı | 23 | 0 | 4,86 |
| 07 Yeni iş | 23 | 1 (pasif "İşi ekle" 1,85; pasif düğme sınırın dışında) | 5,40 |
| 10 Bildirimler | 23 | 0 | 5,56 |
| 12 Ekip | 23 | 0 | 5,40 |

04, 08, 09 ve 11 ölçülmedi.

Yer tutucu metinler bu tabloya girmez, renk kodundan hesaplandı. `#9AA59D` beyazda 2,55:1 (07 başlık). Diğer yer tutucular `#56625A`.

**Klavye** (Tab sırası):

| Ekran | Odaklanan | Odaklanmayan |
|---|---|---|
| 01 | E-posta, Şifre, Şifreyi göster, Şifremi unuttum, Giriş yap. Enter ile giriş yapıldı | yok |
| 02 | Ara, 3 proje, alt menü, Yeni iş ekle | Profil resmi |
| 03 | Projeler, Ara, proje adı, Proje bilgisi, Herkes, Ben, işler, alt menü, Yeni iş ekle | Profil resmi, MA/Y1/Y2 filtresi |
| 05 | Sütunlar, Arşivle, Sil, Vazgeç (06'daki "Diğer işlemler" ile açılır) | yok |
| 06 | Geri, sütun, düzenle, Diğer işlemler, Sorumlu, Son tarih, Sütun, yorum alanı, Gönder | yok |
| 07 | Not ekle, günler, saatler, sütunlar, İşi ekle, Kapat, başlık | **Kime? (hiçbir kişi)** |
| 11 | Geri, Ad, Soyad, Telefon, Şifre, sessize alma, Çıkış | İki bildirim anahtarı |

Esc yeni iş formunu kapatıyor. Odak yalnızca düğmenin hafif koyulaşmasıyla görünüyor (açık yeşilden koyu yeşile 1,32:1), çerçeve yok.

**Dokunma alanı** (44 px): Şifremi unuttum 116 × 40, profil resmi 40 × 40, proje adı 296 × 36, Proje bilgisi 84 × 40, Kapat 40 × 40, bildirim anahtarları 50 × 30.

## Wireframe'de nasıl karşılandı?

- Her alanın görünür, kalıcı etiketi var. Simge yerine yazı: "Ara", "Profil", "Taşı", "Göster".
- Kişiler kodla değil adla: "Yazılımcı 1".
- Seçili olan ✓ ile yazılı. Gecikme "! 2 gün gecikti", hata "!" ile başlıyor.
- Metinlerin en açık rengi `#595959`: beyazda 7,00:1, gri sütunda 5,4:1'in üstünde.
- Düğmeler, alanlar ve menü en az 44 px yüksek.
- Taşıma sürükleme olmadan da yapılıyor.

## Issue'ya yazılacak bulgular

Bunlar test katılımcısından değil, bu kontrolden çıkan bulgulardır. Ciddiyet slayt 30'a göre.

### 1. `[Engelleyici] Klavyeyle iş başkasına verilemiyor (Yeni iş)`
- **Gözlem:** Yeni işte Tab 15 öğe gezdi; "Kime?" altındaki kişilerin hiçbiri odaklanmadı. İş yalnızca varsayılan kişiye (kendine) verilebiliyor.
- **Öneri:** `task_editor_sheet.dart` kişi seçiminde `GestureDetector` yerine `InkWell` ya da `FocusableActionDetector`.
- **Neden engelleyici:** Ana kullanıcı işi klavyeyle bitirilemiyor.

### 2. `[Engelleyici] Profil ve bildirim anahtarları klavyeyle açılmıyor`
- **Gözlem:** 02 ve 03'te profil resmi, 11'de iki anahtar Tab sırasında yok. Anahtarların erişilebilirlik adı da yok.
- **Öneri:** Profil resmini düğme yapın ("Profil"). `AppToggle` yerine adı olan `Switch`/`SwitchListTile`.

### 3. `[Ciddi] Form alanlarının adı yazınca kayboluyor (Giriş)`
- **Gözlem:** Boşken ad "e-posta adresin"; yazınca ad boş. Görünen "E-posta" etiketi alana bağlı değil. 07'de başlığın tek etiketi yer tutucu.
- **Öneri:** `InputDecoration.labelText` ya da `Semantics(label: 'E-posta')`.

### 4. `[Ciddi] Seçili kişi, gün ve sütun ekran okuyucuya bildirilmiyor (Yeni iş)`
- **Gözlem:** "Yarın" ve "Y1" seçildikten sonra ikisi de `seçili = hayır`. Kişi adı yerine "Y1 / Y1" okunuyor.
- **Öneri:** `Semantics(selected: true, label: 'Yazılımcı 1')`.

### 5. `[Küçük] "Ne yapılacak?" yer tutucusu soluk`
- **Gözlem:** `#9AA59D` beyaz üstünde 2,55:1; sınır 3:1.
- **Öneri:** `AppColors.muted` (`#56625A`) kullanın ve kalıcı etiket ekleyin.

### 6. `[Küçük] Beş dokunma alanı 44 pikselden küçük`
- **Gözlem:** Yukarıdaki liste.
- **Öneri:** En az 44 × 44.

### 7. `[Küçük] Klavye odağı zor seçiliyor`
- **Gözlem:** Odaktaki düğme yalnızca 1,32:1 koyulaşıyor.
- **Öneri:** Odakta 2 px koyu çerçeve.

## Plan

| Ne zaman | Kim | Ne |
|---|---|---|
| Test öncesi | Ekip | 1–4 numaralı bulguları uygulamada düzeltmek |
| Her sprint | Geliştirici | Yeni ekranda beş kontrol; `flutter test` içinde `labeledTapTargetGuideline` |
| Teslim öncesi | Ekip | Windows Anlatıcı (Ctrl+Win+Enter) ile 01 ve 07'yi baştan sona denemek |
