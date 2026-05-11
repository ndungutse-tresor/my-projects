import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../lib/api';
import ChatWidget from '../components/ChatWidget';

const SEV_COLOR  = { critical:'#ef4444', high:'#f97316', medium:'#eab308', low:'#22c55e' };
const STATUS_COLOR = { active:'#ef4444', 'in-progress':'#f97316', resolved:'#22c55e', cancelled:'#94a3b8' };
const INC_ICON   = { medical:'🏥', fire:'🔥', security:'🚨', accident:'🚗', other:'⚠️' };
const TIER_BADGE = { vip:'⭐ VIP', private:'🔒 Private', standard:'Standard' };

const MyIncidentsPage = () => {
  const navigate = useNavigate();
  const [incidents, setIncidents] = useState([]);
  const [loading, setLoading]     = useState(true);
  const [activeChat, setActiveChat] = useState(null);

  useEffect(() => {
    api.get('/incidents/my-incidents')
      .then(r => setIncidents(r.data))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const formatDate = d => new Date(d).toLocaleString();

  return (
    <div style={s.page}>
      <div style={s.inner}>
        <div style={s.topBar}>
          <button onClick={() => navigate('/dashboard')} style={s.back}>← Dashboard</button>
          <h1 style={s.title}>📋 My Reports</h1>
          <button onClick={() => navigate('/sos')} style={s.newSos}>+ New SOS</button>
        </div>

        {loading && <div style={s.empty}>Loading your reports…</div>}

        {!loading && incidents.length === 0 && (
          <div style={s.empty}>
            <div style={{ fontSize: 48, marginBottom: 12 }}>📭</div>
            <p>You haven't reported any emergencies yet.</p>
            <button onClick={() => navigate('/sos')} style={s.sosBtn}>Report Emergency</button>
          </div>
        )}

        <div style={s.list}>
          {incidents.map(inc => (
            <div key={inc._id} style={s.card}>
              <div style={s.cardTop}>
                <div style={s.iconWrap}>
                  <span style={{ fontSize: 28 }}>{INC_ICON[inc.type] || '⚠️'}</span>
                </div>
                <div style={{ flex: 1 }}>
                  <div style={s.incTitle}>{inc.title}</div>
                  <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginTop: 4 }}>
                    <span style={{ ...s.pill, background: SEV_COLOR[inc.severity] + '22', color: SEV_COLOR[inc.severity] }}>
                      {inc.severity}
                    </span>
                    <span style={{ ...s.pill, background: STATUS_COLOR[inc.status] + '22', color: STATUS_COLOR[inc.status] }}>
                      {inc.status}
                    </span>
                    <span style={{ ...s.pill, background: '#f1f5f9', color: '#64748b' }}>
                      {TIER_BADGE[inc.serviceType] || 'Standard'}
                    </span>
                  </div>
                </div>
                <div style={s.dateText}>{formatDate(inc.createdAt)}</div>
              </div>

              {inc.description && <p style={s.desc}>{inc.description}</p>}

              {inc.audioFile && (
                <div style={s.mediaRow}>
                  🎙️ Voice note: <audio controls src={`/uploads/${inc.audioFile}`} style={{ height: 32, flex: 1 }} />
                </div>
              )}

              {inc.proofFiles?.length > 0 && (
                <div style={{ display: 'flex', gap: 8, marginTop: 8, flexWrap: 'wrap' }}>
                  {inc.proofFiles.map((f, i) => (
                    <img key={i} src={`/uploads/${f}`} alt="proof" style={{ width: 64, height: 64, objectFit: 'cover', borderRadius: 8, border: '1px solid #e2e8f0' }} />
                  ))}
                </div>
              )}

              {inc.falseAlarmReported && (
                <div style={s.penaltyBanner}>
                  ⚠️ Flagged as false alarm — Penalty: {inc.penaltyAmount?.toLocaleString()} RWF
                </div>
              )}

              <div style={s.cardActions}>
                <button
                  onClick={() => setActiveChat(activeChat === inc._id ? null : inc._id)}
                  style={{ ...s.actionBtn, background: activeChat === inc._id ? '#667eea' : '#f1f5f9', color: activeChat === inc._id ? 'white' : '#334155' }}
                >
                  💬 Chat with Dispatcher
                </button>
                {inc.location?.lat && (
                  <span style={s.locationText}>
                    📍 {inc.location.lat.toFixed(4)}, {inc.location.lng.toFixed(4)}
                  </span>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Floating chat widget — shows for the selected incident */}
      {activeChat && (
        <ChatWidget
          incidentId={activeChat}
          incidentTitle={incidents.find(i => i._id === activeChat)?.title}
        />
      )}
    </div>
  );
};

const s = {
  page:  { minHeight:'100vh', background:'#f8fafc', fontFamily:'Arial, sans-serif' },
  inner: { maxWidth:800, margin:'0 auto', padding:'20px' },
  topBar:{ display:'flex', alignItems:'center', gap:12, marginBottom:24 },
  back:  { background:'white', border:'1px solid #e2e8f0', borderRadius:8, padding:'8px 14px', cursor:'pointer', fontSize:14 },
  title: { flex:1, fontSize:22, fontWeight:'bold', color:'#1e293b', margin:0 },
  newSos:{ background:'#ef4444', color:'white', border:'none', borderRadius:8, padding:'8px 16px', cursor:'pointer', fontWeight:'bold', fontSize:14 },
  empty: { textAlign:'center', padding:'60px 20px', color:'#64748b', fontSize:16 },
  sosBtn:{ background:'#ef4444', color:'white', border:'none', borderRadius:8, padding:'12px 24px', cursor:'pointer', fontWeight:'bold', fontSize:15, marginTop:16 },
  list:  { display:'grid', gap:16 },
  card:  { background:'white', borderRadius:12, padding:20, boxShadow:'0 2px 8px rgba(0,0,0,.07)', border:'1px solid #e2e8f0' },
  cardTop:{ display:'flex', gap:12, alignItems:'flex-start', marginBottom:10 },
  iconWrap:{ width:48, height:48, background:'#fef3f2', borderRadius:10, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 },
  incTitle:{ fontWeight:'bold', fontSize:16, color:'#1e293b' },
  pill:  { padding:'2px 10px', borderRadius:20, fontSize:12, fontWeight:600 },
  dateText:{ fontSize:12, color:'#94a3b8', flexShrink:0, marginTop:2 },
  desc:  { color:'#475569', fontSize:14, marginTop:4, marginBottom:8 },
  mediaRow:{ display:'flex', alignItems:'center', gap:8, fontSize:13, color:'#64748b', marginTop:8 },
  penaltyBanner:{ background:'#fef2f2', color:'#dc2626', padding:'8px 12px', borderRadius:8, fontSize:13, marginTop:10, fontWeight:600 },
  cardActions:{ display:'flex', alignItems:'center', gap:12, marginTop:12, flexWrap:'wrap' },
  actionBtn:{ padding:'7px 14px', borderRadius:8, border:'none', cursor:'pointer', fontSize:13, fontWeight:600 },
  locationText:{ fontSize:12, color:'#94a3b8' },
};

export default MyIncidentsPage;
