import React, { useEffect, useRef, useState } from 'react';
import maplibregl from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';
import api from '../lib/api';

const MAP_STYLE = 'https://tiles.openfreemap.org/styles/liberty';
const KIGALI    = [30.0619, -1.9441];

const SEV_COLOR  = { critical:'#ef4444', high:'#f97316', medium:'#eab308', low:'#22c55e' };
const RSP_COLOR  = { available:'#22c55e', 'on-duty':'#3b82f6', offline:'#9ca3af' };
const INC_ICON   = { medical:'🏥', fire:'🔥', security:'🚨', accident:'🚗', other:'⚠️' };
const TIER_BADGE = { vip:'⭐', private:'🔒', standard:'' };

/* Build a DOM element for an incident marker */
const makeIncidentEl = (inc) => {
  const color = SEV_COLOR[inc.severity] || '#f97316';
  const icon  = INC_ICON[inc.type] || '⚠️';
  const badge = TIER_BADGE[inc.serviceType] || '';
  const el = document.createElement('div');
  el.style.cssText = `
    width:40px;height:40px;background:${color};border-radius:50%;
    border:3px solid white;box-shadow:0 2px 10px rgba(0,0,0,.3);
    display:flex;align-items:center;justify-content:center;
    font-size:20px;cursor:pointer;position:relative;
    ${inc.severity === 'critical' ? 'animation:cspin 1.8s ease-in-out infinite;' : ''}
  `;
  el.innerHTML = icon + (badge ? `<span style="position:absolute;top:-5px;right:-5px;font-size:13px">${badge}</span>` : '');
  return el;
};

const makeResponderEl = (status) => {
  const color = RSP_COLOR[status] || '#9ca3af';
  const el = document.createElement('div');
  el.style.cssText = `
    width:34px;height:34px;background:${color};border-radius:50%;
    border:3px solid white;box-shadow:0 2px 8px rgba(0,0,0,.3);
    display:flex;align-items:center;justify-content:center;font-size:17px;cursor:pointer;
  `;
  el.textContent = '🚒';
  return el;
};

const incidentPopupHTML = (inc) => `
  <div style="font-size:13px;line-height:1.65;padding:2px 0">
    <b style="font-size:14px">${INC_ICON[inc.type]||'⚠️'} ${inc.title||'Emergency'}</b><br/>
    <span style="color:${SEV_COLOR[inc.severity]};font-weight:700;font-size:11px;text-transform:uppercase">
      ${inc.severity} · ${inc.type}${inc.serviceType!=='standard'?` · ${TIER_BADGE[inc.serviceType]} ${inc.serviceType}`:''}
    </span><br/>
    ${inc.description?`<span style="color:#555;display:block;margin-top:3px">${inc.description}</span>`:''}
    ${inc.audioFile?`<audio controls src="/uploads/${inc.audioFile}" style="width:100%;height:30px;margin-top:5px"></audio>`:''}
    ${(inc.proofFiles||[]).length?`<div style="display:flex;gap:4px;flex-wrap:wrap;margin-top:5px">${inc.proofFiles.map(f=>`<img src="/uploads/${f}" style="width:58px;height:58px;object-fit:cover;border-radius:5px">`).join('')}</div>`:''}
    <span style="color:#94a3b8;font-size:11px;margin-top:4px;display:block">👤 ${inc.reporter?.name||'Unknown'}</span>
  </div>`;

const responderPopupHTML = (rsp) => `
  <div style="font-size:13px;line-height:1.6">
    <b>🚒 ${rsp.name||'Responder'}</b><br/>
    <span style="color:${RSP_COLOR[rsp.status]};font-weight:700;font-size:11px">${(rsp.status||'').toUpperCase()}</span><br/>
    <span style="color:#666;font-size:11px">Vehicle: ${rsp.vehicleType||'N/A'}<br>Active: ${rsp.currentAssignments} assignments</span>
  </div>`;

const LiveMap = ({ socket, role }) => {
  const containerRef = useRef(null);
  const mapRef       = useRef(null);
  const readyRef     = useRef(false);
  const incMarkersRef = useRef({});   // _id → Marker
  const rspMarkersRef = useRef({});   // id  → Marker
  const myMarkerRef  = useRef(null);

  const [incidents,  setIncidents]  = useState([]);
  const [responders, setResponders] = useState([]);
  const [loading,    setLoading]    = useState(true);
  const [mapReady,   setMapReady]   = useState(false);

  /* ── Init map ───────────────────────────────────── */
  useEffect(() => {
    if (!containerRef.current) return;

    const map = new maplibregl.Map({
      container: containerRef.current,
      style: MAP_STYLE,
      center: KIGALI,
      zoom: 13,
    });

    map.addControl(new maplibregl.NavigationControl(), 'top-right');
    map.addControl(
      new maplibregl.GeolocateControl({
        positionOptions: { enableHighAccuracy: true },
        trackUserLocation: true,
        showUserHeading: true,
      }),
      'top-right'
    );

    map.on('load', () => {
      mapRef.current = map;
      readyRef.current = true;
      setMapReady(true);
    });

    return () => {
      map.remove();
      mapRef.current  = null;
      readyRef.current = false;
    };
  }, []);

  /* ── Fetch initial data ─────────────────────────── */
  useEffect(() => {
    (async () => {
      try {
        const [ir, rr] = await Promise.all([
          api.get('/dashboard/live'),
          api.get('/dashboard/responders'),
        ]);
        setIncidents(ir.data.incidents || []);
        setResponders(rr.data || []);
      } catch (e) { console.error('Map data:', e); }
      finally { setLoading(false); }
    })();
  }, []);

  /* ── Sync incident markers ──────────────────────── */
  useEffect(() => {
    if (!mapReady || !mapRef.current) return;

    // Remove stale
    Object.entries(incMarkersRef.current).forEach(([id, m]) => {
      if (!incidents.find(i => i._id === id)) { m.remove(); delete incMarkersRef.current[id]; }
    });

    incidents.forEach(inc => {
      if (!inc.location?.lat || !inc.location?.lng) return;
      const existing = incMarkersRef.current[inc._id];

      if (existing) {
        existing.setLngLat([inc.location.lng, inc.location.lat]);
        return;
      }

      const popup = new maplibregl.Popup({ offset: 16, maxWidth: '270px' })
        .setHTML(incidentPopupHTML(inc));

      const marker = new maplibregl.Marker({ element: makeIncidentEl(inc) })
        .setLngLat([inc.location.lng, inc.location.lat])
        .setPopup(popup)
        .addTo(mapRef.current);

      incMarkersRef.current[inc._id] = marker;
    });
  }, [incidents, mapReady]);

  /* ── Sync responder markers ─────────────────────── */
  useEffect(() => {
    if (!mapReady || !mapRef.current) return;
    if (role !== 'dispatcher' && role !== 'admin') return;

    Object.entries(rspMarkersRef.current).forEach(([id, m]) => {
      if (!responders.find(r => r.id === id)) { m.remove(); delete rspMarkersRef.current[id]; }
    });

    responders.forEach(rsp => {
      if (!rsp.lat || !rsp.lng) return;
      const existing = rspMarkersRef.current[rsp.id];
      if (existing) { existing.setLngLat([rsp.lng, rsp.lat]); return; }

      const popup = new maplibregl.Popup({ offset: 13, maxWidth: '210px' })
        .setHTML(responderPopupHTML(rsp));

      const marker = new maplibregl.Marker({ element: makeResponderEl(rsp.status) })
        .setLngLat([rsp.lng, rsp.lat])
        .setPopup(popup)
        .addTo(mapRef.current);

      rspMarkersRef.current[rsp.id] = marker;
    });
  }, [responders, mapReady, role]);

  /* ── Live user location dot ─────────────────────── */
  useEffect(() => {
    if (!mapReady || !navigator.geolocation) return;

    const watchId = navigator.geolocation.watchPosition(pos => {
      const { latitude: lat, longitude: lng } = pos.coords;
      if (!myMarkerRef.current) {
        const el = document.createElement('div');
        el.style.cssText = `
          width:18px;height:18px;background:#3b82f6;border-radius:50%;
          border:3px solid white;box-shadow:0 2px 8px rgba(59,130,246,.5);
        `;
        myMarkerRef.current = new maplibregl.Marker({ element: el })
          .setLngLat([lng, lat])
          .addTo(mapRef.current);
      } else {
        myMarkerRef.current.setLngLat([lng, lat]);
      }
    }, null, { enableHighAccuracy: true, maximumAge: 5000 });

    return () => {
      navigator.geolocation.clearWatch(watchId);
      myMarkerRef.current?.remove();
      myMarkerRef.current = null;
    };
  }, [mapReady]);

  /* ── Socket.IO real-time ────────────────────────── */
  useEffect(() => {
    if (!socket) return;
    socket.emit('join:dashboard');

    const onNew = ({ incident }) => setIncidents(p => [incident, ...p.filter(i => i._id !== incident._id)]);
    const onUpd = ({ incident }) => setIncidents(p =>
      ['resolved','cancelled'].includes(incident.status)
        ? p.filter(i => i._id !== incident._id)
        : p.map(i => i._id === incident._id ? incident : i));
    const onCan = ({ incidentId }) => setIncidents(p => p.filter(i => i._id !== incidentId));
    const onRL  = ({ responderId, location }) => setResponders(p => p.map(r => r.id === responderId ? { ...r, lat: location.lat, lng: location.lng } : r));
    const onRS  = ({ responderId, status })   => setResponders(p => p.map(r => r.id === responderId ? { ...r, status } : r));

    socket.on('incident:new',              onNew);
    socket.on('incident:status:updated',   onUpd);
    socket.on('incident:cancelled',        onCan);
    socket.on('responder:location:updated',onRL);
    socket.on('responder:status:updated',  onRS);

    return () => {
      ['incident:new','incident:status:updated','incident:cancelled',
       'responder:location:updated','responder:status:updated'].forEach(e => socket.off(e));
      socket.emit('leave:dashboard');
    };
  }, [socket]);

  return (
    <div style={{ position:'relative', height:'100%', width:'100%' }}>
      <style>{`
        @keyframes cspin {
          0%,100% { box-shadow: 0 0 0 0 rgba(239,68,68,.5); }
          50%      { box-shadow: 0 0 0 14px rgba(239,68,68,0); }
        }
        .maplibregl-popup-content { padding: 10px 14px !important; border-radius: 8px !important; }
      `}</style>

      {loading && (
        <div style={{ position:'absolute', top:'50%', left:'50%', transform:'translate(-50%,-50%)', zIndex:20, background:'white', padding:'12px 20px', borderRadius:8, boxShadow:'0 2px 12px rgba(0,0,0,.15)', fontSize:14, whiteSpace:'nowrap' }}>
          Loading map data…
        </div>
      )}

      <div ref={containerRef} style={{ width:'100%', height:'100%' }} />

      {/* Legend */}
      <div style={{ position:'absolute', bottom:30, right:10, background:'white', borderRadius:8, padding:'10px 14px', boxShadow:'0 2px 14px rgba(0,0,0,.18)', zIndex:10, fontSize:12, minWidth:135 }}>
        <b style={{ display:'block', marginBottom:6 }}>Legend</b>
        <div style={{ color:'#888', fontSize:10, textTransform:'uppercase', marginBottom:4 }}>Severity</div>
        {Object.entries(SEV_COLOR).map(([s,c]) => (
          <div key={s} style={{ display:'flex', alignItems:'center', gap:6, marginBottom:3 }}>
            <div style={{ width:11, height:11, borderRadius:'50%', background:c, flexShrink:0 }} />
            <span style={{ textTransform:'capitalize' }}>{s}</span>
          </div>
        ))}
        {(role==='dispatcher'||role==='admin') && <>
          <div style={{ color:'#888', fontSize:10, textTransform:'uppercase', margin:'8px 0 4px' }}>Responders</div>
          {Object.entries(RSP_COLOR).map(([s,c]) => (
            <div key={s} style={{ display:'flex', alignItems:'center', gap:6, marginBottom:3 }}>
              <div style={{ width:11, height:11, borderRadius:'50%', background:c, flexShrink:0 }} />
              <span style={{ textTransform:'capitalize' }}>{s}</span>
            </div>
          ))}
        </>}
        <div style={{ color:'#888', fontSize:10, textTransform:'uppercase', margin:'8px 0 4px' }}>Tier</div>
        <div style={{ fontSize:11 }}>⭐ VIP &nbsp; 🔒 Private</div>
      </div>

      {/* Counters */}
      <div style={{ position:'absolute', top:10, left:'50%', transform:'translateX(-50%)', display:'flex', gap:8, zIndex:10 }}>
        <div style={{ background:'white', padding:'5px 12px', borderRadius:20, boxShadow:'0 2px 10px rgba(0,0,0,.15)', fontSize:13, fontWeight:600 }}>🚨 {incidents.length} active</div>
        {(role==='dispatcher'||role==='admin') && (
          <div style={{ background:'white', padding:'5px 12px', borderRadius:20, boxShadow:'0 2px 10px rgba(0,0,0,.15)', fontSize:13, fontWeight:600 }}>🚒 {responders.length}</div>
        )}
      </div>
    </div>
  );
};

export default LiveMap;
