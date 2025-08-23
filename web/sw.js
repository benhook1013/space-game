const CACHE_NAME = 'space-game-cache-v1';
const CORE_ASSETS = [
  '/',
  'index.html',
  'manifest.json',
  'assets_manifest.json',
  'flutter.js',
  'main.dart.js',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(async (cache) => {
      await cache.addAll(CORE_ASSETS);
      try {
        const response = await fetch('assets_manifest.json');
        const manifest = await response.json();
        const assetList = [
          ...(manifest.images || []),
          ...(manifest.audio || []),
          ...(manifest.fonts || []),
        ];
        await cache.addAll(assetList);
      } catch (err) {
        console.error('Asset manifest fetch failed', err);
      }
    })
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((cached) => {
      if (cached) {
        return cached;
      }
      return fetch(event.request)
        .then((response) => {
          if (
            event.request.method === 'GET' &&
            response.status === 200 &&
            !event.request.url.startsWith('chrome-extension')
          ) {
            const responseClone = response.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, responseClone));
          }
          return response;
        })
        .catch(() => cached);
    })
  );
});
