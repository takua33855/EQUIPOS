// Vila Equipos — Service Worker v3
// v1 era cache-first para TODO con un nombre de cache fijo: una vez cacheado,
// index.html se servia para siempre y ningun cambio llegaba al usuario.
// v2 usa network-first para el HTML (siempre la version nueva si hay conexion,
// cache solo como respaldo offline) y deja cache-first para los iconos, que
// no cambian. Subir el numero de version limpia el cache viejo al activar.
// v3: el SW ya no toca NADA de otro origen. v1 y v2 cacheaban las respuestas
// de la API de Supabase, con lo que la app podia leer datos de horas atras.
const CACHE = 'vila-equipos-v3';
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
];

// Instalación — cachea todos los assets
self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(cache => cache.addAll(ASSETS))
  );
  self.skipWaiting();
});

// Activación — limpia caches viejos
self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    )
  );
  self.clients.claim();
});

// ¿Es una petición de la página en sí? (navegación o el propio index.html)
function esHTML(req) {
  return req.mode === 'navigate'
      || (req.destination === 'document')
      || /\/(index\.html)?(\?.*)?$/.test(new URL(req.url).pathname + new URL(req.url).search);
}

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;                  // no tocar POST/PATCH a Supabase

  // NUNCA tocar lo que no es de este origen. Las llamadas a la API de Supabase
  // son datos vivos: cachearlas hacía que la app leyera el estado de hace
  // horas — el importador llegó a recalcular su plan sobre filas ya
  // importadas. Se dejan pasar directo a la red, sin intervención del SW.
  if (new URL(req.url).origin !== self.location.origin) return;

  if (esHTML(req)) {
    // NETWORK-FIRST: la red manda; el cache es solo el respaldo offline.
    // Es lo que hace que un cambio en index.html llegue en la próxima carga.
    e.respondWith(
      fetch(req).then(resp => {
        if (resp && resp.status === 200 && resp.type !== 'opaque') {
          const clone = resp.clone();
          caches.open(CACHE).then(c => c.put('./index.html', clone));
        }
        return resp;
      }).catch(() => caches.match('./index.html').then(c => c || caches.match('./')))
    );
    return;
  }

  // Resto (iconos, manifest): cache-first, porque no cambian.
  e.respondWith(
    caches.match(req).then(cached => cached || fetch(req).then(resp => {
      if (resp && resp.status === 200 && resp.type !== 'opaque') {
        const clone = resp.clone();
        caches.open(CACHE).then(c => c.put(req, clone));
      }
      return resp;
    }))
  );
});
