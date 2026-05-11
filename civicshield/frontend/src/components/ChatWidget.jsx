import React, { useEffect, useRef, useState } from 'react';
import api from '../lib/api';
import { useAuth } from '../hooks/useAuth';
import { useSocket } from '../hooks/useSocket';

const ROLE_COLOR = { citizen: '#667eea', responder: '#22c55e', dispatcher: '#f97316', admin: '#ef4444' };
const ROLE_LABEL = { citizen: '👤', responder: '🚒', dispatcher: '📡', admin: '⚙️' };

const ChatWidget = ({ incidentId, incidentTitle }) => {
  const { user } = useAuth();
  const { socket } = useSocket();
  const [open, setOpen] = useState(false);
  const [messages, setMessages] = useState([]);
  const [text, setText] = useState('');
  const [sending, setSending] = useState(false);
  const [unread, setUnread] = useState(0);
  const bottomRef = useRef(null);

  // Load messages and join room
  useEffect(() => {
    if (!incidentId) return;
    api.get(`/messages/${incidentId}`)
      .then(r => setMessages(r.data))
      .catch(() => {});

    socket?.emit('join:incident', incidentId);
    return () => socket?.emit('leave:incident', incidentId);
  }, [incidentId, socket]);

  // Real-time new messages
  useEffect(() => {
    if (!socket) return;
    const onMsg = ({ message }) => {
      setMessages(prev => [...prev, message]);
      if (!open) setUnread(n => n + 1);
    };
    socket.on('message:new', onMsg);
    return () => socket.off('message:new', onMsg);
  }, [socket, open]);

  // Scroll to bottom
  useEffect(() => {
    if (open) {
      bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
      setUnread(0);
    }
  }, [messages, open]);

  const send = e => {
    e.preventDefault();
    if (!text.trim() || sending || !socket) return;
    setSending(true);
    socket.emit('message:send', {
      incidentId,
      text: text.trim(),
      senderId: user._id || user.id,
      senderName: user.name,
      senderRole: user.role
    });
    setText('');
    setSending(false);
  };

  const isMe = msg => (msg.sender?._id || msg.sender) === (user._id || user.id);

  return (
    <div style={s.wrap}>
      {/* Floating button */}
      <button onClick={() => { setOpen(o => !o); setUnread(0); }} style={s.fab}>
        💬
        {unread > 0 && <span style={s.badge}>{unread}</span>}
      </button>

      {/* Panel */}
      {open && (
        <div style={s.panel}>
          <div style={s.header}>
            <div>
              <div style={{ fontWeight: 'bold', fontSize: 14 }}>📡 Incident Chat</div>
              <div style={{ fontSize: 11, opacity: .8 }}>{incidentTitle || `#${incidentId?.slice(-6)}`}</div>
            </div>
            <button onClick={() => setOpen(false)} style={s.closeBtn}>✕</button>
          </div>

          <div style={s.messages}>
            {messages.length === 0 && (
              <div style={{ textAlign: 'center', color: '#94a3b8', fontSize: 13, padding: '20px 0' }}>
                No messages yet. Start the conversation!
              </div>
            )}
            {messages.map((m, i) => {
              const mine = isMe(m);
              const role = m.senderRole || m.sender?.role;
              return (
                <div key={m._id || i} style={{ display: 'flex', flexDirection: mine ? 'row-reverse' : 'row', gap: 6, marginBottom: 10, alignItems: 'flex-end' }}>
                  {!mine && (
                    <div style={{ width: 28, height: 28, borderRadius: '50%', background: ROLE_COLOR[role] || '#667eea', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 14, flexShrink: 0 }}>
                      {ROLE_LABEL[role] || '👤'}
                    </div>
                  )}
                  <div style={{ maxWidth: '70%' }}>
                    {!mine && <div style={{ fontSize: 10, color: '#94a3b8', marginBottom: 2 }}>{m.sender?.name} · {role}</div>}
                    <div style={{
                      padding: '8px 12px', borderRadius: mine ? '14px 14px 4px 14px' : '14px 14px 14px 4px',
                      background: mine ? '#667eea' : '#f1f5f9',
                      color: mine ? 'white' : '#1e293b',
                      fontSize: 13, lineHeight: 1.5
                    }}>
                      {m.text}
                    </div>
                    <div style={{ fontSize: 10, color: '#94a3b8', marginTop: 2, textAlign: mine ? 'right' : 'left' }}>
                      {new Date(m.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </div>
                  </div>
                </div>
              );
            })}
            <div ref={bottomRef} />
          </div>

          <form onSubmit={send} style={s.inputRow}>
            <input
              value={text}
              onChange={e => setText(e.target.value)}
              placeholder="Type a message…"
              style={s.input}
              autoFocus
            />
            <button type="submit" disabled={sending || !text.trim()} style={s.sendBtn}>
              ➤
            </button>
          </form>
        </div>
      )}
    </div>
  );
};

const s = {
  wrap: { position: 'fixed', bottom: 24, right: 24, zIndex: 9999 },
  fab: {
    width: 52, height: 52, borderRadius: '50%', background: '#667eea', border: 'none',
    color: 'white', fontSize: 22, cursor: 'pointer', boxShadow: '0 4px 16px rgba(0,0,0,.25)',
    position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center'
  },
  badge: {
    position: 'absolute', top: -4, right: -4, background: '#ef4444', color: 'white',
    borderRadius: '50%', width: 18, height: 18, fontSize: 11, fontWeight: 'bold',
    display: 'flex', alignItems: 'center', justifyContent: 'center', border: '2px solid white'
  },
  panel: {
    position: 'absolute', bottom: 64, right: 0,
    width: 320, height: 420, background: 'white', borderRadius: 16,
    boxShadow: '0 8px 32px rgba(0,0,0,.2)',
    display: 'flex', flexDirection: 'column', overflow: 'hidden'
  },
  header: {
    background: '#667eea', color: 'white', padding: '12px 16px',
    display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexShrink: 0
  },
  closeBtn: { background: 'rgba(255,255,255,.2)', border: 'none', color: 'white', borderRadius: 6, width: 28, height: 28, cursor: 'pointer', fontSize: 14 },
  messages: { flex: 1, overflowY: 'auto', padding: '12px 14px' },
  inputRow: { display: 'flex', gap: 8, padding: '10px 12px', borderTop: '1px solid #e2e8f0', flexShrink: 0 },
  input: { flex: 1, padding: '8px 12px', border: '1px solid #e2e8f0', borderRadius: 20, fontSize: 13, outline: 'none' },
  sendBtn: { background: '#667eea', color: 'white', border: 'none', borderRadius: 20, width: 36, height: 36, cursor: 'pointer', fontSize: 16, flexShrink: 0 }
};

export default ChatWidget;
