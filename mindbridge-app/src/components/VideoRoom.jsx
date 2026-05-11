import React, { useEffect, useRef, useState } from 'react';

export default function VideoRoom({ onClose, counselor, roomId, studentId, counselorId, userName }) {
  const containerRef = useRef(null);
  const apiRef = useRef(null);
  const [loaded, setLoaded] = useState(false);
  const [error, setError] = useState('');

  // Deterministic room name so both parties land in the same room
  const room = roomId
    || (studentId && counselorId ? `mindbridge-${studentId}-${counselorId}` : `mindbridge-demo-${Date.now()}`);

  const displayName = userName || 'Anonymous Student';

  useEffect(() => {
    // Load Jitsi External API script once
    const scriptId = 'jitsi-api-script';
    const load = () => initJitsi();

    if (document.getElementById(scriptId)) {
      if (window.JitsiMeetExternalAPI) initJitsi();
      else document.getElementById(scriptId).addEventListener('load', load);
      return;
    }

    const script = document.createElement('script');
    script.id = scriptId;
    script.src = 'https://meet.jit.si/external_api.js';
    script.async = true;
    script.onload = initJitsi;
    script.onerror = () => setError('Could not load Jitsi. Check your internet connection.');
    document.body.appendChild(script);

    return () => {
      if (apiRef.current) { try { apiRef.current.dispose(); } catch {} }
    };
  }, []);

  function initJitsi() {
    if (!window.JitsiMeetExternalAPI || !containerRef.current) return;
    try {
      apiRef.current = new window.JitsiMeetExternalAPI('meet.jit.si', {
        roomName: room,
        parentNode: containerRef.current,
        width: '100%',
        height: '100%',
        configOverwrite: {
          prejoinPageEnabled: false,
          startWithAudioMuted: false,
          startWithVideoMuted: false,
          disableDeepLinking: true,
          enableClosePage: false,
          disableThirdPartyRequests: false,
          backgroundAlpha: 0.5,
          // Enable virtual backgrounds / blur
          virtualBackgrounds: [{ type: 'blur', blurValue: 25 }],
          defaultLocalDisplayName: displayName,
        },
        interfaceConfigOverwrite: {
          SHOW_JITSI_WATERMARK: false,
          SHOW_WATERMARK_FOR_GUESTS: false,
          SHOW_BRAND_WATERMARK: false,
          BRAND_WATERMARK_LINK: '',
          TOOLBAR_BUTTONS: [
            'microphone', 'camera', 'desktop', 'fullscreen',
            'fodeviceselection', 'hangup', 'chat', 'raisehand',
            'videoquality', 'filmstrip', 'tileview', 'select-background',
            'stats', 'shortcuts', 'help',
          ],
          MOBILE_APP_PROMO: false,
          DEFAULT_REMOTE_DISPLAY_NAME: counselor || 'Counselor',
        },
        userInfo: { displayName },
      });

      apiRef.current.addEventListener('videoConferenceJoined', () => setLoaded(true));
      apiRef.current.addEventListener('readyToClose', () => { onClose(); });

      // Auto-apply blur after joining
      apiRef.current.addEventListener('videoConferenceJoined', () => {
        setTimeout(() => {
          try {
            apiRef.current.executeCommand('selectBackground', { backgroundType: 'blur', blurValue: 25 });
          } catch {}
        }, 1500);
      });
    } catch (e) {
      setError('Failed to start video call: ' + e.message);
    }
  }

  return (
    <div style={{ position: 'fixed', inset: 0, background: '#0f172a', zIndex: 300, display: 'flex', flexDirection: 'column' }}>
      {/* Header */}
      <div style={{ padding: '12px 20px', background: 'rgba(0,0,0,.4)', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: '1px solid rgba(255,255,255,.1)', flexShrink: 0 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ width: 36, height: 36, background: 'linear-gradient(135deg,#667eea,#764ba2)', borderRadius: 10, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18 }}>🧠</div>
          <div>
            <div style={{ color: '#fff', fontWeight: 700, fontSize: 15 }}>MindBridge Secure Session</div>
            <div style={{ color: 'rgba(255,255,255,.55)', fontSize: 12 }}>
              Session with {counselor || 'Counselor'} · Room: {room.slice(0, 28)}…
            </div>
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{ background: 'rgba(56,200,140,.2)', border: '1px solid #38c88c', padding: '5px 12px', borderRadius: 20, display: 'flex', alignItems: 'center', gap: 7 }}>
            <i className="fas fa-user-secret" style={{ color: '#38c88c', fontSize: 13 }} />
            <span style={{ color: '#a7f3d0', fontSize: 12, fontWeight: 600 }}>Anonymous Mode — Use blur background to hide your face</span>
          </div>
          <button onClick={onClose} style={{ background: '#ef4444', border: 'none', color: '#fff', borderRadius: 8, padding: '6px 14px', cursor: 'pointer', fontWeight: 600, fontSize: 13 }}>
            Leave Session
          </button>
        </div>
      </div>

      {/* Jitsi container */}
      <div style={{ flex: 1, position: 'relative' }}>
        {!loaded && !error && (
          <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 16, color: '#fff', zIndex: 1 }}>
            <div style={{ width: 48, height: 48, border: '4px solid rgba(255,255,255,.2)', borderTop: '4px solid #667eea', borderRadius: '50%', animation: 'spin 1s linear infinite' }} />
            <div style={{ fontSize: 15, opacity: .8 }}>Connecting to secure session…</div>
            <div style={{ fontSize: 12, opacity: .5 }}>Room: {room}</div>
          </div>
        )}
        {error && (
          <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: 12, color: '#fff' }}>
            <div style={{ fontSize: 40 }}>⚠️</div>
            <div style={{ fontSize: 16, color: '#fca5a5' }}>{error}</div>
            <button onClick={onClose} style={{ marginTop: 8, padding: '10px 24px', borderRadius: 10, border: 'none', background: '#ef4444', color: '#fff', cursor: 'pointer', fontWeight: 600 }}>Close</button>
          </div>
        )}
        <div ref={containerRef} style={{ width: '100%', height: '100%' }} />
      </div>

      <style>{`
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
