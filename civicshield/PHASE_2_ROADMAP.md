# CivicShield Phase 2 - Implementation Roadmap

## Phase 2 Overview

Now that the MVP foundation is complete, Phase 2 focuses on:
1. **Live Map Integration** (Incidents & Responders)
2. **Real-time Responder Assignment UI**
3. **Enhanced Dispatcher Dashboard**
4. **Mobile-responsive UI improvements**

---

## Feature 1: Live Map Integration ⭐ (Start Here)

### 1.1 Install Dependencies

```bash
cd frontend
npm install leaflet react-leaflet
npm install leaflet-clustering
```

### 1.2 Create Map Component

**File**: `src/components/MapComponent.jsx`

```jsx
import React, { useState, useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, Circle } from 'react-leaflet';
import L from 'leaflet';
import api from '../lib/api';

const MapComponent = ({ incidents, responders, onIncidentClick }) => {
  const defaultCenter = [40.7128, -74.0060]; // NYC
  const [zoom, setZoom] = useState(12);

  const markerIcon = L.icon({
    iconUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon.png',
    iconSize: [25, 41],
    iconAnchor: [12, 41]
  });

  const incidentIcon = L.icon({
    iconUrl: 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiI+PHRleHQgeD0iOCIgeT0iMjQiIGZvbnQtc2l6ZT0iMjQiPvCZiIE8L3RleHQ+PC9zdmc+',
    iconSize: [32, 32]
  });

  return (
    <MapContainer center={defaultCenter} zoom={zoom} style={{ height: '100%', width: '100%' }}>
      <TileLayer
        url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        attribution='&copy; OpenStreetMap contributors'
      />

      {/* Incident Markers */}
      {incidents?.map(incident => (
        <Marker
          key={incident._id}
          position={[incident.location.lat, incident.location.lng]}
          icon={incidentIcon}
          eventHandlers={{ click: () => onIncidentClick(incident) }}
        >
          <Popup>
            <div>
              <h3>{incident.title}</h3>
              <p>{incident.description}</p>
              <small>Status: {incident.status}</small>
            </div>
          </Popup>
        </Marker>
      ))}

      {/* Responder Markers */}
      {responders?.map(responder => (
        <Marker
          key={responder._id}
          position={[responder.currentLocation.lat, responder.currentLocation.lng]}
          icon={markerIcon}
        >
          <Popup>
            <div>
              <h3>{responder.userId?.name}</h3>
              <p>Status: {responder.status}</p>
              <p>Vehicle: {responder.vehicleType}</p>
            </div>
          </Popup>
        </Marker>
      ))}

      {/* Incident Radius Circles */}
      {incidents?.map(incident => incident.status === 'active' && (
        <Circle
          key={`circle-${incident._id}`}
          center={[incident.location.lat, incident.location.lng]}
          radius={incident.location.radius || 500}
          pathOptions={{ color: 'red', fillOpacity: 0.1 }}
        />
      ))}
    </MapContainer>
  );
};

export default MapComponent;
```

### 1.3 Create Dispatcher Map Page

**File**: `src/pages/DispatcherMapPage.jsx`

```jsx
import React, { useState, useEffect } from 'react';
import { useAuth } from '../hooks/useAuth';
import api from '../lib/api';
import MapComponent from '../components/MapComponent';

const DispatcherMapPage = () => {
  const { user } = useAuth();
  const [incidents, setIncidents] = useState([]);
  const [responders, setResponders] = useState([]);
  const [selectedIncident, setSelectedIncident] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
    // Refresh every 5 seconds
    const interval = setInterval(fetchData, 5000);
    return () => clearInterval(interval);
  }, []);

  const fetchData = async () => {
    try {
      const [incidentsRes, respondersRes] = await Promise.all([
        api.get('/dashboard/incidents/live'),
        api.get('/dashboard/responders/locations')
      ]);
      setIncidents(incidentsRes.data.incidents || []);
      setResponders(respondersRes.data || []);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching data:', error);
    }
  };

  if (loading) return <div>Loading map...</div>;

  return (
    <div style={styles.container}>
      <div style={styles.mapContainer}>
        <MapComponent
          incidents={incidents}
          responders={responders}
          onIncidentClick={setSelectedIncident}
        />
      </div>

      {selectedIncident && (
        <div style={styles.sidebar}>
          <h3>{selectedIncident.title}</h3>
          <p>{selectedIncident.description}</p>
          <p><strong>Type:</strong> {selectedIncident.type}</p>
          <p><strong>Severity:</strong> {selectedIncident.severity}</p>
          <button
            style={styles.assignButton}
            onClick={() => {/* Open assignment modal */}}
          >
            Assign Responders
          </button>
        </div>
      )}
    </div>
  );
};

const styles = {
  container: { display: 'flex', height: '100vh' },
  mapContainer: { flex: 1 },
  sidebar: { width: '300px', background: 'white', padding: '20px', overflow: 'auto' },
  assignButton: { width: '100%', padding: '10px', background: '#667eea', color: 'white' }
};

export default DispatcherMapPage;
```

---

## Feature 2: Real-time Responder Assignment UI

### 2.1 Create Assignment Modal

**File**: `src/components/AssignmentModal.jsx`

```jsx
import React, { useState, useEffect } from 'react';
import api from '../lib/api';

const AssignmentModal = ({ incident, onClose, onAssign }) => {
  const [availableResponders, setAvailableResponders] = useState([]);
  const [selectedResponders, setSelectedResponders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchNearbyResponders();
  }, [incident]);

  const fetchNearbyResponders = async () => {
    try {
      const response = await api.get('/responders/available/near', {
        params: {
          lat: incident.location.lat,
          lng: incident.location.lng,
          radius: incident.location.radius || 5000
        }
      });
      setAvailableResponders(response.data);
      setLoading(false);
    } catch (error) {
      console.error('Error fetching responders:', error);
      setLoading(false);
    }
  };

  const handleAssign = async () => {
    try {
      await api.post('/assignments/batch', {
        incidentId: incident._id,
        responderIds: selectedResponders
      });
      onAssign?.();
      onClose();
    } catch (error) {
      console.error('Error creating assignments:', error);
    }
  };

  return (
    <div style={styles.overlay}>
      <div style={styles.modal}>
        <h2>Assign Responders</h2>
        <p style={styles.incidentInfo}>
          Incident: {incident.title}
        </p>

        {loading ? (
          <p>Finding nearby responders...</p>
        ) : (
          <div style={styles.responderList}>
            {availableResponders.map(responder => (
              <div key={responder._id} style={styles.responderItem}>
                <input
                  type="checkbox"
                  checked={selectedResponders.includes(responder._id)}
                  onChange={(e) => {
                    if (e.target.checked) {
                      setSelectedResponders([...selectedResponders, responder._id]);
                    } else {
                      setSelectedResponders(selectedResponders.filter(id => id !== responder._id));
                    }
                  }}
                />
                <div style={styles.responderInfo}>
                  <strong>{responder.userId?.name}</strong>
                  <small>Distance: {responder.distance?.toFixed(2)} km</small>
                </div>
              </div>
            ))}
          </div>
        )}

        <div style={styles.buttons}>
          <button style={styles.cancelBtn} onClick={onClose}>Cancel</button>
          <button style={styles.assignBtn} onClick={handleAssign}>
            Assign {selectedResponders.length} Responder(s)
          </button>
        </div>
      </div>
    </div>
  );
};

const styles = {
  overlay: { position: 'fixed', top: 0, left: 0, right: 0, bottom: 0, background: 'rgba(0,0,0,0.5)' },
  modal: { position: 'fixed', top: '50%', left: '50%', transform: 'translate(-50%, -50%)', background: 'white', padding: '30px', borderRadius: '10px', width: '90%', maxWidth: '400px' },
  incidentInfo: { background: '#f0f0f0', padding: '10px', borderRadius: '5px', marginBottom: '15px' },
  responderList: { maxHeight: '300px', overflow: 'auto', marginBottom: '15px' },
  responderItem: { display: 'flex', alignItems: 'center', padding: '10px', borderBottom: '1px solid #eee' },
  responderInfo: { marginLeft: '10px', flex: 1 },
  buttons: { display: 'flex', gap: '10px', justifyContent: 'flex-end' },
  cancelBtn: { padding: '10px 20px', background: '#ccc', border: 'none', borderRadius: '5px', cursor: 'pointer' },
  assignBtn: { padding: '10px 20px', background: '#667eea', color: 'white', border: 'none', borderRadius: '5px', cursor: 'pointer' }
};

export default AssignmentModal;
```

### 2.2 Create Responder Assignment Card

**File**: `src/components/AssignmentCard.jsx`

```jsx
import React from 'react';

const AssignmentCard = ({ assignment, onStatusChange }) => {
  const statusColors = {
    'assigned': '#ffc107',
    'en-route': '#2196F3',
    'on-scene': '#FF5722',
    'completed': '#4CAF50'
  };

  return (
    <div style={{ ...styles.card, borderLeftColor: statusColors[assignment.status] }}>
      <div style={styles.header}>
        <h3>{assignment.incident?.title}</h3>
        <span style={{ ...styles.badge, background: statusColors[assignment.status] }}>
          {assignment.status}
        </span>
      </div>

      <p><strong>Responder:</strong> {assignment.responder?.name}</p>
      <p><strong>Type:</strong> {assignment.incident?.type}</p>
      
      <div style={styles.timeline}>
        {assignment.responseTime && (
          <p><small>Response: {Math.round(assignment.responseTime / 60)} min</small></p>
        )}
        {assignment.travelTime && (
          <p><small>Travel: {Math.round(assignment.travelTime / 60)} min</small></p>
        )}
      </div>

      <div style={styles.actions}>
        {assignment.status === 'assigned' && (
          <button onClick={() => onStatusChange(assignment._id, 'en-route')}>
            En Route
          </button>
        )}
        {assignment.status === 'en-route' && (
          <button onClick={() => onStatusChange(assignment._id, 'on-scene')}>
            On Scene
          </button>
        )}
        {assignment.status === 'on-scene' && (
          <button onClick={() => onStatusChange(assignment._id, 'completed')}>
            Complete
          </button>
        )}
      </div>
    </div>
  );
};

const styles = {
  card: { background: 'white', padding: '15px', borderRadius: '8px', borderLeft: '4px solid', marginBottom: '15px' },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' },
  badge: { color: 'white', padding: '5px 10px', borderRadius: '20px', fontSize: '12px' },
  timeline: { background: '#f9f9f9', padding: '10px', borderRadius: '5px', marginBottom: '10px' },
  actions: { display: 'flex', gap: '10px' }
};

export default AssignmentCard;
```

---

## Feature 3: Responder Dashboard Enhancement

### 3.1 Create Responder Dashboard

**File**: `src/pages/ResponderDashboardPage.jsx`

```jsx
import React, { useState, useEffect } from 'react';
import { useAuth } from '../hooks/useAuth';
import api from '../lib/api';
import AssignmentCard from '../components/AssignmentCard';

const ResponderDashboardPage = () => {
  const { user } = useAuth();
  const [assignments, setAssignments] = useState([]);
  const [stats, setStats] = useState(null);

  useEffect(() => {
    fetchAssignments();
    // Poll every 10 seconds
    const interval = setInterval(fetchAssignments, 10000);
    return () => clearInterval(interval);
  }, []);

  const fetchAssignments = async () => {
    try {
      const response = await api.get('/assignments/my/assignments');
      setAssignments(response.data);
    } catch (error) {
      console.error('Error fetching assignments:', error);
    }
  };

  const handleStatusChange = async (assignmentId, newStatus) => {
    try {
      await api.put(`/assignments/${assignmentId}`, { status: newStatus });
      fetchAssignments();
    } catch (error) {
      console.error('Error updating assignment:', error);
    }
  };

  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <h1>Responder Dashboard</h1>
        <p>{user?.name} • {user?.badge}</p>
      </header>

      <div style={styles.content}>
        <div style={styles.assignmentsSection}>
          <h2>Active Assignments</h2>
          {assignments.length === 0 ? (
            <p>No active assignments</p>
          ) : (
            <div>
              {assignments.map(assignment => (
                <AssignmentCard
                  key={assignment._id}
                  assignment={assignment}
                  onStatusChange={handleStatusChange}
                />
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

const styles = {
  container: { minHeight: '100vh', background: '#f5f5f5' },
  header: { background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', color: 'white', padding: '20px', textAlign: 'center' },
  content: { maxWidth: '1200px', margin: '0 auto', padding: '20px' },
  assignmentsSection: { background: 'white', padding: '20px', borderRadius: '10px' }
};

export default ResponderDashboardPage;
```

---

## Implementation Order (Priority)

### Week 1-2: Live Map
1. Install Leaflet dependencies
2. Create MapComponent
3. Create DispatcherMapPage
4. Integrate with existing incident data
5. Real-time updates via Socket.IO

### Week 2-3: Assignment UI
1. Create AssignmentModal
2. Create AssignmentCard
3. Implement status tracking
4. Add performance metrics
5. Test with demo data

### Week 3-4: Dashboards
1. Enhance ResponderDashboard
2. Enhance DispatcherDashboard
3. Add admin dashboard
4. Mobile responsiveness
5. Polish UI/UX

---

## Socket.IO Integration for Real-time Updates

```javascript
// Listen for incidents
socket.on('incident:new', (data) => {
  setIncidents(prev => [data.incident, ...prev]);
  // Update map
});

// Listen for responder location updates
socket.on('responder:location:updated', (data) => {
  setResponders(prev => prev.map(r => 
    r._id === data.responderId 
      ? { ...r, currentLocation: data.location }
      : r
  ));
});

// Listen for assignment updates
socket.on('assignment:status:updated', (data) => {
  setAssignments(prev => prev.map(a =>
    a._id === data.assignment._id
      ? data.assignment
      : a
  ));
});
```

---

## Testing Phase 2 Features

1. **Map Test**: Login as dispatcher → View live map
2. **Assignment Test**: Click incident → Assign responders → Track on map
3. **Real-time Test**: Open in multiple tabs → See updates in real-time
4. **Mobile Test**: Open on mobile → Test responsive UI

---

## Performance Optimization

- Use `React.memo` for MapComponent
- Implement virtual scrolling for large lists
- Cache API responses
- Debounce location updates
- Use WebWorkers for calculations

---

## Security Considerations for Phase 2

- Validate all assignment changes server-side
- Rate limit map data endpoints
- Encrypt location data in transit (HTTPS)
- Audit all assignment changes
- Verify user permissions for incident access

This Phase 2 roadmap will transform CivicShield into a fully operational emergency response platform with visual incident tracking and real-time responder coordination.
