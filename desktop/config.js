// ==== AKIŞ FİRMA AYARLARI ====
// Her firma için bu dosya ayrı doldurulur. Kalan koda (index.html) dokunmaya gerek yoktur.
// Yeni firma eklerken: bu dosyayı kopyala, aşağıdaki değerleri o firmaya göre değiştir.

window.AKIS_CONFIG = {
  // --- Supabase bağlantısı (her firmanın kendi Supabase projesi olur) ---
  supabaseUrl: "https://jsjqyoibvdoqhvijhmwh.supabase.co",
  supabaseAnonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpzanF5b2lidmRvcWh2aWpobXdoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI4NjY5MzQsImV4cCI6MjA5ODQ0MjkzNH0.TgSbpElM7N1qoEB145u7_4yTxcsUe0eupiRe9Vxp7Bw",

  // --- Firma bilgileri (ekranlarda görünür) ---
  firmaAdi: "Anıl Orman Ürünleri",
  firmaLogo: "icons/akis-logo.png",

  // --- Bu firmada hangi modüller aktif? ---
  // Olası değerler: "satis", "uretim", "tedarik" (Satın Alma), "mobilya"
  // Not: "tedarik" ve "mobilya" modüllerinin sekmeleri şu an Anıl Orman'ın
  // kontraplak + mobilya üretimine özeldir. Farklı sektörden bir firma eklenince
  // bu sekmeler ayrıca gözden geçirilmeli.
  aktifModuller: ["satis", "uretim", "tedarik", "mobilya"]
};
