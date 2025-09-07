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
"README.md": "cff68b0dede4343ff501db10f5006bcc",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"manifest.json": "b561a71abfbc5e4202badf5794401417",
"icons/README.md": "d4147a9005e3fcdeee09ed9aedcd496b",
"icons/icon-192.png": "0be74780b317bfb1cf9d30b6393334c4",
"icons/icon-512.png": "408f9a687171af1e975e3d9ebc292caa",
"main.dart.js": "5701dfa8dd714c340cfb1ace5ec998e4",
"version.json": "015fcbc753f376ba31f853aff8d57f36",
"assets/NOTICES": "b434f64ea67add55db4ec4aa259facaa",
"assets/fonts/MaterialIcons-Regular.otf": "35e6000655523d76c638aa78b246ca3b",
"assets/AssetManifest.json": "15729738ef659032c7bf1eb957c7f85c",
"assets/assets/fonts/README.md": "ef3550644c76179dfb0b84004aaa4c82",
"assets/assets/audio/README.md": "ceb19a343f3d088d9d3191b2877d2ca1",
"assets/assets/audio/laser-bullet.mp3": "1269df9642aa53602c41226db033cef2",
"assets/assets/audio/mining-laser-continuous.mp3": "6583fad6aa7339f58f0e6db581123dd2",
"assets/assets/audio/explosion.mp3": "79f285e353c50ab66d7245b9c1d200c2",
"assets/assets/images/README.md": "ff92e4e92dc931f2ada182e2c00bb830",
"assets/assets/images/enemies/enemy1.png": "bd3ac232987ac8b4d9218aec94041db2",
"assets/assets/images/enemies/enemy4.png": "ad63b16de87608174336966a05294e72",
"assets/assets/images/enemies/enemy3.png": "f480e1a3a5417cda5c9c3aee780531d5",
"assets/assets/images/enemies/enemy2.png": "f62cb6d825d0f50a2cca68bb519471df",
"assets/assets/images/asteroids/asteroid3.png": "b2cb4be849b870c1b351de051855da63",
"assets/assets/images/asteroids/asteroid2.png": "ef7565d43fc00bc985acf253da03ff2f",
"assets/assets/images/asteroids/asteroid1.png": "6ef9dfb7dc912ce20411ecf920217d46",
"assets/assets/images/asteroids/asteroid5.png": "31526f8c24ca99e0fc2eb18bc78fd93f",
"assets/assets/images/asteroids/asteroid4.png": "5d1e42f9b6e1b3cd6a1706bdc9d8d55e",
"assets/assets/images/icons/score.png": "5c7e02dc0fe4fc7311bcc976d2ee0eaf",
"assets/assets/images/icons/health.png": "bec545c1be9728e8a7d59b78493584d8",
"assets/assets/images/icons/settings.png": "21dda4ce6dd48330e7274dc843da2ceb",
"assets/assets/images/icons/mineral.png": "a5a25fda7b96958f5d51f3414aa92170",
"assets/assets/images/bullet.png": "3473e9c111b0058c6fe00c81635b2d98",
"assets/assets/images/explosions/explosion1.png": "95bc45e0d5da7efa3230e2d220613961",
"assets/assets/images/explosions/explosion2.png": "915a30d49948e0f538ec368088ebedc2",
"assets/assets/images/explosions/explosion3.png": "e4e1f71c1c3fa41cd142d2405d9e0802",
"assets/assets/images/players/player1.png": "1163ba63821dbd17e78082987b152c66",
"assets/assets/images/players/player2.png": "b6c4e517c4c409f23e546b70720819f7",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/AssetManifest.bin.json": "cfef0d623468d3fe7aee769be036a533",
"assets/AssetManifest.bin": "6b7289acbc1d2818bc19c79fa520d645",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"flutter_bootstrap.js": "580a86805f2b702de9e84fec62f39810",
"assets_manifest.json": "71551524a1dc3e62fcd0bf0dca69d93b",
"sw.js": "dd02ac3a423b806e339aef5b3cecf10b",
"favicon.png": "6ef9dfb7dc912ce20411ecf920217d46",
"index.html": "f809f028d30d2af17239c62b91d1509b",
"/": "f809f028d30d2af17239c62b91d1509b"};
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
