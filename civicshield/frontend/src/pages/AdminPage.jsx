import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../lib/api';
import ChatWidget from '../components/ChatWidget';

const ROLE_COLOR  = { citizen:'#667eea', responder:'#22c55e', dispatcher:'#f97316', admin:'#ef4444' };
const SEV_COLOR   = { critical:'#ef4444', high:'#f97316', medium:'#eab308', low:'#22c55e' };
const INC_ICON    = { medical:'🏥', fire:'🔥', security:'🚨', accident:'🚗', other:'⚠️' };

const AdminPage = () => {
  const navigate = useNavigate();
  const [tab, setTab]             = useState('incidents');
  const [incidents, setIncidents] = useState([]);
  const [users, setUsers]         = useState([]);
  const [stats, setStats]         = useState(null);
  const [loading, setLoading]     = useState(true);
  const [activeChat, setActiveChat] = useState(null);

  useEffect(() => {
    const loadAll = async () => {
      try {
        const [inc, st] = await Promise.all([
          api.get('/incidents?limit=50'),
          api.get('/dashboard/stats'),
        ]);
        setIncidents(inc.data.incidents || []);
        setStats(st.data);
      } catch {}

      try {
        const u = await api.get('/admin/users');
        setUsers(u.data?.users || u.data || []);
      } catch {}

      setLoading(false);
    };
    loadAll();
  }, []);

  const flagFalseAlarm = async incId => {
    if (!window.confirm('Confirm this is a false alarm? A penalty will be applied to the reporter.')) return;
    try {
      const r = await api.post(`/incidents/${incId}/false-alarm`);
      alert(r.data.message);
      setIncidents(prev => prev.map(i => i._id === incId ? { ...i, falseAlarmReported: true, status: 'cancelled' } : i));
    } catch (e) {
      alert(e.response?.data?.error || 'Failed');
    }
  };

  const Stat = ({ label, value, color }) => (
    <div style={{ background:'white', borderRadius:12, padding:'16px 20px', textAlign:'center', boxShadow:'0 2px 8px rgba(0,0,0,.06)' }}>
      <div style={{ fontSize:32, fontWeight:'bold', color: color || '#667eea' }}>{value ?? '—'}</div>
      <div style={{ fontSize:13, color:'#64748b', marginTop:4 }}>{label}</div>
    </div>
  );

  return (
    <div style={s.page}>
      <div style={s.inner}>
        <div style={s.topBar}>
          <button onClick={() => navigate('/dashboard')} style={s.back}>← Dashboard</button>
          <h1 style={s.title}>⚙️ Admin / Dispatcher Panel</h1>
        </div>

        {/* Stats row */}
        {stats && (
          <div style={s.statsGrid}>
            <Stat label="Active Incidents"     value={stats.incidents?.active}    color="#ef4444" />
            <Stat label="Today's Incidents"    value={stats.incidents?.today}     color="#f97316" />
            <Stat label="Available Responders" value={stats.responders?.available} color="#22c55e" />
            <Stat label="Avg Response"         value={stats.performance?.averageResponseTime ? Math.round(stats.performance.averageResponseTime) + 's' : '—'} color="#667eea" />
          </div>
        )}

        {/* Tabs */}
        <div style={s.tabs}>
          {['incidents','users'].map(t => (
            <button key={t} onClick={() => setTab(t)} style={{ ...s.tab, borderBottom: tab === t ? '3px solid #667eea' : '3px solid transparent', color: tab === t ? '#667eea' : '#64748b', fontWeight: tab === t ? 'bold' : 'normal' }}>
              {t === 'incidents' ? '🚨 Incidents' : '👥 Users'}
            </button>
          ))}
        </div>

        {loading && <div style={s.empty}>Loading…</div>}

        {/* Incidents tab */}
        {!loading && tab === 'incidents' && (
          <div style={s.list}>
            {incidents.length === 0 && <div style={s.empty}>No incidents found.</div>}
            {incidents.map(inc => (
              <div key={inc._id} style={s.card}>
                <div style={s.cardTop}>
                  <span style={{ fontSize: 28 }}>{INC_ICON[inc.type] || '⚠️'}</span>
                  <div style={{ flex: 1 }}>
                    <div style={s.incTitle}>{inc.title}</div>
                    <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap', marginTop: 4 }}>
                      <span style={{ ...s.pill, background: SEV_COLOR[inc.severity]+'22', color: SEV_COLOR[inc.severity] }}>{inc.severity}</span>
                      <span style={{ ...s.pill, background:'#f1f5f9', color:'#64748b' }}>{inc.status}</span>
                      <span style={{ ...s.pill, background:'#f1f5f9', color:'#64748b' }}>{inc.type}</span>
                      {inc.serviceType !== 'standard' && <span style={{ ...s.pill, background:'#fef9c3', color:'#ca8a04' }}>{inc.serviceType === 'vip' ? '⭐ VIP' : '🔒 Private'}</span>}
                    </div>
                    <div style={{ fontSize:12, color:'#94a3b8', marginTop:4 }}>
                      Reporter: {inc.reporter?.name} · {new Date(inc.createdAt).toLocaleString()}
                    </div>
                    {inc.falseAlarmReported && <div style={s.falseBadge}>⚠️ False alarm — {inc.penaltyAmount?.toLocaleString()} RWF penalty issued</div>}
                  </div>
                </div>
                <div style={s.cardActions}>
                  <button
                    onClick={() => setActiveChat(activeChat === inc._id ? null : inc._id)}
                    style={{ ...s.actionBtn, background: activeChat === inc._id ? '#667eea' : '#f1f5f9', color: activeChat === inc._id ? 'white' : '#334155' }}
                  >
                    💬 Chat
                  </button>
                  {!inc.falseAlarmReported && inc.status !== 'cancelled' && (
                    <button onClick={() => flagFalseAlarm(inc._id)} style={{ ...s.actionBtn, background:'#fef2f2', color:'#dc2626' }}>
                      🚫 False Alarm
                    </button>
                  )}
                  {inc.audioFile && (
                    <audio controls src={`/uploads/${inc.audioFile}`} style={{ height: 30 }} />
                  )}
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Users tab */}
        {!loading && tab === 'users' && (
          <div style={s.list}>
            {users.length === 0 && <div style={s.empty}>No users found.</div>}
            {users.map(u => (
              <div key={u._id} style={{ ...s.card, display:'flex', alignItems:'center', gap:14 }}>
                <div style={{ width:44, height:44, borderRadius:'50%', background: ROLE_COLOR[u.role]+'22', display:'flex', alignItems:'center', justifyContent:'center', fontSize:20, flexShrink:0 }}>
                  {u.role === 'citizen' ? '👤' : u.role === 'responder' ? '🚒' : u.role === 'dispatcher' ? '📡' : '⚙️'}
                </div>
                <div style={{ flex:1 }}>
                  <div style={{ fontWeight:'bold', fontSize:15, color:'#1e293b' }}>{u.name}</div>
                  <div style={{ fontSize:13, color:'#64748b' }}>{u.email} · {u.phone}</div>
                </div>
                <div style={{ textAlign:'right' }}>
                  <span style={{ ...s.pill, background: ROLE_COLOR[u.role]+'22', color: ROLE_COLOR[u.role] }}>{u.role}</span>
                  {u.penaltyBalance > 0 && (
                    <div style={{ fontSize:12, color:'#dc2626', marginTop:4, fontWeight:600 }}>
                      💸 Owes {u.penaltyBalance.toLocaleString()} RWF
                    </div>
                  )}
                  {u.falseAlarmCount > 0 && (
                    <div style={{ fontSize:11, color:'#94a3b8' }}>{u.falseAlarmCount} false alarm(s)</div>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

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
  page:       { minHeight:'100vh', background:'#f8fafc', fontFamily:'Arial, sans-serif' },
  inner:      { maxWidth:900, margin:'0 auto', padding:20 },
  topBar:     { display:'flex', alignItems:'center', gap:12, marginBottom:20 },
  back:       { background:'white', border:'1px solid #e2e8f0', borderRadius:8, padding:'8px 14px', cursor:'pointer', fontSize:14 },
  title:      { fontSize:22, fontWeight:'bold', color:'#1e293b', margin:0 },
  statsGrid:  { display:'grid', gridTemplateColumns:'repeat(auto-fit,minmax(160px,1fr))', gap:16, marginBottom:24 },
  tabs:       { display:'flex', gap:0, borderBottom:'1px solid #e2e8f0', marginBottom:20 },
  tab:        { padding:'10px 20px', background:'none', border:'none', cursor:'pointer', fontSize:14, transition:'all .2s' },
  empty:      { textAlign:'center', padding:'40px 20px', color:'#64748b', fontSize:15 },
  list:       { display:'grid', gap:14 },
  card:       { background:'white', borderRadius:12, padding:20, boxShadow:'0 2px 8px rgba(0,0,0,.06)', border:'1px solid #e2e8f0' },
  cardTop:    { display:'flex', gap:12, alignItems:'flex-start' },
  incTitle:   { fontWeight:'bold', fontSize:15, color:'#1e293b' },
  pill:       { padding:'2px 10px', borderRadius:20, fontSize:12, fontWeight:600 },
  falseBadge: { background:'#fef2f2', color:'#dc2626', padding:'4px 10px', borderRadius:6, fontSize:12, fontWeight:600, marginTop:6, display:'inline-block' },
  cardActions:{ display:'flex', gap:10, marginTop:12, alignItems:'center', flexWrap:'wrap' },
  actionBtn:  { padding:'7px 14px', borderRadius:8, border:'none', cursor:'pointer', fontSize:13, fontWeight:600 },
};

export default AdminPage;
