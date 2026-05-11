import React from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../hooks/useAuth';
import { useSocket } from '../hooks/useSocket';
import LiveMap from '../components/LiveMap';

const MapPage = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const { socket, connected } = useSocket();

  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <div style={styles.headerContent}>
          <button onClick={() => navigate('/dashboard')} style={styles.backBtn}>
            ← Dashboard
          </button>
          <h1 style={styles.title}>🗺️ Live Emergency Map</h1>
          <div style={styles.statusArea}>
            <span style={{ ...styles.dot, background: connected ? '#22c55e' : '#ef4444' }} />
            <span style={styles.statusText}>{connected ? 'Live' : 'Reconnecting...'}</span>
            <span style={styles.roleBadge}>{user?.role}</span>
          </div>
        </div>
      </header>

      <div style={styles.mapArea}>
        <LiveMap socket={socket} role={user?.role} />
      </div>
    </div>
  );
};

const styles = {
  container: {
    display: 'flex',
    flexDirection: 'column',
    height: '100vh',
    background: '#111',
  },
  header: {
    background: 'linear-gradient(135deg, #1e293b 0%, #334155 100%)',
    padding: '12px 20px',
    flexShrink: 0,
  },
  headerContent: {
    display: 'flex',
    alignItems: 'center',
    gap: '16px',
    maxWidth: '1400px',
    margin: '0 auto',
  },
  backBtn: {
    background: 'rgba(255,255,255,0.1)',
    color: 'white',
    border: '1px solid rgba(255,255,255,0.2)',
    padding: '7px 14px',
    borderRadius: '6px',
    cursor: 'pointer',
    fontSize: '13px',
    flexShrink: 0,
  },
  title: {
    color: 'white',
    flex: 1,
    fontSize: '18px',
    fontWeight: 'bold',
    margin: 0,
  },
  statusArea: {
    display: 'flex',
    alignItems: 'center',
    gap: '8px',
    flexShrink: 0,
  },
  dot: {
    width: '10px',
    height: '10px',
    borderRadius: '50%',
    display: 'inline-block',
    flexShrink: 0,
  },
  statusText: {
    color: 'white',
    fontSize: '13px',
  },
  roleBadge: {
    background: '#667eea',
    color: 'white',
    padding: '3px 10px',
    borderRadius: '12px',
    fontSize: '12px',
    textTransform: 'capitalize',
  },
  mapArea: {
    flex: 1,
    overflow: 'hidden',
  },
};

export default MapPage;
