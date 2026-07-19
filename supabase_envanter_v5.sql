-- ============================================================
-- Envanter (Satın Alma modülü) — v5 migration
-- Kategoriler: Makine Yedek Parçaları / İş Kıyafetleri / Kırtasiye
-- Basit hareket-kaydı mantığı: her giriş/çıkış ayrı bir satır,
-- stok = toplam giriş - toplam çıkış (Kantar/Soyma ile aynı yaklaşım)
-- ============================================================

create table if not exists envanter_hareketleri (
  id uuid primary key default gen_random_uuid(),
  tarih date not null,
  kategori text not null check (kategori in ('makine_yedek_parca','is_kiyafeti','kirtasiye')),
  urun_adi text not null,
  miktar numeric not null check (miktar >= 0),
  hareket_tipi text not null check (hareket_tipi in ('giris','cikis')),
  aciklama text,
  created_by uuid references profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

alter table envanter_hareketleri enable row level security;

-- Görüntüleme: Satın Alma, Vardiya Amiri, Admin, Patron
create policy "envanter_select" on envanter_hareketleri
  for select
  using (current_rol() in ('satin_alma','vardiya_amiri','admin','patron'));

-- Ekleme: Giriş kaydı sadece Satın Alma + Admin, Çıkış kaydı sadece Vardiya Amiri + Admin
create policy "envanter_insert" on envanter_hareketleri
  for insert
  with check (
    (hareket_tipi = 'giris' and current_rol() in ('satin_alma','admin'))
    or (hareket_tipi = 'cikis' and current_rol() in ('vardiya_amiri','admin'))
  );

-- Düzenleme/Silme: sadece Admin (envanter kayıtlarında karışıklık olmaması için)
create policy "envanter_update" on envanter_hareketleri
  for update
  using (current_rol() = 'admin');

create policy "envanter_delete" on envanter_hareketleri
  for delete
  using (current_rol() = 'admin');

-- Sorgu performansı için indeksler
create index if not exists idx_envanter_tarih on envanter_hareketleri(tarih desc);
create index if not exists idx_envanter_kategori on envanter_hareketleri(kategori);
