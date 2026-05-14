import React, { useState } from 'react';
import { dataSource } from '../lib/dataSource';

export default function AdminSchedulePage({ users, sessions, setSessions }) {
  const [form, setForm] = useState({ studentId:'', counselorId:'', date:'', time:'' });
  const [success, setSuccess] = useState(false);

  const students = users.filter(u=>u.role==='student'&&u.enrolled);
  const counselors = users.filter(u=>u.role==='counselor');

  const handleSchedule = async (e) => {
    e.preventDefault();
    const newSession = {
      id:'sess'+Date.now(),
      studentId:form.studentId,
      counselorId:form.counselorId,
      studentName:(students.find(s=>s.id===form.studentId)||{}).name||'',
      date:form.date,
      time:form.time,
      status:'upcoming',
      type:'video',
      anonymous:true,
      notes:''
    };
    try { await dataSource.createSession(newSession); } catch(e) { console.error('Failed to save session:', e); }
    setSessions(p=>[...p,newSession]);
    setSuccess(true);
    setTimeout(()=>{setSuccess(false);setForm({studentId:'',counselorId:'',date:'',time:''});},2000);
  };

  return (
    <div className="animate-fade" style={{maxWidth:600}}>
      <div className="page-header">
        <div className="page-title">Schedule Session</div>
        <div className="page-subtitle">Create a new counseling session</div>
      </div>
      <div className="card">
        {success?(
          <div style={{textAlign:'center',padding:'40px'}}>
            <div style={{fontSize:48,marginBottom:16}}>✅</div>
            <div style={{fontSize:18,fontWeight:700,marginBottom:8}}>Session Scheduled!</div>
            <div style={{color:'#6b7280'}}>The student and counselor have been notified.</div>
          </div>
        ):(
          <form onSubmit={handleSchedule}>
            <div className="form-group">
              <label className="label">Student *</label>
              <select className="select" required value={form.studentId} onChange={e=>setForm({...form,studentId:e.target.value})}>
                <option value="">Select a student...</option>
                {students.map(s=><option key={s.id} value={s.id}>{s.name}</option>)}
              </select>
            </div>
            <div className="form-group">
              <label className="label">Counselor *</label>
              <select className="select" required value={form.counselorId} onChange={e=>setForm({...form,counselorId:e.target.value})}>
                <option value="">Select a counselor...</option>
                {counselors.map(c=><option key={c.id} value={c.id}>{c.name}</option>)}
              </select>
            </div>
            <div className="form-group">
              <label className="label">Date *</label>
              <input type="date" className="input" required value={form.date} onChange={e=>setForm({...form,date:e.target.value})} />
            </div>
            <div className="form-group">
              <label className="label">Time *</label>
              <input type="time" className="input" required value={form.time} onChange={e=>setForm({...form,time:e.target.value})} />
            </div>
            <button className="btn btn-primary" type="submit" style={{width:'100%',justifyContent:'center'}}><i className="fas fa-calendar-plus"/>Schedule Session</button>
          </form>
        )}
      </div>
    </div>
  );
}
