import React, { useState } from 'react';
import Avatar from '../components/Avatar';

export default function Dashboard({ user, users, stories, sessions, applications, setPage, setUsers }) {
  const [toggling, setToggling] = useState(false);

  const enrolledStudents = users.filter(u => u.role === 'student' && u.enrolled).length;
  const pendingApps = applications.filter(a => a.status === 'pending').length;
  const upcomingSessions = sessions.filter(s => s.status === 'upcoming').length;
  const myStudents = user.role === 'counselor' ? sessions.filter(s => s.counselorId === user.id).map(s => s.studentId) : [];
  const onlineCounselors = users.filter(u => (u.role === 'counselor' || u.role === 'peer') && u.online);

  const toggleAvailability = () => {
    setToggling(true);
    setTimeout(() => {
      setUsers(prev => prev.map(u => u.id === user.id ? { ...u, online: !u.online } : u));
      setToggling(false);
    }, 400);
  };

  const currentUser = users.find(u => u.id === user.id) || user;

  if (user.role === 'admin') return (
    <div className="animate-fade">
      <div className="page-header">
        <div className="page-title">Admin Dashboard</div>
        <div className="page-subtitle">MindBridge platform overview</div>
      </div>
      <div className="grid-3">
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#eef0ff', color: '#5b6cf9' }}>👥</div>
          <div className="stat-value">{enrolledStudents}</div>
          <div className="stat-label">Enrolled Students</div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#fff1f3', color: '#f43f5e' }}>📋</div>
          <div className="stat-value">{pendingApps}</div>
          <div className="stat-label">Pending Applications</div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#d1fae5', color: '#38c88c' }}>🎥</div>
          <div className="stat-value">{upcomingSessions}</div>
          <div className="stat-label">Upcoming Sessions</div>
        </div>
      </div>
      <div className="card" style={{ marginTop: 24 }}>
        <div style={{ fontWeight: 700, fontSize: 15, marginBottom: 14 }}>Counselor Availability</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {users.filter(u => u.role === 'counselor' || u.role === 'peer').map(c => (
            <div key={c.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '10px 14px', borderRadius: 10, background: '#f9fafb' }}>
              <div style={{ position: 'relative' }}>
                <Avatar name={c.name} color={c.color} size={36} />
                <div style={{ position: 'absolute', bottom: 0, right: 0, width: 11, height: 11, borderRadius: '50%', background: c.online ? '#38c88c' : '#d1d5db', border: '2px solid #fff' }} />
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 600, fontSize: 13 }}>{c.name}</div>
                <div style={{ fontSize: 12, color: c.online ? '#16a34a' : '#9ca3af' }}>{c.online ? 'Available for sessions' : 'Offline'}</div>
              </div>
              <span style={{ fontSize: 11, fontWeight: 600, padding: '3px 10px', borderRadius: 12, background: c.online ? '#d1fae5' : '#f3f4f6', color: c.online ? '#16a34a' : '#6b7280' }}>
                {c.role === 'peer' ? 'Peer' : 'Counselor'}
              </span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  if (user.role === 'student' || user.role === 'peer') return (
    <div className="animate-fade">
      <div className="page-header">
        <div className="page-title">Welcome, {user.name.split(' ')[0]}!</div>
        <div className="page-subtitle">
          {user.enrolled ? 'You are enrolled and have full access.' : 'Your application is being reviewed. You can still message a counselor.'}
        </div>
      </div>
      <div className="grid-3">
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#f0fdf4', color: '#38c88c' }}>📖</div>
          <div className="stat-value">{stories.length}</div>
          <div className="stat-label">Stories Available</div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#eff6ff', color: '#5b6cf9' }}>🎥</div>
          <div className="stat-value">{sessions.filter(s => s.studentId === user.id).length}</div>
          <div className="stat-label">My Sessions</div>
        </div>
        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setPage('messages')}>
          <div className="stat-icon" style={{ background: '#f3effe', color: '#8b5cf6' }}>💬</div>
          <div className="stat-value">{onlineCounselors.length}</div>
          <div className="stat-label">Counselors Online</div>
        </div>
      </div>

      {/* Live counselors */}
      <div className="card" style={{ marginTop: 24 }}>
        <div style={{ fontWeight: 700, fontSize: 15, marginBottom: 14, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <span>Support Team — Live Status</span>
          <button className="btn btn-primary btn-sm" onClick={() => setPage('sessions')}>
            <i className="fas fa-video" /> Connect Now
          </button>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {users.filter(u => u.role === 'counselor' || u.role === 'peer').map(c => (
            <div key={c.id} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 14px', borderRadius: 10, background: c.online ? '#f0fdf4' : '#f9fafb', border: `1px solid ${c.online ? '#bbf7d0' : '#e5e7eb'}` }}>
              <div style={{ position: 'relative' }}>
                <Avatar name={c.name} color={c.color} size={40} />
                <div style={{ position: 'absolute', bottom: 1, right: 1, width: 12, height: 12, borderRadius: '50%', background: c.online ? '#38c88c' : '#d1d5db', border: '2px solid #fff' }} />
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 600, fontSize: 14 }}>{c.name}</div>
                <div style={{ fontSize: 12, color: '#6b7280' }}>{c.role === 'peer' ? 'Peer Supporter' : 'Counselor'}</div>
              </div>
              <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                <span style={{ fontSize: 12, fontWeight: 600, color: c.online ? '#16a34a' : '#9ca3af' }}>
                  {c.online ? '● Available' : '○ Offline'}
                </span>
                {c.online && (
                  <button className="btn btn-success btn-sm" onClick={() => setPage('sessions')}>
                    <i className="fas fa-video" /> Join
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  if (user.role === 'counselor') return (
    <div className="animate-fade">
      <div className="page-header">
        <div className="page-title">Counselor Dashboard</div>
        <div className="page-subtitle">Your schedule and student updates</div>
      </div>

      {/* Availability toggle */}
      <div className="card" style={{ marginBottom: 24, background: currentUser.online ? 'linear-gradient(135deg,#f0fdf4,#dcfce7)' : 'linear-gradient(135deg,#f9fafb,#f3f4f6)', border: `2px solid ${currentUser.online ? '#86efac' : '#e5e7eb'}` }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 16 }}>
          <div style={{ width: 52, height: 52, borderRadius: '50%', background: currentUser.online ? '#d1fae5' : '#f3f4f6', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 26 }}>
            {currentUser.online ? '🟢' : '⚫'}
          </div>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 700, fontSize: 16, color: currentUser.online ? '#15803d' : '#374151' }}>
              {currentUser.online ? 'You are Available' : 'You are Offline'}
            </div>
            <div style={{ fontSize: 13, color: '#6b7280', marginTop: 2 }}>
              {currentUser.online
                ? 'Students can see you online and request instant sessions.'
                : 'Students cannot reach you for instant calls. Booked sessions still work.'}
            </div>
          </div>
          <button
            onClick={toggleAvailability}
            disabled={toggling}
            className={`btn ${currentUser.online ? 'btn-outline' : 'btn-success'}`}
            style={{ minWidth: 140, justifyContent: 'center' }}>
            {toggling
              ? <><i className="fas fa-spinner fa-spin" /> Updating…</>
              : currentUser.online
              ? <><i className="fas fa-toggle-on" /> Go Offline</>
              : <><i className="fas fa-toggle-off" /> Go Available</>
            }
          </button>
        </div>
      </div>

      <div className="grid-3">
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#eef0ff', color: '#5b6cf9' }}>👥</div>
          <div className="stat-value">{new Set(myStudents).size}</div>
          <div className="stat-label">Students You Support</div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#fffbeb', color: '#f59e0b' }}>📅</div>
          <div className="stat-value">{sessions.filter(s => s.counselorId === user.id && s.status === 'upcoming').length}</div>
          <div className="stat-label">Upcoming Sessions</div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#f0fdf4', color: '#38c88c' }}>✅</div>
          <div className="stat-value">{sessions.filter(s => s.counselorId === user.id && s.status === 'completed').length}</div>
          <div className="stat-label">Completed Sessions</div>
        </div>
      </div>

      {/* Upcoming sessions quick view */}
      {sessions.filter(s => s.counselorId === user.id && s.status === 'upcoming').length > 0 && (
        <div className="card" style={{ marginTop: 24 }}>
          <div style={{ fontWeight: 700, fontSize: 15, marginBottom: 12 }}>Upcoming Sessions</div>
          {sessions.filter(s => s.counselorId === user.id && s.status === 'upcoming').map(s => (
            <div key={s.id} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '10px 0', borderBottom: '1px solid #f3f4f6' }}>
              <div>
                <div style={{ fontWeight: 600, fontSize: 14 }}>{s.studentName}</div>
                <div style={{ fontSize: 12, color: '#6b7280' }}>{s.date} at {s.time}</div>
              </div>
              <button className="btn btn-success btn-sm" onClick={() => setPage('sessions')}>
                <i className="fas fa-video" /> Join
              </button>
            </div>
          ))}
        </div>
      )}
    </div>
  );

  return null;
}
