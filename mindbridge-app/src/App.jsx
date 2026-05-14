import React, { useEffect, useState } from 'react';
import { SEED_USERS, SEED_APPLICATIONS, SEED_STORIES, SEED_SESSIONS, SEED_MESSAGES } from './data/seedData';
import { dataSource, isSupabaseEnabled } from './lib/dataSource';
import Spinner from './components/Spinner';
import Sidebar from './components/Sidebar';
import LandingPage from './pages/LandingPage';
import Dashboard from './pages/Dashboard';
import StoriesPage from './pages/StoriesPage';
import AddStoryPage from './pages/AddStoryPage';
import MessagesPage from './pages/MessagesPage';
import SessionsPage from './pages/SessionsPage';
import EnrollmentPage from './pages/EnrollmentPage';
import ApplicationsPage from './pages/ApplicationsPage';
import UsersPage from './pages/UsersPage';
import AdminSchedulePage from './pages/AdminSchedulePage';
import WellnessResourcesPage from './pages/WellnessResourcesPage';
import SolidMindsClinicPage from './pages/SolidMindsClinicPage';

export default function App() {
  const [currentUser, setCurrentUser] = useState(null);
  const [page, setPage] = useState('dashboard');
  const [users, setUsers] = useState(SEED_USERS);
  const [applications, setApplications] = useState(SEED_APPLICATIONS);
  const [stories, setStories] = useState(SEED_STORIES);
  const [sessions, setSessions] = useState(SEED_SESSIONS);
  const [messages, setMessages] = useState(SEED_MESSAGES);
  const [loading, setLoading] = useState(true);
  const [usingSupabase] = useState(isSupabaseEnabled);

  useEffect(() => {
    const loadData = async () => {
      setLoading(true);
      try {
        const [fetchedUsers, fetchedApplications, fetchedStories, fetchedSessions, fetchedMessages] = await Promise.all([
          dataSource.getUsers(),
          dataSource.getApplications(),
          dataSource.getStories(),
          dataSource.getSessions(),
          dataSource.getAllMessages(),
        ]);

        if (Array.isArray(fetchedUsers)) setUsers(fetchedUsers);
        if (Array.isArray(fetchedApplications)) setApplications(fetchedApplications);
        if (Array.isArray(fetchedStories)) setStories(fetchedStories);
        if (Array.isArray(fetchedSessions)) setSessions(fetchedSessions);
        if (Array.isArray(fetchedMessages)) setMessages(fetchedMessages);
      } catch (error) {
        console.error('Unable to load data from Supabase:', error);
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, []);

  const handleLogin = (user) => {
    setCurrentUser({ ...user, enrolled: user.enrolled || false });
    setPage('dashboard');
  };

  const handleLogout = () => {
    setCurrentUser(null);
    setPage('landing');
  };

  if (loading) {
    return (
      <div style={{ display: 'grid', placeItems: 'center', minHeight: '100vh', background: '#f0f4f8' }}>
        <Spinner />
      </div>
    );
  }

  if (!currentUser) {
    return <LandingPage onLogin={handleLogin} users={users} setUsers={setUsers} applications={applications} setApplications={setApplications} />;
  }

  const renderPage = () => {
    switch(page) {
      case 'dashboard': return <Dashboard user={currentUser} users={users} setUsers={setUsers} stories={stories} sessions={sessions} applications={applications} setPage={setPage} />;
      case 'stories': return <StoriesPage user={currentUser} stories={stories} setStories={setStories} users={users} setMessages={setMessages} />;
      case 'stories-admin': return <StoriesPage user={currentUser} stories={stories} setStories={setStories} users={users} setMessages={setMessages} />;
      case 'add-story': return <AddStoryPage user={currentUser} stories={stories} setStories={setStories} />;
      case 'sessions': return <SessionsPage user={currentUser} sessions={sessions} setSessions={setSessions} users={users} />;
      case 'sessions-admin': return <SessionsPage user={currentUser} sessions={sessions} setSessions={setSessions} users={users} />;
      case 'messages': return <MessagesPage user={currentUser} users={users} messages={messages} setMessages={setMessages} />;
      case 'enroll': return <EnrollmentPage user={currentUser} />;
      case 'applications': return <ApplicationsPage applications={applications} setApplications={setApplications} users={users} setUsers={setUsers} />;
      case 'users': return <UsersPage users={users} setUsers={setUsers} />;
      case 'schedule-session': return <AdminSchedulePage users={users} sessions={sessions} setSessions={setSessions} />;
      case 'wellness-admin': return <WellnessResourcesPage isAdminView={true} standalone />;
      case 'solid-minds': return <SolidMindsClinicPage />;
      default: return <Dashboard user={currentUser} users={users} stories={stories} sessions={sessions} applications={applications} setPage={setPage} />;
    }
  };

  return (
    <div style={{display:'flex',background:'#f0f4f8',minHeight:'100vh'}}>
      <Sidebar user={currentUser} page={page} setPage={setPage} onLogout={handleLogout} />
      <div className="main-content">
        {renderPage()}
      </div>
    </div>
  );
}
