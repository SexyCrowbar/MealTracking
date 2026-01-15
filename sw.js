const CACHE_NAME = 'meal-tracker-v1';
const ASSETS = [
  './index.html',
  './styles/main.css',
  './styles/components.css',
  './styles/screens.css',
  './js/app.js'
];

self.addEventListener('install', (e) => {
  e.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS))
  );
});

self.addEventListener('fetch', (e) => {
  e.respondWith(
    caches.match(e.request).then((response) => response || fetch(e.request))
  );
});
