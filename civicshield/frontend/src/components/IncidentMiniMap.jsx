import { useRef, useEffect } from 'react';
import maplibregl from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';

const MAP_STYLE = 'https://tiles.openfreemap.org/styles/liberty';

// Keep a single responder marker element across renders so we can reuse it
let responderMarkerInstance = null;

export default function IncidentMiniMap({ incident, responderLocation }) {
  const mapContainerRef = useRef(null);
  const mapRef = useRef(null);
  const responderMarkerRef = useRef(null);

  const lat = incident?.location?.lat;
  const lng = incident?.location?.lng;

  // ── Mount / unmount map ────────────────────────────────────────────────────
  useEffect(() => {
    if (!lat || !lng) return;

    const map = new maplibregl.Map({
      container: mapContainerRef.current,
      style: MAP_STYLE,
      center: [lng, lat],
      zoom: 15,
    });

    map.addControl(new maplibregl.NavigationControl(), 'top-right');

    map.on('load', () => {
      // ── Incident marker (red 🚨 circle) ──────────────────────────────────
      const incidentEl = document.createElement('div');
      incidentEl.cssText = [
        'width:36px',
        'height:36px',
        'border-radius:50%',
        'background-color:#ef4444',
        'border:3px solid #fff',
        'box-shadow:0 2px 8px rgba(0,0,0,0.45)',
        'display:flex',
        'align-items:center',
        'justify-content:center',
        'font-size:18px',
        'cursor:pointer',
        'user-select:none',
      ].join(';');
      incidentEl.textContent = '🚨';

      const popup = new maplibregl.Popup({ offset: 20, closeButton: false })
        .setHTML(
          `<div style="font-family:sans-serif;font-size:13px;line-height:1.4">
            <strong style="display:block;margin-bottom:2px">${incident.title || 'Incident'}</strong>
            <span style="color:#64748b">${incident.type || ''}</span>
          </div>`
        );

      new maplibregl.Marker({ element: incidentEl })
        .setLngLat([lng, lat])
        .setPopup(popup)
        .addTo(map);
    });

    mapRef.current = map;

    return () => {
      responderMarkerRef.current = null;
      map.remove();
    };
    // We intentionally run this only on mount; lat/lng changes are edge-case.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // ── Update responder marker whenever responderLocation changes ─────────────
  useEffect(() => {
    const map = mapRef.current;
    if (!map || !responderLocation?.lat || !responderLocation?.lng) return;

    const { lat: rLat, lng: rLng } = responderLocation;

    if (!responderMarkerRef.current) {
      // Create responder dot element
      const responderEl = document.createElement('div');
      responderEl.cssText = [
        'width:20px',
        'height:20px',
        'border-radius:50%',
        'background-color:#3b82f6',
        'border:3px solid #fff',
        'box-shadow:0 2px 6px rgba(59,130,246,0.55)',
        'box-sizing:border-box',
      ].join(';');

      const marker = new maplibregl.Marker({ element: responderEl })
        .setLngLat([rLng, rLat])
        .addTo(map);

      responderMarkerRef.current = marker;
    } else {
      responderMarkerRef.current.setLngLat([rLng, rLat]);
    }

    // Fit bounds to show both incident and responder
    if (lat && lng) {
      map.fitBounds(
        [
          [Math.min(lng, rLng), Math.min(lat, rLat)],
          [Math.max(lng, rLng), Math.max(lat, rLat)],
        ],
        { padding: 40, maxZoom: 16, duration: 600 }
      );
    }
  }, [responderLocation, lat, lng]);

  // ── Guard: nothing to show without a location ──────────────────────────────
  if (!lat || !lng) return null;

  const googleMapsUrl = `https://www.google.com/maps?q=${lat},${lng}`;

  // ── Styles ─────────────────────────────────────────────────────────────────
  const wrapperStyle = {
    borderRadius: '10px',
    overflow: 'hidden',
    border: '1px solid #e2e8f0',
    fontFamily: 'sans-serif',
  };

  const headerStyle = {
    backgroundColor: '#1e293b',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '10px 14px',
    boxSizing: 'border-box',
  };

  const headerLeftStyle = {
    color: '#fff',
    fontSize: '13px',
    fontWeight: 600,
    letterSpacing: '0.01em',
  };

  const headerLinkStyle = {
    color: '#60a5fa',
    fontSize: '12px',
    textDecoration: 'none',
    fontWeight: 500,
  };

  const mapContainerStyle = {
    height: '220px',
    width: '100%',
  };

  // ── Render ─────────────────────────────────────────────────────────────────
  return (
    <div style={wrapperStyle}>
      {/* Header bar */}
      <div style={headerStyle}>
        <span style={headerLeftStyle}>📍 Incident Location</span>
        <a
          href={googleMapsUrl}
          target="_blank"
          rel="noopener noreferrer"
          style={headerLinkStyle}
        >
          Open Google Maps →
        </a>
      </div>

      {/* Map */}
      <div ref={mapContainerRef} style={mapContainerStyle} />
    </div>
  );
}
