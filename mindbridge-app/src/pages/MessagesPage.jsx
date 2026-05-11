import React, { useState, useRef, useEffect } from 'react';
import Avatar from '../components/Avatar';

async function getCounselorReply(userMessage, contactName) {
  const groqKey = import.meta.env.VITE_GROQ_API_KEY;
  if (groqKey) {
    try {
      const res = await fetch('https://api.groq.com/openai/v1/chat/completions', {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${groqKey}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          model: 'llama-3.1-8b-instant',
          max_tokens: 200,
          messages: [
            { role: 'system', content: `You are ${contactName}, a compassionate mental health counselor at MindBridge, a university wellness platform. Read the student's message carefully and respond directly and specifically to exactly what they said. Keep your reply to 2-3 sentences. Be warm, empathetic and professional. Never diagnose. If the student seems in crisis, gently urge them to book an urgent session.` },
            { role: 'user', content: userMessage },
          ],
        }),
      });
      if (!res.ok) throw new Error(await res.text());
      const data = await res.json();
      return data.choices[0].message.content.trim();
    } catch (err) {
      console.error('[MindBridge] Groq error:', err.message);
    }
  }
  return localReply(userMessage);
}

function localReply(userMessage) {
  const msg = userMessage.toLowerCase();
  const rules = [
    {
      keywords: ['stress', 'stressed', 'overwhelm', 'pressure', 'too much', 'burden'],
      replies: [
        `I hear you — stress can feel truly overwhelming, especially in an academic environment. Let's take a breath together. What's feeling heaviest for you right now?`,
        `Thank you for sharing that. Stress is your mind's way of signaling it needs support. Can you tell me more about what's been piling up lately?`,
        `It sounds like you're carrying a lot right now. You don't have to face this alone — let's talk through it. What started feeling this way?`,
      ],
    },
    {
      keywords: ['anxi', 'worry', 'worried', 'nervous', 'fear', 'panic', 'scared'],
      replies: [
        `Anxiety can be so exhausting, especially when it shows up constantly. You were brave to reach out. What does this anxiety feel like for you day to day?`,
        `I'm really glad you told me. Anxiety is very common among students, and there are real tools that can help. Would you like to explore some grounding techniques together?`,
        `That sounds really difficult. When anxiety shows up, it can feel like there's no escape — but there is a way through. What situations tend to trigger it most for you?`,
      ],
    },
    {
      keywords: ['depress', 'sad', 'hopeless', 'empty', 'numb', 'worthless', 'nothing matters'],
      replies: [
        `What you're describing sounds really painful, and I want you to know — your feelings are valid and you matter deeply. Can you tell me how long you've been feeling this way?`,
        `Thank you for trusting me with this. Feeling low and empty can be a sign your mind needs more support right now. You don't have to go through this alone. Are you sleeping and eating okay?`,
        `I'm really glad you reached out today. These feelings are real and they deserve real care. Let's work through this together — what's been the hardest part of your days lately?`,
      ],
    },
    {
      keywords: ['lonely', 'alone', 'isolated', 'no friends', 'nobody', 'no one'],
      replies: [
        `Loneliness on campus is more common than people admit — you are not the only one feeling this way. I'm here with you right now. What does your typical day look like socially?`,
        `Thank you for opening up. Feeling isolated can make everything harder. Have there been any spaces or activities where you felt even slightly more connected?`,
        `That takes courage to say. Loneliness is real and painful. Let's explore some small steps that might help — even one genuine connection can shift things. What kind of people or settings feel safest to you?`,
      ],
    },
    {
      keywords: ['exam', 'study', 'grades', 'fail', 'academic', 'assignment', 'coursework', 'lecture'],
      replies: [
        `Academic pressure is one of the biggest sources of student distress, and it's completely understandable to feel this way. What's the most stressful subject or deadline right now?`,
        `It sounds like university demands are really weighing on you. Let's think about some realistic strategies. Are you finding it hard to focus, or is it more about the volume of work?`,
        `I hear you. The pressure to perform can be crushing. Remember — your worth is not your GPA. Let's talk about what support might help you get through this period.`,
      ],
    },
    {
      keywords: ['sleep', 'insomnia', 'tired', 'exhausted', 'can\'t sleep', "can't rest"],
      replies: [
        `Sleep struggles can affect absolutely everything — mood, focus, energy. How long has this been going on, and do you have any idea what's keeping you awake?`,
        `I'm glad you brought this up. Poor sleep and mental health are deeply connected. Let's look at what might be disrupting your rest and find some gentle solutions.`,
        `That sounds really draining. Not sleeping well makes every challenge feel bigger. Would you like to talk about some evidence-based techniques that have helped other students?`,
      ],
    },
    {
      keywords: ['grief', 'loss', 'death', 'died', 'miss', 'bereavement', 'passed away'],
      replies: [
        `I'm so sorry for what you're going through. Grief is one of the heaviest things a person can carry, and there's no right or wrong way to feel it. I'm here to listen — tell me about them.`,
        `Losing someone while trying to keep up with life is incredibly hard. Your pain is completely valid. Please know you don't have to pretend to be okay. How can I support you today?`,
        `That kind of loss changes everything. Thank you for trusting me with something so personal. Grief takes time — and so does healing. Are you able to talk to anyone else around you about this?`,
      ],
    },
    {
      keywords: ['suicid', 'end my life', 'want to die', 'don\'t want to live', 'hurt myself', 'self-harm'],
      replies: [
        `What you just shared is very important and I take it seriously. Please know you are not alone and help is available right now. I strongly encourage you to book an urgent session or contact a crisis line immediately. You matter — please reach out.`,
        `Thank you for telling me this. Your life has value and what you're feeling can get better with the right support. Please book an urgent counseling session today — I am here for you and so are others.`,
      ],
    },
    {
      keywords: ['better', 'improving', 'progress', 'good today', 'helped', 'thank you', 'grateful'],
      replies: [
        `That's wonderful to hear! Progress, even small steps, is still progress. What do you think has made the biggest difference for you recently?`,
        `I'm really glad things are looking up. Healing isn't linear, but you're clearly putting in real effort. Keep going — I'm proud of how far you've come.`,
        `It means a lot to hear that. Remember this feeling — especially on harder days. You've shown that things can get better. What's been helping most?`,
      ],
    },
    {
      keywords: ['hi', 'hello', 'hey', 'good morning', 'good evening', 'how are you'],
      replies: [
        `Hello! I'm glad you reached out today. How are you feeling? There's no rush — we can talk about whatever is on your mind.`,
        `Hi there! It's good to hear from you. How has your week been going? I'm here and listening whenever you're ready to share.`,
        `Hello! Welcome. This is a safe space — you can talk about anything that's been weighing on you. How are you doing today?`,
      ],
    },
  ];

  for (const rule of rules) {
    if (rule.keywords.some(k => msg.includes(k))) {
      const options = rule.replies;
      return options[Math.floor(Math.random() * options.length)];
    }
  }

  const general = [
    `Thank you for sharing that with me. I want to make sure I understand — can you tell me a little more about what's been going on?`,
    `I hear you, and I'm glad you reached out. How long have you been feeling this way?`,
    `That's really important to acknowledge. You took a meaningful step by talking about it. What feels most urgent to you right now?`,
    `Your feelings are completely valid. Let's explore this together — what does a typical day feel like for you lately?`,
    `I'm here and I'm listening. Sometimes putting it into words is the hardest part — you did that, and it matters. What would feel most helpful right now?`,
  ];
  return general[Math.floor(Math.random() * general.length)];
} // end localReply

export default function MessagesPage({ user, users, messages, setMessages }) {
  const [activeChat, setActiveChat] = useState(null);
  const [newMsg, setNewMsg] = useState('');
  const [typing, setTyping] = useState(false);
  const bottomRef = useRef(null);

  const contacts = users.filter(u => {
    if (u.id === user.id) return false;
    // All students (enrolled or not) can reach admin and counselor
    if (user.role === 'student') return u.role === 'counselor' || u.role === 'admin';
    if (user.role === 'counselor') return u.role === 'student' || u.role === 'admin';
    if (user.role === 'admin') return u.role === 'counselor' || u.role === 'student';
    if (user.role === 'peer') return u.role === 'student' || u.role === 'counselor' || u.role === 'admin';
    return false;
  });

  const convoWith = (uid) => messages.filter(m=>(m.from===user.id&&m.to===uid)||(m.to===user.id&&m.from===uid));
  const lastMsg = (uid) => { const msgs=convoWith(uid); return msgs[msgs.length-1]; };
  const unread = (uid) => convoWith(uid).filter(m=>m.from===uid&&!m.read).length;

  const sendMsg = async () => {
    if(!newMsg.trim()||!activeChat||typing) return;
    const text = newMsg.trim();
    const msg={id:'msg'+Date.now(),from:user.id,to:activeChat.id,text,time:new Date().toLocaleTimeString([],{hour:'2-digit',minute:'2-digit'}),date:'Today'};
    setMessages(p=>[...p,msg]);
    setNewMsg('');
    if(activeChat.role==='counselor'||activeChat.role==='peer') {
      setTyping(true);
      const replyText = await getCounselorReply(text, activeChat.name);
      setTyping(false);
      setMessages(p=>[...p,{id:'msg'+(Date.now()+1),from:activeChat.id,to:user.id,text:replyText,time:new Date().toLocaleTimeString([],{hour:'2-digit',minute:'2-digit'}),date:'Today'}]);
    }
  };

  useEffect(()=>{ if(bottomRef.current) bottomRef.current.scrollIntoView({behavior:'smooth'}); },[messages,activeChat]);

  const convo = activeChat ? convoWith(activeChat.id) : [];

  return (
    <div className="animate-fade">
      <div className="page-header"><div className="page-title">Messages</div><div className="page-subtitle">Secure messaging with your support team</div></div>
      <div className="card" style={{padding:0,overflow:'hidden'}}>
        <div style={{display:'grid',gridTemplateColumns:'280px 1fr',height:'60vh'}}>
          <div style={{borderRight:'1px solid #f3f4f6',overflow:'auto'}}>
            <div style={{padding:'16px',borderBottom:'1px solid #f3f4f6',fontWeight:600,fontSize:14,color:'#374151'}}>Conversations</div>
            {contacts.length===0&&<div style={{padding:20,color:'#9ca3af',fontSize:14,textAlign:'center'}}>No contacts yet</div>}
            {contacts.map(c=>{
              const lm=lastMsg(c.id); const cnt=unread(c.id);
              return (
                <div key={c.id} onClick={()=>setActiveChat(c)} style={{padding:'14px 16px',cursor:'pointer',background:(activeChat&&activeChat.id===c.id)?'#eef0ff':'transparent',borderBottom:'1px solid #f9fafb',display:'flex',gap:12,alignItems:'center',transition:'background .15s'}}>
                  <div style={{position:'relative'}}>
                    <Avatar name={c.name} color={c.color} size={40} />
                    {c.online&&<div style={{width:10,height:10,borderRadius:'50%',background:'#38c88c',position:'absolute',bottom:0,right:0,border:'2px solid #fff'}} />}
                  </div>
                  <div style={{flex:1,minWidth:0}}>
                    <div style={{display:'flex',justifyContent:'space-between',alignItems:'center'}}>
                      <span style={{fontWeight:600,fontSize:14,color:'#1f2937'}}>{c.name.split(' ')[0]} {c.name.split(' ')[1]?c.name.split(' ')[1][0]+'.':''}</span>
                      {cnt>0&&<span style={{background:'#5b6cf9',color:'#fff',borderRadius:'50%',width:18,height:18,fontSize:11,display:'flex',alignItems:'center',justifyContent:'center',fontWeight:700}}>{cnt}</span>}
                    </div>
                    <div style={{fontSize:12,color:'#9ca3af',whiteSpace:'nowrap',overflow:'hidden',textOverflow:'ellipsis'}}>{lm?lm.text:'No messages yet'}</div>
                  </div>
                </div>
              );
            })}
          </div>
          {activeChat ? (
            <div style={{display:'flex',flexDirection:'column'}}>
              <div style={{padding:'14px 20px',borderBottom:'1px solid #f3f4f6',display:'flex',alignItems:'center',gap:12}}>
                <Avatar name={activeChat.name} color={activeChat.color} size={36} />
                <div><div style={{fontWeight:600,fontSize:15}}>{activeChat.name}</div><div style={{fontSize:12,color:activeChat.online?'#38c88c':'#9ca3af'}}>{activeChat.online?'Online':'Offline'}</div></div>
                <div style={{marginLeft:'auto',display:'flex',gap:8}}>
                  <button className="btn btn-outline btn-sm"><i className="fas fa-video"/>Video Call</button>
                </div>
              </div>
              <div style={{flex:1,overflow:'auto',padding:'20px',display:'flex',flexDirection:'column'}}>
                {convo.length===0&&<div style={{textAlign:'center',color:'#9ca3af',fontSize:14,marginTop:40}}>No messages yet. Say hello!</div>}
                {convo.map(m=>(
                  <div key={m.id} style={{marginBottom:12,display:'flex',flexDirection:m.from===user.id?'row-reverse':'row',alignItems:'flex-end',gap:8}}>
                    {m.from!==user.id&&<Avatar name={activeChat.name} color={activeChat.color} size={28} fontSize={11} />}
                    <div>
                      <div className={`chat-bubble ${m.from===user.id?'bubble-out':'bubble-in'}`}>{m.text}</div>
                      <div style={{fontSize:11,color:'#9ca3af',textAlign:m.from===user.id?'right':'left',marginTop:2}}>{m.time}</div>
                    </div>
                  </div>
                ))}
                {typing && (
                  <div style={{display:'flex',alignItems:'flex-end',gap:8,marginBottom:12}}>
                    <Avatar name={activeChat.name} color={activeChat.color} size={28} fontSize={11} />
                    <div className="chat-bubble bubble-in" style={{display:'flex',gap:4,alignItems:'center',padding:'10px 14px'}}>
                      <span style={{width:7,height:7,borderRadius:'50%',background:'#9ca3af',animation:'bounce 1s infinite'}}/>
                      <span style={{width:7,height:7,borderRadius:'50%',background:'#9ca3af',animation:'bounce 1s infinite .2s'}}/>
                      <span style={{width:7,height:7,borderRadius:'50%',background:'#9ca3af',animation:'bounce 1s infinite .4s'}}/>
                    </div>
                  </div>
                )}
                <div ref={bottomRef}/>
              </div>
              <div style={{padding:'14px 20px',borderTop:'1px solid #f3f4f6',display:'flex',gap:10}}>
                <input className="input" value={newMsg} onChange={e=>setNewMsg(e.target.value)} onKeyDown={e=>e.key==='Enter'&&sendMsg()} placeholder="Type a message..." style={{flex:1}} />
                <button className="btn btn-primary btn-sm" onClick={sendMsg}><i className="fas fa-paper-plane"/></button>
              </div>
            </div>
          ) : (
            <div style={{display:'flex',alignItems:'center',justifyContent:'center',color:'#9ca3af',flexDirection:'column',gap:12}}>
              <i className="fas fa-comments" style={{fontSize:40,opacity:.4}}/>
              <span style={{fontSize:15}}>Select a conversation</span>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
