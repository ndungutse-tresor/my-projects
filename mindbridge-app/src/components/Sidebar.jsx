import React, { useState, useEffect } from 'react';
import Avatar from './Avatar';

const roleColors  = { admin:'#8b5cf6', counselor:'#5b6cf9', student:'#14b8a6', peer:'#38c88c' };
const roleLabels  = { admin:'Administrator', counselor:'Counselor', student:'Student', peer:'Peer Supporter' };

const NAV = {
  admin: [
    { id:'dashboard',       icon:'fa-gauge',          label:'Dashboard' },
    { id:'applications',    icon:'fa-file-alt',       label:'Applications' },
    { id:'users',           icon:'fa-users',          label:'Users' },
    { id:'schedule-session',icon:'fa-calendar-plus',  label:'Schedule Session' },
    { id:'sessions-admin',  icon:'fa-video',          label:'All Sessions' },
    { id:'stories-admin',   icon:'fa-book-open',      label:'Stories' },
    { id:'wellness-admin',  icon:'fa-heart',          label:'Wellness Resources' },
    { id:'solid-minds',     icon:'fa-clinic-medical', label:'Solid Minds Clinic' },
  ],
  counselor: [
    { id:'dashboard', icon:'fa-gauge',    label:'Dashboard' },
    { id:'sessions',  icon:'fa-video',    label:'My Sessions' },
    { id:'messages',  icon:'fa-comments', label:'Messages' },
  ],
  student: [
    { id:'dashboard', icon:'fa-gauge',     label:'Dashboard' },
    { id:'stories',   icon:'fa-book-open', label:'Healed Stories' },
    { id:'sessions',  icon:'fa-video',     label:'Counseling' },
    { id:'messages',  icon:'fa-comments',  label:'Messages' },
    { id:'enroll',    icon:'fa-id-card',   label:'My Enrollment' },
  ],
  peer: [
    { id:'dashboard',  icon:'fa-gauge',       label:'Dashboard' },
    { id:'stories',    icon:'fa-book-open',   label:'Stories Library' },
    { id:'sessions',   icon:'fa-video',       label:'Support Sessions' },
    { id:'add-story',  icon:'fa-plus-circle', label:'Add Story' },
    { id:'messages',   icon:'fa-comments',    label:'Messages' },
  ],
};

export default function Sidebar({ user, page, setPage, onLogout }) {
  const [open, setOpen] = useState(false);
  const items = NAV[user.role] || [];

  // Close drawer when route changes
  useEffect(() => { setOpen(false); }, [page]);

  // Lock body scroll when drawer is open
  useEffect(() => {
    document.body.style.overflow = open ? 'hidden' : '';
    return () => { document.body.style.overflow = ''; };
  }, [open]);

  const navigate = (id) => { setPage(id); setOpen(false); };

  const SidebarContent = () => (
    <>
      {/* Logo */}
      <div className="sidebar-logo">
        <div style={{ display:'flex', alignItems:'center', gap:10 }}>
          <div style={{ width:36, height:36, background:'linear-gradient(135deg,#667eea,#764ba2)', borderRadius:10, display:'flex', alignItems:'center', justifyContent:'center', fontSize:18 }}>🧠</div>
          <div>
            <div style={{ fontWeight:800, fontSize:16, color:'#1a202c' }}>MindBridge</div>
            <div style={{ fontSize:11, color:'#9ca3af' }}>Mental Health Support</div>
          </div>
        </div>
      </div>

      {/* Nav items */}
      <div className="sidebar-nav">
        {items.map(item => (
          <div key={item.id}
            className={`nav-item ${page === item.id ? 'active' : ''}`}
            onClick={() => navigate(item.id)}>
            <span className="icon"><i className={`fas ${item.icon}`} /></span>
            <span>{item.label}</span>
          </div>
        ))}
      </div>

      {/* User footer */}
      <div style={{ padding:'16px 20px', borderTop:'1px solid #f3f4f6', flexShrink:0 }}>
        <div style={{ display:'flex', alignItems:'center', gap:10, marginBottom:12 }}>
          <Avatar name={user.name} color={user.color} size={36} fontSize={13} />
          <div style={{ flex:1, minWidth:0 }}>
            <div style={{ fontSize:13, fontWeight:600, color:'#1f2937', whiteSpace:'nowrap', overflow:'hidden', textOverflow:'ellipsis' }}>{user.name.split(' ')[0]}</div>
            <div style={{ fontSize:11, padding:'1px 6px', borderRadius:10, background:roleColors[user.role]+'22', color:roleColors[user.role], fontWeight:600, display:'inline-block' }}>
              {roleLabels[user.role]}
            </div>
          </div>
        </div>
        <button className="btn btn-outline btn-sm" style={{ width:'100%', justifyContent:'center' }} onClick={onLogout}>
          <i className="fas fa-sign-out-alt" /> Sign Out
        </button>
      </div>
    </>
  );

  return (
    <>
      {/* ── DESKTOP sidebar ── */}
      <div className="sidebar desktop-sidebar">
        <SidebarContent />
      </div>

      {/* ── MOBILE top bar ── */}
      <div className="mobile-topbar">
        <button className="mobile-hamburger" onClick={() => setOpen(true)} aria-label="Open menu">
          <i className="fas fa-bars" />
        </button>
        <div style={{ display:'flex', alignItems:'center', gap:8 }}>
          <div style={{ width:28, height:28, background:'linear-gradient(135deg,#667eea,#764ba2)', borderRadius:8, display:'flex', alignItems:'center', justifyContent:'center', fontSize:14 }}>🧠</div>
          <span style={{ fontWeight:800, fontSize:15, color:'#1a202c' }}>MindBridge</span>
        </div>
        <Avatar name={user.name} color={user.color} size={32} fontSize={12} />
      </div>

      {/* ── MOBILE backdrop ── */}
      {open && (
        <div className="mobile-backdrop" onClick={() => setOpen(false)} />
      )}

      {/* ── MOBILE drawer ── */}
      <div className={`mobile-drawer ${open ? 'mobile-drawer-open' : ''}`}>
        <div style={{ display:'flex', flexDirection:'column', height:'100%' }}>
          {/* Close button */}
          <div style={{ display:'flex', justifyContent:'flex-end', padding:'16px 16px 0' }}>
            <button onClick={() => setOpen(false)}
              style={{ background:'#f3f4f6', border:'none', borderRadius:8, width:36, height:36, cursor:'pointer', fontSize:16, display:'flex', alignItems:'center', justifyContent:'center', color:'#6b7280' }}>
              ✕
            </button>
          </div>
          <SidebarContent />
        </div>
      </div>
    </>
  );
}
