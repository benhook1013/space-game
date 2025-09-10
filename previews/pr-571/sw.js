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

const RARELY_CHANGED_EXTENSIONS = new Set([
  "png",
  "jpg",
  "jpeg",
  "gif",
  "svg",
  "mp3",
  "wav",
  "ogg",
  "json",
  "woff",
  "woff2",
]);

let cachedManifest;

// Only cache optional assets once per service worker version. Without this
// guard the manifest message posted on every page load would trigger
// `cacheOptionalAssets` repeatedly, forcing network requests for assets that
// are already cached.
self.addEventListener("message", (event) => {
  if (event.data && event.data.type === "assetManifest" && !cachedManifest) {
    cachedManifest = event.data.manifest;
    caches.open(CACHE_NAME).then((cache) => cacheOptionalAssets(cache));
  }
});

async function cacheAll(cache, assets) {
  const urls = [...new Set(assets)];
  await Promise.all(
    urls.map((url) =>
      cache.add(url).catch((err) => {
        console.warn(`Failed to cache ${url}`, err);
      })
    )
  );
}

async function cacheOptionalAssets(cache) {
  try {
    if (!cachedManifest) {
      const response = await fetch("assets_manifest.json");
      cachedManifest = await response.json();
    }
    const assetList = [
      ...(cachedManifest.images || []),
      ...(cachedManifest.audio || []),
      ...(cachedManifest.fonts || []),
    ].map((asset) => (asset.startsWith("assets/") ? asset : `assets/${asset}`));
    await cacheAll(cache, assetList);
  } catch (err) {
    console.error("Asset manifest fetch failed", err);
  }
}

self.addEventListener("install", (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE_NAME);
      await cacheAll(cache, CORE_ASSETS);
    })()
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
        keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k))
      );
      await self.clients.claim();
      // Optional assets are cached once the manifest is received from the page.
    })()
  );
});

async function staleWhileRevalidate(event) {
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
}

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return;
  const url = new URL(event.request.url);
  const ext = url.pathname.split(".").pop();
  if (ext && RARELY_CHANGED_EXTENSIONS.has(ext)) {
    event.respondWith(staleWhileRevalidate(event));
    return;
  }
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        if (
          response.status === 200 &&
          !event.request.url.startsWith("chrome-extension")
        ) {
          const responseClone = response.clone();
          caches
            .open(CACHE_NAME)
            .then((cache) => cache.put(event.request, responseClone))
            .catch((err) => {
              console.warn("Cache put failed", err);
            });
        }
        return response;
      })
      .catch(async () => {
        const cache = await caches.open(CACHE_NAME);
        return cache.match(event.request);
      })
  );
});
