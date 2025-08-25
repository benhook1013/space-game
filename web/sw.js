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
  for (const asset of assets) {
    const url = asset.startsWith("assets/") ? `assets/${asset}` : asset;
    try {
      await cache.add(url);
    } catch (err) {
      console.warn(`Failed to cache ${url}`, err);
    }
  }
}

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(async (cache) => {
      await cacheAssets(cache, CORE_ASSETS);
    }),
  );

  // Cache additional assets after activation so the install step finishes quickly.
  caches.open(CACHE_NAME).then(async (cache) => {
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
    }
  });
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)),
        ),
      ),
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
