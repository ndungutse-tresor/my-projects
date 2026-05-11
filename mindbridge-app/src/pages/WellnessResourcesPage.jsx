import React, { useState, useRef } from 'react';
import Modal from '../components/Modal';

export default function WellnessResourcesPage({ isAdminView, startModal, onClose, standalone }) {
  const [activeModal, setActiveModal] = useState(null);
  const [breathStep, setBreathStep] = useState(0);
  const [breathing, setBreathing] = useState(false);
  const [journal, setJournal] = useState('');
  const [savedJournal, setSavedJournal] = useState('');
  const [journalSuccess, setJournalSuccess] = useState(false);
  const timerRef = useRef(null);
  const breathSteps = [
    {label:'Inhale',duration:4,color:'#5b6cf9'},
    {label:'Hold',duration:4,color:'#8b5cf6'},
    {label:'Exhale',duration:4,color:'#38c88c'}
  ];

  const startBreathing = () => {
    setBreathing(true);
    setBreathStep(0);
    let step = 0;
    const cycle = () => {
      const s = step % breathSteps.length;
      setBreathStep(s);
      timerRef.current = setTimeout(()=>{step++;cycle();},breathSteps[s].duration*1000);
    };
    cycle();
  };

  const stopBreathing = () => {
    setBreathing(false);
    if(timerRef.current) clearTimeout(timerRef.current);
  };

  const saveJournal = () => {
    setSavedJournal(journal);
    setJournalSuccess(true);
    setTimeout(()=>setJournalSuccess(false),2000);
  };

  const resources = [
    {icon:'🧘',title:'Guided Breathing',desc:'4-7-8 breathing technique for anxiety relief',color:'#5b6cf9'},
    {icon:'📔',title:'Mood Journal',desc:'Track your emotions and identify patterns',color:'#8b5cf6'},
    {icon:'📞',title:'Crisis Resources',desc:'24/7 hotline contacts for emergencies',color:'#f43f5e'},
    {icon:'📚',title:'Self-Help Library',desc:'Curated articles and books on mental health',color:'#38c88c'},
  ];

  if(standalone) return (
    <div style={{minHeight:'100vh',background:'#f0f4f8',padding:'32px'}}>
      <div style={{maxWidth:1000,margin:'0 auto'}}>
        <div className="page-header">
          <div className="page-title">Wellness Resources</div>
          <div className="page-subtitle">Tools and resources for your mental health</div>
        </div>
        <div className="grid-4">
          {resources.map((r,i)=>(
            <div key={i} className="card" style={{cursor:'pointer',background:'#fff',border:`2px solid ${r.color}33`}} onClick={()=>setActiveModal(i)}>
              <div style={{fontSize:32,marginBottom:12}}>{r.icon}</div>
              <div style={{fontWeight:700,fontSize:15,color:'#1f2937',marginBottom:6}}>{r.title}</div>
              <div style={{fontSize:13,color:'#6b7280'}}>{r.desc}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );

  return (
    <>
      <div className="animate-fade">
        <div className="page-header">
          <div className="page-title">Wellness Resources</div>
          <div className="page-subtitle">Tools and resources to support your mental health journey</div>
        </div>
        <div className="grid-4">
          {resources.map((r,i)=>(
            <div key={i} className="card" style={{cursor:'pointer'}} onClick={()=>setActiveModal(i)}>
              <div style={{fontSize:32,marginBottom:12}}>{r.icon}</div>
              <div style={{fontWeight:700,fontSize:15,color:'#1f2937',marginBottom:6}}>{r.title}</div>
              <div style={{fontSize:13,color:'#6b7280'}}>{r.desc}</div>
            </div>
          ))}
        </div>
      </div>

      <Modal show={activeModal===0} onClose={()=>setActiveModal(null)} title="Guided Breathing Exercise">
        <div style={{textAlign:'center',padding:'40px 20px'}}>
          {!breathing?(
            <>
              <div style={{marginBottom:20}}>
                <div style={{color:'#6b7280',marginBottom:20}}>The 4-7-8 breathing technique helps calm your nervous system. It takes about 2 minutes.</div>
                <button className="btn btn-primary" onClick={startBreathing} style={{width:'100%',justifyContent:'center'}}><i className="fas fa-play"/>Start Exercise</button>
              </div>
            </>
          ):(
            <>
              <div style={{fontSize:64,marginBottom:20,color:breathSteps[breathStep].color,animation:'pulse 1s infinite'}}>{breathSteps[breathStep].label}</div>
              <div style={{fontSize:24,fontWeight:700,marginBottom:20,color:breathSteps[breathStep].color}}>{breathSteps[breathStep].duration}</div>
              <button className="btn btn-danger" onClick={stopBreathing}><i className="fas fa-stop"/>Stop</button>
            </>
          )}
        </div>
      </Modal>

      <Modal show={activeModal===1} onClose={()=>setActiveModal(null)} title="Mood Journal" wide>
        <div>
          <div className="form-group">
            <label className="label">How are you feeling right now?</label>
            <textarea className="input" rows={8} value={journal} onChange={e=>setJournal(e.target.value)} placeholder="Write freely... your thoughts, feelings, and experiences are safe here." />
          </div>
          {journalSuccess&&<div className="alert alert-success"><i className="fas fa-check"/>Entry saved to your journal.</div>}
          <div style={{display:'flex',gap:10}}>
            <button className="btn btn-primary" onClick={saveJournal}><i className="fas fa-save"/>Save Entry</button>
            <button className="btn btn-outline" onClick={()=>setActiveModal(null)}>Close</button>
          </div>
          {savedJournal&&<div className="card" style={{marginTop:20,background:'#f0fdf4',borderLeft:'4px solid #38c88c'}}>
            <div style={{fontSize:12,fontWeight:600,color:'#6b7280',marginBottom:8}}>LAST ENTRY</div>
            <div style={{fontSize:14,color:'#374151'}}>{savedJournal}</div>
          </div>}
        </div>
      </Modal>

      <Modal show={activeModal===2} onClose={()=>setActiveModal(null)} title="Crisis Resources">
        <div className="alert alert-danger" style={{marginBottom:20}}>If you are in immediate danger, call emergency services (911 in the US) or go to your nearest emergency room.</div>
        <div style={{display:'flex',flexDirection:'column',gap:16}}>
          {[
            {name:'National Suicide Prevention Lifeline',number:'1-800-273-8255',desc:'Available 24/7, confidential, free'},
            {name:'Crisis Text Line',number:'Text HOME to 741741',desc:'Text-based support available 24/7'},
            {name:'International Association for Suicide Prevention',number:'https://www.iasp.info/resources/Crisis_Centres/',desc:'Global crisis resources'}
          ].map((r,i)=>(
            <div key={i} className="card" style={{background:'#fff9f5',borderLeft:'4px solid #f43f5e'}}>
              <div style={{fontWeight:700,fontSize:15,marginBottom:4}}>{r.name}</div>
              <div style={{fontSize:14,color:'#1f2937',marginBottom:4}}>{r.number}</div>
              <div style={{fontSize:12,color:'#6b7280'}}>{r.desc}</div>
            </div>
          ))}
        </div>
      </Modal>

      <Modal show={activeModal===3} onClose={()=>setActiveModal(null)} title="Mental Health Library">
        <div style={{display:'flex',flexDirection:'column',gap:12}}>
          {[
            {title:'The Anxiety and Phobia Workbook',author:'Edmund Bourne',type:'Book'},
            {title:'Emotional Intelligence',author:'Daniel Goleman',type:'Book'},
            {title:'The Noonday Demon',author:'Andrew Solomon',type:'Book'},
            {title:'Mindfulness for Beginners',author:'Jon Kabat-Zinn',type:'Course'},
            {title:'Understanding Depression',desc:'A comprehensive guide to causes and treatments',type:'Article'},
          ].map((r,i)=>(
            <div key={i} className="card">
              <div style={{display:'flex',alignItems:'flex-start',justifyContent:'space-between',gap:16}}>
                <div style={{flex:1}}>
                  <div style={{fontWeight:700,fontSize:15,marginBottom:2}}>{r.title}</div>
                  {r.author&&<div style={{fontSize:13,color:'#6b7280'}}>by {r.author}</div>}
                  {r.desc&&<div style={{fontSize:13,color:'#6b7280'}}>{r.desc}</div>}
                </div>
                <span style={{fontSize:11,fontWeight:600,background:'#eef0ff',color:'#5b6cf9',padding:'4px 12px',borderRadius:20,whiteSpace:'nowrap'}}>{r.type}</span>
              </div>
            </div>
          ))}
        </div>
      </Modal>
    </>
  );
}
