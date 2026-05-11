import React from 'react';

export default function EnrollmentPage({ user }) {
  const steps = [
    { label:'Create Account', done:true },
    { label:'Submit Application', done:true },
    { label:'Admin Review', done:user.enrolled },
    { label:'Access Granted', done:user.enrolled },
  ];
  return (
    <div className="animate-fade" style={{maxWidth:640}}>
      <div className="page-header"><div className="page-title">My Enrollment</div><div className="page-subtitle">Track your MindBridge enrollment status</div></div>
      <div className="card">
        <div className="step-indicator">
          {steps.map((s,i)=>(
            <React.Fragment key={i}>
              <div className="step">
                <div className={`step-num ${s.done?'done':'active'}`}>{s.done?<i className="fas fa-check"/>:i+1}</div>
                <span style={{fontSize:13,fontWeight:500,color:s.done?'#059669':'#374151'}}>{s.label}</span>
              </div>
              {i<steps.length-1&&<div className={`step-line ${steps[i+1].done?'done':''}`} style={{flex:1}}/>}
            </React.Fragment>
          ))}
        </div>
        <div className="divider"/>
        <div style={{textAlign:'center',padding:'20px 0'}}>
          {user.enrolled?(
            <>
              <div style={{fontSize:48,marginBottom:16}}>🎉</div>
              <h3 style={{fontSize:20,fontWeight:700,color:'#059669',marginBottom:8}}>You're Enrolled!</h3>
              <p style={{color:'#6b7280'}}>You have full access to all MindBridge features including counseling sessions, healed stories, and messaging.</p>
              <div style={{marginTop:20,padding:'14px',background:'#f0fdf4',borderRadius:12,fontSize:14,color:'#166534'}}>
                <i className="fas fa-calendar-check"/> Enrolled since: <strong>{user.enrolledDate||'September 2025'}</strong>
              </div>
            </>
          ):(
            <>
              <div style={{fontSize:48,marginBottom:16}}>⏳</div>
              <h3 style={{fontSize:20,fontWeight:700,marginBottom:8}}>Application Under Review</h3>
              <p style={{color:'#6b7280'}}>Our admin team is reviewing your application. You'll receive an email notification within 24 hours.</p>
              <div className="alert alert-warning" style={{marginTop:20}}><i className="fas fa-clock"/>Average review time: <strong>4-12 hours</strong></div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
