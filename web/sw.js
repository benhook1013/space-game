// VERSION is a content hash of `assets_manifest.json` computed in
// `index.html` and passed as the `v` query parameter. This ensures the cache
// is invalidated whenever any asset changes.
const VERSION = new URL(self.location.href).searchParams.get("v") || "v1";
const CACHE_NAME = `space-game-cache-${VERSION}`;
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

async function cacheOptionalAssets(cache) {
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
}

self.addEventListener("install", (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE_NAME);
      await cacheAssets(cache, CORE_ASSETS);
    })(),
  );
  self.skipWaiting();
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
      const cache = await caches.open(CACHE_NAME);
      // Cache optional assets without delaying activation.
      cacheOptionalAssets(cache);
    })(),
  );
});

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return;
  event.respondWith(
    (async () => {
      const cache = await caches.open(CACHE_NAME);
      const cached = await cache.match(event.request);
      const fetchPromise = fetch(event.request)
        .then((response) => {
          if (
            response.status === 200 &&
            !event.request.url.startsWith("chrome-extension")
          ) {
            cache.put(event.request, response.clone());
          }
          return response;
        })
        .catch(() => cached);
      if (cached) {
        event.waitUntil(fetchPromise);
        return cached;
      }
      return fetchPromise;
    })(),
  );
});
