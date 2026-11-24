# Kullanıcı testi

BZ 313 Hafta 7, slayt 27–34. Prototip: Balsamiq "GörevAkış WireFrame", sunum modu. **Katılımcı: grup dışından en az 5 kişi.** Başlangıç ekranı: `01 Giriş`. `00 Akış haritası` ve `99 Tasarım notları` katılımcıya gösterilmez.

> Bu dosyadaki tablolar boştur. Yalnızca gerçek testte görülenler yazılır.

## Görev cümleleri

Görev, yapılacak işi söyler; nasıl yapılacağını söylemez.

| No | Katılımcıya okunan cümle | İş bitti sayılır | En kısa yol (yalnızca gözlemci için) |
|---|---|---|---|
| G1 | "Destek ve Bakım projesinde yedekleme betiğinin güncellenmesi gerekiyor. Bu işi Cuma 17.00'ye yetişecek şekilde Yazılımcı 1'e verin." | `03 Proje panosu – iş verildi` açıldı ve katılımcı işin kimde olduğunu söyledi | 01 → 02 → 03 → 07 boş → 07 dolu → 03 iş verildi |
| G2 | "Mobil girişteki oturum hatası üzerinde çalışmaya başladınız. Ekibin bunu görmesini sağlayın." | `03 Proje panosu – iş taşındı` açıldı | 03 → 05 → 03 iş taşındı (06 üzerinden de olur) |
| G3 | "Kasım bakım takvimi işinin sahibi yok. Bu işi siz üstlenin." | `03 Proje panosu – iş başkasında` açıldı ve katılımcı işin Yazılımcı 2'de olduğunu söyledi | 03 → "Ben alırım" → 03 iş başkasında |

G3 bilerek hata durumuna gider: kullanıcının hatayı anlayıp anlamadığı ölçülür.

## Testi yürütmek

1. **Karşılama (okuyun):** "Siz Yazılımcı 3'sünüz. Sizi değil, tasarımı değerlendiriyoruz. Düşündüklerinizi sesli söyleyin. Bu bir taslak; bazı düğmeler açılmaz. Formda bir yere dokununca kalan yerler kendiliğinden dolar; siz ne yazıp ne seçeceğinizi sesli söyleyin."
2. **Görev:** Cümleyi bir kez okuyun, kâğıdını verin. Süreyi başlatın.
3. **Gözlem:** Yol göstermeyin. Nereye tıkladığını ve ne dediğini yazın.
4. **Takılırsa:** Yalnızca "Burada ne olmasını bekliyordunuz?" diye sorun. Yol gösterdiyseniz sonucu "yardımla" yazın.
5. **Vazgeçerse:** Yine aynı soruyu sorun, sonra sonraki göreve geçin.
6. **Görev belirsizse:** Hedefi açıklayabilirsiniz, yolu değil. Belirsizliği not edin.

### Hazırlık ve prototipin sınırları (yalnızca gözlemci için)

- **Açma:** `01 Giriş`i açın, sağ alttaki sunum simgesine basın, **User test** sekmesini seçip Close deyin. Ekran listesi, yorumlar ve bağlantı ipuçları kapalı gelir. Çıkış Esc.
- **Görevler arasında:** Önceki görevin sonucu ekranda kalmasın. "‹ Projeler", sonra Destek ve Bakım'da "Panoyu aç" ile `03 Proje panosu`na dönün. G2 ve G3 buradan başlar; sonuç ekranlarındaki "Taşı" düğmeleri açılmaz.
- **Form tek dokunuşta dolar:** `07` boş formda "Ne yapılacak?", Yazılımcı 1, Cuma ya da 17.00'ye dokununca dolu form açılır. Katılımcının hangisine önce dokunduğunu ve ne söylediğini yazın. Formun kendiliğinden dolmasına şaşırması tasarım bulgusu değil, prototip sınırıdır.
- **Şifre yanlış, bağlantı koptu ve boş liste** ekranları görevlerde çıkmaz; `00 Akış haritası`ndan açılır.

İzin: Ad, telefon, yüz kaydı almayın. Katılımcılar K1–K5 diye yazılır.

## Gözlem formu

Her katılımcı için doldurun. Sonuç: `bitirdi`, `yardımla`, `vazgeçti`.

| Kişi | Tarih | Görev | Süre (sn) | Sonuç | İlk tıkladığı yer | Takıldığı yer ve yaptığı | Söylediği söz (aynen) |
|---|---|---|--:|---|---|---|---|
| K1 | | G1 | | | | | |
| K1 | | G2 | | | | | |
| K1 | | G3 | | | | | |
| K2 | | G1 | | | | | |
| K2 | | G2 | | | | | |
| K2 | | G3 | | | | | |
| K3 | | G1 | | | | | |
| K3 | | G2 | | | | | |
| K3 | | G3 | | | | | |
| K4 | | G1 | | | | | |
| K4 | | G2 | | | | | |
| K4 | | G3 | | | | | |
| K5 | | G1 | | | | | |
| K5 | | G2 | | | | | |
| K5 | | G3 | | | | | |

**Gözlem mi, yorum mu?** "5 kişiden 3'ü + Yeni iş'i 30 saniyeden uzun aradı" gözlemdir. "Ekran karışık" yorumdur, yazmayın.

## Bulguları sıralamak

| Ciddiyet | Ölçüt | Ne zaman düzeltilir? |
|---|---|---|
| Engelleyici | İşi yardımsız bitiremiyor | Hemen |
| Ciddi | Bitiriyor ama çok uzun sürüyor ya da hata yapıyor | Bu sprintte |
| Küçük | Kısa duraksama, iş yine bitiyor | Sonraki sprintte |
| Görünüm | İşi etkilemeyen ayrıntı | Zaman kalırsa |

| Bulgu | Gözlem (kaç kişi, ne yaptı, ne dedi) | Kaynak: tasarım / görev / ortam | Öneri | Ciddiyet | Issue no |
|---|---|---|---|---|---|
| | | | | | |

Her bulgu için [issue-sablonu.md](issue-sablonu.md) ile bir Issue açılır. Engelleyici bulgu boardda düzeltilir ve en az 1–2 kişiyle yeniden denenir.

## Önce dikkat edilecek yerler (varsayım, sonuç değil)

Testte özellikle izleyin: "+ Yeni iş" kaydırmadan fark ediliyor mu? "Taşı" ile "durumu değiştirmek" aynı şey olarak anlaşılıyor mu? "Sonra seçilecek" ne anlama geliyor sanılıyor? Kişinin yanındaki sayı anlaşılıyor mu?
