import React, { useState } from 'react';
import VideoRoom from '../components/VideoRoom';
import Modal from '../components/Modal';
import { dataSource } from '../lib/dataSource';

export default function SessionsPage({ user, sessions, setSessions, users }) {
  const [showBook, setShowBook] = useState(false);
  const [booking, setBooking] = useState({ date: '', time: '', note: '', type: 'counseling' });
  const [activeCall, setActiveCall] = useState(null); // { roomId, counselorName, studentId, counselorId }
  const [booked, setBooked] = useState(false);
  const [waitingFor, setWaitingFor] = useState(null); // counselor being waited for

  const isPeer = user.role === 'peer';
  const isStudent = user.role === 'student';
  const isAdmin = user.role === 'admin';
  const isCounselor = user.role === 'counselor';

  const counselors = users.filter(u => u.role === 'counselor' || u.role === 'peer');
  const availableCounselors = counselors.filter(u => u.online);

  const userSessions = isStudent
    ? sessions.filter(s => s.studentId === user.id)
    : isCounselor
    ? sessions.filter(s => s.counselorId === user.id)
    : sessions;

  const upcomingSessions = userSessions.filter(s => s.status === 'upcoming');
  const pastSessions = userSessions.filter(s => s.status === 'completed');

  const bookSession = async (e) => {
    e.preventDefault();
    if (!booking.date || !booking.time) return;
    const isPeerSession = booking.type === 'peer';
    const targetCounselor = isPeerSession
      ? users.find(u => u.role === 'peer')
      : users.find(u => u.role === 'counselor');
    const s = {
      id: 'sess' + Date.now(),
      studentId: user.id,
      counselorId: targetCounselor?.id || null,
      studentName: user.name,
      date: booking.date,
      time: booking.time,
      status: 'upcoming',
      type: 'video',
      sessionType: booking.type,
      anonymous: true,
      notes: booking.note,
    };
    try { await dataSource.createSession(s); } catch(e) { console.error('Failed to save session:', e); }
    setSessions(p => [...p, s]);
    setShowBook(false);
    setBooking({ date: '', time: '', note: '', type: 'counseling' });
    setBooked(true);
    setTimeout(() => setBooked(false), 4000);
  };

  const joinSession = (session) => {
    const roomId = `mindbridge-session-${session.id}`;
    const counselor = users.find(u => u.id === session.counselorId);
    setActiveCall({
      roomId,
      counselorName: counselor?.name || 'Counselor',
      studentId: session.studentId,
      counselorId: session.counselorId,
      userName: isCounselor ? user.name : 'Anonymous Student',
    });
  };

  const joinInstant = (counselor) => {
    const roomId = `mindbridge-instant-${user.id}-${counselor.id}`;
    setActiveCall({
      roomId,
      counselorName: counselor.name,
      studentId: user.id,
      counselorId: counselor.id,
      userName: isCounselor ? user.name : 'Anonymous Student',
    });
  };

  if (activeCall) return (
    <VideoRoom
      onClose={() => setActiveCall(null)}
      roomId={activeCall.roomId}
      counselor={activeCall.counselorName}
      studentId={activeCall.studentId}
      counselorId={activeCall.counselorId}
      userName={activeCall.userName}
    />
  );

  return (
    <div className="animate-fade">
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 28 }}>
        <div>
          <div className="page-title">{isPeer ? 'Peer Support Sessions' : isCounselor ? 'My Sessions' : 'Counseling Sessions'}</div>
          <div className="page-subtitle">Real anonymous video sessions — face blurred, voice protected</div>
        </div>
        {(isStudent && user.enrolled) || isPeer ? (
          <button className="btn btn-primary" onClick={() => setShowBook(true)}>
            <i className="fas fa-plus" /> Book Session
          </button>
        ) : null}
      </div>

      {!user.enrolled && isStudent && (
        <div className="alert alert-warning" style={{ marginBottom: 20 }}>
          <i className="fas fa-lock" /> You must be enrolled to book sessions. You can still message a counselor or admin for help.
        </div>
      )}

      {/* Live availability panel */}
      {(isStudent || isPeer) && (
        <div className="card" style={{ marginBottom: 24, padding: 0, overflow: 'hidden' }}>
          <div style={{ padding: '14px 20px', background: 'linear-gradient(135deg,#667eea,#764ba2)', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <div style={{ color: '#fff' }}>
              <div style={{ fontWeight: 700, fontSize: 15 }}>Live Availability</div>
              <div style={{ fontSize: 12, opacity: .8 }}>Connect instantly with an available counselor or peer supporter</div>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 7, background: 'rgba(255,255,255,.15)', padding: '5px 12px', borderRadius: 20 }}>
              <span style={{ width: 8, height: 8, borderRadius: '50%', background: availableCounselors.length ? '#38c88c' : '#f59e0b', display: 'inline-block' }} />
              <span style={{ color: '#fff', fontSize: 13, fontWeight: 600 }}>
                {availableCounselors.length ? `${availableCounselors.length} available` : 'All offline'}
              </span>
            </div>
          </div>
          <div style={{ padding: 20, display: 'flex', flexDirection: 'column', gap: 12 }}>
            {counselors.length === 0 && <div style={{ color: '#9ca3af', textAlign: 'center' }}>No counselors found.</div>}
            {counselors.map(c => (
              <div key={c.id} style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '12px 16px', borderRadius: 12, background: c.online ? '#f0fdf4' : '#f9fafb', border: `1px solid ${c.online ? '#bbf7d0' : '#e5e7eb'}` }}>
                <div style={{ position: 'relative', flexShrink: 0 }}>
                  <div style={{ width: 44, height: 44, borderRadius: '50%', background: c.color, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff', fontWeight: 700, fontSize: 15 }}>{c.avatar}</div>
                  <div style={{ position: 'absolute', bottom: 1, right: 1, width: 12, height: 12, borderRadius: '50%', background: c.online ? '#38c88c' : '#d1d5db', border: '2px solid #fff' }} />
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontWeight: 600, fontSize: 14 }}>{c.name}</div>
                  <div style={{ fontSize: 12, color: c.online ? '#16a34a' : '#9ca3af' }}>
                    {c.online ? '● Available now' : '○ Offline — book a session below'}
                  </div>
                </div>
                {c.online ? (
                  <button className="btn btn-success btn-sm" onClick={() => joinInstant(c)}>
                    <i className="fas fa-video" /> Join Now
                  </button>
                ) : (
                  <button className="btn btn-outline btn-sm" onClick={() => { setWaitingFor(c); setShowBook(true); }}>
                    <i className="fas fa-calendar" /> Book
                  </button>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Counselor join panel */}
      {isCounselor && (
        <div className="card" style={{ marginBottom: 24, borderLeft: '4px solid #5b6cf9', display: 'flex', alignItems: 'center', gap: 20 }}>
          <div style={{ fontSize: 32 }}>🎥</div>
          <div style={{ flex: 1 }}>
            <div style={{ fontWeight: 700, fontSize: 15 }}>Ready to receive a session?</div>
            <div style={{ color: '#6b7280', fontSize: 13, marginTop: 4 }}>
              Make sure you are marked as <strong>Available</strong> in your dashboard. Students can then connect with you instantly.
            </div>
          </div>
          <div style={{ display: 'flex', gap: 8 }}>
            {upcomingSessions.map(s => (
              <button key={s.id} className="btn btn-success btn-sm" onClick={() => joinSession(s)}>
                <i className="fas fa-video" /> Join with {s.studentName}
              </button>
            ))}
            {upcomingSessions.length === 0 && (
              <span style={{ fontSize: 13, color: '#9ca3af', alignSelf: 'center' }}>No sessions yet</span>
            )}
          </div>
        </div>
      )}

      <div className="alert alert-info" style={{ marginBottom: 24 }}>
        <i className="fas fa-user-secret" />
        <div>
          <strong>Anonymous by default.</strong> In every session, use the <em>blur background</em> option in the video controls to hide your face. Your counselor sees only you wish to show.
        </div>
      </div>

      {/* Upcoming sessions */}
      <div style={{ marginBottom: 16, fontWeight: 600, fontSize: 16 }}>Upcoming Sessions ({upcomingSessions.length})</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginBottom: 28 }}>
        {upcomingSessions.map(s => {
          const counselor = users.find(u => u.id === s.counselorId);
          const isOnline = counselor?.online;
          return (
            <div key={s.id} className="card">
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                <div>
                  <div style={{ fontWeight: 600, fontSize: 15 }}>
                    {isCounselor ? s.studentName : (counselor?.name || 'Counselor')}
                  </div>
                  <div style={{ fontSize: 13, color: '#6b7280', marginTop: 4 }}>
                    <i className="fas fa-calendar" /> {s.date} at {s.time}
                  </div>
                  <div style={{ fontSize: 12, marginTop: 4, display: 'flex', alignItems: 'center', gap: 5 }}>
                    <span style={{ width: 7, height: 7, borderRadius: '50%', background: isOnline ? '#38c88c' : '#d1d5db', display: 'inline-block' }} />
                    <span style={{ color: isOnline ? '#16a34a' : '#9ca3af' }}>
                      {isCounselor ? 'Session room ready' : isOnline ? 'Counselor is online — join now' : 'Counselor offline — session at scheduled time'}
                    </span>
                  </div>
                </div>
                <button
                  className={`btn btn-sm ${isOnline || isCounselor ? 'btn-success' : 'btn-outline'}`}
                  onClick={() => joinSession(s)}
                >
                  <i className="fas fa-video" /> {isOnline || isCounselor ? 'Join Now' : 'Enter Room'}
                </button>
              </div>
            </div>
          );
        })}
        {upcomingSessions.length === 0 && (
          <div style={{ color: '#9ca3af', textAlign: 'center', padding: '20px' }}>No upcoming sessions</div>
        )}
      </div>

      {/* Past sessions */}
      <div style={{ marginBottom: 16, fontWeight: 600, fontSize: 16 }}>Past Sessions ({pastSessions.length})</div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
        {pastSessions.map(s => (
          <div key={s.id} className="card" style={{ opacity: .7 }}>
            <div style={{ fontWeight: 600, fontSize: 15 }}>{isCounselor ? s.studentName : 'Counseling Session'}</div>
            <div style={{ fontSize: 13, color: '#6b7280', marginTop: 4 }}><i className="fas fa-calendar" /> {s.date} at {s.time}</div>
            {s.notes && <div style={{ marginTop: 8, fontSize: 13, color: '#374151', background: '#f9fafb', padding: '10px', borderRadius: 8 }}>Notes: {s.notes}</div>}
          </div>
        ))}
        {pastSessions.length === 0 && (
          <div style={{ color: '#9ca3af', textAlign: 'center', padding: '20px' }}>No past sessions</div>
        )}
      </div>

      {/* Booking modal */}
      <Modal show={showBook} onClose={() => { setShowBook(false); setWaitingFor(null); }} title="Book a Session">
        <form onSubmit={bookSession} style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: 16 }}>
          {waitingFor && (
            <div className="alert alert-warning" style={{ margin: 0, fontSize: 13 }}>
              <i className="fas fa-clock" /> <strong>{waitingFor.name}</strong> is currently offline. Book a future slot and they will confirm.
            </div>
          )}
          <div>
            <label style={{ fontSize: 13, fontWeight: 600, color: '#374151', display: 'block', marginBottom: 6 }}>Session Type</label>
            <div style={{ display: 'flex', gap: 10 }}>
              {['counseling', 'peer'].map(t => (
                <button key={t} type="button"
                  onClick={() => setBooking(b => ({ ...b, type: t }))}
                  className={`btn btn-sm ${booking.type === t ? 'btn-primary' : 'btn-outline'}`}
                  style={{ flex: 1 }}>
                  {t === 'counseling' ? '🧑‍⚕️ Counseling' : '🤝 Peer Support'}
                </button>
              ))}
            </div>
          </div>
          <div>
            <label style={{ fontSize: 13, fontWeight: 600, color: '#374151', display: 'block', marginBottom: 6 }}>Date <span style={{ color: '#f43f5e' }}>*</span></label>
            <input type="date" className="input" required value={booking.date}
              min={new Date().toISOString().split('T')[0]}
              onChange={e => setBooking(b => ({ ...b, date: e.target.value }))} />
          </div>
          <div>
            <label style={{ fontSize: 13, fontWeight: 600, color: '#374151', display: 'block', marginBottom: 6 }}>Time <span style={{ color: '#f43f5e' }}>*</span></label>
            <input type="time" className="input" required value={booking.time}
              onChange={e => setBooking(b => ({ ...b, time: e.target.value }))} />
          </div>
          <div>
            <label style={{ fontSize: 13, fontWeight: 600, color: '#374151', display: 'block', marginBottom: 6 }}>What would you like to talk about? (optional)</label>
            <textarea className="input" rows={3} placeholder="This is confidential..."
              value={booking.note} onChange={e => setBooking(b => ({ ...b, note: e.target.value }))}
              style={{ resize: 'vertical' }} />
          </div>
          <div className="alert alert-info" style={{ margin: 0, fontSize: 13 }}>
            <i className="fas fa-user-secret" /> Your identity will be anonymous in this session.
          </div>
          <div style={{ display: 'flex', gap: 10, justifyContent: 'flex-end' }}>
            <button type="button" className="btn btn-outline" onClick={() => { setShowBook(false); setWaitingFor(null); }}>Cancel</button>
            <button type="submit" className="btn btn-primary"><i className="fas fa-calendar-check" /> Confirm Booking</button>
          </div>
        </form>
      </Modal>

      {booked && (
        <div style={{ position: 'fixed', bottom: 24, right: 24, background: '#38c88c', color: '#fff', padding: '14px 20px', borderRadius: 12, fontWeight: 600, fontSize: 15, boxShadow: '0 4px 16px rgba(0,0,0,.15)', zIndex: 999, display: 'flex', gap: 10, alignItems: 'center' }}>
          <i className="fas fa-check-circle" /> Session booked! You'll get a notification when confirmed.
        </div>
      )}
    </div>
  );
}
