const CACHE_NAME = 'siparis-takip-v1';
const APP_SHELL = [
  './index.html',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-512.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(APP_SHELL))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((names) =>
      Promise.all(names.filter(n => n !== CACHE_NAME).map(n => caches.delete(n)))
    )
  );
  self.clients.claim();
});

// Ağ önce (fresh data için) — başarısız olursa (offline) önbellekten dön.
// Supabase API çağrıları önbelleğe alınmaz, sadece uygulama kabuğu (index.html, ikonlar) alınır.
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  if(url.origin !== location.origin){ return; } // Supabase isteklerine dokunma

  event.respondWith(
    fetch(event.request)
      .then((res) => {
        const copy = res.clone();
        caches.open(CACHE_NAME).then(cache => cache.put(event.request, copy));
        return res;
      })
      .catch(() => caches.match(event.request))
  );
});
