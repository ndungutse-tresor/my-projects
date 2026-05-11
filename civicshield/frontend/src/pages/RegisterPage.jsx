import React, { useState } from 'react';
import { useAuth } from '../hooks/useAuth';
import { useNavigate } from 'react-router-dom';

const RESPONDER_TYPES = [
  { value: 'ambulance', label: '🚑 Ambulance / Medical', color: '#ef4444' },
  { value: 'police',    label: '🚔 Police / Security',  color: '#3b82f6' },
  { value: 'fire',      label: '🚒 Fire Brigade',        color: '#f97316' },
  { value: 'rescue',    label: '⛑️ Search & Rescue',     color: '#22c55e' },
];

const RegisterPage = () => {
  const { register } = useAuth();
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: '', password: '', name: '', phone: '',
    role: 'citizen', responderType: ''
  });
  const [error, setError]     = useState('');
  const [loading, setLoading] = useState(false);

  const set = (k, v) => setFormData(p => ({ ...p, [k]: v }));

  const handleSubmit = async e => {
    e.preventDefault();
    if (formData.role === 'responder' && !formData.responderType) {
      setError('Please select your responder type.');
      return;
    }
    setLoading(true);
    setError('');
    try {
      await register(
        formData.email, formData.password,
        formData.name,  formData.phone,
        formData.role,  formData.responderType || undefined
      );
      navigate('/dashboard');
    } catch (err) {
      setError(err.response?.data?.error || 'Registration failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={s.page}>
      <div style={s.card}>
        <h1 style={s.logo}>🚨 CivicShield</h1>
        <p style={s.sub}>Create Your Account</p>

        <form onSubmit={handleSubmit}>
          {/* Name */}
          <div style={s.group}>
            <label style={s.label}>Full Name</label>
            <input style={s.input} type="text" required placeholder="John Doe"
              value={formData.name} onChange={e => set('name', e.target.value)} />
          </div>

          {/* Email */}
          <div style={s.group}>
            <label style={s.label}>Email</label>
            <input style={s.input} type="email" required placeholder="you@example.com"
              value={formData.email} onChange={e => set('email', e.target.value)} />
          </div>

          {/* Phone */}
          <div style={s.group}>
            <label style={s.label}>Phone</label>
            <input style={s.input} type="tel" required placeholder="+250 7XX XXX XXX"
              value={formData.phone} onChange={e => set('phone', e.target.value)} />
          </div>

          {/* Password */}
          <div style={s.group}>
            <label style={s.label}>Password</label>
            <input style={s.input} type="password" required minLength={8} placeholder="min 8 characters"
              value={formData.password} onChange={e => set('password', e.target.value)} />
          </div>

          {/* Role */}
          <div style={s.group}>
            <label style={s.label}>Account Type</label>
            <div style={s.roleGrid}>
              {[
                { v:'citizen',    icon:'👤', label:'Citizen',    desc:'Report emergencies' },
                { v:'responder',  icon:'🚑', label:'Responder',  desc:'Respond to calls'   },
                { v:'dispatcher', icon:'📡', label:'Dispatcher', desc:'Coordinate teams'   },
              ].map(r => (
                <button key={r.v} type="button" onClick={() => set('role', r.v)}
                  style={{
                    ...s.roleBtn,
                    borderColor:  formData.role === r.v ? '#667eea' : '#ddd',
                    background:   formData.role === r.v ? '#667eea15' : 'white',
                    color:        formData.role === r.v ? '#667eea' : '#333',
                  }}>
                  <div style={{ fontSize: 22 }}>{r.icon}</div>
                  <div style={{ fontWeight: 'bold', fontSize: 13 }}>{r.label}</div>
                  <div style={{ fontSize: 11, opacity: .7 }}>{r.desc}</div>
                </button>
              ))}
            </div>
          </div>

          {/* Responder type — shown only for responders */}
          {formData.role === 'responder' && (
            <div style={s.group}>
              <label style={s.label}>Responder Type</label>
              <div style={s.typeGrid}>
                {RESPONDER_TYPES.map(t => (
                  <button key={t.value} type="button"
                    onClick={() => set('responderType', t.value)}
                    style={{
                      ...s.typeBtn,
                      borderColor: formData.responderType === t.value ? t.color : '#ddd',
                      background:  formData.responderType === t.value ? t.color + '18' : 'white',
                      color:       formData.responderType === t.value ? t.color : '#444',
                    }}>
                    {t.label}
                  </button>
                ))}
              </div>
            </div>
          )}

          {error && <div style={s.error}>{error}</div>}

          <button type="submit" disabled={loading} style={s.btn}>
            {loading ? 'Creating Account…' : 'Create Account'}
          </button>
        </form>

        <p style={s.foot}>
          Already have an account?{' '}
          <a href="/login" style={{ color: '#667eea', textDecoration: 'none' }}>Login here</a>
        </p>
      </div>
    </div>
  );
};

const s = {
  page:     { minHeight: '100vh', background: 'linear-gradient(135deg,#667eea,#764ba2)', display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 20, fontFamily: 'Arial, sans-serif' },
  card:     { background: 'white', borderRadius: 12, padding: '36px 32px', width: '100%', maxWidth: 460, boxShadow: '0 12px 40px rgba(0,0,0,.25)' },
  logo:     { textAlign: 'center', fontSize: 30, margin: '0 0 6px' },
  sub:      { textAlign: 'center', color: '#666', fontSize: 15, margin: '0 0 24px' },
  group:    { marginBottom: 18 },
  label:    { display: 'block', fontSize: 13, fontWeight: 'bold', color: '#333', marginBottom: 6 },
  input:    { width: '100%', padding: '11px 12px', border: '1px solid #ddd', borderRadius: 7, fontSize: 14, boxSizing: 'border-box' },
  roleGrid: { display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 8 },
  roleBtn:  { padding: '10px 6px', border: '2px solid', borderRadius: 8, cursor: 'pointer', textAlign: 'center', transition: 'all .15s' },
  typeGrid: { display: 'grid', gridTemplateColumns: 'repeat(2,1fr)', gap: 8 },
  typeBtn:  { padding: '10px 12px', border: '2px solid', borderRadius: 8, cursor: 'pointer', textAlign: 'left', fontSize: 13, fontWeight: 600, transition: 'all .15s' },
  error:    { background: '#fee', color: '#c00', padding: '10px 12px', borderRadius: 7, marginBottom: 14, fontSize: 13 },
  btn:      { width: '100%', padding: 13, background: '#667eea', color: 'white', border: 'none', borderRadius: 8, fontSize: 16, fontWeight: 'bold', cursor: 'pointer', marginTop: 4 },
  foot:     { textAlign: 'center', color: '#666', fontSize: 14, marginTop: 20 },
};

export default RegisterPage;
