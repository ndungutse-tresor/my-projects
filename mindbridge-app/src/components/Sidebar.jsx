import React from 'react';
import Avatar from './Avatar';

export default function Sidebar({ user, page, setPage, onLogout }) {
  const navItems = {
    admin: [
      { id:'dashboard', icon:'fa-gauge', label:'Dashboard' },
      { id:'applications', icon:'fa-file-alt', label:'Applications' },
      { id:'users', icon:'fa-users', label:'Users' },
      { id:'schedule-session', icon:'fa-calendar-plus', label:'Schedule Session' },
      { id:'sessions-admin', icon:'fa-video', label:'All Sessions' },
      { id:'stories-admin', icon:'fa-book-open', label:'Stories' },
      { id:'wellness-admin', icon:'fa-heart', label:'Wellness Resources' },
      { id:'solid-minds', icon:'fa-clinic-medical', label:'Solid Minds Clinic' },
    ],
    counselor: [
      { id:'dashboard', icon:'fa-gauge', label:'Dashboard' },
      { id:'sessions', icon:'fa-video', label:'My Sessions' },
      { id:'messages', icon:'fa-comments', label:'Messages' },
      { id:'students', icon:'fa-users', label:'My Students' },
    ],
    student: [
      { id:'dashboard', icon:'fa-gauge', label:'Dashboard' },
      { id:'stories', icon:'fa-book-open', label:'Healed Stories' },
      { id:'sessions', icon:'fa-video', label:'Counseling' },
      { id:'messages', icon:'fa-comments', label:'Messages' },
      { id:'enroll', icon:'fa-id-card', label:'My Enrollment' },
    ],
    peer: [
      { id:'dashboard', icon:'fa-gauge', label:'Dashboard' },
      { id:'stories', icon:'fa-book-open', label:'Stories Library' },
      { id:'sessions', icon:'fa-video', label:'Support Sessions' },
      { id:'add-story', icon:'fa-plus-circle', label:'Add Story' },
      { id:'messages', icon:'fa-comments', label:'Messages' },
    ],
  };
  const items = navItems[user.role]||[];
  const roleColors = { admin:'#8b5cf6', counselor:'#5b6cf9', student:'#14b8a6', peer:'#38c88c' };
  const roleLabels = { admin:'Administrator', counselor:'Counselor', student:'Student', peer:'Peer Supporter' };

  return (
    <div className="sidebar">
      <div className="sidebar-logo">
        <div style={{display:'flex',alignItems:'center',gap:10}}>
          <div style={{width:36,height:36,background:'linear-gradient(135deg,#667eea,#764ba2)',borderRadius:10,display:'flex',alignItems:'center',justifyContent:'center',fontSize:18}}>🧠</div>
          <div><div style={{fontWeight:800,fontSize:16,color:'#1a202c'}}>MindBridge</div><div style={{fontSize:11,color:'#9ca3af'}}>Mental Health Support</div></div>
        </div>
      </div>
      <div className="sidebar-nav">
        {items.map(item=>(
          <div key={item.id} className={`nav-item ${page===item.id?'active':''}`} onClick={()=>setPage(item.id)}>
            <span className="icon"><i className={`fas ${item.icon}`} /></span>
            <span>{item.label}</span>
          </div>
        ))}
      </div>
      <div style={{padding:'16px 20px',borderTop:'1px solid #f3f4f6'}}>
        <div style={{display:'flex',alignItems:'center',gap:10,marginBottom:12}}>
          <Avatar name={user.name} color={user.color} size={36} fontSize={13} />
          <div style={{flex:1,minWidth:0}}>
            <div style={{fontSize:13,fontWeight:600,color:'#1f2937',whiteSpace:'nowrap',overflow:'hidden',textOverflow:'ellipsis'}}>{user.name.split(' ')[0]}</div>
            <div style={{fontSize:11,padding:'1px 6px',borderRadius:10,background:roleColors[user.role]+'22',color:roleColors[user.role],fontWeight:600,display:'inline-block'}}>{roleLabels[user.role]}</div>
          </div>
        </div>
        <button className="btn btn-outline btn-sm" style={{width:'100%',justifyContent:'center'}} onClick={onLogout}><i className="fas fa-sign-out-alt"/>Sign Out</button>
      </div>
    </div>
  );
}
