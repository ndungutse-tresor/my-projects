import React, { useState, useEffect, useRef } from 'react';
import Spinner from '../components/Spinner';
import SolidMindsClinicPage from './SolidMindsClinicPage';
import { dataSource } from '../lib/dataSource';

const MINDBRIDGE_CONTEXT = `You are Trezor, MindBridge's friendly AI assistant on the landing page. MindBridge is a university student mental health platform. Key facts:
- Students apply for support (free), get approved within 24h, then get full access
- All video counseling sessions are anonymous: face is blurred, voice is disguised
- Features: anonymous video sessions, private messaging with counselors, Healed Stories library, peer support network, wellness resources
- To get started: click "Apply for Support" or "Get Support" button
- Already have an account: click "Sign In"
- Enrollment is required to access counseling sessions and stories
- It's free, confidential, and only for university students
- Counselors are licensed mental health professionals
- Peer supporters are recovered students who volunteer

Answer the visitor's question warmly and concisely (2-3 sentences). If they seem distressed, express empathy first. Always guide them toward applying or signing in when appropriate.`;

async function getTrezorReply(messages) {
  const groqKey = import.meta.env.VITE_GROQ_API_KEY;
  if (groqKey) {
    try {
      const res = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${groqKey}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model: 'llama-3.1-8b-instant',
          max_tokens: 180,
          messages: [{ role: 'system', content: MINDBRIDGE_CONTEXT }, ...messages],
        }),
      });
      if (res.ok) {
        const data = await res.json();
        return data.choices[0].message.content.trim();
      }
    } catch {}
  }
  // Local fallback
  const last = messages[messages.length - 1]?.content?.toLowerCase() || '';
  if (last.includes('apply') || last.includes('join') || last.includes('start')) return 'Applying is easy and free! Click the "Apply for Support" button, fill in a short confidential form (3 minutes), and our team will respond within 24 hours.';
  if (last.includes('anon') || last.includes('privacy') || last.includes('identity')) return 'Your privacy is our top priority. In every video session your face is automatically blurred and your voice is disguised — your counselor never sees or hears the real you.';
  if (last.includes('cost') || last.includes('free') || last.includes('pay')) return 'MindBridge is completely free for enrolled university students. There are no fees for sessions, messaging, or any platform features.';
  if (last.includes('counsel') || last.includes('therapist') || last.includes('doctor')) return 'Our counselors are licensed mental health professionals. You can message them directly or book anonymous video sessions through the platform.';
  if (last.includes('sign in') || last.includes('login') || last.includes('account')) return 'If you already have an account, click "Sign In" in the top right. If you\'re new, start by applying for support — it only takes 3 minutes!';
  return "I'm here to help you learn about MindBridge! You can ask me anything about how the platform works, how to apply, or what support is available.";
}

function LandingChatbot({ onApply, onLogin }) {
  const [open, setOpen] = useState(false);
  const [messages, setMessages] = useState([
    { role: 'assistant', content: "Hi! I'm Trezor 👋 MindBridge's assistant. Ask me anything about the platform, or I can help guide you to get started." }
  ]);
  const [input, setInput] = useState('');
  const [typing, setTyping] = useState(false);
  const [unread, setUnread] = useState(1);
  const bottomRef = useRef(null);

  useEffect(() => { if (bottomRef.current) bottomRef.current.scrollIntoView({ behavior: 'smooth' }); }, [messages]);
  useEffect(() => { if (open) setUnread(0); }, [open]);

  const send = async () => {
    if (!input.trim() || typing) return;
    const userMsg = { role: 'user', content: input.trim() };
    setMessages(p => [...p, userMsg]);
    setInput('');
    setTyping(true);
    const reply = await getTrezorReply([...messages, userMsg]);
    setTyping(false);
    setMessages(p => [...p, { role: 'assistant', content: reply }]);
  };

  const quickActions = [
    { label: '🚀 How do I get started?', msg: 'How do I get started?' },
    { label: '🎭 Is it anonymous?', msg: 'Is it anonymous?' },
    { label: '💰 Is it free?', msg: 'Is it free?' },
    { label: '👨‍⚕️ Who are the counselors?', msg: 'Who are the counselors?' },
  ];

  return (
    <div style={{ position: 'fixed', bottom: 28, right: 28, zIndex: 9999, fontFamily: 'inherit' }}>
      {open && (
        <div style={{ width: 360, background: '#fff', borderRadius: 20, boxShadow: '0 8px 48px rgba(0,0,0,.18)', marginBottom: 16, display: 'flex', flexDirection: 'column', overflow: 'hidden', border: '1px solid #e5e7eb', maxHeight: 520 }}>
          {/* Header */}
          <div style={{ background: 'linear-gradient(135deg,#667eea,#764ba2)', padding: '16px 18px', display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ width: 40, height: 40, borderRadius: '50%', background: 'rgba(255,255,255,.2)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 20 }}>🤖</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: 700, fontSize: 15, color: '#fff' }}>Trezor — MindBridge Assistant</div>
              <div style={{ fontSize: 12, color: 'rgba(255,255,255,.75)', display: 'flex', alignItems: 'center', gap: 5 }}>
                <span style={{ width: 7, height: 7, borderRadius: '50%', background: '#38c88c', display: 'inline-block' }} /> Online now
              </div>
            </div>
            <button onClick={() => setOpen(false)} style={{ background: 'rgba(255,255,255,.15)', border: 'none', color: '#fff', borderRadius: 8, width: 30, height: 30, cursor: 'pointer', fontSize: 16, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>×</button>
          </div>

          {/* Messages */}
          <div style={{ flex: 1, overflowY: 'auto', padding: '16px', display: 'flex', flexDirection: 'column', gap: 10, maxHeight: 300 }}>
            {messages.map((m, i) => (
              <div key={i} style={{ display: 'flex', flexDirection: m.role === 'user' ? 'row-reverse' : 'row', gap: 8, alignItems: 'flex-end' }}>
                {m.role === 'assistant' && (
                  <div style={{ width: 28, height: 28, borderRadius: '50%', background: 'linear-gradient(135deg,#667eea,#764ba2)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 14, flexShrink: 0 }}>🤖</div>
                )}
                <div style={{ maxWidth: '78%', padding: '10px 14px', borderRadius: m.role === 'user' ? '16px 16px 4px 16px' : '16px 16px 16px 4px', background: m.role === 'user' ? 'linear-gradient(135deg,#667eea,#764ba2)' : '#f3f4f6', color: m.role === 'user' ? '#fff' : '#1f2937', fontSize: 13, lineHeight: 1.6 }}>
                  {m.content}
                </div>
              </div>
            ))}
            {typing && (
              <div style={{ display: 'flex', gap: 8, alignItems: 'flex-end' }}>
                <div style={{ width: 28, height: 28, borderRadius: '50%', background: 'linear-gradient(135deg,#667eea,#764ba2)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 14 }}>🤖</div>
                <div style={{ padding: '10px 14px', borderRadius: '16px 16px 16px 4px', background: '#f3f4f6', display: 'flex', gap: 4 }}>
                  {[0, .2, .4].map(d => <span key={d} style={{ width: 7, height: 7, borderRadius: '50%', background: '#9ca3af', animation: `bounce 1s infinite ${d}s`, display: 'inline-block' }} />)}
                </div>
              </div>
            )}
            <div ref={bottomRef} />
          </div>

          {/* Quick actions */}
          {messages.length <= 2 && (
            <div style={{ padding: '0 12px 10px', display: 'flex', flexWrap: 'wrap', gap: 6 }}>
              {quickActions.map(a => (
                <button key={a.label} onClick={() => { setInput(a.msg); }} style={{ fontSize: 11, padding: '5px 10px', borderRadius: 20, border: '1.5px solid #e5e7eb', background: '#f9fafb', cursor: 'pointer', color: '#374151', fontWeight: 500 }}>{a.label}</button>
              ))}
            </div>
          )}

          {/* CTA buttons */}
          <div style={{ padding: '8px 12px', display: 'flex', gap: 8 }}>
            <button onClick={onApply} style={{ flex: 1, padding: '8px', borderRadius: 10, border: 'none', background: 'linear-gradient(135deg,#667eea,#764ba2)', color: '#fff', fontSize: 12, fontWeight: 700, cursor: 'pointer' }}>Apply for Support</button>
            <button onClick={onLogin} style={{ flex: 1, padding: '8px', borderRadius: 10, border: '1.5px solid #e5e7eb', background: '#fff', color: '#374151', fontSize: 12, fontWeight: 700, cursor: 'pointer' }}>Sign In</button>
          </div>

          {/* Input */}
          <div style={{ padding: '10px 12px 14px', borderTop: '1px solid #f3f4f6', display: 'flex', gap: 8 }}>
            <input value={input} onChange={e => setInput(e.target.value)} onKeyDown={e => e.key === 'Enter' && send()}
              placeholder="Ask me anything..." style={{ flex: 1, padding: '9px 14px', borderRadius: 12, border: '1.5px solid #e5e7eb', fontSize: 13, outline: 'none', fontFamily: 'inherit' }} />
            <button onClick={send} disabled={!input.trim() || typing}
              style={{ width: 38, height: 38, borderRadius: 12, border: 'none', background: 'linear-gradient(135deg,#667eea,#764ba2)', color: '#fff', cursor: 'pointer', fontSize: 16, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              ➤
            </button>
          </div>
        </div>
      )}

      {/* Floating button */}
      <button onClick={() => setOpen(o => !o)} style={{ width: 60, height: 60, borderRadius: '50%', border: 'none', background: 'linear-gradient(135deg,#667eea,#764ba2)', color: '#fff', fontSize: 26, cursor: 'pointer', boxShadow: '0 4px 20px rgba(102,126,234,.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', position: 'relative', transition: 'transform .2s' }}
        onMouseEnter={e => e.currentTarget.style.transform = 'scale(1.1)'}
        onMouseLeave={e => e.currentTarget.style.transform = 'scale(1)'}>
        {open ? '×' : '💬'}
        {!open && unread > 0 && (
          <span style={{ position: 'absolute', top: 2, right: 2, width: 18, height: 18, borderRadius: '50%', background: '#f43f5e', fontSize: 10, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center', border: '2px solid #fff' }}>{unread}</span>
        )}
      </button>
    </div>
  );
}

export default function LandingPage({ onLogin, users, setUsers, applications, setApplications }) {
  const [mode, setMode] = useState('home');
  const [form, setForm] = useState({ email:'', password:'' });
  const [reg, setReg] = useState({ name:'', email:'', password:'', role:'student', studentId:'' });
  const [app, setApp] = useState({ name:'', email:'', studentId:'', issue:'', urgency:'medium' });
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const [logoClicks, setLogoClicks] = useState(0);
  const [showAdminAccess, setShowAdminAccess] = useState(false);
  
  useEffect(()=>{
    const fn=()=>setScrolled(window.scrollY>40);
    window.addEventListener('scroll',fn);
    return ()=>window.removeEventListener('scroll',fn);
  },[]);
  
  const handleLogoClick = () => {
    const newClicks = logoClicks + 1;
    setLogoClicks(newClicks);
    if (newClicks >= 5) {
      setShowAdminAccess(true);
      setLogoClicks(0);
    }
  };

  const handleLogin = (e) => {
    e.preventDefault(); setError(''); setLoading(true);
    setTimeout(()=>{
      const user = users.find(u=>u.email===form.email&&u.password===form.password);
      if (!user) { setError('Invalid email or password.'); setLoading(false); return; }
      onLogin(user); setLoading(false);
    },800);
  };

  const handleRegister = async (e) => {
    e.preventDefault(); setError(''); setLoading(true);
    if (users.find(u=>u.email===reg.email)) { setError('Email already registered.'); setLoading(false); return; }
    const colors = ['#5b6cf9','#8b5cf6','#14b8a6','#f59e0b','#f43f5e','#38c88c'];
    const newUser = {
      id:'u'+(Date.now()), name:reg.name, email:reg.email, password:reg.password,
      role:reg.role==='peer'?'peer':'student', enrolled:false, applicationStatus:'none',
      avatar:reg.name.split(' ').map(n=>n[0]).join('').slice(0,2).toUpperCase(),
      color:colors[Math.floor(Math.random()*colors.length)], online:true
    };
    try {
      await dataSource.createUser(newUser);
    } catch (err) {
      console.error('Failed to save user to database:', err);
    }
    setUsers(prev=>[...prev,newUser]);
    setLoading(false); setSuccess('Account created! You can now log in.');
    setTimeout(()=>{ setMode('login'); setSuccess(''); setForm({email:reg.email,password:''}); },1800);
  };

  const handleApply = async (e) => {
    e.preventDefault(); setError(''); setLoading(true);
    const existing = applications.find(a=>a.email===app.email);
    if (existing) { setError('An application with this email already exists.'); setLoading(false); return; }
    const newApp = { id:'a'+Date.now(), userId:null, name:app.name, email:app.email, studentId:app.studentId, issue:app.issue, urgency:app.urgency, date:new Date().toISOString().split('T')[0], status:'pending' };
    try {
      await dataSource.createApplication(newApp);
    } catch (err) {
      console.error('Failed to save application:', err);
    }
    setApplications(prev=>[...prev,newApp]);
    setLoading(false); setSuccess('Application submitted! You will receive an email once approved.');
    setApp({ name:'', email:'', studentId:'', issue:'', urgency:'medium' });
  };

  if (mode==='home') return (
    <div style={{minHeight:'100vh',background:'#fff',fontFamily:'inherit'}}>
      <nav style={{position:'fixed',top:0,left:0,right:0,zIndex:100,background:scrolled?'rgba(255,255,255,.97)':'transparent',backdropFilter:scrolled?'blur(12px)':'none',borderBottom:scrolled?'1px solid #e5e7eb':'none',padding:'0 40px',height:68,display:'flex',alignItems:'center',justifyContent:'space-between',transition:'all .3s'}}>
        <div style={{display:'flex',alignItems:'center',gap:10,cursor:'pointer'}} onClick={handleLogoClick}>
          <div style={{width:36,height:36,background:'linear-gradient(135deg,#667eea,#764ba2)',borderRadius:10,display:'flex',alignItems:'center',justifyContent:'center',fontSize:18}}>🧠</div>
          <span style={{fontWeight:800,fontSize:20,color:scrolled?'#1a202c':'#fff'}}>MindBridge</span>
        </div>
        <div style={{display:'flex',alignItems:'center',gap:28}}>
          {['About','Features','How It Works','Stories'].map(item=>(
            <a key={item} href={'#'+item.toLowerCase().replace(/ /g,'-')} style={{color:scrolled?'#4b5563':'rgba(255,255,255,.85)',fontSize:14,fontWeight:500,textDecoration:'none',transition:'color .2s'}}>{item}</a>
          ))}
        </div>
        <div style={{display:'flex',gap:10}}>
          {showAdminAccess && (
            <button className="btn btn-sm" style={{background:'rgba(139,92,246,.2)',color:scrolled?'#764ba2':'rgba(255,255,255,.9)',border:scrolled?'2px solid #764ba2':'1px solid rgba(255,255,255,.3)',fontSize:12}} onClick={()=>setMode('solid-minds')}>🔐 Clinic Info</button>
          )}
          <button className="btn btn-sm" style={{background:scrolled?'transparent':'rgba(255,255,255,.15)',color:scrolled?'#5b6cf9':'#fff',border:scrolled?'2px solid #5b6cf9':''}} onClick={()=>setMode('login')}>Sign In</button>
          <button className="btn btn-sm" style={{background:'linear-gradient(135deg,#667eea,#764ba2)',color:'#fff',border:'none'}} onClick={()=>setMode('apply')}>Get Support</button>
        </div>
      </nav>

      <section style={{minHeight:'100vh',background:'linear-gradient(135deg,#667eea 0%,#764ba2 100%)',display:'flex',alignItems:'center',justifyContent:'center',padding:'80px 40px 60px',position:'relative',overflow:'hidden'}}>
        <div style={{position:'absolute',top:'10%',left:'5%',width:300,height:300,background:'rgba(255,255,255,.04)',borderRadius:'50%'}}/>
        <div style={{position:'absolute',bottom:'15%',right:'8%',width:200,height:200,background:'rgba(255,255,255,.06)',borderRadius:'50%'}}/>
        <div style={{maxWidth:760,textAlign:'center',color:'#fff',position:'relative',zIndex:1}}>
          <div style={{display:'inline-flex',alignItems:'center',gap:8,background:'rgba(255,255,255,.15)',borderRadius:20,padding:'6px 16px',marginBottom:24,fontSize:13,fontWeight:600}}>
            <span style={{width:8,height:8,borderRadius:'50%',background:'#38c88c',display:'inline-block'}}/>
            Safe · Confidential · Anonymous
          </div>
          <h1 style={{fontSize:56,fontWeight:900,lineHeight:1.15,marginBottom:20}}>Your mental health<br/>matters here.</h1>
          <p style={{fontSize:19,opacity:.88,lineHeight:1.7,marginBottom:36,maxWidth:580,margin:'0 auto 36px'}}>MindBridge connects university students with professional counselors through anonymous, face-hidden video sessions — so you can get help without fear of being recognized.</p>
          <div style={{display:'flex',gap:14,justifyContent:'center',flexWrap:'wrap',marginBottom:48}}>
            <button style={{padding:'14px 32px',borderRadius:12,border:'none',fontSize:16,fontWeight:700,background:'#fff',color:'#5b6cf9',cursor:'pointer',transition:'all .2s'}} onClick={()=>setMode('apply')}>Apply for Support</button>
            <button style={{padding:'14px 32px',borderRadius:12,border:'2px solid rgba(255,255,255,.6)',fontSize:16,fontWeight:700,background:'transparent',color:'#fff',cursor:'pointer'}} onClick={()=>setMode('login')}>Sign In to Platform</button>
          </div>
          <div style={{display:'flex',justifyContent:'center',gap:48,opacity:.8}}>
            {[['200+','Students Helped'],['98%','Privacy Protected'],['24h','Response Time'],['4.9★','Counselor Rating']].map(([v,l])=>(
              <div key={l} style={{textAlign:'center'}}>
                <div style={{fontSize:24,fontWeight:800}}>{v}</div>
                <div style={{fontSize:12,opacity:.8,marginTop:2}}>{l}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section id="features" style={{padding:'80px 40px',background:'#f8fafc'}}>
        <div style={{maxWidth:1100,margin:'0 auto'}}>
          <div style={{textAlign:'center',marginBottom:56}}>
            <div style={{fontSize:13,fontWeight:700,color:'#5b6cf9',textTransform:'uppercase',letterSpacing:'.1em',marginBottom:10}}>Why MindBridge</div>
            <h2 style={{fontSize:38,fontWeight:800,color:'#1a202c',marginBottom:14}}>Built for students, by people who care</h2>
            <p style={{fontSize:17,color:'#6b7280',maxWidth:540,margin:'0 auto'}}>Every feature is designed around one principle: you should be able to get help without risking your identity or reputation.</p>
          </div>
          <div style={{display:'grid',gridTemplateColumns:'repeat(3,1fr)',gap:28}}>
            {[
              {icon:'🎭',title:'Anonymous Video Counseling',desc:'Your face is automatically blurred and voice pitch-shifted in every video session. Your counselor sees and hears an anonymous version of you — full privacy, real connection.',color:'#eef0ff',accent:'#5b6cf9'},
              {icon:'📖',title:'Healed Stories Library',desc:'Read real recovery journeys shared by students just like you. Access is gated — only enrolled members can read these stories, protecting both readers and authors.',color:'#f0fdf4',accent:'#38c88c'},
              {icon:'💬',title:'Secure Private Messaging',desc:'Message your counselor or peer supporter directly. All conversations are encrypted and visible only to you and your support team.',color:'#f3effe',accent:'#8b5cf6'},
              {icon:'🛡️',title:'Enrollment Gatekeeping',desc:'Every student must apply and be approved before gaining full access. This ensures a safe, verified community of people who are genuinely seeking support.',color:'#fff1f3',accent:'#f43f5e'},
              {icon:'👥',title:'Peer Support Network',desc:'Connect with recovered students who volunteer as peer supporters. Sometimes the most powerful thing is hearing "I went through this too, and I made it."',color:'#fffbeb',accent:'#f59e0b'},
              {icon:'🧘',title:'Wellness Resources',desc:'Access guided breathing exercises, a personal mood journal, crisis hotline contacts, and a curated self-help library — available anytime, on demand.',color:'#e6faf8',accent:'#14b8a6'},
            ].map((f,i)=>(
              <div key={i} style={{background:'#fff',borderRadius:18,padding:'28px',boxShadow:'0 2px 16px rgba(0,0,0,.06)',borderTop:`3px solid ${f.accent}`}}>
                <div style={{width:52,height:52,background:f.color,borderRadius:14,display:'flex',alignItems:'center',justifyContent:'center',fontSize:26,marginBottom:18}}>{f.icon}</div>
                <div style={{fontWeight:700,fontSize:17,marginBottom:10,color:'#1a202c'}}>{f.title}</div>
                <div style={{fontSize:14,color:'#6b7280',lineHeight:1.7}}>{f.desc}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section id="how-it-works" style={{padding:'80px 40px',background:'#fff'}}>
        <div style={{maxWidth:900,margin:'0 auto'}}>
          <div style={{textAlign:'center',marginBottom:56}}>
            <div style={{fontSize:13,fontWeight:700,color:'#5b6cf9',textTransform:'uppercase',letterSpacing:'.1em',marginBottom:10}}>Process</div>
            <h2 style={{fontSize:38,fontWeight:800,color:'#1a202c'}}>Getting help in 3 simple steps</h2>
          </div>
          <div style={{display:'grid',gridTemplateColumns:'repeat(3,1fr)',gap:40,position:'relative'}}>
            {[
              {step:'01',icon:'📝',title:'Apply for Support',desc:"Fill out a short, confidential application describing what you're going through. Takes 3 minutes."},
              {step:'02',icon:'✅',title:'Get Approved',desc:'Our admin team reviews applications within 24 hours and grants you full platform access.'},
              {step:'03',icon:'🎭',title:'Start Your Journey',desc:'Book anonymous video sessions, read healing stories, and message your counselor — all in one place.'},
            ].map((s,i)=>(
              <div key={i} style={{textAlign:'center',padding:'32px 24px',borderRadius:18,background:'#f8fafc',position:'relative'}}>
                <div style={{position:'absolute',top:-16,left:'50%',transform:'translateX(-50%)',width:36,height:36,background:'linear-gradient(135deg,#667eea,#764ba2)',borderRadius:'50%',display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontSize:12,fontWeight:800}}>{s.step}</div>
                <div style={{fontSize:40,marginBottom:16,marginTop:8}}>{s.icon}</div>
                <div style={{fontWeight:700,fontSize:18,marginBottom:10,color:'#1a202c'}}>{s.title}</div>
                <div style={{fontSize:14,color:'#6b7280',lineHeight:1.7}}>{s.desc}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section id="about" style={{padding:'80px 40px',background:'linear-gradient(135deg,#f8fafc,#eef0ff)'}}>
        <div style={{maxWidth:900,margin:'0 auto',display:'grid',gridTemplateColumns:'1fr 1fr',gap:60,alignItems:'center'}}>
          <div>
            <div style={{fontSize:13,fontWeight:700,color:'#5b6cf9',textTransform:'uppercase',letterSpacing:'.1em',marginBottom:10}}>About</div>
            <h2 style={{fontSize:34,fontWeight:800,color:'#1a202c',marginBottom:18,lineHeight:1.25}}>Mental health support that respects your privacy</h2>
            <p style={{fontSize:15,color:'#4b5563',lineHeight:1.8,marginBottom:20}}>University life is challenging. MindBridge was created to ensure that no student has to face anxiety, depression, grief, or any other mental health struggle alone — especially when the fear of being seen or judged can be a barrier to getting help.</p>
            <p style={{fontSize:15,color:'#4b5563',lineHeight:1.8,marginBottom:28}}>Our platform is the only student mental health service that blurs your face and disguises your voice in video counseling by default, giving you the freedom to be fully honest.</p>
            <button style={{padding:'12px 28px',borderRadius:12,border:'none',fontSize:15,fontWeight:700,background:'linear-gradient(135deg,#667eea,#764ba2)',color:'#fff',cursor:'pointer'}} onClick={()=>setMode('apply')}>Start Your Application</button>
          </div>
          <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:16}}>
            {[
              {icon:'🎓',label:'University Students',val:'Only verified students can enroll'},
              {icon:'🔒',label:'Zero Identity Risk',val:'Anonymous by default in all sessions'},
              {icon:'👨‍⚕️',label:'Trained Counselors',val:'Licensed mental health professionals'},
              {icon:'💚',label:'Peer Community',val:'Recovered students volunteer to help'},
            ].map((c,i)=>(
              <div key={i} style={{background:'#fff',borderRadius:14,padding:'20px',boxShadow:'0 2px 10px rgba(0,0,0,.06)'}}>
                <div style={{fontSize:28,marginBottom:8}}>{c.icon}</div>
                <div style={{fontWeight:700,fontSize:14,color:'#1a202c',marginBottom:4}}>{c.label}</div>
                <div style={{fontSize:12,color:'#6b7280'}}>{c.val}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section id="stories" style={{padding:'80px 40px',background:'#fff'}}>
        <div style={{maxWidth:1000,margin:'0 auto'}}>
          <div style={{textAlign:'center',marginBottom:48}}>
            <div style={{fontSize:13,fontWeight:700,color:'#5b6cf9',textTransform:'uppercase',letterSpacing:'.1em',marginBottom:10}}>Community</div>
            <h2 style={{fontSize:38,fontWeight:800,color:'#1a202c',marginBottom:12}}>Stories of healing</h2>
            <p style={{color:'#6b7280',fontSize:16}}>Full access to the story library is available after enrollment. Here is a preview.</p>
          </div>
          <div style={{display:'grid',gridTemplateColumns:'repeat(2,1fr)',gap:24,marginBottom:36}}>
            {[
              {title:'How I overcame exam anxiety and found my rhythm',tags:['Anxiety','Mindfulness'],excerpt:'I was failing two courses and barely sleeping. I thought it was over. But through counseling sessions and breathing exercises, I found a way back...',color:'#5b6cf9'},
              {title:'Learning to ask for help changed my life',tags:['Peer Support','Self-Worth'],excerpt:'Growing up, asking for help felt like admitting defeat. Until the day I realized that strength and vulnerability are not opposites...',color:'#38c88c'},
            ].map((s,i)=>(
              <div key={i} style={{background:'#f8fafc',borderRadius:16,padding:'24px',borderLeft:`4px solid ${s.color}`}}>
                <div style={{marginBottom:10}}>{s.tags.map(t=><span key={t} style={{background:'#eef0ff',color:'#5b6cf9',padding:'2px 10px',borderRadius:20,fontSize:11,fontWeight:600,marginRight:6}}>{t}</span>)}</div>
                <div style={{fontWeight:700,fontSize:15,marginBottom:10,color:'#1a202c',lineHeight:1.4}}>{s.title}</div>
                <div style={{fontSize:13,color:'#6b7280',lineHeight:1.7}}>{s.excerpt}</div>
                <div style={{marginTop:14,fontSize:13,color:'#9ca3af'}}>🔒 Full story available after enrollment</div>
              </div>
            ))}
          </div>
          <div style={{textAlign:'center'}}>
            <button style={{padding:'12px 32px',borderRadius:12,border:'2px solid #5b6cf9',fontSize:15,fontWeight:700,background:'transparent',color:'#5b6cf9',cursor:'pointer'}} onClick={()=>setMode('apply')}>Apply to Read All Stories</button>
          </div>
        </div>
      </section>

      <section style={{padding:'80px 40px',background:'linear-gradient(135deg,#667eea 0%,#764ba2 100%)',textAlign:'center',color:'#fff'}}>
        <h2 style={{fontSize:38,fontWeight:800,marginBottom:16}}>Ready to take the first step?</h2>
        <p style={{fontSize:17,opacity:.85,marginBottom:36,maxWidth:480,margin:'0 auto 36px'}}>Applying takes 3 minutes. Your application is completely confidential. Our team will respond within 24 hours.</p>
        <div style={{display:'flex',gap:14,justifyContent:'center',flexWrap:'wrap'}}>
          <button style={{padding:'14px 32px',borderRadius:12,border:'none',fontSize:16,fontWeight:700,background:'#fff',color:'#5b6cf9',cursor:'pointer'}} onClick={()=>setMode('apply')}>Apply for Support</button>
          <button style={{padding:'14px 32px',borderRadius:12,border:'2px solid rgba(255,255,255,.6)',fontSize:16,fontWeight:700,background:'transparent',color:'#fff',cursor:'pointer'}} onClick={()=>setMode('login')}>Sign In</button>
        </div>
        <div style={{marginTop:28,fontSize:13,opacity:.7}}>
          Already registered? Sign in · Need to register? Create an account · <span style={{textDecoration:'underline',cursor:'pointer'}} onClick={()=>setMode('register')}>Register here</span>
        </div>
        <div style={{marginTop:24,padding:'12px 20px',background:'rgba(255,255,255,.12)',borderRadius:12,fontSize:12,display:'inline-block',opacity:.85}}>
          <strong>Demo:</strong> tresor@stud.ur.ac.rw / student123 &nbsp;·&nbsp; admin@mindbridge.edu / admin123 &nbsp;·&nbsp; amara@mindbridge.edu / counselor123
        </div>
      </section>

      <footer style={{background:'#1a202c',color:'rgba(255,255,255,.6)',padding:'32px 40px',display:'flex',justifyContent:'space-between',alignItems:'center',fontSize:13}}>
        <div style={{display:'flex',alignItems:'center',gap:10}}>
          <div style={{width:28,height:28,background:'linear-gradient(135deg,#667eea,#764ba2)',borderRadius:8,display:'flex',alignItems:'center',justifyContent:'center',fontSize:14}}>🧠</div>
          <span style={{color:'#fff',fontWeight:700}}>MindBridge</span>
          <span>— Student Mental Health Support</span>
        </div>
        <div>All sessions are anonymous. All data is confidential.</div>
        <div style={{display:'flex',gap:16}}>
          <span style={{cursor:'pointer'}} onClick={()=>setMode('login')}>Sign In</span>
          <span style={{cursor:'pointer'}} onClick={()=>setMode('apply')}>Apply</span>
          <span style={{cursor:'pointer'}} onClick={()=>setMode('register')}>Register</span>
        </div>
      </footer>

      <LandingChatbot onApply={()=>setMode('apply')} onLogin={()=>setMode('login')} />
    </div>
  );

  if (mode==='login') return (
    <div className="landing">
      <div className="hero">
        <div className="hero-card animate-fade">
          <button style={{background:'none',border:'none',color:'rgba(255,255,255,.7)',cursor:'pointer',marginBottom:20,fontSize:14}} onClick={()=>setMode('home')}>← Back</button>
          <div style={{fontWeight:800,fontSize:24,marginBottom:8}}>Welcome back</div>
          <div style={{opacity:.75,fontSize:14,marginBottom:28}}>Sign in to your MindBridge account</div>
          <form onSubmit={handleLogin}>
            <input className="hero-input" type="email" placeholder="Email address" required value={form.email} onChange={e=>setForm({...form,email:e.target.value})} />
            <input className="hero-input" type="password" placeholder="Password" required value={form.password} onChange={e=>setForm({...form,password:e.target.value})} />
            {error&&<div style={{background:'rgba(239,68,68,.25)',color:'#fecaca',padding:'10px 14px',borderRadius:10,marginBottom:12,fontSize:14}}>{error}</div>}
            <button className="hero-btn hero-btn-primary" type="submit" disabled={loading} style={{display:'flex',alignItems:'center',justifyContent:'center',gap:10}}>
              {loading?<Spinner/>:'Sign In'}
            </button>
          </form>
          <div style={{textAlign:'center',marginTop:20,opacity:.75,fontSize:14}}>
            No account? <span style={{textDecoration:'underline',cursor:'pointer'}} onClick={()=>setMode('register')}>Create one</span>
            &nbsp;·&nbsp;
            <span style={{textDecoration:'underline',cursor:'pointer'}} onClick={()=>setMode('apply')}>Apply for Support</span>
          </div>
        </div>
      </div>
    </div>
  );

  if (mode==='register') return (
    <div className="landing">
      <div className="hero" style={{padding:'20px'}}>
        <div className="hero-card animate-fade" style={{maxWidth:500}}>
          <button style={{background:'none',border:'none',color:'rgba(255,255,255,.7)',cursor:'pointer',marginBottom:20,fontSize:14}} onClick={()=>setMode('home')}>← Back</button>
          <div style={{fontWeight:800,fontSize:24,marginBottom:8}}>Create Account</div>
          <div style={{opacity:.75,fontSize:14,marginBottom:24}}>Join MindBridge and start your journey</div>
          <form onSubmit={handleRegister}>
            <input className="hero-input" placeholder="Full name" required value={reg.name} onChange={e=>setReg({...reg,name:e.target.value})} />
            <input className="hero-input" type="email" placeholder="Email address" required value={reg.email} onChange={e=>setReg({...reg,email:e.target.value})} />
            <input className="hero-input" type="password" placeholder="Password (min 6 chars)" minLength={6} required value={reg.password} onChange={e=>setReg({...reg,password:e.target.value})} />
            <select className="hero-input" style={{background:'rgba(255,255,255,.15)',color:'#fff'}} value={reg.role} onChange={e=>setReg({...reg,role:e.target.value})}>
              <option value="student" style={{color:'#111'}}>I'm a student seeking support</option>
              <option value="peer" style={{color:'#111'}}>I'm a peer supporter</option>
            </select>
            {error&&<div style={{background:'rgba(239,68,68,.25)',color:'#fecaca',padding:'10px 14px',borderRadius:10,marginBottom:12,fontSize:14}}>{error}</div>}
            {success&&<div style={{background:'rgba(56,200,140,.25)',color:'#d1fae5',padding:'10px 14px',borderRadius:10,marginBottom:12,fontSize:14}}>{success}</div>}
            <button className="hero-btn hero-btn-primary" type="submit" disabled={loading} style={{display:'flex',alignItems:'center',justifyContent:'center',gap:10}}>
              {loading?<Spinner/>:'Create Account'}
            </button>
          </form>
          <div style={{textAlign:'center',marginTop:20,opacity:.75,fontSize:14}}>
            Already have an account? <span style={{textDecoration:'underline',cursor:'pointer'}} onClick={()=>setMode('login')}>Sign in</span>
          </div>
          <div style={{marginTop:16,padding:'12px',background:'rgba(255,255,255,.1)',borderRadius:10,fontSize:12,opacity:.8}}>
            <strong>Note:</strong> As a student, you'll need to submit an enrollment application to access counseling features. Admin will review and approve your request.
          </div>
        </div>
      </div>
    </div>
  );

  if (mode==='apply') return (
    <div className="landing">
      <div className="hero" style={{padding:'20px'}}>
        <div className="hero-card animate-fade" style={{maxWidth:520}}>
          <button style={{background:'none',border:'none',color:'rgba(255,255,255,.7)',cursor:'pointer',marginBottom:20,fontSize:14}} onClick={()=>setMode('home')}>← Back</button>
          <div style={{fontWeight:800,fontSize:24,marginBottom:8}}>Apply for Mental Health Support</div>
          <div style={{opacity:.75,fontSize:14,marginBottom:24}}>All information is strictly confidential. Our admin team reviews applications within 24 hours.</div>
          {success ? (
            <div style={{textAlign:'center',padding:'40px 20px'}}>
              <div style={{fontSize:48,marginBottom:16}}>✅</div>
              <div style={{fontSize:18,fontWeight:700,marginBottom:8}}>Application Submitted!</div>
              <div style={{opacity:.8,marginBottom:24}}>We'll review your application and send confirmation to your email within 24 hours.</div>
              <button className="hero-btn hero-btn-outline" onClick={()=>setMode('home')}>Return to Home</button>
            </div>
          ) : (
            <form onSubmit={handleApply}>
              <input className="hero-input" placeholder="Full name" required value={app.name} onChange={e=>setApp({...app,name:e.target.value})} />
              <input className="hero-input" type="email" placeholder="University email" required value={app.email} onChange={e=>setApp({...app,email:e.target.value})} />
              <input className="hero-input" placeholder="Student ID number" required value={app.studentId} onChange={e=>setApp({...app,studentId:e.target.value})} />
              <textarea className="hero-input" placeholder="Briefly describe what you're going through (this is confidential)..." rows={4} required value={app.issue} onChange={e=>setApp({...app,issue:e.target.value})} style={{resize:'vertical'}} />
              <select className="hero-input" style={{background:'rgba(255,255,255,.15)',color:'#fff'}} value={app.urgency} onChange={e=>setApp({...app,urgency:e.target.value})}>
                <option value="low" style={{color:'#111'}}>Low urgency — I'd like to talk when possible</option>
                <option value="medium" style={{color:'#111'}}>Medium — I'm struggling and need support soon</option>
                <option value="high" style={{color:'#111'}}>High — I'm in significant distress</option>
              </select>
              {error&&<div style={{background:'rgba(239,68,68,.25)',color:'#fecaca',padding:'10px 14px',borderRadius:10,marginBottom:12,fontSize:14}}>{error}</div>}
              <button className="hero-btn hero-btn-primary" type="submit" disabled={loading} style={{display:'flex',alignItems:'center',justifyContent:'center',gap:10}}>
                {loading?<Spinner/>:'Submit Application'}
              </button>
            </form>
          )}
        </div>
      </div>
    </div>
  );

  if (mode==='solid-minds') return (
    <div style={{minHeight:'100vh',background:'#f8fafc',fontFamily:'inherit'}}>
      <nav style={{position:'sticky',top:0,zIndex:100,background:'rgba(255,255,255,.95)',backdropFilter:'blur(12px)',borderBottom:'1px solid #e5e7eb',padding:'0 40px',height:68,display:'flex',alignItems:'center',justifyContent:'space-between'}}>
        <div style={{display:'flex',alignItems:'center',gap:10,cursor:'pointer'}} onClick={()=>setMode('home')}>
          <div style={{width:36,height:36,background:'linear-gradient(135deg,#667eea,#764ba2)',borderRadius:10,display:'flex',alignItems:'center',justifyContent:'center',fontSize:18}}>🧠</div>
          <span style={{fontWeight:800,fontSize:20,color:'#1a202c'}}>MindBridge</span>
        </div>
        <button className="btn btn-sm" style={{background:'transparent',color:'#5b6cf9',border:'2px solid #5b6cf9'}} onClick={()=>setMode('home')}>← Back to Home</button>
      </nav>
      <SolidMindsClinicPage />
    </div>
  );
}

