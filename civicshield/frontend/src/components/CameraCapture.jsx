import { useRef, useState, useEffect, useCallback } from 'react';

export default function CameraCapture({
  onCapture,
  onClose,
  maxPhotos = 5,
  currentCount = 0,
}) {
  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const streamRef = useRef(null);

  const [facingMode, setFacingMode] = useState('environment');
  const [ready, setReady] = useState(false);
  const [error, setError] = useState(null);

  const startCamera = useCallback(async (facing) => {
    // Stop any existing stream first
    if (streamRef.current) {
      streamRef.current.getTracks().forEach((t) => t.stop());
      streamRef.current = null;
    }
    setReady(false);
    setError(null);

    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          facingMode: facing,
          width: { ideal: 1280 },
          height: { ideal: 720 },
        },
      });
      streamRef.current = stream;
      if (videoRef.current) {
        videoRef.current.srcObject = stream;
      }
    } catch {
      setError('Camera access denied. Please allow camera permissions and try again.');
    }
  }, []);

  useEffect(() => {
    startCamera(facingMode);
    return () => {
      if (streamRef.current) {
        streamRef.current.getTracks().forEach((t) => t.stop());
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleFlip = () => {
    const next = facingMode === 'environment' ? 'user' : 'environment';
    setFacingMode(next);
    startCamera(next);
  };

  const handleCapture = () => {
    const video = videoRef.current;
    const canvas = canvasRef.current;
    if (!video || !canvas) return;

    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    const ctx = canvas.getContext('2d');
    ctx.drawImage(video, 0, 0, canvas.width, canvas.height);
    canvas.toBlob((blob) => onCapture(blob), 'image/jpeg', 0.88);
  };

  // ── Styles ──────────────────────────────────────────────────────────────────

  const overlayStyle = {
    position: 'fixed',
    inset: 0,
    backgroundColor: '#111',
    zIndex: 9999,
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'space-between',
    color: '#fff',
    fontFamily: 'sans-serif',
  };

  const headerStyle = {
    width: '100%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '14px 20px',
    backgroundColor: 'rgba(0,0,0,0.55)',
    boxSizing: 'border-box',
    flexShrink: 0,
  };

  const headerTitleStyle = {
    fontSize: '16px',
    fontWeight: 600,
    letterSpacing: '0.02em',
  };

  const closeBtnStyle = {
    background: 'none',
    border: 'none',
    color: '#fff',
    fontSize: '22px',
    cursor: 'pointer',
    lineHeight: 1,
    padding: '2px 6px',
  };

  const viewfinderWrapStyle = {
    position: 'relative',
    flex: 1,
    width: '100%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  };

  // 4:3 viewfinder box — grows to fill available space while keeping ratio
  const viewfinderBoxStyle = {
    position: 'relative',
    width: '100%',
    maxWidth: 'min(100%, calc((100vh - 180px) * 4/3))',
    aspectRatio: '4 / 3',
    overflow: 'hidden',
    backgroundColor: '#000',
  };

  const videoStyle = {
    width: '100%',
    height: '100%',
    objectFit: 'cover',
    display: 'block',
  };

  // Crosshair overlay
  const crosshairStyle = {
    position: 'absolute',
    inset: 0,
    pointerEvents: 'none',
  };

  const crosshairLineH = {
    position: 'absolute',
    top: '50%',
    left: '20%',
    right: '20%',
    height: '1px',
    backgroundColor: 'rgba(255,255,255,0.35)',
    transform: 'translateY(-50%)',
  };

  const crosshairLineV = {
    position: 'absolute',
    left: '50%',
    top: '20%',
    bottom: '20%',
    width: '1px',
    backgroundColor: 'rgba(255,255,255,0.35)',
    transform: 'translateX(-50%)',
  };

  // Corner brackets
  const cornerBase = {
    position: 'absolute',
    width: '24px',
    height: '24px',
    borderColor: 'rgba(255,255,255,0.75)',
    borderStyle: 'solid',
  };

  const corners = [
    { top: '12%', left: '8%', borderWidth: '2px 0 0 2px' },
    { top: '12%', right: '8%', borderWidth: '2px 2px 0 0' },
    { bottom: '12%', left: '8%', borderWidth: '0 0 2px 2px' },
    { bottom: '12%', right: '8%', borderWidth: '0 2px 2px 0' },
  ];

  const loadingOverlayStyle = {
    position: 'absolute',
    inset: 0,
    backgroundColor: 'rgba(0,0,0,0.72)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    fontSize: '15px',
    color: '#fff',
    letterSpacing: '0.03em',
  };

  const errorOverlayStyle = {
    position: 'absolute',
    inset: 0,
    backgroundColor: 'rgba(0,0,0,0.82)',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '24px',
    textAlign: 'center',
    gap: '12px',
    fontSize: '15px',
    color: '#fca5a5',
  };

  const controlsRowStyle = {
    width: '100%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '18px 32px',
    backgroundColor: 'rgba(0,0,0,0.55)',
    boxSizing: 'border-box',
    flexShrink: 0,
    position: 'relative',
    minHeight: '90px',
  };

  const flipBtnStyle = {
    position: 'absolute',
    left: '32px',
    background: 'rgba(255,255,255,0.15)',
    border: '1.5px solid rgba(255,255,255,0.4)',
    borderRadius: '50%',
    width: '48px',
    height: '48px',
    fontSize: '22px',
    cursor: 'pointer',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  };

  const captureBtnStyle = {
    width: '68px',
    height: '68px',
    borderRadius: '50%',
    backgroundColor: '#fff',
    border: '4px solid rgba(255,255,255,0.5)',
    cursor: ready && !error ? 'pointer' : 'not-allowed',
    opacity: ready && !error ? 1 : 0.45,
    outline: 'none',
    boxShadow: '0 0 0 3px rgba(255,255,255,0.25)',
    flexShrink: 0,
  };

  // ── Render ──────────────────────────────────────────────────────────────────

  return (
    <div style={overlayStyle}>
      {/* Header */}
      <div style={headerStyle}>
        <span style={headerTitleStyle}>
          📷 Take Photo ({currentCount}/{maxPhotos})
        </span>
        <button style={closeBtnStyle} onClick={onClose} aria-label="Close camera">
          ✕
        </button>
      </div>

      {/* Viewfinder */}
      <div style={viewfinderWrapStyle}>
        <div style={viewfinderBoxStyle}>
          <video
            ref={videoRef}
            style={videoStyle}
            autoPlay
            playsInline
            muted
            onCanPlay={() => setReady(true)}
          />

          {/* Crosshair */}
          <div style={crosshairStyle}>
            <div style={crosshairLineH} />
            <div style={crosshairLineV} />
            {corners.map((c, i) => (
              <div key={i} style={{ ...cornerBase, ...c }} />
            ))}
          </div>

          {/* "Starting camera…" overlay */}
          {!ready && !error && (
            <div style={loadingOverlayStyle}>Starting camera…</div>
          )}

          {/* Error overlay */}
          {error && (
            <div style={errorOverlayStyle}>
              <span style={{ fontSize: '36px' }}>🚫</span>
              <span>{error}</span>
            </div>
          )}
        </div>
      </div>

      {/* Controls */}
      <div style={controlsRowStyle}>
        <button style={flipBtnStyle} onClick={handleFlip} aria-label="Flip camera">
          🔄
        </button>
        <button
          style={captureBtnStyle}
          onClick={handleCapture}
          disabled={!ready || !!error}
          aria-label="Capture photo"
        />
      </div>

      {/* Hidden canvas for frame capture */}
      <canvas ref={canvasRef} style={{ display: 'none' }} />
    </div>
  );
}
