import React, { useEffect, useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../lib/api';
import { useAuth } from '../hooks/useAuth';
import { useSocket } from '../hooks/useSocket';
import ChatWidget from '../components/ChatWidget';
import IncidentMiniMap from '../components/IncidentMiniMap';

const STATUS_ORDER = ['assigned', 'en-route', 'on-scene', 'completed'];
const STATUS_COLOR = { assigned:'#f97316', 'en-route':'#3b82f6', 'on-scene':'#8b5cf6', completed:'#22c55e' };
const SEV_COLOR    = { critical:'#ef4444', high:'#f97316', medium:'#eab308', low:'#22c55e' };
const INC_ICON     = { medical:'🏥', fire:'🔥', security:'🚨', accident:'🚗', other:'⚠️' };
const NEXT_STATUS  = { assigned:'en-route', 'en-route':'on-scene', 'on-scene':'completed' };
const NEXT_LABEL   = { assigned:'🚗 En Route', 'en-route':'📍 On Scene', 'on-scene':'✅ Complete' };

const MyAssignmentsPage = () => {
  const navigate         = useNavigate();
  const { user }         = useAuth();
  const { socket }       = useSocket();

  const [assignments, setAssignments] = useState([]);
  const [loading,     setLoading]     = useState(true);
  const [updating,    setUpdating]    = useState(null);
  const [activeChat,  setActiveChat]  = useState(null);
  const [myLocation,  setMyLocation]  = useState(null);   // {lat, lng}
  const [citizenLocs, setCitizenLocs] = useState({});     // incidentId → {lat, lng}
  const watchIdRef = useRef(null);

  const load = () => {
    api.get('/assignments/my/assignments')
      .then(r => setAssignments(Array.isArray(r.data) ? r.data : []))
      .catch(() => setAssignments([]))
      .finally(() => setLoading(false));
  };

  useEffect(() => { load(); }, []);

  // GPS: watch responder position, broadcast to dispatcher + show on own map
  useEffect(() => {
    if (!navigator.geolocation) return;
    watchIdRef.current = navigator.geolocation.watchPosition(
      pos => {
        const { latitude: lat, longitude: lng } = pos.coords;
        setMyLocation({ lat, lng });
        if (socket && user) {
          socket.emit('responder:location:duty', { responderId: user.id || user._id, lat, lng });
        }
      },
      null,
      { enableHighAccuracy: true, maximumAge: 4000 }
    );
    return () => {
      if (watchIdRef.current != null) navigator.geolocation.clearWatch(watchIdRef.current);
    };
  }, [socket, user]);

  // Join incident rooms + listen for citizen live location updates
  useEffect(() => {
    if (!socket || assignments.length === 0) return;
    assignments.forEach(asn => {
      if (asn.incident?._id) socket.emit('join:incident', asn.incident._id);
    });
    const onCitizenLoc = ({ incidentId, lat, lng }) => {
      setCitizenLocs(prev => ({ ...prev, [incidentId]: { lat, lng } }));
    };
    socket.on('citizen:location:updated', onCitizenLoc);
    return () => {
      socket.off('citizen:location:updated', onCitizenLoc);
      assignments.forEach(asn => {
        if (asn.incident?._id) socket.emit('leave:incident', asn.incident._id);
      });
    };
  }, [socket, assignments]);

  const updateStatus = async (assignmentId, status) => {
    setUpdating(assignmentId);
    try {
      await api.put(`/assignments/${assignmentId}`, { status });
      load();
    } catch (e) {
      alert(e.response?.data?.error || 'Update failed');
    } finally {
      setUpdating(null);
    }
  };

  const fmt = s => Math.round(s / 60) > 0 ? `${Math.round(s / 60)}m` : `${s}s`;

  return (
    <div style={s.page}>
      <div style={s.inner}>
        <div style={s.topBar}>
          <button onClick={() => navigate('/dashboard')} style={s.back}>← Dashboard</button>
          <h1 style={s.title}>📍 My Assignments</h1>
          <button onClick={load} style={s.refresh}>↻ Refresh</button>
        </div>

        {/* My GPS */}
        {myLocation && (
          <div style={s.myLocBar}>
            <span style={s.gpsGreen} />
            GPS active · {myLocation.lat.toFixed(5)}, {myLocation.lng.toFixed(5)}
            <span style={{ marginLeft: 'auto', fontSize: 11, color: '#94a3b8' }}>Broadcasting to dispatcher</span>
          </div>
        )}

        {loading && <div style={s.empty}>Loading assignments…</div>}

        {!loading && assignments.length === 0 && (
          <div style={s.empty}>
            <div style={{ fontSize: 48, marginBottom: 12 }}>✅</div>
            <p>No active assignments right now.</p>
            <p style={{ fontSize: 13, color: '#94a3b8' }}>You'll be notified when assigned to an incident.</p>
          </div>
        )}

        <div style={s.list}>
          {assignments.map(asn => {
            const inc  = asn.incident;
            const next = NEXT_STATUS[asn.status];
            // Show citizen live location on map if available, else incident's stored location
            const citizenLive = citizenLocs[inc?._id];
            const mapIncident = citizenLive && inc
              ? { ...inc, location: { ...inc.location, lat: citizenLive.lat, lng: citizenLive.lng } }
              : inc;

            return (
              <div key={asn._id} style={s.card}>
                {/* Status progress */}
                <div style={s.progressBar}>
                  {STATUS_ORDER.slice(0, -1).map(st => (
                    <div key={st} style={{
                      ...s.progressStep,
                      background: STATUS_ORDER.indexOf(st) <= STATUS_ORDER.indexOf(asn.status)
                        ? STATUS_COLOR[asn.status] : '#e2e8f0',
                      flex: 1
                    }}>
                      <span style={{ fontSize: 10, color: STATUS_ORDER.indexOf(st) <= STATUS_ORDER.indexOf(asn.status) ? 'white' : '#94a3b8' }}>
                        {st}
                      </span>
                    </div>
                  ))}
                </div>

                <div style={s.cardBody}>
                  <div style={{ fontSize: 36, marginRight: 12 }}>{INC_ICON[inc?.type] || '⚠️'}</div>
                  <div style={{ flex: 1 }}>
                    <div style={s.incTitle}>{inc?.title || 'Emergency'}</div>
                    <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginTop: 4 }}>
                      <span style={{ ...s.pill, background: SEV_COLOR[inc?.severity] + '22', color: SEV_COLOR[inc?.severity] }}>{inc?.severity}</span>
                      <span style={{ ...s.pill, background: STATUS_COLOR[asn.status] + '22', color: STATUS_COLOR[asn.status] }}>{asn.status}</span>
                      {inc?.serviceType !== 'standard' && (
                        <span style={{ ...s.pill, background: '#fef9c3', color: '#ca8a04' }}>
                          {inc?.serviceType === 'vip' ? '⭐ VIP' : '🔒 Private'}
                        </span>
                      )}
                      {citizenLive && (
                        <span style={{ ...s.pill, background: '#f0fdf4', color: '#16a34a', border: '1px solid #bbf7d0' }}>
                          📡 Live location
                        </span>
                      )}
                    </div>
                    <div style={s.dispatcher}>Assigned by: {asn.dispatcher?.name || 'Dispatcher'}</div>
                  </div>
                </div>

                {/* Mini Map */}
                {inc?.location?.lat && (
                  <div style={{ padding: '0 16px 12px' }}>
                    <IncidentMiniMap incident={mapIncident} responderLocation={myLocation} />
                  </div>
                )}

                {/* Timing */}
                <div style={s.timingRow}>
                  {asn.responseTime && <div style={s.timingItem}>⏱ Response: <b>{fmt(asn.responseTime)}</b></div>}
                  {asn.travelTime   && <div style={s.timingItem}>🚗 Travel: <b>{fmt(asn.travelTime)}</b></div>}
                  {asn.serviceTime  && <div style={s.timingItem}>🔧 Service: <b>{fmt(asn.serviceTime)}</b></div>}
                </div>

                <div style={s.actions}>
                  {next && asn.status !== 'completed' && (
                    <button
                      onClick={() => updateStatus(asn._id, next)}
                      disabled={updating === asn._id}
                      style={{ ...s.statusBtn, background: STATUS_COLOR[next] }}
                    >
                      {updating === asn._id ? 'Updating…' : NEXT_LABEL[asn.status]}
                    </button>
                  )}
                  <button
                    onClick={() => setActiveChat(activeChat === inc?._id ? null : inc?._id)}
                    style={{ ...s.chatBtn, background: activeChat === inc?._id ? '#667eea' : '#f1f5f9', color: activeChat === inc?._id ? 'white' : '#334155' }}
                  >
                    💬 Chat
                  </button>
                  {inc?.audioFile && (
                    <audio controls src={`/uploads/${inc.audioFile}`} style={{ height: 32 }} />
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {activeChat && (
        <ChatWidget
          incidentId={activeChat}
          incidentTitle={assignments.find(a => a.incident?._id === activeChat)?.incident?.title}
        />
      )}
    </div>
  );
};

const s = {
  page:        { minHeight:'100vh', background:'#f8fafc', fontFamily:'Arial, sans-serif' },
  inner:       { maxWidth:800, margin:'0 auto', padding:20 },
  topBar:      { display:'flex', alignItems:'center', gap:12, marginBottom:16 },
  back:        { background:'white', border:'1px solid #e2e8f0', borderRadius:8, padding:'8px 14px', cursor:'pointer', fontSize:14 },
  title:       { flex:1, fontSize:22, fontWeight:'bold', color:'#1e293b', margin:0 },
  refresh:     { background:'white', border:'1px solid #e2e8f0', borderRadius:8, padding:'8px 14px', cursor:'pointer', fontSize:14 },
  myLocBar:    { display:'flex', alignItems:'center', gap:8, background:'#f0fdf4', border:'1px solid #bbf7d0', borderRadius:8, padding:'8px 14px', marginBottom:16, fontSize:12, color:'#166534' },
  gpsGreen:    { width:8, height:8, borderRadius:'50%', background:'#22c55e', display:'inline-block', flexShrink:0 },
  empty:       { textAlign:'center', padding:'60px 20px', color:'#64748b', fontSize:16 },
  list:        { display:'grid', gap:16 },
  card:        { background:'white', borderRadius:12, overflow:'hidden', boxShadow:'0 2px 8px rgba(0,0,0,.07)', border:'1px solid #e2e8f0' },
  progressBar: { display:'flex', gap:2, padding:0 },
  progressStep:{ padding:'4px 8px', display:'flex', alignItems:'center', justifyContent:'center', transition:'background .3s' },
  cardBody:    { display:'flex', alignItems:'flex-start', padding:'16px 16px 8px' },
  incTitle:    { fontWeight:'bold', fontSize:16, color:'#1e293b' },
  pill:        { padding:'2px 10px', borderRadius:20, fontSize:12, fontWeight:600 },
  dispatcher:  { fontSize:12, color:'#94a3b8', marginTop:4 },
  timingRow:   { display:'flex', gap:16, padding:'8px 16px', background:'#f8fafc', borderTop:'1px solid #f1f5f9' },
  timingItem:  { fontSize:12, color:'#64748b' },
  actions:     { display:'flex', gap:10, padding:'12px 16px', alignItems:'center', flexWrap:'wrap', borderTop:'1px solid #f1f5f9' },
  statusBtn:   { color:'white', border:'none', borderRadius:8, padding:'9px 18px', cursor:'pointer', fontWeight:'bold', fontSize:14 },
  chatBtn:     { border:'none', borderRadius:8, padding:'9px 18px', cursor:'pointer', fontWeight:600, fontSize:14 },
};

export default MyAssignmentsPage;
