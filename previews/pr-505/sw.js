const CACHE_NAME = "space-game-cache-v1";
const CORE_ASSETS = [
  "./",
  "index.html",
  "manifest.json",
  "assets_manifest.json",
  "flutter_bootstrap.js",
  "main.dart.js",
];

async function cacheAssets(cache, assets) {
  await Promise.all(
    assets.map(async (asset) => {
      const url = asset.startsWith("assets/") ? `assets/${asset}` : asset;
      try {
        await cache.add(url);
      } catch (err) {
        console.warn(`Failed to cache ${url}`, err);
      }
    }),
  );
}

self.addEventListener("install", (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE_NAME);
      await cacheAssets(cache, CORE_ASSETS);
      try {
        const response = await fetch("assets_manifest.json");
        const manifest = await response.json();
        const assetList = [
          ...(manifest.images || []),
          ...(manifest.audio || []),
          ...(manifest.fonts || []),
        ];
        await cacheAssets(cache, assetList);
      } catch (err) {
        console.error("Asset manifest fetch failed", err);
      } finally {
        // Activate the new service worker after attempting to cache optional
        // assets. If caching fails, still activate to avoid blocking updates
        // indefinitely.
        self.skipWaiting();
      }
    })(),
  );
});

self.addEventListener("activate", (event) => {
  // Take control of open pages right away so cached resources are served
  // during the first load after this service worker activates.
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(
        keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)),
      );
      await self.clients.claim();
    })(),
  );
});

self.addEventListener("fetch", (event) => {
  event.respondWith(
    caches.match(event.request).then((cached) => {
      if (cached) {
        return cached;
      }
      return fetch(event.request)
        .then((response) => {
          if (
            event.request.method === "GET" &&
            response.status === 200 &&
            !event.request.url.startsWith("chrome-extension")
          ) {
            const responseClone = response.clone();
            caches
              .open(CACHE_NAME)
              .then((cache) => cache.put(event.request, responseClone));
          }
          return response;
        })
        .catch(() => cached);
    }),
  );
});
