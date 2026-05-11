import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, AuthContext } from './context/AuthContext';
import LoginPage          from './pages/LoginPage';
import RegisterPage       from './pages/RegisterPage';
import DashboardPage      from './pages/DashboardPage';
import SOSPage            from './pages/SOSPage';
import SOSConfirmPage     from './pages/SOSConfirmPage';
import MapPage            from './pages/MapPage';
import MyIncidentsPage    from './pages/MyIncidentsPage';
import MyAssignmentsPage  from './pages/MyAssignmentsPage';
import AdminPage          from './pages/AdminPage';
import './index.css';

const ProtectedRoute = ({ children }) => {
  const { user, loading } = React.useContext(AuthContext);
  if (loading) return <div style={{ display:'flex', alignItems:'center', justifyContent:'center', height:'100vh', fontSize:18 }}>Loading…</div>;
  if (!user)   return <Navigate to="/login" />;
  return children;
};

const P = ({ children }) => <ProtectedRoute>{children}</ProtectedRoute>;

const App = () => (
  <Router future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
    <AuthProvider>
      <Routes>
        <Route path="/login"    element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />

        <Route path="/dashboard"       element={<P><DashboardPage /></P>} />
        <Route path="/sos"             element={<P><SOSPage /></P>} />
        <Route path="/sos-confirm/:id" element={<P><SOSConfirmPage /></P>} />
        <Route path="/my-incidents"    element={<P><MyIncidentsPage /></P>} />
        <Route path="/my-assignments"  element={<P><MyAssignmentsPage /></P>} />
        <Route path="/admin"           element={<P><AdminPage /></P>} />
        <Route path="/dispatcher-map"  element={<P><MapPage /></P>} />
        <Route path="/responder-map"   element={<P><MapPage /></P>} />

        <Route path="/" element={<Navigate to="/dashboard" />} />
      </Routes>
    </AuthProvider>
  </Router>
);

export default App;
