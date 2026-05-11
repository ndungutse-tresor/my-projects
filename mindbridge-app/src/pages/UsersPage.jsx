import React from 'react';
import Avatar from '../components/Avatar';

export default function UsersPage({ users }) {
  const roleColors = { admin:'#8b5cf6', counselor:'#5b6cf9', student:'#14b8a6', peer:'#38c88c' };
  const roleLabels = { admin:'Administrator', counselor:'Counselor', student:'Student', peer:'Peer Supporter' };

  return (
    <div className="animate-fade">
      <div className="page-header">
        <div className="page-title">Users</div>
        <div className="page-subtitle">Manage platform users and roles</div>
      </div>
      <div className="card">
        <table className="table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Role</th>
              <th>Status</th>
              <th>Enrolled</th>
            </tr>
          </thead>
          <tbody>
            {users.map(u=>(
              <tr key={u.id}>
                <td style={{display:'flex',alignItems:'center',gap:10}}>
                  <Avatar name={u.name} color={u.color} size={32} fontSize={12} />
                  {u.name}
                </td>
                <td>{u.email}</td>
                <td><span style={{background:roleColors[u.role]+'22',color:roleColors[u.role],padding:'4px 12px',borderRadius:20,fontSize:12,fontWeight:600}}>{roleLabels[u.role]}</span></td>
                <td><span style={{color:u.online?'#38c88c':'#9ca3af',fontSize:13}}>{u.online?'🟢 Online':'🔴 Offline'}</span></td>
                <td>{u.enrolled?'✓ Yes':'✗ No'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
