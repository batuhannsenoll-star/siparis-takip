# Sipariş Takip — GitHub ile Otomatik Güncelleme Kurulumu

Bu depo iki klasör içerir:
- `web/`   → Netlify'a bağlanacak, web + telefon (PWA) sürümü
- `desktop/` → Electron masaüstü uygulaması (Windows kurulum dosyası buradan üretiliyor)

Kod her güncellendiğinde: `web/` klasöründeki değişiklik Netlify'a otomatik yansır, `desktop/` klasöründeki değişiklik ise kurulu masaüstü uygulamalarına otomatik "güncelleme var" bildirimi olarak gider.

---

## BÖLÜM 1 — GitHub hesabı ve depo (repo) oluşturma

1. **https://github.com/signup** adresine git, ücretsiz bir hesap oluştur (e-posta, kullanıcı adı, şifre).
2. Giriş yaptıktan sonra sağ üstteki **+** işaretine tıkla → **"New repository"**.
3. **Repository name:** `siparis-takip` yaz.
4. **Private** seçeneğini işaretle (dış dünyaya kapalı olsun, sadece sen ve eklediğin kişiler görsün).
5. Diğer seçenekleri (README ekle vb.) **boş bırak**, direkt **"Create repository"**ye bas.
6. Açılan sayfada bir adres göreceksin, şuna benzer: `https://github.com/KULLANICI_ADIN/siparis-takip.git` — bu adresi not al, birazdan lazım olacak.

## BÖLÜM 2 — GitHub Desktop kurma (kod yükleme için en kolay yol)

Komut satırıyla uğraşmamak için görsel bir araç kullanacağız:

1. **https://desktop.github.com** adresinden **GitHub Desktop**'ı indir, kur.
2. Açtığında GitHub hesabınla giriş yap.
3. Üst menüden **File → Add local repository**.
4. Bu zip'i çıkardığın klasörü (içinde `web`, `desktop`, `.gitignore` olan ana klasör — `siparis-takip-repo`) seç.
5. "This directory does not appear to be a Git repository" gibi bir uyarı çıkarsa, altındaki **"create a repository"** linkine tıkla, onayla.
6. Sol altta bir **"Publish repository"** butonu göreceksin — ona tıkla.
7. Açılan pencerede **"Keep this code private"** işaretli olsun, **isim alanına `siparis-takip` yaz** (Bölüm 1'de oluşturduğun depoyla aynı isim), **"Publish Repository"**ye bas.

Kodun artık GitHub'da. Bundan sonra her değişiklikte:
1. Dosyalar güncellenince GitHub Desktop'ı aç, değişen dosyaları göreceksin.
2. Alt kısımdaki mesaj kutusuna kısa bir not yaz (ör. "yeni aşama alanı eklendi").
3. **"Commit to main"** → sonra üstteki **"Push origin"** butonuna bas.

Bu kadar — kod GitHub'a gitti.

## BÖLÜM 3 — Netlify'ı GitHub'a bağlama (web + telefon otomatik güncellensin)

1. Netlify'da projenin sayfasına git (`gleeful-wisp-898937`).
2. Sol menüden **Project configuration** → **Build & deploy** (veya "Continuous deployment") sekmesine gir.
3. **"Link repository"** / **"Link site to Git"** gibi bir buton bulacaksın, ona tıkla.
4. GitHub ile bağlan (izin ver), listeden **`siparis-takip`** deposunu seç.
5. Build ayarlarında:
   - **Base directory:** `web`
   - **Publish directory:** `web`
   - **Build command:** boş bırak (statik dosyalar, derlemeye gerek yok)
6. Kaydet.

Artık her `Push origin` yaptığında (web klasöründe değişiklik varsa), Netlify birkaç saniye içinde otomatik olarak siteyi günceller — sen hiçbir şey yapmıyorsun, ekip de mevcut adresi/kısayolu kullanmaya devam ediyor.

## BÖLÜM 4 — Masaüstü uygulaması için otomatik güncelleme

Bu kısım biraz daha teknik ama tek seferlik kurulum:

### 4.1 — Kişisel erişim anahtarı (token) oluşturma
1. GitHub'da sağ üstteki profil resmine tıkla → **Settings**.
2. Sol altta **Developer settings** → **Personal access tokens** → **Tokens (classic)**.
3. **Generate new token (classic)**.
4. İsim ver (ör. "siparis-takip-yayinlama"), süre olarak "No expiration" ya da uzun bir süre seç.
5. Yetkilerden sadece **`repo`** kutusunu işaretle.
6. **Generate token** — sana `ghp_...` ile başlayan bir kod verecek. **Bunu bir kenara not et, bir daha gösterilmeyecek.** (Bu kodu benimle veya başka biriyle paylaşma, sadece kendi bilgisayarında kullanacaksın.)

### 4.2 — package.json içindeki yeri güncelleme
`desktop/package.json` dosyasında şu satırı bul:
```
"owner": "KULLANICI_ADIN",
```
`KULLANICI_ADIN` yazan yeri kendi GitHub kullanıcı adınla değiştir.

### 4.3 — Token'ı bilgisayarına tanıtma
Komut isteminde (electron-app klasöründeyken) şunu çalıştır — `ghp_...` kısmına kendi tokenını yapıştır:
```
setx GH_TOKEN "ghp_buraya_kendi_tokenin"
```
Bunu bir kere yaptıktan sonra komut istemini kapatıp yeniden aç (yeni pencerede geçerli olur).

### 4.4 — Paketleri güncelle ve yayınla
```
cd desktop
npm install
npm run publish:win
```
Bu komut hem `.exe` kurulum dosyasını üretir hem de otomatik olarak GitHub'daki deponun **"Releases"** (Sürümler) bölümüne yükler.

### 4.5 — Yeni sürüm çıkardığında yapman gereken tek şey
Her yeni güncellemede `desktop/package.json` içindeki `"version": "1.0.0"` satırını bir artır (ör. `1.0.1`), sonra:
```
npm run publish:win
```
çalıştır. Kurulu olan tüm masaüstü uygulamaları, açıldıklarında bunu otomatik fark edip arka planda indirir; indirme bitince kullanıcıya "Yeniden başlatılsın mı?" diye sorar.

**İlk kurulumu ekip arkadaşlarına yine elle dağıtman gerekiyor** (ilk `.exe`'yi bir kere kurmaları lazım) — ama o kurulumdan sonraki tüm güncellemeler otomatik olur, tekrar `.exe` göndermene gerek kalmaz.

---

## Özet — bundan sonra bir değişiklik istediğinde süreç
1. Bana ne değiştirmek istediğini söylersin.
2. Ben `web/` ve/veya `desktop/` klasöründeki dosyaları güncellerim, sana veririm.
3. Sen GitHub Desktop'ta **Commit → Push** yaparsın.
4. Web/telefon: birkaç saniyede otomatik güncellenir.
5. Masaüstü: `desktop` klasöründe versiyon numarasını artırıp `npm run publish:win` çalıştırırsın — kurulu uygulamalar otomatik güncellenir.
