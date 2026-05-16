import React, { useEffect, useRef, useState } from 'react';

export default function VideoRoom({ onClose, counselor, roomId, userName }) {
  const containerRef = useRef(null);
  const apiRef = useRef(null);
  const [status, setStatus] = useState('connecting'); // connecting | ready | error
  const [error, setError] = useState('');
  const [muted, setMuted] = useState(false);
  const [videoOff, setVideoOff] = useState(false);
  const [participantCount, setParticipantCount] = useState(1);

  const displayName = userName || 'Anonymous';

  useEffect(() => {
    const scriptId = 'jitsi-api-script';

    const initJitsi = () => {
      if (!window.JitsiMeetExternalAPI || !containerRef.current) return;
      try {
        apiRef.current = new window.JitsiMeetExternalAPI('meet.jit.si', {
          roomName: roomId,
          parentNode: containerRef.current,
          width: '100%',
          height: '100%',
          configOverwrite: {
            prejoinPageEnabled: false,
            startWithAudioMuted: false,
            startWithVideoMuted: false,
            disableDeepLinking: true,
            enableClosePage: false,
            disableSimulcast: false,
            defaultLocalDisplayName: displayName,
            // Modern toolbar config (replaces deprecated interfaceConfigOverwrite.TOOLBAR_BUTTONS)
            toolbarButtons: [
              'microphone',
              'camera',
              'desktop',
              'chat',
              'raisehand',
              'tileview',
              'select-background',
              'fullscreen',
              'hangup',
            ],
            // Virtual background / blur
            backgroundAlpha: 0.5,
          },
          interfaceConfigOverwrite: {
            SHOW_JITSI_WATERMARK: false,
            SHOW_WATERMARK_FOR_GUESTS: false,
            SHOW_BRAND_WATERMARK: false,
            BRAND_WATERMARK_LINK: '',
            MOBILE_APP_PROMO: false,
            DEFAULT_REMOTE_DISPLAY_NAME: counselor || 'Participant',
            DISABLE_JOIN_LEAVE_NOTIFICATIONS: false,
          },
          userInfo: { displayName },
        });

        apiRef.current.addEventListener('videoConferenceJoined', () => {
          setStatus('ready');
          // Apply blur background after joining
          setTimeout(() => {
            try {
              apiRef.current.executeCommand('toggleVirtualBackgroundDialog');
            } catch {}
          }, 2000);
        });

        apiRef.current.addEventListener('participantJoined', () => {
          setParticipantCount(c => c + 1);
        });

        apiRef.current.addEventListener('participantLeft', () => {
          setParticipantCount(c => Math.max(1, c - 1));
        });

        apiRef.current.addEventListener('audioMuteStatusChanged', ({ muted: m }) => {
          setMuted(m);
        });

        apiRef.current.addEventListener('videoMuteStatusChanged', ({ muted: m }) => {
          setVideoOff(m);
        });

        apiRef.current.addEventListener('readyToClose', () => {
          onClose();
        });

      } catch (e) {
        setStatus('error');
        setError('Failed to start video call: ' + e.message);
      }
    };

    if (document.getElementById(scriptId)) {
      if (window.JitsiMeetExternalAPI) initJitsi();
      else document.getElementById(scriptId).addEventListener('load', initJitsi);
    } else {
      const script = document.createElement('script');
      script.id = scriptId;
      script.src = 'https://meet.jit.si/external_api.js';
      script.async = true;
      script.onload = initJitsi;
      script.onerror = () => { setStatus('error'); setError('Could not load Jitsi. Check your internet connection.'); };
      document.body.appendChild(script);
    }

    return () => {
      if (apiRef.current) { try { apiRef.current.dispose(); } catch {} }
    };
  }, []);

  const toggleMute = () => {
    if (apiRef.current) { apiRef.current.executeCommand('toggleAudio'); }
  };
  const toggleVideo = () => {
    if (apiRef.current) { apiRef.current.executeCommand('toggleVideo'); }
  };
  const toggleChat = () => {
    if (apiRef.current) { apiRef.current.executeCommand('toggleChat'); }
  };
  const toggleFullscreen = () => {
    if (apiRef.current) { apiRef.current.executeCommand('toggleFilmStrip'); }
  };

  return (
    <div style={{ position:'fixed', inset:0, background:'#0f172a', zIndex:300, display:'flex', flexDirection:'column' }}>

      {/* Header */}
      <div style={{ padding:'10px 20px', background:'rgba(0,0,0,.5)', display:'flex', alignItems:'center', justifyContent:'space-between', borderBottom:'1px solid rgba(255,255,255,.1)', flexShrink:0 }}>
        <div style={{ display:'flex', alignItems:'center', gap:12 }}>
          <div style={{ width:36, height:36, background:'linear-gradient(135deg,#667eea,#764ba2)', borderRadius:10, display:'flex', alignItems:'center', justifyContent:'center', fontSize:18 }}>🧠</div>
          <div>
            <div style={{ color:'#fff', fontWeight:700, fontSize:15 }}>MindBridge Secure Session</div>
            <div style={{ color:'rgba(255,255,255,.5)', fontSize:12 }}>
              {counselor ? `With ${counselor}` : 'Session room'} ·{' '}
              <span style={{ color: participantCount > 1 ? '#38c88c' : '#f59e0b' }}>
                {participantCount > 1 ? `${participantCount} participants connected` : 'Waiting for other participant…'}
              </span>
            </div>
          </div>
        </div>

        <div style={{ display:'flex', alignItems:'center', gap:10 }}>
          {/* Anonymous badge */}
          <div style={{ background:'rgba(56,200,140,.15)', border:'1px solid #38c88c44', padding:'5px 12px', borderRadius:20, display:'flex', alignItems:'center', gap:7 }}>
            <span style={{ fontSize:13 }}>🎭</span>
            <span style={{ color:'#a7f3d0', fontSize:12, fontWeight:600 }}>Anonymous Mode</span>
          </div>

          {/* Quick controls */}
          {status === 'ready' && (
            <div style={{ display:'flex', gap:6 }}>
              <button onClick={toggleMute}
                style={{ width:36, height:36, borderRadius:8, border:'none', cursor:'pointer', fontSize:16, display:'flex', alignItems:'center', justifyContent:'center',
                  background: muted ? '#ef4444' : 'rgba(255,255,255,.15)', color:'#fff' }}
                title={muted ? 'Unmute' : 'Mute'}>
                {muted ? '🔇' : '🎤'}
              </button>
              <button onClick={toggleVideo}
                style={{ width:36, height:36, borderRadius:8, border:'none', cursor:'pointer', fontSize:16, display:'flex', alignItems:'center', justifyContent:'center',
                  background: videoOff ? '#ef4444' : 'rgba(255,255,255,.15)', color:'#fff' }}
                title={videoOff ? 'Turn video on' : 'Turn video off'}>
                {videoOff ? '📵' : '📹'}
              </button>
              <button onClick={toggleChat}
                style={{ width:36, height:36, borderRadius:8, border:'none', cursor:'pointer', fontSize:16, display:'flex', alignItems:'center', justifyContent:'center', background:'rgba(255,255,255,.15)', color:'#fff' }}
                title="Toggle chat">
                💬
              </button>
            </div>
          )}

          <button onClick={onClose}
            style={{ background:'#ef4444', border:'none', color:'#fff', borderRadius:8, padding:'8px 18px', cursor:'pointer', fontWeight:700, fontSize:13 }}>
            Leave
          </button>
        </div>
      </div>

      {/* Share room link hint — shows until second person joins */}
      {status === 'ready' && participantCount < 2 && (
        <div style={{ background:'#1e3a5f', padding:'10px 20px', display:'flex', alignItems:'center', gap:12, borderBottom:'1px solid rgba(255,255,255,.08)', flexShrink:0 }}>
          <span style={{ fontSize:18 }}>⏳</span>
          <div style={{ flex:1, color:'rgba(255,255,255,.8)', fontSize:13 }}>
            <strong style={{ color:'#93c5fd' }}>Waiting for the other person to join.</strong>
            {' '}Share the session link or ask them to join from their Sessions page.
          </div>
          <button
            onClick={() => { navigator.clipboard?.writeText(`${window.location.origin}${window.location.pathname}#room-${roomId}`).catch(()=>{}); }}
            style={{ background:'rgba(255,255,255,.1)', border:'1px solid rgba(255,255,255,.2)', color:'#fff', borderRadius:8, padding:'6px 14px', cursor:'pointer', fontSize:12, fontWeight:600 }}>
            Copy Room ID
          </button>
        </div>
      )}

      {/* Jitsi container */}
      <div style={{ flex:1, position:'relative' }}>
        {status === 'connecting' && (
          <div style={{ position:'absolute', inset:0, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:16, color:'#fff', zIndex:1 }}>
            <div style={{ width:52, height:52, border:'4px solid rgba(255,255,255,.15)', borderTop:'4px solid #667eea', borderRadius:'50%', animation:'spin 1s linear infinite' }} />
            <div style={{ fontSize:16, fontWeight:600 }}>Connecting to secure room…</div>
            <div style={{ fontSize:12, opacity:.5, fontFamily:'monospace' }}>{roomId}</div>
          </div>
        )}
        {status === 'error' && (
          <div style={{ position:'absolute', inset:0, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', gap:12, color:'#fff' }}>
            <div style={{ fontSize:48 }}>⚠️</div>
            <div style={{ fontSize:16, color:'#fca5a5', textAlign:'center', maxWidth:400 }}>{error}</div>
            <button onClick={onClose} style={{ marginTop:8, padding:'10px 24px', borderRadius:10, border:'none', background:'#ef4444', color:'#fff', cursor:'pointer', fontWeight:700 }}>Close</button>
          </div>
        )}
        <div ref={containerRef} style={{ width:'100%', height:'100%' }} />
      </div>

      <style>{`
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
