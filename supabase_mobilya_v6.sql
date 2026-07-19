-- ============================================================
-- Mobilya Üretim Modülü — v6 migration
-- Yeni rol: mobilya_vardiya_amiri (profiles.rol alanına elle atanacak,
-- şema değişikliği gerekmiyor çünkü rol serbest metin sütunu)
-- Akış: Giyotin Kesim -> (Dış Papel Stoğu ayrı besleme) -> Pres Hattı
--       -> Ara Stok (hesaplanır) -> CNC Hattı -> Ara Stok (hesaplanır)
--       -> Zımpara/Fitil Çakımı -> Depo/Sevkiyat
-- ============================================================

-- 1) Giyotin Kesim
create table if not exists mobilya_giyotin_kesim (
  id uuid primary key default gen_random_uuid(),
  tarih date not null,
  vardiya smallint not null check (vardiya in (1,2,3)),
  olcu text not null,
  adet integer not null check (adet >= 0),
  aciklama text,
  created_by uuid references profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

-- 2) Dış Papel Stoğu (giriş/çıkış hareket kaydı)
create table if not exists mobilya_dis_papel_hareketleri (
  id uuid primary key default gen_random_uuid(),
  tarih date not null,
  olcu_tur text not null,
  miktar numeric not null check (miktar >= 0),
  hareket_tipi text not null check (hareket_tipi in ('giris','cikis')),
  aciklama text,
  created_by uuid references profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

-- 3) Pres Hattı
create table if not exists mobilya_pres_uretim (
  id uuid primary key default gen_random_uuid(),
  tarih date not null,
  vardiya smallint not null check (vardiya in (1,2,3)),
  olcu text,
  adet integer not null check (adet >= 0),
  aciklama text,
  created_by uuid references profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

-- 4) CNC Hattı
create table if not exists mobilya_cnc_islem (
  id uuid primary key default gen_random_uuid(),
  tarih date not null,
  vardiya smallint not null check (vardiya in (1,2,3)),
  olcu text,
  adet integer not null check (adet >= 0),
  aciklama text,
  created_by uuid references profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

-- 5) Zımpara / Fitil Çakımı
create table if not exists mobilya_zimpara_fitil (
  id uuid primary key default gen_random_uuid(),
  tarih date not null,
  vardiya smallint not null check (vardiya in (1,2,3)),
  bolum text not null check (bolum in ('zimpara','fitil','ikisi')),
  adet integer not null check (adet >= 0),
  cikis_yeri text not null check (cikis_yeri in ('depo','sevkiyat')),
  aciklama text,
  created_by uuid references profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz
);

-- ============================================================
-- RLS: hepsi için aynı kural seti
-- Görüntüleme: mobilya_vardiya_amiri, admin, patron
-- Ekleme/Düzenleme/Silme: mobilya_vardiya_amiri, admin
-- ============================================================

do $$
declare
  tbl text;
  tablolar text[] := array[
    'mobilya_giyotin_kesim',
    'mobilya_dis_papel_hareketleri',
    'mobilya_pres_uretim',
    'mobilya_cnc_islem',
    'mobilya_zimpara_fitil'
  ];
begin
  foreach tbl in array tablolar loop
    execute format('alter table %I enable row level security;', tbl);

    execute format('create policy "%s_select" on %I for select using (current_rol() in (''mobilya_vardiya_amiri'',''admin'',''patron''));', tbl, tbl);
    execute format('create policy "%s_insert" on %I for insert with check (current_rol() in (''mobilya_vardiya_amiri'',''admin''));', tbl, tbl);
    execute format('create policy "%s_update" on %I for update using (current_rol() in (''mobilya_vardiya_amiri'',''admin''));', tbl, tbl);
    execute format('create policy "%s_delete" on %I for delete using (current_rol() in (''mobilya_vardiya_amiri'',''admin''));', tbl, tbl);
  end loop;
end $$;

-- Sorgu performansı için indeksler
create index if not exists idx_mobilya_giyotin_tarih on mobilya_giyotin_kesim(tarih desc);
create index if not exists idx_mobilya_dispapel_tarih on mobilya_dis_papel_hareketleri(tarih desc);
create index if not exists idx_mobilya_pres_tarih on mobilya_pres_uretim(tarih desc);
create index if not exists idx_mobilya_cnc_tarih on mobilya_cnc_islem(tarih desc);
create index if not exists idx_mobilya_zimpara_tarih on mobilya_zimpara_fitil(tarih desc);
