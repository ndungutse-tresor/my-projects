# CivicShield Frontend

React + Vite frontend for the emergency response platform.

## Quick Start

```bash
cd frontend
npm install
npm run dev
```

Frontend runs on http://localhost:5173

## Building

```bash
npm run build
```

Output is in the `dist/` directory.

## Project Structure

```
frontend/src/
├── pages/
│   ├── LoginPage.jsx
│   ├── RegisterPage.jsx
│   ├── DashboardPage.jsx
│   ├── SOSPage.jsx
│   ├── ResponderDashboard.jsx
│   └── DispatcherDashboard.jsx
├── components/
│   ├── MapComponent.jsx
│   ├── IncidentCard.jsx
│   ├── ResponderCard.jsx
│   └── Navigation.jsx
├── context/
│   └── AuthContext.jsx
├── hooks/
│   └── useAuth.js
├── lib/
│   ├── api.js
│   └── socket.js
├── App.jsx
├── main.jsx
└── index.css
```

## Features

- **Role-based Dashboards**: Citizen, Responder, Dispatcher, Admin
- **SOS Emergency Reporting**: Quick emergency alert with geolocation
- **Real-time Updates**: Socket.IO integration
- **Live Map**: Incident and responder locations
- **Responsive UI**: Mobile-first design
