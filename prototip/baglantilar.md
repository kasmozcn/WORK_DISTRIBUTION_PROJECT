# Ekran bağlantıları

Bütün bağlantılar 24 Kasım 2026'da Balsamiq editöründe kuruldu. Her öğenin üstüne gelinip hedefi okundu: 00'daki 17 kutu ve aşağıdaki listenin tamamı doğru boarda gidiyor.

| Board | Öğe | Gittiği board |
|---|---|---|
| 00 Akış haritası | Her kutu (17) | Kutunun üstünde yazan board |
| 01 Giriş | Giriş yap | 02 Projeler |
| 01 Giriş – hatalı | Giriş yap | 02 Projeler |
| 02 Projeler | Panoda gör (iki düğme) | 03 Proje panosu |
| 02 Projeler | Panoyu aç (Destek ve Bakım) | 03 Proje panosu |
| 02 Projeler – boş | Listeyi yenile | 02 Projeler |
| 03 Proje panosu | ‹ Projeler | 02 Projeler |
| 03 Proje panosu | + Yeni iş | 07 Yeni iş – boş form |
| 03 Proje panosu | Mobil girişte… başlığı | 06 İş detayı |
| 03 Proje panosu | Taşı (Mobil girişte…) | 05 İşi taşıma |
| 03 Proje panosu | Ben alırım | 03 Proje panosu – iş başkasında |
| 03 Proje panosu – boş | ‹ Projeler | 02 Projeler |
| 03 Proje panosu – boş | + Yeni iş | 07 Yeni iş – boş form |
| 03 – iş verildi | Geri al | 03 Proje panosu |
| 03 – iş taşındı | Geri al | 03 Proje panosu |
| 03 – iş arşivlendi | Geri al | 03 Proje panosu |
| 03 – iş verildi, taşındı, başkasında, arşivlendi, silindi | ‹ Projeler | 02 Projeler |
| 03 – iş verildi, taşındı, başkasında, arşivlendi, silindi | + Yeni iş | 07 Yeni iş – boş form |
| 03'ün yedi boardu | Alt menü: Projeler | 02 Projeler |
| 05 İşi taşıma | ‹ Pano | 03 Proje panosu |
| 05 İşi taşıma | Devam Ediyor | 03 Proje panosu – iş taşındı |
| 05 İşi taşıma | Arşivle | 03 Proje panosu – iş arşivlendi |
| 05 İşi taşıma | Sil… | 05 İşi taşıma – silme onayı |
| 05 – silme onayı | ‹ Geri ve "Vazgeç, silme" | 05 İşi taşıma |
| 05 – silme onayı | Arşivle | 03 Proje panosu – iş arşivlendi |
| 05 – silme onayı | İşi sil | 03 Proje panosu – iş silindi |
| 06 İş detayı | ‹ Pano | 03 Proje panosu |
| 06 İş detayı | Taşı | 05 İşi taşıma |
| 07 – boş form | ‹ Pano | 03 Proje panosu |
| 07 – boş form | Ne yapılacak? alanı, Yazılımcı 1, Cuma, 17.00 | 07 Yeni iş – dolu |
| 07 – dolu | ‹ Pano | 03 Proje panosu |
| 07 – dolu | İşi ekle | 03 Proje panosu – iş verildi |
| 07 – bağlantı koptu | ‹ Pano ve Panoya bak | 03 Proje panosu |

## Sunum modunda tıklanan yollar

24 Kasım 2026, "User test" ayarı (ekran listesi, yorumlar, bağlantı ipuçları kapalı). Bu bir çalışırlık kontrolüdür, kullanıcı testi değildir.

| Yol | Sonuç |
|---|---|
| G1: 01 → 02 → 03 → 07 boş → 07 dolu → 03 iş verildi | Tamamlandı |
| Geri al → 03; G2: Taşı → 05 → Devam Ediyor → 03 iş taşındı | Tamamlandı |
| Geri al → 03; G3: Ben alırım → 03 iş başkasında | Tamamlandı |
| ‹ Projeler → 02 → Panoda gör → 03 → başlık → 06 → Taşı → 05 → Sil… → silme onayı → İşi sil → 03 iş silindi | Tamamlandı |
| 00 harita → 07 bağlantı koptu → Panoya bak → 03 → Taşı → 05 → Arşivle → 03 iş arşivlendi | Tamamlandı |

## Bilerek açılmayanlar

Ara, Profil, Bildirimler, Ekip, diğer iki proje, Düzenle, Şifremi unuttum, Göster, Tamamlandı, kişi filtresi, sonuç boardlarındaki "Taşı". Bunlar ana işin dışında; test karşılamasında "bazı düğmeler açılmaz" deniyor.

## Ortak parçalar

Slayt 22'deki "Symbol", Balsamiq'te artık **Component**. İki Component var: `Ust cubuk` (‹ Projeler, Ara, Profil) ve `Alt menu` (+ Yeni iş, Projeler, Bildirimler, Ekip). Yedi 03 boardunda aynı Component kullanılıyor; bağlantıları bir kez kuruldu, biri değişince yedisi birden değişir.

## Değiştirmek isterseniz

Öğeyi seçin, seçim çubuğundaki **zincir simgesine** basıp boardu seçin. Düğme çubuğunda (gün, saat, alt menü) her parça ayrı bağlanır. Üstüne gelince mor etikette hedef yazar.
