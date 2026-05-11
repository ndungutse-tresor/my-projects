import React, { useState } from 'react';
import Modal from '../components/Modal';
import Avatar from '../components/Avatar';

export default function StoriesPage({ user, stories, setStories, users = [], setMessages }) {
  const [selected, setSelected] = useState(null);
  const [filter, setFilter] = useState('All');
  const [likedIds, setLikedIds] = useState([]);
  const [showShare, setShowShare] = useState(false);
  const [shareStory, setShareStory] = useState(null);
  const [shareNote, setShareNote] = useState('');
  const [shareSent, setShareSent] = useState(false);
  const [selectedFriends, setSelectedFriends] = useState([]);

  const categories = ['All','Anxiety','Depression','Grief & Loss','Self-Worth'];
  const filtered = filter==='All'?stories:stories.filter(s=>s.category===filter||s.tags.includes(filter));
  const isAuthorized = user.enrolled||user.role==='peer'||user.role==='counselor'||user.role==='admin';

  const enrolledFriends = users.filter(u =>
    u.id !== user.id && u.enrolled && (u.role === 'student' || u.role === 'peer')
  );

  const openShare = (story, e) => {
    e && e.stopPropagation();
    setShareStory(story);
    setSelectedFriends([]);
    setShareNote('');
    setShowShare(true);
  };

  const toggleFriend = (id) =>
    setSelectedFriends(p => p.includes(id) ? p.filter(x => x !== id) : [...p, id]);

  const sendShare = () => {
    if (!selectedFriends.length || !shareStory) return;
    const time = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    const msgs = selectedFriends.map(fid => ({
      id: 'msg' + Date.now() + fid,
      from: user.id,
      to: fid,
      text: `📖 I thought you might find this story helpful: "${shareStory.title}"${shareNote ? `\n\n${shareNote}` : ''}`,
      time,
      date: 'Today',
    }));
    if (setMessages) setMessages(p => [...p, ...msgs]);
    setShowShare(false);
    setShareSent(true);
    setTimeout(() => setShareSent(false), 4000);
  };

  if (!isAuthorized) return (
    <div className="animate-fade">
      <div className="page-header"><div className="page-title">Healed Stories</div><div className="page-subtitle">Recovery journeys shared by students who've walked this path</div></div>
      <div className="card" style={{textAlign:'center',padding:'60px 40px'}}>
        <div style={{fontSize:48,marginBottom:20}}>🔒</div>
        <h3 style={{fontSize:20,fontWeight:700,marginBottom:12}}>Access Restricted</h3>
        <p style={{color:'#6b7280',maxWidth:480,margin:'0 auto 24px'}}>Healed Stories are only available to enrolled students. Please submit an enrollment application to access this library.</p>
        <div className="alert alert-info" style={{maxWidth:440,margin:'0 auto'}}>
          <i className="fas fa-info-circle" /> Your application is currently pending. You'll receive access once it's approved.
        </div>
      </div>
    </div>
  );

  if (selected) return (
    <div className="animate-fade">
      <button className="btn btn-outline btn-sm" onClick={()=>setSelected(null)} style={{marginBottom:20}}><i className="fas fa-arrow-left"/>Back to Stories</button>
      <div className="card" style={{maxWidth:760}}>
        <div style={{marginBottom:20}}>
          {selected.tags.map(t=><span key={t} className="tag">{t}</span>)}
        </div>
        <h2 style={{fontSize:22,fontWeight:800,lineHeight:1.4,marginBottom:16}}>{selected.title}</h2>
        <div style={{display:'flex',alignItems:'center',gap:10,marginBottom:24,paddingBottom:20,borderBottom:'1px solid #f3f4f6'}}>
          <div style={{width:36,height:36,borderRadius:'50%',background:selected.authorColor,display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontWeight:700,fontSize:14}}>A</div>
          <div><div style={{fontSize:14,fontWeight:600}}>{selected.author}</div><div style={{fontSize:12,color:'#9ca3af'}}>{selected.date}</div></div>
          <div style={{marginLeft:'auto',display:'flex',gap:16,color:'#9ca3af',fontSize:13}}>
            <span><i className="fas fa-heart" style={{color:'#f43f5e'}} /> {selected.likes+(likedIds.includes(selected.id)?1:0)}</span>
            <span><i className="fas fa-eye" /> {selected.views}</span>
          </div>
        </div>
        {selected.content.split('\n\n').map((p,i)=>(
          <p key={i} style={{fontSize:15,lineHeight:1.85,color:'#374151',marginBottom:20}}>{p}</p>
        ))}
        <div style={{display:'flex',gap:12,marginTop:24}}>
          <button className={`btn ${likedIds.includes(selected.id)?'btn-danger':'btn-outline'} btn-sm`} onClick={()=>setLikedIds(p=>p.includes(selected.id)?p.filter(x=>x!==selected.id):[...p,selected.id])}>
            <i className="fas fa-heart"/>{likedIds.includes(selected.id)?'Liked':'Like this story'}
          </button>
          {(user.enrolled||user.role==='peer') && (
            <button className="btn btn-outline btn-sm" onClick={()=>openShare(selected)}>
              <i className="fas fa-share-nodes"/>Share with a Friend
            </button>
          )}
        </div>
      </div>

      <Modal show={showShare} onClose={()=>setShowShare(false)} title="Share this Story">
        <div style={{padding:'20px',display:'flex',flexDirection:'column',gap:16}}>
          <div style={{background:'#f9fafb',borderRadius:10,padding:'12px 14px',fontSize:13,color:'#374151',borderLeft:'3px solid #5b6cf9'}}>
            <strong>Story:</strong> {shareStory?.title}
          </div>
          <div>
            <div style={{fontSize:13,fontWeight:600,color:'#374151',marginBottom:8}}>Select enrolled friends to share with:</div>
            {enrolledFriends.length === 0 ? (
              <div style={{color:'#9ca3af',fontSize:13,textAlign:'center',padding:'16px'}}>No enrolled friends found.</div>
            ) : (
              <div style={{display:'flex',flexDirection:'column',gap:8,maxHeight:200,overflowY:'auto'}}>
                {enrolledFriends.map(f=>(
                  <label key={f.id} style={{display:'flex',alignItems:'center',gap:12,padding:'10px 12px',borderRadius:8,cursor:'pointer',background:selectedFriends.includes(f.id)?'#eef0ff':'#f9fafb',border:`1.5px solid ${selectedFriends.includes(f.id)?'#5b6cf9':'#e5e7eb'}`,transition:'all .15s'}}>
                    <input type="checkbox" checked={selectedFriends.includes(f.id)} onChange={()=>toggleFriend(f.id)} style={{accentColor:'#5b6cf9'}} />
                    <Avatar name={f.name} color={f.color} size={32} />
                    <div>
                      <div style={{fontSize:14,fontWeight:600,color:'#1f2937'}}>{f.name}</div>
                      <div style={{fontSize:11,color:'#9ca3af'}}>{f.role==='peer'?'Peer Supporter':'Student'}</div>
                    </div>
                  </label>
                ))}
              </div>
            )}
          </div>
          <div>
            <label style={{fontSize:13,fontWeight:600,color:'#374151',display:'block',marginBottom:6}}>Add a personal note (optional)</label>
            <textarea className="input" rows={2} placeholder="e.g. This helped me a lot, hope it helps you too..."
              value={shareNote} onChange={e=>setShareNote(e.target.value)} style={{resize:'vertical'}} />
          </div>
          <div style={{display:'flex',gap:10,justifyContent:'flex-end'}}>
            <button className="btn btn-outline" onClick={()=>setShowShare(false)}>Cancel</button>
            <button className="btn btn-primary" disabled={!selectedFriends.length} onClick={sendShare}>
              <i className="fas fa-paper-plane"/>Send to {selectedFriends.length||''} {selectedFriends.length===1?'Friend':'Friends'}
            </button>
          </div>
        </div>
      </Modal>

      {shareSent && (
        <div style={{position:'fixed',bottom:24,right:24,background:'#5b6cf9',color:'#fff',padding:'14px 20px',borderRadius:12,fontWeight:600,fontSize:15,boxShadow:'0 4px 16px rgba(0,0,0,.15)',zIndex:999,display:'flex',gap:10,alignItems:'center'}}>
          <i className="fas fa-check-circle"/> Story shared successfully!
        </div>
      )}
    </div>
  );

  return (
    <div className="animate-fade">
      <div className="page-header">
        <div className="page-title">Healed Stories</div>
        <div className="page-subtitle">Real journeys of recovery — shared with hope, read in confidence</div>
      </div>
      <div className="alert alert-success" style={{marginBottom:20}}>
        <i className="fas fa-shield-alt"/>
        <div><strong>Confidential access.</strong> These stories are only visible to enrolled members of MindBridge. All authors chose to share anonymously.</div>
      </div>
      <div style={{display:'flex',gap:8,marginBottom:24,flexWrap:'wrap'}}>
        {categories.map(c=>(
          <button key={c} className={`btn btn-sm ${filter===c?'btn-primary':'btn-outline'}`} onClick={()=>setFilter(c)}>{c}</button>
        ))}
      </div>
      <div className="grid-2">
        {filtered.map(story=>(
          <div key={story.id} className="story-card" onClick={()=>setSelected(story)}>
            <div style={{marginBottom:12}}>{story.tags.map(t=><span key={t} className="tag">{t}</span>)}</div>
            <h3 style={{fontSize:16,fontWeight:700,lineHeight:1.45,marginBottom:10,color:'#1f2937'}}>{story.title}</h3>
            <p style={{fontSize:13,color:'#6b7280',lineHeight:1.7,marginBottom:16}}>{story.excerpt}</p>
            <div style={{display:'flex',alignItems:'center',gap:8}}>
              <div style={{width:28,height:28,borderRadius:'50%',background:story.authorColor,display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontSize:12,fontWeight:700}}>A</div>
              <span style={{fontSize:13,color:'#6b7280',flex:1}}>{story.author}</span>
              <span style={{fontSize:12,color:'#9ca3af'}}><i className="fas fa-heart" style={{color:'#f43f5e'}}/> {story.likes}</span>
              <span style={{fontSize:12,color:'#9ca3af',marginLeft:8}}><i className="fas fa-eye"/> {story.views}</span>
              {(user.enrolled||user.role==='peer') && (
                <button className="btn btn-outline btn-sm" style={{marginLeft:8,padding:'4px 10px',fontSize:12}} onClick={e=>openShare(story,e)}>
                  <i className="fas fa-share-nodes"/>Share
                </button>
              )}
            </div>
          </div>
        ))}
      </div>

      <Modal show={showShare} onClose={()=>setShowShare(false)} title="Share this Story">
        <div style={{padding:'20px',display:'flex',flexDirection:'column',gap:16}}>
          <div style={{background:'#f9fafb',borderRadius:10,padding:'12px 14px',fontSize:13,color:'#374151',borderLeft:'3px solid #5b6cf9'}}>
            <strong>Story:</strong> {shareStory?.title}
          </div>
          <div>
            <div style={{fontSize:13,fontWeight:600,color:'#374151',marginBottom:8}}>Select enrolled friends to share with:</div>
            {enrolledFriends.length === 0 ? (
              <div style={{color:'#9ca3af',fontSize:13,textAlign:'center',padding:'16px'}}>No enrolled friends found.</div>
            ) : (
              <div style={{display:'flex',flexDirection:'column',gap:8,maxHeight:200,overflowY:'auto'}}>
                {enrolledFriends.map(f=>(
                  <label key={f.id} style={{display:'flex',alignItems:'center',gap:12,padding:'10px 12px',borderRadius:8,cursor:'pointer',background:selectedFriends.includes(f.id)?'#eef0ff':'#f9fafb',border:`1.5px solid ${selectedFriends.includes(f.id)?'#5b6cf9':'#e5e7eb'}`,transition:'all .15s'}}>
                    <input type="checkbox" checked={selectedFriends.includes(f.id)} onChange={()=>toggleFriend(f.id)} style={{accentColor:'#5b6cf9'}} />
                    <Avatar name={f.name} color={f.color} size={32} />
                    <div>
                      <div style={{fontSize:14,fontWeight:600,color:'#1f2937'}}>{f.name}</div>
                      <div style={{fontSize:11,color:'#9ca3af'}}>{f.role==='peer'?'Peer Supporter':'Student'}</div>
                    </div>
                  </label>
                ))}
              </div>
            )}
          </div>
          <div>
            <label style={{fontSize:13,fontWeight:600,color:'#374151',display:'block',marginBottom:6}}>Add a personal note (optional)</label>
            <textarea className="input" rows={2} placeholder="e.g. This helped me a lot, hope it helps you too..."
              value={shareNote} onChange={e=>setShareNote(e.target.value)} style={{resize:'vertical'}} />
          </div>
          <div style={{display:'flex',gap:10,justifyContent:'flex-end'}}>
            <button className="btn btn-outline" onClick={()=>setShowShare(false)}>Cancel</button>
            <button className="btn btn-primary" disabled={!selectedFriends.length} onClick={sendShare}>
              <i className="fas fa-paper-plane"/>Send to {selectedFriends.length||''} {selectedFriends.length===1?'Friend':'Friends'}
            </button>
          </div>
        </div>
      </Modal>

      {shareSent && (
        <div style={{position:'fixed',bottom:24,right:24,background:'#5b6cf9',color:'#fff',padding:'14px 20px',borderRadius:12,fontWeight:600,fontSize:15,boxShadow:'0 4px 16px rgba(0,0,0,.15)',zIndex:999,display:'flex',gap:10,alignItems:'center'}}>
          <i className="fas fa-check-circle"/> Story shared successfully!
        </div>
      )}
    </div>
  );
}
