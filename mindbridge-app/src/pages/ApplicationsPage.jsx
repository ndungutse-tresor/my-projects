import React, { useState } from 'react';
import Modal from '../components/Modal';
import Avatar from '../components/Avatar';
import { dataSource } from '../lib/dataSource';

export default function ApplicationsPage({ applications, setApplications, users, setUsers }) {
  const [selected, setSelected] = useState(null);
  const [filter, setFilter] = useState('pending');
  const filtered = filter==='all'?applications:applications.filter(a=>a.status===filter);

  const approve = async (id) => {
    const app = applications.find(a=>a.id===id);
    if(!app) return;
    const enrolledDate = new Date().toISOString().split('T')[0];
    const existingUser = users.find(u=>u.email===app.email);
    if (existingUser) {
      // User already has an account — just enroll them
      try { await dataSource.updateUser(existingUser.id, { enrolled: true, enrolledDate }); } catch(e) { console.error(e); }
      setUsers(p=>p.map(u=>u.id===existingUser.id?{...u,enrolled:true,enrolledDate}:u));
      try { await dataSource.updateApplication(id, { status:'approved', userId: existingUser.id }); } catch(e) { console.error(e); }
    } else {
      // No account yet — create a temporary one
      const newUser = {id:'u'+Date.now(),name:app.name,email:app.email,password:'Welcome@2026',role:'student',enrolled:true,enrolledDate,avatar:app.name.split(' ').map(n=>n[0]).join('').slice(0,2).toUpperCase(),color:'#14b8a6',online:false};
      try { await dataSource.createUser(newUser); } catch(e) { console.error(e); }
      setUsers(p=>[...p,newUser]);
      try { await dataSource.updateApplication(id, { status:'approved', userId: newUser.id }); } catch(e) { console.error(e); }
    }
    setApplications(p=>p.map(a=>a.id===id?{...a,status:'approved'}:a));
    setSelected(null);
  };

  const reject = async (id) => {
    try { await dataSource.updateApplication(id, { status:'rejected' }); } catch(e) { console.error(e); }
    setApplications(p=>p.map(a=>a.id===id?{...a,status:'rejected'}:a));
    setSelected(null);
  };

  return (
    <div className="animate-fade">
      <div className="page-header">
        <div className="page-title">Applications</div>
        <div className="page-subtitle">Review and manage student enrollment applications</div>
      </div>
      <div style={{display:'flex',gap:8,marginBottom:24}}>
        {['pending','approved','rejected','all'].map(f=>(
          <button key={f} className={`btn btn-sm ${filter===f?'btn-primary':'btn-outline'}`} onClick={()=>setFilter(f)}>
            {f.charAt(0).toUpperCase()+f.slice(1)} ({applications.filter(a=>f==='all'?true:a.status===f).length})
          </button>
        ))}
      </div>

      <div className="card">
        <table className="table">
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Issue</th>
              <th>Urgency</th>
              <th>Date</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map(a=>(
              <tr key={a.id} onClick={()=>setSelected(a)} style={{cursor:'pointer'}}>
                <td>{a.name}</td>
                <td>{a.email}</td>
                <td style={{maxWidth:200,overflow:'hidden',textOverflow:'ellipsis'}}>{a.issue.substring(0,50)}...</td>
                <td><span className={`badge badge-${a.urgency==='high'?'danger':a.urgency==='medium'?'warning':'gray'}`}>{a.urgency}</span></td>
                <td>{a.date}</td>
                <td><span className={`badge badge-${a.status==='approved'?'success':a.status==='rejected'?'danger':'warning'}`}>{a.status}</span></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <Modal show={!!selected} onClose={()=>setSelected(null)} title="Application Details" wide>
        {selected&&(
          <div>
            <div style={{marginBottom:20}}>
              <div style={{fontSize:13,fontWeight:600,color:'#6b7280',marginBottom:4}}>Name</div>
              <div style={{fontSize:15}}>{selected.name}</div>
            </div>
            <div style={{marginBottom:20}}>
              <div style={{fontSize:13,fontWeight:600,color:'#6b7280',marginBottom:4}}>Email</div>
              <div style={{fontSize:15}}>{selected.email}</div>
            </div>
            <div style={{marginBottom:20}}>
              <div style={{fontSize:13,fontWeight:600,color:'#6b7280',marginBottom:4}}>Student ID</div>
              <div style={{fontSize:15}}>{selected.studentId}</div>
            </div>
            <div style={{marginBottom:20}}>
              <div style={{fontSize:13,fontWeight:600,color:'#6b7280',marginBottom:4}}>Issue Description</div>
              <div style={{fontSize:15,lineHeight:1.6}}>{selected.issue}</div>
            </div>
            <div style={{marginBottom:20}}>
              <div style={{fontSize:13,fontWeight:600,color:'#6b7280',marginBottom:4}}>Urgency</div>
              <span className={`badge badge-${selected.urgency==='high'?'danger':selected.urgency==='medium'?'warning':'gray'}`}>{selected.urgency}</span>
            </div>
            {selected.status==='pending'&&(
              <div style={{display:'flex',gap:10,marginTop:24}}>
                <button className="btn btn-success" onClick={()=>approve(selected.id)}><i className="fas fa-check"/>Approve</button>
                <button className="btn btn-danger" onClick={()=>reject(selected.id)}><i className="fas fa-times"/>Reject</button>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
}
