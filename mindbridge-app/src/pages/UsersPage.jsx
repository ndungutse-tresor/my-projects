import React, { useState } from 'react';
import Avatar from '../components/Avatar';
import Modal from '../components/Modal';
import { dataSource } from '../lib/dataSource';

const ROLE_COLORS = { admin:'#8b5cf6', counselor:'#5b6cf9', student:'#14b8a6', peer:'#38c88c' };
const ROLE_LABELS = { admin:'Administrator', counselor:'Counselor', student:'Student', peer:'Peer Supporter' };
const AVATAR_COLORS = ['#5b6cf9','#8b5cf6','#14b8a6','#f59e0b','#f43f5e','#38c88c'];

const emptyForm = { name:'', email:'', password:'', role:'counselor' };

export default function UsersPage({ users, setUsers }) {
  const [showCreate, setShowCreate] = useState(false);
  const [form, setForm] = useState(emptyForm);
  const [error, setError] = useState('');
  const [saving, setSaving] = useState(false);
  const [changingRole, setChangingRole] = useState(null); // userId being edited
  const [search, setSearch] = useState('');
  const [filterRole, setFilterRole] = useState('all');

  const filtered = users.filter(u => {
    const matchRole = filterRole === 'all' || u.role === filterRole;
    const matchSearch = !search || u.name.toLowerCase().includes(search.toLowerCase()) || u.email.toLowerCase().includes(search.toLowerCase());
    return matchRole && matchSearch;
  });

  const handleCreate = async (e) => {
    e.preventDefault();
    setError('');
    if (users.find(u => u.email === form.email)) {
      setError('An account with this email already exists.');
      return;
    }
    setSaving(true);
    const newUser = {
      id: 'u' + Date.now(),
      name: form.name,
      email: form.email,
      password: form.password,
      role: form.role,
      avatar: form.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase(),
      color: AVATAR_COLORS[Math.floor(Math.random() * AVATAR_COLORS.length)],
      online: false,
      enrolled: form.role === 'counselor' || form.role === 'admin' ? false : false,
      enrolledDate: null,
      applicationStatus: null,
    };
    try {
      await dataSource.createUser(newUser);
      setUsers(prev => [...prev, newUser]);
      setShowCreate(false);
      setForm(emptyForm);
    } catch (err) {
      setError('Failed to create account. Please try again.');
      console.error(err);
    } finally {
      setSaving(false);
    }
  };

  const handleRoleChange = async (userId, newRole) => {
    try {
      await dataSource.updateUser(userId, { role: newRole });
      setUsers(prev => prev.map(u => u.id === userId ? { ...u, role: newRole } : u));
    } catch (err) {
      console.error('Failed to update role:', err);
    }
    setChangingRole(null);
  };

  return (
    <div className="animate-fade">
      <div className="page-header" style={{ display:'flex', justifyContent:'space-between', alignItems:'flex-start' }}>
        <div>
          <div className="page-title">Users</div>
          <div className="page-subtitle">Manage platform users and roles</div>
        </div>
        <button className="btn btn-primary" onClick={() => { setShowCreate(true); setError(''); setForm(emptyForm); }}>
          <i className="fas fa-user-plus" /> Create Account
        </button>
      </div>

      {/* Filters */}
      <div style={{ display:'flex', gap:10, marginBottom:20, flexWrap:'wrap', alignItems:'center' }}>
        <input
          className="input" placeholder="Search by name or email..."
          value={search} onChange={e => setSearch(e.target.value)}
          style={{ maxWidth:260, padding:'8px 14px', fontSize:13 }}
        />
        {['all','admin','counselor','student','peer'].map(r => (
          <button key={r} className={`btn btn-sm ${filterRole===r?'btn-primary':'btn-outline'}`} onClick={() => setFilterRole(r)}>
            {r === 'all' ? `All (${users.length})` : `${ROLE_LABELS[r]}s (${users.filter(u=>u.role===r).length})`}
          </button>
        ))}
      </div>

      <div className="card">
        <div className="table-wrap">
        <table className="table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Role</th>
              <th>Status</th>
              <th>Enrolled</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 && (
              <tr><td colSpan={6} style={{ textAlign:'center', color:'#9ca3af', padding:'32px' }}>No users found.</td></tr>
            )}
            {filtered.map(u => (
              <tr key={u.id}>
                <td style={{ display:'flex', alignItems:'center', gap:10 }}>
                  <Avatar name={u.name} color={u.color} size={32} fontSize={12} />
                  <span style={{ fontWeight:500 }}>{u.name}</span>
                </td>
                <td style={{ fontSize:13, color:'#6b7280' }}>{u.email}</td>
                <td>
                  {changingRole === u.id ? (
                    <div style={{ display:'flex', gap:6, alignItems:'center' }}>
                      <select
                        className="select" defaultValue={u.role}
                        style={{ fontSize:12, padding:'4px 8px' }}
                        onChange={e => handleRoleChange(u.id, e.target.value)}
                        autoFocus
                      >
                        <option value="admin">Administrator</option>
                        <option value="counselor">Counselor</option>
                        <option value="student">Student</option>
                        <option value="peer">Peer Supporter</option>
                      </select>
                      <button className="btn btn-sm btn-outline" onClick={() => setChangingRole(null)} style={{ padding:'4px 8px' }}>✕</button>
                    </div>
                  ) : (
                    <span
                      style={{ background:ROLE_COLORS[u.role]+'22', color:ROLE_COLORS[u.role], padding:'4px 12px', borderRadius:20, fontSize:12, fontWeight:600, cursor:'pointer' }}
                      title="Click to change role"
                      onClick={() => setChangingRole(u.id)}
                    >
                      {ROLE_LABELS[u.role]} ✎
                    </span>
                  )}
                </td>
                <td>
                  <span style={{ color:u.online?'#38c88c':'#9ca3af', fontSize:13 }}>
                    {u.online ? '🟢 Online' : '⚫ Offline'}
                  </span>
                </td>
                <td style={{ color:u.enrolled?'#38c88c':'#9ca3af', fontWeight:600 }}>
                  {u.enrolled ? '✓ Yes' : '✗ No'}
                </td>
                <td>
                  <button
                    className="btn btn-sm btn-outline"
                    style={{ fontSize:11 }}
                    onClick={() => setChangingRole(changingRole === u.id ? null : u.id)}
                  >
                    Change Role
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        </div>
      </div>

      {/* Create Account Modal */}
      <Modal show={showCreate} onClose={() => setShowCreate(false)} title="Create Account" wide>
        <form onSubmit={handleCreate}>
          <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:16, marginBottom:16 }}>
            <div className="form-group" style={{ margin:0 }}>
              <label className="label">Full Name *</label>
              <input className="input" required placeholder="e.g. Dr. Jane Smith"
                value={form.name} onChange={e => setForm({ ...form, name:e.target.value })} />
            </div>
            <div className="form-group" style={{ margin:0 }}>
              <label className="label">Role *</label>
              <select className="select" value={form.role} onChange={e => setForm({ ...form, role:e.target.value })}>
                <option value="counselor">Counselor</option>
                <option value="admin">Administrator</option>
                <option value="student">Student</option>
                <option value="peer">Peer Supporter</option>
              </select>
            </div>
          </div>
          <div className="form-group">
            <label className="label">Email Address *</label>
            <input className="input" type="email" required placeholder="Any email address (Gmail, work, etc.)"
              value={form.email} onChange={e => setForm({ ...form, email:e.target.value })} />
          </div>
          <div className="form-group">
            <label className="label">Password *</label>
            <input className="input" type="password" required minLength={6} placeholder="Minimum 6 characters"
              value={form.password} onChange={e => setForm({ ...form, password:e.target.value })} />
            {(form.role === 'counselor' || form.role === 'admin') && (
              <div style={{ fontSize:12, color:'#6b7280', marginTop:4 }}>
                Share these credentials with the person so they can log in.
              </div>
            )}
          </div>

          {/* Role info box */}
          <div style={{ padding:'12px 16px', borderRadius:10, marginBottom:16, fontSize:13, lineHeight:1.6,
            background: form.role==='admin'?'#f3effe': form.role==='counselor'?'#eef0ff': form.role==='peer'?'#f0fdf4':'#f8fafc',
            borderLeft: `3px solid ${ROLE_COLORS[form.role]||'#e5e7eb'}` }}>
            {form.role === 'admin' && <><strong>Administrator:</strong> Full access — can approve applications, manage users, schedule sessions, and view all data.</>}
            {form.role === 'counselor' && <><strong>Counselor:</strong> Can receive session bookings, message students, and view their assigned cases.</>}
            {form.role === 'peer' && <><strong>Peer Supporter:</strong> Recovered student volunteer — can message students and support conversations.</>}
            {form.role === 'student' && <><strong>Student:</strong> Will need to submit an enrollment application to access counseling features.</>}
          </div>

          {error && <div style={{ background:'#fee2e2', color:'#dc2626', padding:'10px 14px', borderRadius:8, marginBottom:12, fontSize:13 }}>{error}</div>}

          <div style={{ display:'flex', gap:10, justifyContent:'flex-end' }}>
            <button type="button" className="btn btn-outline" onClick={() => setShowCreate(false)}>Cancel</button>
            <button type="submit" className="btn btn-primary" disabled={saving}>
              {saving ? 'Creating...' : 'Create Account'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
}
