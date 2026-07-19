-- ============================================================
-- Hedef Günlük Kontraplak Üretimi ayarı — v8 migration
-- Tomruk Sahası ekranındaki "Hedefe Göre Tomruk İhtiyacı"
-- bloğu için gereken varsayılan ayar satırını ekler.
-- ============================================================

insert into sistem_ayarlari (anahtar, deger)
values ('hedef_gunluk_kontraplak_m3', 30)
on conflict (anahtar) do nothing;
