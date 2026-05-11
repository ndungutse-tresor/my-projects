import React, { useState, useEffect, useRef } from 'react';
import { useAuth } from '../hooks/useAuth';
import { useNavigate } from 'react-router-dom';
import api from '../lib/api';
import CameraCapture from '../components/CameraCapture';

const TIER_INFO = {
  standard: { label: 'Standard',  color: '#667eea', desc: 'Regular emergency response', price: 'Free'    },
  private:  { label: 'Private',   color: '#8b5cf6', desc: 'Dedicated, priority dispatch', price: 'Premium' },
  vip:      { label: 'VIP ⭐',    color: '#f59e0b', desc: 'Fastest response, elite team', price: 'VIP'     },
};

const SOSPage = () => {
  const { user } = useAuth();
  const navigate  = useNavigate();

  const [form, setForm] = useState({
    title: 'Emergency', description: '', type: 'medical',
    severity: 'critical', serviceType: 'standard',
    location: { lat: null, lng: null, address: '' }
  });
  const [locationLoading, setLocationLoading] = useState(true);
  const [loading, setLoading] = useState(false);
  const [error,   setError]   = useState('');

  // Audio recording
  const [recording,     setRecording]     = useState(false);
  const [audioBlob,     setAudioBlob]     = useState(null);
  const [audioUrl,      setAudioUrl]      = useState(null);
  const [recordingTime, setRecordingTime] = useState(0);
  const mediaRecRef = useRef(null);
  const chunksRef   = useRef([]);
  const timerRef    = useRef(null);

  // Camera / photos
  const [showCamera,    setShowCamera]    = useState(false);
  const [proofFiles,    setProofFiles]    = useState([]);  // Blob[]
  const [proofPreviews, setProofPreviews] = useState([]);  // object URLs

  // Live location sharing
  const [shareLive, setShareLive] = useState(false);

  // Geolocation (current fix)
  useEffect(() => {
    if (!navigator.geolocation) { setLocationLoading(false); return; }
    navigator.geolocation.getCurrentPosition(
      pos => {
        setForm(p => ({ ...p, location: { ...p.location, lat: pos.coords.latitude, lng: pos.coords.longitude } }));
        setLocationLoading(false);
      },
      () => setLocationLoading(false),
      { enableHighAccuracy: true, timeout: 10000 }
    );
  }, []);

  // Audio helpers
  const startRecording = async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      chunksRef.current = [];
      const rec = new MediaRecorder(stream);
      rec.ondataavailable = e => { if (e.data.size > 0) chunksRef.current.push(e.data); };
      rec.onstop = () => {
        const blob = new Blob(chunksRef.current, { type: 'audio/webm' });
        setAudioBlob(blob);
        setAudioUrl(URL.createObjectURL(blob));
        stream.getTracks().forEach(t => t.stop());
      };
      rec.start();
      mediaRecRef.current = rec;
      setRecording(true);
      setRecordingTime(0);
      timerRef.current = setInterval(() => setRecordingTime(t => t + 1), 1000);
    } catch { setError('Microphone access denied.'); }
  };

  const stopRecording = () => {
    mediaRecRef.current?.stop();
    clearInterval(timerRef.current);
    setRecording(false);
  };

  const clearAudio = () => { setAudioBlob(null); setAudioUrl(null); setRecordingTime(0); };

  // Camera capture callback
  const handleCameraCapture = blob => {
    if (proofFiles.length >= 5) return;
    const url = URL.createObjectURL(blob);
    setProofFiles(p  => [...p, blob]);
    setProofPreviews(p => [...p, url]);
  };

  const removeProof = idx => {
    setProofFiles(p => p.filter((_, i) => i !== idx));
    setProofPreviews(p => p.filter((_, i) => i !== idx));
  };

  const handleSubmit = async e => {
    e.preventDefault();
    setError('');
    if (!form.location.lat || !form.location.lng) {
      setError('Location is required. Enable GPS and try again.');
      return;
    }
    if (!form.description && !audioBlob && proofFiles.length === 0) {
      setError('Please add a description, voice note, or at least one photo.');
      return;
    }
    setLoading(true);
    try {
      const fd = new FormData();
      fd.append('title',       form.title);
      fd.append('description', form.description);
      fd.append('type',        form.type);
      fd.append('severity',    form.severity);
      fd.append('serviceType', form.serviceType);
      fd.append('location',    JSON.stringify(form.location));
      fd.append('shareLive',   shareLive ? '1' : '0');
      if (audioBlob) fd.append('audio', audioBlob, 'voice-note.webm');
      proofFiles.forEach(f => fd.append('proofFiles', f, 'photo.jpg'));

      const res = await api.post('/incidents', fd, { headers: { 'Content-Type': 'multipart/form-data' } });
      navigate(`/sos-confirm/${res.data._id}`, { state: { shareLive } });
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to send SOS');
    } finally {
      setLoading(false);
    }
  };

  const fmt = s => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;

  return (
    <div style={s.page}>
      {showCamera && (
        <CameraCapture
          onCapture={handleCameraCapture}
          onClose={() => setShowCamera(false)}
          maxPhotos={5}
          currentCount={proofFiles.length}
        />
      )}

      <div style={s.card}>
        {/* Header */}
        <div style={s.header}>
          <button onClick={() => navigate('/dashboard')} style={s.back}>←</button>
          <h1 style={s.title}>🆘 EMERGENCY SOS</h1>
          <div style={{ width: 36 }} />
        </div>

        {user && (
          <div style={s.userBadge}>
            Reporting as: <strong>{user.name}</strong> · {user.phone}
          </div>
        )}

        <form onSubmit={handleSubmit}>

          {/* Service Tier */}
          <div style={s.section}>
            <label style={s.label}>Service Tier</label>
            <div style={s.tierGrid}>
              {Object.entries(TIER_INFO).map(([key, info]) => (
                <button key={key} type="button"
                  onClick={() => setForm(p => ({ ...p, serviceType: key }))}
                  style={{
                    ...s.tierBtn,
                    borderColor: form.serviceType === key ? info.color : '#ddd',
                    background:  form.serviceType === key ? info.color + '15' : 'white',
                    color:       form.serviceType === key ? info.color : '#333',
                  }}>
                  <div style={{ fontWeight: 'bold', fontSize: 14 }}>{info.label}</div>
                  <div style={{ fontSize: 11, marginTop: 2, opacity: .8 }}>{info.desc}</div>
                  <div style={{ fontSize: 11, fontWeight: 600, marginTop: 2 }}>{info.price}</div>
                </button>
              ))}
            </div>
          </div>

          {/* Type & Severity */}
          <div style={s.row}>
            <div style={{ flex: 1 }}>
              <label style={s.label}>Type</label>
              <select value={form.type} onChange={e => setForm(p => ({ ...p, type: e.target.value }))} style={s.select}>
                <option value="medical">🏥 Medical</option>
                <option value="fire">🔥 Fire</option>
                <option value="security">🚨 Security</option>
                <option value="accident">🚗 Accident</option>
                <option value="other">⚠️ Other</option>
              </select>
            </div>
            <div style={{ flex: 1 }}>
              <label style={s.label}>Severity</label>
              <select value={form.severity} onChange={e => setForm(p => ({ ...p, severity: e.target.value }))} style={s.select}>
                <option value="critical">🔴 Critical</option>
                <option value="high">🟠 High</option>
                <option value="medium">🟡 Medium</option>
                <option value="low">🟢 Low</option>
              </select>
            </div>
          </div>

          {/* Description */}
          <div style={s.section}>
            <label style={s.label}>Description <span style={{ color: '#999', fontWeight: 'normal' }}>(or use voice/photo below)</span></label>
            <textarea
              value={form.description}
              onChange={e => setForm(p => ({ ...p, description: e.target.value }))}
              placeholder="What is happening? Where exactly? How many people affected?"
              rows={3} style={s.textarea}
            />
          </div>

          {/* Voice Note */}
          <div style={s.section}>
            <label style={s.label}>🎙️ Voice Note</label>
            {!audioUrl ? (
              <div style={s.recordBox}>
                {recording ? (
                  <>
                    <div style={s.recPulse} />
                    <span style={{ color: '#ef4444', fontWeight: 'bold' }}>● REC {fmt(recordingTime)}</span>
                    <button type="button" onClick={stopRecording} style={s.stopBtn}>■ Stop</button>
                  </>
                ) : (
                  <button type="button" onClick={startRecording} style={s.micBtn}>🎙️ Record Voice</button>
                )}
              </div>
            ) : (
              <div style={s.audioPreview}>
                <audio controls src={audioUrl} style={{ flex: 1, height: 36 }} />
                <button type="button" onClick={clearAudio} style={s.clearBtn}>✕</button>
              </div>
            )}
          </div>

          {/* Photo Proof — camera only */}
          <div style={s.section}>
            <label style={s.label}>📸 Photo Evidence <span style={{ color: '#999', fontWeight: 'normal' }}>(camera only, up to 5)</span></label>
            <div style={s.proofRow}>
              {proofPreviews.map((url, i) => (
                <div key={i} style={s.thumb}>
                  <img src={url} alt="proof" style={s.thumbImg} />
                  <button type="button" onClick={() => removeProof(i)} style={s.removeBtn}>✕</button>
                </div>
              ))}
              {proofFiles.length < 5 && (
                <button type="button" onClick={() => setShowCamera(true)} style={s.camBtn}>
                  📷<br /><span style={{ fontSize: 10 }}>Camera</span>
                </button>
              )}
            </div>
          </div>

          {/* Location */}
          <div style={s.section}>
            <label style={s.label}>📍 Your Location</label>
            <div style={s.locBox}>
              {locationLoading
                ? <span style={{ color: '#666' }}>Getting your GPS location…</span>
                : form.location.lat
                  ? <span style={{ color: '#22c55e' }}>✓ {form.location.lat.toFixed(5)}, {form.location.lng.toFixed(5)}</span>
                  : <span style={{ color: '#ef4444' }}>⚠️ GPS unavailable — enable location access</span>
              }
            </div>

            {/* Live location toggle */}
            <div style={s.liveRow}>
              <button
                type="button"
                onClick={() => setShareLive(v => !v)}
                style={{
                  ...s.liveToggle,
                  background: shareLive ? '#22c55e' : '#e2e8f0',
                  color:      shareLive ? 'white'   : '#64748b',
                  borderColor: shareLive ? '#22c55e' : '#e2e8f0',
                }}
              >
                {shareLive ? '📡 Live Location ON' : '📍 Send Live Location'}
              </button>
              <span style={{ fontSize: 11, color: '#94a3b8' }}>
                {shareLive
                  ? 'Your GPS will stream in real-time to responders'
                  : 'Tap to stream your position continuously'}
              </span>
            </div>
          </div>

          {error && <div style={s.error}>{error}</div>}

          <button
            type="submit"
            disabled={loading || !form.location.lat}
            style={{
              ...s.sosBtn,
              background: loading ? '#ccc'
                : form.serviceType === 'vip'     ? '#f59e0b'
                : form.serviceType === 'private' ? '#8b5cf6'
                : '#ef4444',
              cursor: loading || !form.location.lat ? 'not-allowed' : 'pointer',
            }}
          >
            {loading ? 'Sending SOS…' : `🚨 SEND ${form.serviceType.toUpperCase()} SOS`}
          </button>

          <p style={s.penalty}>
            ⚠️ False alarms result in penalties: Standard 5,000 RWF · Private 15,000 RWF · VIP 30,000 RWF
          </p>
        </form>
      </div>
    </div>
  );
};

const s = {
  page:       { minHeight: '100vh', background: 'linear-gradient(135deg,#1e293b,#334155)', display: 'flex', alignItems: 'flex-start', justifyContent: 'center', padding: 20, fontFamily: 'Arial, sans-serif' },
  card:       { background: 'white', borderRadius: 12, width: '100%', maxWidth: 540, boxShadow: '0 20px 60px rgba(0,0,0,.4)', overflow: 'hidden' },
  header:     { background: '#ef4444', padding: '16px 20px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' },
  back:       { background: 'rgba(255,255,255,.2)', border: '1px solid rgba(255,255,255,.4)', color: 'white', borderRadius: 6, width: 36, height: 36, cursor: 'pointer', fontSize: 18 },
  title:      { color: 'white', fontSize: 20, fontWeight: 'bold', margin: 0 },
  userBadge:  { background: '#fef3f2', padding: '10px 20px', fontSize: 13, color: '#555', borderBottom: '1px solid #fee2e2' },
  section:    { padding: '14px 20px 0' },
  label:      { display: 'block', fontWeight: 'bold', fontSize: 13, marginBottom: 8, color: '#333' },
  row:        { display: 'flex', gap: 12, padding: '14px 20px 0' },
  tierGrid:   { display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 8 },
  tierBtn:    { padding: '10px 8px', border: '2px solid', borderRadius: 8, cursor: 'pointer', textAlign: 'center', transition: 'all .2s' },
  select:     { width: '100%', padding: 10, border: '1px solid #ddd', borderRadius: 6, fontSize: 14, background: 'white' },
  textarea:   { width: '100%', padding: 10, border: '1px solid #ddd', borderRadius: 6, fontSize: 14, resize: 'vertical', fontFamily: 'Arial, sans-serif', boxSizing: 'border-box' },
  recordBox:  { display: 'flex', alignItems: 'center', gap: 12, padding: 12, background: '#fef3f2', borderRadius: 8, border: '1px dashed #fca5a5' },
  recPulse:   { width: 12, height: 12, borderRadius: '50%', background: '#ef4444', animation: 'pulse 1s infinite' },
  micBtn:     { background: '#ef4444', color: 'white', border: 'none', padding: '10px 20px', borderRadius: 8, cursor: 'pointer', fontWeight: 'bold', fontSize: 14 },
  stopBtn:    { background: '#1e293b', color: 'white', border: 'none', padding: '8px 16px', borderRadius: 6, cursor: 'pointer', fontWeight: 'bold' },
  audioPreview:{ display: 'flex', alignItems: 'center', gap: 8, padding: 8, background: '#f0fdf4', borderRadius: 8, border: '1px solid #bbf7d0' },
  clearBtn:   { background: '#fee2e2', border: 'none', borderRadius: 6, width: 32, height: 32, cursor: 'pointer', color: '#ef4444', fontWeight: 'bold', flexShrink: 0 },
  proofRow:   { display: 'flex', gap: 8, flexWrap: 'wrap' },
  thumb:      { position: 'relative', width: 72, height: 72 },
  thumbImg:   { width: '100%', height: '100%', objectFit: 'cover', borderRadius: 8, border: '1px solid #ddd' },
  removeBtn:  { position: 'absolute', top: -6, right: -6, width: 20, height: 20, borderRadius: '50%', background: '#ef4444', color: 'white', border: 'none', cursor: 'pointer', fontSize: 10, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 0 },
  camBtn:     { width: 72, height: 72, background: '#f8fafc', border: '2px dashed #cbd5e1', borderRadius: 8, cursor: 'pointer', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', fontSize: 22, color: '#64748b' },
  locBox:     { padding: '10px 12px', background: '#f8fafc', borderRadius: 8, border: '1px solid #e2e8f0', fontSize: 13 },
  liveRow:    { display: 'flex', alignItems: 'center', gap: 10, marginTop: 10 },
  liveToggle: { padding: '8px 14px', border: '2px solid', borderRadius: 20, cursor: 'pointer', fontSize: 13, fontWeight: 600, flexShrink: 0, whiteSpace: 'nowrap' },
  error:      { margin: '12px 20px 0', background: '#fee2e2', color: '#dc2626', padding: '10px 14px', borderRadius: 8, fontSize: 13 },
  sosBtn:     { display: 'block', width: 'calc(100% - 40px)', margin: '16px 20px', padding: 16, color: 'white', border: 'none', borderRadius: 10, fontSize: 18, fontWeight: 'bold', letterSpacing: '.05em' },
  penalty:    { textAlign: 'center', fontSize: 11, color: '#94a3b8', padding: '0 20px 16px', margin: 0 },
};

export default SOSPage;
