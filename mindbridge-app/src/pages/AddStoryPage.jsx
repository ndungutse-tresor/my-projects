import React, { useState } from 'react';
import { dataSource } from '../lib/dataSource';

export default function AddStoryPage({ user, stories, setStories }) {
  const [form, setForm] = useState({ title:'', excerpt:'', content:'', category:'Anxiety', tagInput:'', tags:[] });
  const [success, setSuccess] = useState(false);

  const addTag = () => {
    if(form.tagInput.trim()&&!form.tags.includes(form.tagInput.trim())) {
      setForm({...form,tags:[...form.tags,form.tagInput.trim()],tagInput:''});
    }
  };

  const submit = async (e) => {
    e.preventDefault();
    const colors=['#5b6cf9','#8b5cf6','#14b8a6','#f59e0b','#f43f5e','#38c88c'];
    const newStory={
      id:'s'+Date.now(), title:form.title, author:user.role==='peer'?user.name+' (Peer Supporter)':'Anonymous Student',
      authorColor:colors[Math.floor(Math.random()*colors.length)], tags:form.tags, excerpt:form.excerpt,
      content:form.content, likes:0, views:0, date:new Date().toISOString().split('T')[0], category:form.category
    };
    try {
      await dataSource.createStory(newStory);
    } catch (err) {
      console.error('Failed to save story:', err);
    }
    setStories(prev=>[newStory,...prev]);
    setSuccess(true);
    setTimeout(()=>{ setSuccess(false); setForm({title:'',excerpt:'',content:'',category:'Anxiety',tagInput:'',tags:[]}); },3000);
  };

  return (
    <div className="animate-fade" style={{maxWidth:700}}>
      <div className="page-header"><div className="page-title">Share Your Story</div><div className="page-subtitle">Help others by sharing your healing journey</div></div>
      {success?(<div className="card" style={{textAlign:'center',padding:'48px'}}><div style={{fontSize:48,marginBottom:16}}>🌟</div><h3 style={{fontSize:20,fontWeight:700,marginBottom:8}}>Story Submitted!</h3><p style={{color:'#6b7280'}}>Your story will be reviewed and published to the library. Thank you for your courage.</p></div>):(
      <div className="card">
        <div className="alert alert-info" style={{marginBottom:20}}><i className="fas fa-user-secret"/><div>Your story will be published anonymously by default unless you choose to use your name.</div></div>
        <form onSubmit={submit}>
          <div className="form-group"><label className="label">Story Title *</label><input className="input" required value={form.title} onChange={e=>setForm({...form,title:e.target.value})} placeholder="Give your story a meaningful title..." /></div>
          <div className="form-group"><label className="label">Category *</label>
            <select className="select" value={form.category} onChange={e=>setForm({...form,category:e.target.value})}>
              <option>Anxiety</option><option>Depression</option><option>Grief &amp; Loss</option><option>Self-Worth</option><option>Academic Stress</option><option>Other</option>
            </select>
          </div>
          <div className="form-group"><label className="label">Short Excerpt (2-3 sentences) *</label><textarea className="input" rows={3} required value={form.excerpt} onChange={e=>setForm({...form,excerpt:e.target.value})} placeholder="A brief teaser for your story..." /></div>
          <div className="form-group"><label className="label">Full Story *</label><textarea className="input" rows={10} required value={form.content} onChange={e=>setForm({...form,content:e.target.value})} placeholder="Share your full journey — where you started, what helped, where you are now..." /></div>
          <div className="form-group"><label className="label">Tags</label>
            <div style={{display:'flex',gap:8,marginBottom:8}}>
              <input className="input" placeholder="Add a tag..." value={form.tagInput} onChange={e=>setForm({...form,tagInput:e.target.value})} onKeyDown={e=>e.key==='Enter'&&(e.preventDefault(),addTag())} style={{flex:1}} />
              <button type="button" className="btn btn-outline btn-sm" onClick={addTag}><i className="fas fa-plus"/></button>
            </div>
            {form.tags.map(t=><span key={t} className="tag" style={{cursor:'pointer'}} onClick={()=>setForm({...form,tags:form.tags.filter(x=>x!==t)})}>{t} ×</span>)}
          </div>
          <button className="btn btn-primary" type="submit" style={{width:'100%',justifyContent:'center'}}><i className="fas fa-paper-plane"/>Publish Story</button>
        </form>
      </div>
      )}
    </div>
  );
}
