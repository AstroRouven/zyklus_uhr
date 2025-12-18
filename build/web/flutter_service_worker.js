'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "5d36ed3573782652fce0abc3b50b96e7",
"assets/AssetManifest.bin.json": "647b896334008a25ff67235631227245",
"assets/assets/clock/p01_current.png": "6d8bb787dadb9167d922e216afbc1622",
"assets/assets/clock/p01_preview.png": "3764054ba9ceaaa0c15af2f578f8ca5a",
"assets/assets/clock/p02_current.png": "38132635e0834ddd21f957ddf2dc18d3",
"assets/assets/clock/p02_preview.png": "a2f963948055a25f914f5f234da202a7",
"assets/assets/clock/p03_current.png": "acc5243aceed1ccf859c560f24c6de1e",
"assets/assets/clock/p03_preview.png": "fcd0de28b4e00a6a6047ee9d92672e25",
"assets/assets/clock/p04_current.png": "135d3edad18df7d75f8a292ab7b99a75",
"assets/assets/clock/p04_preview.png": "87aec3b781f875185a9e619e5d1d66ef",
"assets/assets/clock/p05_current.png": "6c46c808b6be0b2105584f08cdc592ba",
"assets/assets/clock/p05_preview.png": "745837e20caf0d4825f7d0e8e6febd13",
"assets/assets/clock/p06_current.png": "6f8ca2ac6220c5653e09c792b5570b0a",
"assets/assets/clock/p06_preview.png": "4bfa98ce15ffe716092b6ca6a0da866d",
"assets/assets/clock/p07_current.png": "d54de7a506bc122c1b84e4d1ee44b489",
"assets/assets/clock/p07_preview.png": "b42cadcceccd3c6df58e86aa899bc6a5",
"assets/assets/clock/p08_current.png": "d84c60ecc83b600d9c41812b525158e0",
"assets/assets/clock/p08_preview.png": "e6b133ca90bbd9cbea29c243aa820fde",
"assets/assets/clock/p09_current.png": "3a6f9775542eed186f4da6ad51dd301b",
"assets/assets/clock/p09_preview.png": "86d2accc1e14c526fb012408472cb9f0",
"assets/assets/clock/p10_current.png": "0d695b33ae8cb8960fbac4edaa55d5ff",
"assets/assets/clock/p10_preview.png": "29edceb27eed1cab0056ab76ae29accf",
"assets/assets/clock/p11_current.png": "93d53dfb759f68f4fd66a05c1696e69a",
"assets/assets/clock/p11_preview.png": "d97378745261d769c4dd0dd02b658994",
"assets/assets/clock/p12_current.png": "d53054a1e3d6d46720495af91a9dd544",
"assets/assets/clock/p12_preview.png": "23ad60bdbcc151ced69f9e385c4e2214",
"assets/assets/female/p01_0.png": "3a10cad78fd01d07d2de1a2825a6e198",
"assets/assets/female/p01_1.png": "bdd280381595b8438709fc87ad1b5baf",
"assets/assets/female/p02_0.png": "934ae033fdef862d7f4994a326baa07d",
"assets/assets/female/p02_1.png": "c8759d4e01f9f39c2e7eaf0ffeac1f68",
"assets/assets/female/p03_0.png": "bac92d66e389efdc2ac92188707331e1",
"assets/assets/female/p03_1.png": "ee68cb2b93d88f43817413aa4e047e0a",
"assets/assets/female/p04_0.png": "d8a4e3270d2da7d21c9fbe6783b10e9d",
"assets/assets/female/p04_1.png": "488308edfcad38e8f0675dda2624aece",
"assets/assets/female/p05_0.png": "7ea1eb458614c73eaf196b56e89776c8",
"assets/assets/female/p05_1.png": "9ba01787277c4bc80c79cc48defef4cc",
"assets/assets/female/p06_0.png": "7467e43b5d63450ef205245d1a43f22e",
"assets/assets/female/p06_1.png": "b2ad956cea40d4165e21069e4d159483",
"assets/assets/female/p07_0.png": "4cf052b37b041802e493dadd2b7b64af",
"assets/assets/female/p07_1.png": "81d7743d78f2c53d6b31b638a059a96d",
"assets/assets/female/p08_0.png": "ab98039b08c10b201341cacfde821b12",
"assets/assets/female/p08_1.png": "fa477f4adeacaa588bba6b525712ec56",
"assets/assets/female/p09_0.png": "d7f76fdc01e431ab5c186b6db76d80b1",
"assets/assets/female/p09_1.png": "747b94efec413efe9190eebccf79fdae",
"assets/assets/female/p10_0.png": "fa317cbf2ddd9e1b95b95c2639188b7e",
"assets/assets/female/p10_1.png": "8e2bd50788966b46a0e9ecc0dc9dde3c",
"assets/assets/female/p11_0.png": "b6dc642111e855ee5822fe25ae142b70",
"assets/assets/female/p11_1.png": "0e8de8e67f8cb4c57b256eb3d723406c",
"assets/assets/female/p12_0.png": "e1a7354d4dd4f749da5d819e2546aa7c",
"assets/assets/female/p12_1.png": "668ee2cb890ca351319c1ee196d2d345",
"assets/assets/male/p01_0.png": "4ffff9afe33de22f4215982276d8f20d",
"assets/assets/male/p01_1.png": "9290833dfbf3c3819e6002d1f7554f64",
"assets/assets/male/p01_2.png": "6841f84d01f3527b82c054086aa8788e",
"assets/assets/male/p02_0.png": "a02995247228a928450fd0921dc21a91",
"assets/assets/male/p02_1.png": "8a8c1a595031cb90162555418f86051a",
"assets/assets/male/p02_2.png": "c79cad76b36b63efe9b24597bd4c6676",
"assets/assets/male/p03_0.png": "a3dc2f48027857fd1e6d3c742ff3606b",
"assets/assets/male/p03_1.png": "0132d13183e06bf5f6588a868ea90ef2",
"assets/assets/male/p03_2.png": "017060eef9f48ce03dc176eff9d2abe0",
"assets/assets/male/p04_0.png": "3bdb8794bff33e0457881bafe571fb76",
"assets/assets/male/p04_1.png": "c22592219df24c5cab1857eb38acfbf7",
"assets/assets/male/p04_2.png": "33fb77082be5b07be8e4a1d776e4e91c",
"assets/assets/male/p05_0.png": "5fb751d1bfea943e7cad63868607f341",
"assets/assets/male/p05_1.png": "a58a2d763eade911c0dbc728a6c283a4",
"assets/assets/male/p05_2.png": "44c938cd5a252f43b289d64b38f04c72",
"assets/assets/male/p06_0.png": "33ea04b348b2fd0234eb229a89e2ef43",
"assets/assets/male/p06_1.png": "35480660c464140098ebd908a66be39d",
"assets/assets/male/p06_2.png": "ee541abd382401c1cce89e231e95f3c1",
"assets/assets/male/p07_0.png": "3de9eb2d8c9c785937df24edff1b53c9",
"assets/assets/male/p07_1.png": "b35c0a7d11c9f4243bd6a7850430dffd",
"assets/assets/male/p07_2.png": "075bf8e951c766628f58edcd9cdbbd95",
"assets/assets/male/p08_0.png": "e8889339c6d6665b48f8d75b2f99a665",
"assets/assets/male/p08_1.png": "3d333e8278420f0027ee2e59997ad360",
"assets/assets/male/p08_2.png": "c9e1ec8e6295edbc1cbe663bedd54b10",
"assets/assets/male/p09_0.png": "c25145790bd0ddd30c5ea807ff11e65e",
"assets/assets/male/p09_1.png": "b8545864ae7b42adf3595b76d5081fcf",
"assets/assets/male/p09_2.png": "c7115966f8c369e5199816f2352f1661",
"assets/assets/male/p10_0.png": "c3303a7ad59bde89360d4b900395cbfc",
"assets/assets/male/p10_1.png": "c49cda74bf734ed0ced37dedd14b4385",
"assets/assets/male/p10_2.png": "5b9609599d82560755fb97c6833680d3",
"assets/assets/male/p11_0.png": "5addebb322b55ca076849a7ea386981b",
"assets/assets/male/p11_1.png": "4051aa0e0a98698a4644ae5ba9a3715f",
"assets/assets/male/p11_2.png": "e6f40efe9085d1ef2fa9426faa07af34",
"assets/assets/male/p12_0.png": "53ae7f108bbbb9441aa64f31b85d361a",
"assets/assets/male/p12_1.png": "fd8cb81d1879efc7dc2b7e3d14950385",
"assets/assets/male/p12_2.png": "701252da5c211f30fef377c6e32351ec",
"assets/assets/rel/p01_0.png": "d5f93d8c704bf28bf5cd4fbecbdd34ba",
"assets/assets/rel/p01_1.png": "3a828d5ee0076a6adaf87aec8956accf",
"assets/assets/rel/p02_0.png": "0716b9fd8fb83dbd7f92f2bcb7835f7c",
"assets/assets/rel/p02_1.png": "66278c54b8d466d431e2232632f08dcf",
"assets/assets/rel/p03_0.png": "f4ff58a07d5376c089ef13e1bb7b792e",
"assets/assets/rel/p03_1.png": "2c192dcb48242833acc7e715f27bcedd",
"assets/assets/rel/p04_0.png": "237e2aca859935f6153b1e1cd130ad1e",
"assets/assets/rel/p04_1.png": "755fc501ce1e7e32a72220b6b5604445",
"assets/assets/rel/p05_0.png": "5c316cfd45ec9f7f8e5a857d1f63f09d",
"assets/assets/rel/p05_1.png": "b6531f9bfabe5d0e0b42421333042802",
"assets/assets/rel/p06_0.png": "a662f81bf7bfd83db808c68e109e3807",
"assets/assets/rel/p06_1.png": "232bb9d650927581d22349f79732dce8",
"assets/assets/rel/p07_0.png": "436f89c03acb1d6a581e4f342d8112c3",
"assets/assets/rel/p07_1.png": "428cae98ce35fa37fc69cede54018543",
"assets/assets/rel/p08_0.png": "4dd736572650656c1a0e87b6d7559d01",
"assets/assets/rel/p08_1.png": "ae0183c69b12f2ab539251c3d91f0f7b",
"assets/assets/rel/p09_0.png": "15593e74da0c318d4b2d23f252255992",
"assets/assets/rel/p09_1.png": "154566a338b678daa6b43eda27819067",
"assets/assets/rel/p10_0.png": "fac7330ef78a3b4ef6bec22d9aab6d7c",
"assets/assets/rel/p10_1.png": "f6ff7c44bb0793a4ce1cfcd85af06568",
"assets/assets/rel/p11_0.png": "b242729ebeb856524bca00e74203a1fd",
"assets/assets/rel/p11_1.png": "324ea7d6d353a2452405539ce34c6f0f",
"assets/assets/rel/p12_0.png": "f532ff753f3d7a53e1864a40b12b1067",
"assets/assets/rel/p12_1.png": "7e41e52b9f5d369ebf700912b5ad01b1",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "2c22b386fd3365a289251c0eeee4efaf",
"assets/NOTICES": "f95b4f9267cd79cadbca7aab496b9b97",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "00f098b376195141d2d723ebd3889623",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "68a26f75b1eba4ee28a0aca3c8fbb3bc",
"/": "68a26f75b1eba4ee28a0aca3c8fbb3bc",
"main.dart.js": "f52e749dafe414136e2f6aef7398bdb8",
"manifest.json": "08201218728652928292f74bc0885e40",
"version.json": "950bde19615a39d4765264c0dbc28f06"};
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
