// filepath: utils/geocode.js
// Lightweight geocoding via OpenStreetMap Nominatim (no API key, works on both
// web and native). Intended for low-volume, prototype use.

const BASE = 'https://nominatim.openstreetmap.org';

// Look up coordinates for a place name / address.
export async function geocodePlace(query) {
  const q = (query || '').trim();
  if (!q) return null;
  try {
    const res = await fetch(
      `${BASE}/search?format=json&limit=1&q=${encodeURIComponent(q)}`,
      { headers: { Accept: 'application/json' } }
    );
    if (!res.ok) return null;
    const arr = await res.json();
    if (!arr || !arr.length) return null;
    return {
      latitude: parseFloat(arr[0].lat),
      longitude: parseFloat(arr[0].lon),
      displayName: arr[0].display_name || q,
    };
  } catch (e) {
    return null;
  }
}

// Best-effort human-readable name for a set of coordinates.
export async function reverseGeocode(latitude, longitude) {
  try {
    const res = await fetch(
      `${BASE}/reverse?format=json&lat=${latitude}&lon=${longitude}`,
      { headers: { Accept: 'application/json' } }
    );
    if (!res.ok) return null;
    const data = await res.json();
    return data.display_name || null;
  } catch (e) {
    return null;
  }
}

// URL that opens the point in the device/browser map app.
export function mapsUrl(latitude, longitude) {
  return `https://www.google.com/maps/search/?api=1&query=${latitude},${longitude}`;
}
