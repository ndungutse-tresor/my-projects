import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import api from '../lib/api';

const ROLE_THEME = {
  citizen:    { bg:'#667eea', icon:'👤', label:'Citizen' },
  responder:  { bg:'#22c55e', icon:'🚒', label:'Responder' },
  dispatcher: { bg:'#f97316', icon:'📡', label:'Dispatcher' },
  admin:      { bg:'#ef4444', icon:'⚙️',  label:'Admin' },
};

const SEV_COLOR = { critical:'#ef4444', high:'#f97316', medium:'#eab308', low:'#22c55e' };
const INC_ICON  = { medical:'🏥', fire:'🔥', security:'🚨', accident:'🚗', other:'⚠️' };

const DashboardPage = () => {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [incidents, setIncidents] = useState([]);
  const [stats, setStats]         = useState(null);
  const [loading, setLoading]     = useState(true);

  useEffect(() => {
    const load = async () => {
      try {
        const incRes = await api.get('/incidents?limit=5');
        setIncidents(incRes.data.incidents || []);
        if (user?.role === 'dispatcher' || user?.role === 'admin') {
          const sRes = await api.get('/dashboard/stats');
          setStats(sRes.data);
        }
      } catch {}
      setLoading(false);
    };
    load();
  }, [user]);

  const role   = user?.role || 'citizen';
  const theme  = ROLE_THEME[role] || ROLE_THEME.citizen;

  const NavCard = ({ icon, label, to, color = '#667eea', sub }) => (
    <button onClick={() => navigate(to)} style={{ ...s.navCard, borderTop: `4px solid ${color}` }}>
      <div style={{ fontSize: 32, marginBottom: 6 }}>{icon}</div>
      <div style={{ fontWeight: 'bold', fontSize: 15, color: '#1e293b' }}>{label}</div>
      {sub && <div style={{ fontSize: 12, color: '#94a3b8', marginTop: 2 }}>{sub}</div>}
    </button>
  );

  const StatCard = ({ label, value, color }) => (
    <div style={{ background: 'white', borderRadius: 12, padding: '18px 20px', textAlign: 'center', boxShadow: '0 2px 8px rgba(0,0,0,.06)' }}>
      <div style={{ fontSize: 36, fontWeight: 'bold', color: color || '#667eea' }}>{value ?? '—'}</div>
      <div style={{ fontSize: 13, color: '#64748b', marginTop: 4 }}>{label}</div>
    </div>
  );

  if (loading) return (
    <div style={{ display:'flex', alignItems:'center', justifyContent:'center', height:'100vh', fontSize:18, color:'#64748b' }}>Loading…</div>
  );

  return (
    <div style={s.page}>
      {/* Header */}
      <header style={{ ...s.header, background: theme.bg }}>
        <div style={s.headerContent}>
          <div>
            <h1 style={s.appName}>🚨 CivicShield</h1>
            <div style={s.roleTag}>{theme.icon} {theme.label}</div>
          </div>
          <div style={s.userMenu}>
            <span style={s.userName}>{user?.name}</span>
            <button onClick={() => { logout(); navigate('/login'); }} style={s.logoutBtn}>Logout</button>
          </div>
        </div>
      </header>

      <div style={s.content}>

        {/* ─── CITIZEN ──────────────────────────────────────── */}
        {role === 'citizen' && (
          <>
            <div style={s.hero}>
              <div style={{ fontSize: 52 }}>👋</div>
              <h2 style={{ margin: '8px 0 4px' }}>Welcome, {user?.name}!</h2>
              <p style={{ color: '#64748b', margin: 0 }}>Your safety is our priority. Report any emergency instantly.</p>
            </div>

            <div style={s.navGrid}>
              <NavCard icon="🆘" label="Emergency SOS"   to="/sos"            color="#ef4444" sub="Report emergency now" />
              <NavCard icon="📋" label="My Reports"       to="/my-incidents"   color="#667eea" sub="View your history" />
              <NavCard icon="🗺️" label="Nearby Map"       to="/responder-map"  color="#22c55e" sub="See nearby incidents" />
            </div>

            <div style={s.section}>
              <h3 style={s.sectionTitle}>Recent Incidents Near You</h3>
              {incidents.length === 0
                ? <div style={s.noData}>No active incidents nearby.</div>
                : incidents.slice(0, 5).map(inc => <IncidentRow key={inc._id} inc={inc} />)
              }
            </div>

            <div style={s.contactBox}>
              <h3 style={{ margin: '0 0 12px' }}>📞 Emergency Contacts</h3>
              <div style={s.contactGrid}>
                <ContactCard icon="🚑" label="Medical" number="912" color="#ef4444" />
                <ContactCard icon="🔥" label="Fire"    number="110" color="#f97316" />
                <ContactCard icon="🚔" label="Police"  number="113" color="#3b82f6" />
                <ContactCard icon="🚒" label="Rescue"  number="115" color="#22c55e" />
              </div>
            </div>
          </>
        )}

        {/* ─── RESPONDER ────────────────────────────────────── */}
        {role === 'responder' && (
          <>
            <div style={s.hero}>
              <div style={{ fontSize: 52 }}>🚒</div>
              <h2 style={{ margin: '8px 0 4px' }}>Ready for duty, {user?.name}!</h2>
              <p style={{ color: '#64748b', margin: 0 }}>Check your assignments and stay on the live map.</p>
            </div>

            <div style={s.navGrid}>
              <NavCard icon="📍" label="My Assignments" to="/my-assignments" color="#22c55e" sub="View & update status" />
              <NavCard icon="🗺️" label="Live Map"       to="/responder-map"  color="#3b82f6" sub="Real-time incidents" />
            </div>

            <div style={s.section}>
              <h3 style={s.sectionTitle}>Active Incidents (latest)</h3>
              {incidents.length === 0
                ? <div style={s.noData}>No active incidents right now.</div>
                : incidents.filter(i => i.status === 'active').slice(0, 5).map(inc => <IncidentRow key={inc._id} inc={inc} />)
              }
            </div>

            <div style={s.contactBox}>
              <h3 style={{ margin: '0 0 12px' }}>📡 Dispatcher Line</h3>
              <p style={{ color: '#64748b', fontSize: 14 }}>
                Use the <strong>💬 Chat</strong> button on your assignments to contact your dispatcher in real time.
                The dispatcher can see your location on the live map.
              </p>
            </div>
          </>
        )}

        {/* ─── DISPATCHER / ADMIN ───────────────────────────── */}
        {(role === 'dispatcher' || role === 'admin') && (
          <>
            {stats && (
              <div style={s.statsGrid}>
                <StatCard label="Active Incidents"     value={stats.incidents?.active}    color="#ef4444" />
                <StatCard label="Today's Incidents"    value={stats.incidents?.today}     color="#f97316" />
                <StatCard label="Available Responders" value={stats.responders?.available} color="#22c55e" />
                <StatCard label="Avg Response"
                  value={stats.performance?.averageResponseTime ? Math.round(stats.performance.averageResponseTime) + 's' : '—'}
                  color="#667eea"
                />
              </div>
            )}

            <div style={s.navGrid}>
              <NavCard icon="🗺️" label="Live Incident Map" to="/dispatcher-map" color="#f97316" sub="Real-time overview" />
              <NavCard icon="🚨" label="All Incidents"      to="/admin"          color="#ef4444" sub="Manage & assign" />
              <NavCard icon="👥" label="Users & Penalties"  to="/admin"          color="#667eea" sub="Manage accounts" />
            </div>

            <div style={s.section}>
              <h3 style={s.sectionTitle}>Live Feed (latest 5)</h3>
              {incidents.length === 0
                ? <div style={s.noData}>No incidents yet.</div>
                : incidents.slice(0, 5).map(inc => <IncidentRow key={inc._id} inc={inc} />)
              }
            </div>

            <div style={s.contactBox}>
              <h3 style={{ margin: '0 0 12px' }}>📡 Cross-Role Communication</h3>
              <p style={{ color:'#64748b', fontSize:14 }}>
                Open the <strong>Admin Panel → Incidents</strong> and click <strong>💬 Chat</strong> on any incident to
                message the citizen reporter or assigned responders in real time. All parties share the same incident chat room.
              </p>
            </div>
          </>
        )}

      </div>
    </div>
  );
};

/* ── Small reusable components ─────────────────────────── */

const IncidentRow = ({ inc }) => (
  <div style={{ background:'white', borderRadius:10, padding:'12px 16px', marginBottom:10, border:'1px solid #e2e8f0', display:'flex', gap:12, alignItems:'center' }}>
    <span style={{ fontSize:24 }}>{INC_ICON[inc.type] || '⚠️'}</span>
    <div style={{ flex:1 }}>
      <div style={{ fontWeight:'bold', fontSize:14, color:'#1e293b' }}>{inc.title}</div>
      <div style={{ fontSize:12, color:'#94a3b8' }}>{inc.reporter?.name} · {new Date(inc.createdAt).toLocaleTimeString()}</div>
    </div>
    <span style={{ padding:'2px 10px', borderRadius:20, fontSize:12, fontWeight:600, background: SEV_COLOR[inc.severity]+'22', color: SEV_COLOR[inc.severity] }}>
      {inc.severity}
    </span>
  </div>
);

const ContactCard = ({ icon, label, number, color }) => (
  <a href={`tel:${number}`} style={{ textDecoration:'none', background:'white', borderRadius:10, padding:'14px 10px', textAlign:'center', border:`2px solid ${color}22`, display:'block' }}>
    <div style={{ fontSize:28 }}>{icon}</div>
    <div style={{ fontWeight:'bold', fontSize:13, color:'#1e293b', marginTop:4 }}>{label}</div>
    <div style={{ fontSize:18, fontWeight:'bold', color, marginTop:2 }}>{number}</div>
  </a>
);

/* ── Styles ────────────────────────────────────────────── */
const s = {
  page:         { minHeight:'100vh', background:'#f8fafc', fontFamily:'Arial, sans-serif' },
  header:       { color:'white', padding:'18px 0', boxShadow:'0 2px 12px rgba(0,0,0,.15)' },
  headerContent:{ maxWidth:1000, margin:'0 auto', padding:'0 20px', display:'flex', justifyContent:'space-between', alignItems:'center' },
  appName:      { margin:0, fontSize:24, fontWeight:'bold' },
  roleTag:      { fontSize:13, opacity:.85, marginTop:2 },
  userMenu:     { display:'flex', gap:12, alignItems:'center' },
  userName:     { fontSize:14 },
  logoutBtn:    { background:'rgba(255,255,255,.2)', color:'white', border:'1px solid rgba(255,255,255,.4)', padding:'6px 14px', borderRadius:6, cursor:'pointer', fontSize:13 },
  content:      { maxWidth:1000, margin:'0 auto', padding:'28px 20px' },
  hero:         { background:'white', borderRadius:12, padding:'28px 24px', textAlign:'center', marginBottom:24, boxShadow:'0 2px 8px rgba(0,0,0,.06)' },
  navGrid:      { display:'grid', gridTemplateColumns:'repeat(auto-fit,minmax(180px,1fr))', gap:16, marginBottom:28 },
  navCard:      { background:'white', borderRadius:12, padding:'20px 16px', cursor:'pointer', border:'1px solid #e2e8f0', boxShadow:'0 2px 8px rgba(0,0,0,.06)', textAlign:'center', transition:'transform .15s,box-shadow .15s' },
  statsGrid:    { display:'grid', gridTemplateColumns:'repeat(auto-fit,minmax(180px,1fr))', gap:16, marginBottom:24 },
  section:      { background:'white', borderRadius:12, padding:'20px', marginBottom:24, boxShadow:'0 2px 8px rgba(0,0,0,.06)' },
  sectionTitle: { margin:'0 0 14px', fontSize:16, color:'#1e293b' },
  noData:       { color:'#94a3b8', textAlign:'center', padding:'20px 0', fontSize:14 },
  contactBox:   { background:'white', borderRadius:12, padding:20, boxShadow:'0 2px 8px rgba(0,0,0,.06)', marginBottom:24 },
  contactGrid:  { display:'grid', gridTemplateColumns:'repeat(4,1fr)', gap:10 },
};

export default DashboardPage;
