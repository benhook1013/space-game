'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"segmenter_polyfill.js": "42e980438259612fd275ba3eb9a06067",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"README.md": "69e54bb8ad1801c4b01cc722dd2f8a75",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"manifest.json": "b561a71abfbc5e4202badf5794401417",
"icons/README.md": "d4147a9005e3fcdeee09ed9aedcd496b",
"icons/icon-192.png": "0be74780b317bfb1cf9d30b6393334c4",
"icons/icon-512.png": "408f9a687171af1e975e3d9ebc292caa",
"main.dart.js": "9fd6ba5a618c6d4c1802466ad3fc7147",
"version.json": "015fcbc753f376ba31f853aff8d57f36",
"assets/NOTICES": "b434f64ea67add55db4ec4aa259facaa",
"assets/fonts/MaterialIcons-Regular.otf": "620013362443d1ba40f8f3bde4466a0e",
"assets/AssetManifest.json": "c67be9a86cdbea0530a40b13e22c49ad",
"assets/assets/fonts/README.md": "ef3550644c76179dfb0b84004aaa4c82",
"assets/assets/audio/README.md": "87badf46837b243b29e881c748a2efb5",
"assets/assets/audio/shoot.wav": "d3a008d94a3259421fa6ac6d1483bd81",
"assets/assets/images/README.md": "a1e4da0d77583e1ba5509c623f88b424",
"assets/assets/images/enemies/enemy1.png": "d1f4d669f832c5d1062ea4a10941a448",
"assets/assets/images/enemies/enemy4.png": "ad63b16de87608174336966a05294e72",
"assets/assets/images/enemies/enemy3.png": "f480e1a3a5417cda5c9c3aee780531d5",
"assets/assets/images/enemies/enemy2.png": "f62cb6d825d0f50a2cca68bb519471df",
"assets/assets/images/asteroids/asteroid3.png": "ef7565d43fc00bc985acf253da03ff2f",
"assets/assets/images/asteroids/asteroid2.png": "6ef9dfb7dc912ce20411ecf920217d46",
"assets/assets/images/asteroids/asteroid1.png": "5f0e50eec8e29a257ebd9099ea85ced6",
"assets/assets/images/asteroids/asteroid5.png": "5d1e42f9b6e1b3cd6a1706bdc9d8d55e",
"assets/assets/images/asteroids/asteroid4.png": "b2cb4be849b870c1b351de051855da63",
"assets/assets/images/asteroids/asteroid6.png": "31526f8c24ca99e0fc2eb18bc78fd93f",
"assets/assets/images/bullet.png": "3473e9c111b0058c6fe00c81635b2d98",
"assets/assets/images/players/player1.png": "1163ba63821dbd17e78082987b152c66",
"assets/assets/images/players/player2.png": "b6c4e517c4c409f23e546b70720819f7",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "74d415116a85391989a75033577ad99f",
"assets/AssetManifest.bin": "8d443819fdc86abd9a52c640a5ec27b6",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"flutter_bootstrap.js": "f8195c9414445ac92b44b07221a161c0",
"assets_manifest.json": "c40a9a81fabbc60ef89499a7e8c1b386",
"sw.js": "c38e1cb38ee382fc005886bf39c6f867",
"index.html": "6faae429c8fc1f78fc4d1ecc9e6c7b78",
"/": "6faae429c8fc1f78fc4d1ecc9e6c7b78"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
