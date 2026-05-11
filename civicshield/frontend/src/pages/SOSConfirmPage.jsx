import React, { useState, useEffect, useRef } from 'react';
import { useParams, useNavigate, useLocation } from 'react-router-dom';
import api from '../lib/api';
import { useSocket } from '../hooks/useSocket';

const CANCEL_WINDOW = 40;

const SOSConfirmPage = () => {
  const { id }       = useParams();
  const navigate     = useNavigate();
  const { state }    = useLocation();
  const { socket }   = useSocket();
  const shareLive    = state?.shareLive || false;

  const [secondsLeft, setSecondsLeft] = useState(CANCEL_WINDOW);
  const [cancelled,   setCancelled]   = useState(false);
  const [cancelling,  setCancelling]  = useState(false);
  const [confirmed,   setConfirmed]   = useState(false);
  const [error,       setError]       = useState('');
  const [liveActive,  setLiveActive]  = useState(shareLive);
  const intervalRef  = useRef(null);
  const watchIdRef   = useRef(null);

  // Countdown
  useEffect(() => {
    intervalRef.current = setInterval(() => {
      setSecondsLeft(s => {
        if (s <= 1) { clearInterval(intervalRef.current); setConfirmed(true); return 0; }
        return s - 1;
      });
    }, 1000);
    return () => clearInterval(intervalRef.current);
  }, []);

  // Live location broadcasting
  useEffect(() => {
    if (!liveActive || !socket || !id || !navigator.geolocation) return;
    socket.emit('join:incident', id);
    watchIdRef.current = navigator.geolocation.watchPosition(
      pos => {
        socket.emit('citizen:location:update', {
          incidentId: id,
          lat: pos.coords.latitude,
          lng: pos.coords.longitude,
        });
      },
      null,
      { enableHighAccuracy: true, maximumAge: 3000 }
    );
    return () => {
      if (watchIdRef.current != null) navigator.geolocation.clearWatch(watchIdRef.current);
    };
  }, [liveActive, socket, id]);

  const handleCancelMistake = async () => {
    setCancelling(true);
    try {
      await api.post(`/incidents/${id}/cancel-mistake`);
      clearInterval(intervalRef.current);
      setCancelled(true);
    } catch (err) {
      setError(err.response?.data?.error || 'Could not cancel. Window may have closed.');
    } finally {
      setCancelling(false);
    }
  };

  const progress = (secondsLeft / CANCEL_WINDOW) * 100;
  const urgentColor = secondsLeft <= 10 ? '#ef4444' : secondsLeft <= 20 ? '#f97316' : '#22c55e';

  // CANCELLED STATE
  if (cancelled) return (
    <div style={s.page}>
      <div style={s.card}>
        <div style={{ fontSize: 64, marginBottom: 16 }}>✅</div>
        <h2 style={{ color: '#22c55e', marginBottom: 8 }}>SOS Cancelled</h2>
        <p style={{ color: '#666', marginBottom: 24 }}>Your emergency alert was cancelled. No penalty applied.</p>
        <button onClick={() => navigate('/dashboard')} style={s.dashBtn}>← Back to Dashboard</button>
      </div>
    </div>
  );

  // CONFIRMED STATE
  if (confirmed) return (
    <div style={s.page}>
      <div style={s.card}>
        <div style={{ fontSize: 64, marginBottom: 16 }}>🚨</div>
        <h2 style={{ color: '#ef4444', marginBottom: 8 }}>SOS Confirmed</h2>
        <p style={{ color: '#555', marginBottom: 8 }}>Responders have been dispatched to your location.</p>
        <p style={{ color: '#888', fontSize: 13, marginBottom: 24 }}>Stay calm and remain at your location. Help is on the way.</p>
        <div style={s.tips}>
          <div style={s.tip}>📞 Keep your phone accessible</div>
          <div style={s.tip}>🚪 Unlock your door if possible</div>
          <div style={s.tip}>🏳️ Wave if you see responders</div>
        </div>
        <button onClick={() => navigate('/dashboard')} style={s.dashBtn}>View Dashboard</button>
        <p style={{ color: '#94a3b8', fontSize: 11, marginTop: 12 }}>
          ⚠️ Cancelling now may result in a penalty. Contact responders directly if resolved.
        </p>
      </div>
    </div>
  );

  // COUNTDOWN STATE
  return (
    <div style={s.page}>
      <div style={s.card}>
        <h2 style={{ color: '#ef4444', marginBottom: 4, fontSize: 22 }}>🚨 SOS Sent!</h2>
        <p style={{ color: '#666', marginBottom: 24, fontSize: 14 }}>Responders are being notified. You have {CANCEL_WINDOW}s to cancel if this was a mistake.</p>

        {/* Countdown ring */}
        <div style={{ position: 'relative', width: 140, height: 140, margin: '0 auto 24px' }}>
          <svg width="140" height="140" style={{ transform: 'rotate(-90deg)' }}>
            <circle cx="70" cy="70" r="60" fill="none" stroke="#f1f5f9" strokeWidth="10" />
            <circle
              cx="70" cy="70" r="60"
              fill="none"
              stroke={urgentColor}
              strokeWidth="10"
              strokeDasharray={`${2 * Math.PI * 60}`}
              strokeDashoffset={`${2 * Math.PI * 60 * (1 - progress / 100)}`}
              style={{ transition: 'stroke-dashoffset 1s linear, stroke 0.5s' }}
            />
          </svg>
          <div style={{
            position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
            alignItems: 'center', justifyContent: 'center'
          }}>
            <div style={{ fontSize: 36, fontWeight: 'bold', color: urgentColor, lineHeight: 1 }}>{secondsLeft}</div>
            <div style={{ fontSize: 12, color: '#94a3b8' }}>seconds</div>
          </div>
        </div>

        {/* Live location status */}
        {liveActive && (
          <div style={{ display:'flex', alignItems:'center', gap:8, background:'#f0fdf4', border:'1px solid #bbf7d0', borderRadius:8, padding:'8px 14px', marginBottom:14, fontSize:13, color:'#166534' }}>
            <span style={{ width:8, height:8, borderRadius:'50%', background:'#22c55e', display:'inline-block', animation:'pulse 1.5s infinite' }} />
            📡 Streaming live location to responders
            <button onClick={() => setLiveActive(false)} style={{ marginLeft:'auto', background:'none', border:'none', color:'#94a3b8', cursor:'pointer', fontSize:12 }}>Stop</button>
          </div>
        )}

        {error && <div style={s.error}>{error}</div>}

        <button
          onClick={handleCancelMistake}
          disabled={cancelling}
          style={s.cancelBtn}
        >
          {cancelling ? 'Cancelling...' : '✕ Cancel — This was a mistake'}
        </button>

        <div style={s.divider}>or</div>

        <button onClick={() => navigate('/dashboard')} style={s.dashBtn}>
          Confirm & Track Response →
        </button>

        <p style={{ color: '#94a3b8', fontSize: 11, marginTop: 16, textAlign: 'center' }}>
          After {secondsLeft}s the SOS is locked. False alarms are subject to fines.
        </p>
      </div>
    </div>
  );
};

const s = {
  page: {
    minHeight: '100vh',
    background: 'linear-gradient(135deg, #1e293b, #0f172a)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: 20,
    fontFamily: 'Arial, sans-serif',
    textAlign: 'center'
  },
  card: {
    background: 'white',
    borderRadius: 16,
    padding: '40px 32px',
    width: '100%',
    maxWidth: 380,
    boxShadow: '0 20px 60px rgba(0,0,0,0.5)',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center'
  },
  cancelBtn: {
    width: '100%',
    padding: '14px',
    background: '#fef2f2',
    color: '#ef4444',
    border: '2px solid #fca5a5',
    borderRadius: 10,
    fontSize: 15,
    fontWeight: 'bold',
    cursor: 'pointer'
  },
  dashBtn: {
    width: '100%',
    padding: '14px',
    background: '#667eea',
    color: 'white',
    border: 'none',
    borderRadius: 10,
    fontSize: 15,
    fontWeight: 'bold',
    cursor: 'pointer'
  },
  divider: {
    color: '#94a3b8',
    fontSize: 13,
    margin: '12px 0'
  },
  error: {
    width: '100%',
    background: '#fee2e2',
    color: '#dc2626',
    padding: '10px 14px',
    borderRadius: 8,
    fontSize: 13,
    marginBottom: 12
  },
  tips: {
    width: '100%',
    background: '#f0fdf4',
    border: '1px solid #bbf7d0',
    borderRadius: 10,
    padding: 16,
    marginBottom: 20,
    textAlign: 'left'
  },
  tip: {
    fontSize: 13,
    color: '#166534',
    marginBottom: 6
  }
};

export default SOSConfirmPage;
