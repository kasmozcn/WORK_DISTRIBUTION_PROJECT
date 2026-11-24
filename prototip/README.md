# GörevAkış: tıklanabilir WireFrame prototip

BZ 313 Yazılım Mühendisliği, Hafta 7 ödevi. Ekip 9. Araç: Balsamiq. Proje: [GörevAkış WireFrame](https://balsamiq.cloud/smr1cku/p694tfx) (giriş gerektirir).

## Ödev durumu (slayt 37)

| # | İstenen | Durum | Nerede |
|---|---|---|---|
| 1a | Ana işi kâğıtta çizin | **Yapılacak**, elle çizilecek | [Kâğıt eskiz](#kâğıt-eskiz) |
| 1b | Balsamiq'te ekranları bağlayın | Yapıldı: 17 ekran bağlı, üç görev sunum modunda çalışıyor | [baglantilar.md](baglantilar.md) |
| 2 | Hata durumu ve boş liste | Çizildi: 4 hata/onay, 2 boş liste | [Ekranlar](#ekranlar) |
| 3 | Grup dışından en az 5 kişiyle test, 3 görev | Görevler ve form hazır. **Test yapılmadı** | [kullanici-testi.md](kullanici-testi.md) |
| 4 | Bulgular GitHub Issues'a | Şablon hazır. **Test sonrası** | [issue-sablonu.md](issue-sablonu.md) |
| 5 | Erişilebilirlik planı, çalışan arayüzde 5 kontrol | Yapıldı. Windows Anlatıcı denemesi yapılacak | [erisilebilirlik.md](erisilebilirlik.md) |
| 6 | PDF ya da bağlantı README'de | Eklendi: [PDF](GorevAkis-prototip.pdf) | [Kök README](../README.md) |

## Ana kullanıcı işi

**Bir işi doğru kişiye, teslim gün ve saatiyle vermek ve verildiğini görmek.**

Grup Dakikası sorusunun cevabı da budur: kullanıcı bu işi Giriş → Projeler → Proje panosu → Yeni iş → İş verildi ekranlarından geçerek yapar.

### Kullanım senaryosu

Aktör: projenin üyesi (Yazılımcı 3). Ön koşul: hesabı yönetici açmış, kişi "Destek ve Bakım" projesine eklenmiş.

| Adım | Kullanıcı | Sistem | Ekran |
|--:|---|---|---|
| 1 | E-posta ve şifreyle girer | Bekleyen işleri ve projeleri gösterir | 01 Giriş → 02 Projeler |
| 2 | Projenin panosunu açar | Sütunları, işleri ve kişi başına iş sayısını gösterir | 03 Proje panosu |
| 3 | + Yeni iş'e dokunur | Boş formu açar, "İşi ekle" pasiftir ve nedeni yazar | 07 Yeni iş – boş form |
| 4 | Ne, kime, ne zamana alanlarını doldurur | Seçimi tek cümlede özetler, düğmeyi açar | 07 Yeni iş – dolu |
| 5 | İşi ekle'ye dokunur | İşi panoya koyar, kime ve ne zamana verildiğini yazar, kişiye haber verir | 03 Proje panosu – iş verildi |

Alternatif akışlar:

| Nerede | Ne olur | Ekran |
|---|---|---|
| 1 | Şifre yanlış | 01 Giriş – hatalı |
| 1 | Hiç proje yok | 02 Projeler – boş |
| 2 | Projede iş yok | 03 Proje panosu – boş |
| 2 | Sahipsiz işi başkası önce aldı | 03 Proje panosu – iş başkasında |
| 5 | Bağlantı koptu | 07 Yeni iş – bağlantı koptu |
| 5 sonrası | İş ilerletilir | 06 İş detayı, 05 İşi taşıma → 03 Proje panosu – iş taşındı |
| 5 sonrası | İş arşivlenir ya da silinir | 03 – iş arşivlendi; 05 – silme onayı → 03 – iş silindi |

## Ekranlar

| Board | Tür |
|---|---|
| [00 Akış haritası](balsamiq-onizleme/00-akis-haritasi.webp) | Genel görünüm |
| [01 Giriş](balsamiq-onizleme/01-giris.webp) | Ana akış |
| [01 Giriş – hatalı](balsamiq-onizleme/01-giris-hatali.webp) | Hata |
| [02 Projeler](balsamiq-onizleme/02-projeler.webp) | Ana akış |
| [02 Projeler – boş](balsamiq-onizleme/02-projeler-bos.webp) | Boş liste |
| [03 Proje panosu](balsamiq-onizleme/03-proje-panosu.webp) | Ana akış |
| [03 Proje panosu – boş](balsamiq-onizleme/03-proje-panosu-bos.webp) | Boş liste |
| [03 Proje panosu – iş verildi](balsamiq-onizleme/03-is-verildi.webp) | Sonuç |
| [03 Proje panosu – iş taşındı](balsamiq-onizleme/03-is-tasindi.webp) | Sonuç |
| [03 Proje panosu – iş başkasında](balsamiq-onizleme/03-is-baskasinda.webp) | Hata |
| [03 Proje panosu – iş arşivlendi](balsamiq-onizleme/03-is-arsivlendi.webp) | Sonuç |
| [03 Proje panosu – iş silindi](balsamiq-onizleme/03-is-silindi.webp) | Sonuç |
| [05 İşi taşıma](balsamiq-onizleme/05-isi-tasima.webp) | Akış |
| [05 İşi taşıma – silme onayı](balsamiq-onizleme/05-silme-onayi.webp) | Onay (hata önleme) |
| [06 İş detayı](balsamiq-onizleme/06-is-detayi.webp) | Akış |
| [07 Yeni iş – boş form](balsamiq-onizleme/07-yeni-is-bos.webp) | Ana akış |
| [07 Yeni iş – dolu](balsamiq-onizleme/07-yeni-is-dolu.webp) | Ana akış |
| [07 Yeni iş – bağlantı koptu](balsamiq-onizleme/07-baglanti-koptu.webp) | Hata |
| [99 Tasarım notları](balsamiq-onizleme/99-tasarim-notlari.webp) | Prototipin parçası değil |

Numaralar onaylı Figma ekranlarının numaralarıdır. Müşteri 2 Kasım'da tasarımı dondurduğu için **yeni ekran eklenmedi**; eklenenler aynı ekranların hata, boş ve sonuç durumlarıdır.

## Dört ilkeye göre yapılan düzeltmeler

| Önceki sorun (onaylı tasarım ya da uygulama) | İlke | Düzeltme |
|---|---|---|
| Kişiler "MA, Y1, Y2" koduyla | Zihinsel model | "Yönetici", "Yazılımcı 1" |
| Taşıma yalnızca işi basılı tutunca açılıyor | Üç soru: ne yapabilirim? | Her kartta "Taşı" düğmesi |
| İş eklenince yalnızca "İş eklendi." yazıyor | Geri bildirim | Ne, kimde, ne zamana kadar ve "Geri al" |
| "İşi ekle" pasifken nedeni yazmıyor | Hata önleme | Nedeni düğmenin üstünde |
| Projeler ekranındaki "+" işi sormadan ilk projeye ekliyor | Hata önleme | Yeni iş yalnızca panodan |
| Giriş hatası ne yapılacağını söylemiyor | Hata mesajı | Ne oldu, neden, şimdi ne yapmalı |
| "+", "…", "‹", "X" yalnızca simge | Erişilebilirlik | Yazılı düğmeler |
| "2 iş seni bekliyor" altında iş adı yok | Üç soru: ne yapabilirim? | İşlerin adı ve "Panoda gör" |
| Formu kapatma sağ üstte, panoda geri sol üstte | Tutarlılık | Geri her ekranda sol üstte |
| "Sahibi yok" yazısı panoda kesiliyor ("Sahibi …") | Geri bildirim | Tarih ve sahip iki ayrı satır |

Silme onayı uygulamada zaten var; wireframe'de işin adı ve silinecek yorum sayısı eklendi.

## Tutanaklarla uyum

| Tutanak | Madde | Board |
|---|---|---|
| 18 Ekim, Karar 1 | Kullanıcı girişi; kart oluşturma | 01; 07 |
| 18 Ekim, Karar 1 | Sürükle-bırak ile durum güncelleme | 05 (dokunarak da) |
| 18 Ekim, Karar 1; 2 Kasım, Karar 2 | Alt görev listesi | 06 |
| 18 Ekim, 3.4 | Yalnızca ilgili kişiye bildirim | 07, 03 – iş verildi |
| 18 Ekim, 3.4 | Kimde kaç aktif iş var | 03 |
| 25 Ekim, 3.2 | Önce proje, proje altında üç sütun | 02, 03 |
| 25 Ekim, 3.3 madde 2 | Gün ve saat | 07 |
| 25 Ekim, 3.3 madde 4 | Silme ve arşivleme | 05 ve sonuç boardları |
| 25 Ekim, 3.4; 2 Kasım, 3.2 | Kişiyi yönetici ekler | 01 |
| 25 Ekim, Karar 2 | Sabit üç sütun | 03 |

## Kâğıt eskiz

Ekipten biri tek A4'e kurşun kalemle altı kutu çizer, oklarla bağlar, fotoğrafını `kagit-eskiz.jpg` adıyla bu klasöre koyar:

1. **Giriş:** e-posta, şifre, Giriş yap
2. **Projeler:** bekleyen işler, proje listesi
3. **Pano:** kişiler, Yapılacak sütunu, + Yeni iş
4. **Yeni iş:** ne, kime, ne zamana, İşi ekle
5. **İş verildi:** "Yazılımcı 1'de, Cuma 17.00", Geri al
6. **Bağlantı koptu** (4'ten aşağı ok): "eklenip eklenmediğini bilemiyoruz"

Eskizin ekranlardan farklı olması sorun değildir; denenen fikri gösterir.

## Dışa aktarma

[GorevAkis-prototip.pdf](GorevAkis-prototip.pdf): 18 sayfa (harita ve 17 ekran), Balsamiq'in board önizlemelerinden üretildi. Balsamiq'teki bağlantılar PDF'te de tıklanır.

Balsamiq'in kendi PDF'si istenirse: önce boş `New board 1` silinir, sonra **Project > Share/Export** (Ctrl+E). Balsamiq, PDF'in ekran bağlantılarını koruduğunu yazıyor. Düzenlenebilir kopya `GorevAkis.bmpr` olarak aynı menüden alınır. Paylaşım için **Review Link** hesap istemez, yalnızca proje ya da alan sahibi oluşturabilir.

Kaynaklar: [Full screen presentation](https://balsamiq.com/support/sharing/reviewing/full-screen-presentation-mode/), [Linking](https://balsamiq.com/support/creating-and-editing/linking/), [Public reviews](https://balsamiq.com/support/sharing/reviewing/public-reviews/), [Interactive PDF](https://balsamiq.com/support/sharing/reviewing/pdf-file/), [Components](https://balsamiq.com/support/creating-and-editing/components/creating/)
