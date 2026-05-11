# CivicShield - Complete Setup Guide

This guide covers the full setup and deployment of the CivicShield emergency response platform.

## Prerequisites

- Node.js 16+ 
- MongoDB 4.4+ (local or Atlas)
- npm or yarn
- Git
- Geolocation API key (Google Maps or Mapbox)

## Quick Start (Development)

### 1. Clone and Setup Backend

```bash
cd civicshield
cp .env.example .env
```

Edit `.env` with your configuration:
```
MONGODB_URI=mongodb://localhost:27017/civicshield
JWT_SECRET=your_super_secret_key_change_this
PORT=5000
NODE_ENV=development
```

### 2. Install Backend Dependencies

```bash
npm install
```

### 3. Start MongoDB

**Local MongoDB:**
```bash
mongod
```

**MongoDB Atlas:**
Update `.env` with your Atlas connection string:
```
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/civicshield
```

### 4. Start Backend Server

```bash
npm run dev
```

Server starts at `http://localhost:5000`

### 5. Setup Frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend runs at `http://localhost:5173`

## Architecture Overview

```
CivicShield
├── Backend (Node.js + Express)
│   ├── REST API
│   ├── Socket.IO Real-time
│   ├── MongoDB Database
│   └── JWT Authentication
├── Frontend (React + Vite)
│   ├── Citizen Interface
│   ├── Responder Dashboard
│   ├── Dispatcher Dashboard
│   └── Admin Panel
└── Database
    ├── Users
    ├── Incidents
    ├── Assignments
    ├── Responders
    └── Audit Logs
```

## Database Setup

### MongoDB Collections

The following collections are automatically created:

- **users**: User accounts (citizens, responders, dispatchers, admins)
- **incidents**: Emergency reports
- **responders**: Responder profiles and locations
- **assignments**: Incident-to-responder assignments
- **auditlogs**: Action audit trails

### Initialize Demo Data

Create a `seed.js` file in the root:

```javascript
import User from './models/User.js';
import connectDB from './config/database.js';

connectDB();

const seedData = async () => {
  try {
    // Clear existing data
    await User.deleteMany({});

    // Create demo users
    const users = await User.insertMany([
      {
        email: 'citizen@civicshield.local',
        password: 'password123',
        name: 'John Citizen',
        phone: '+1234567890',
        role: 'citizen'
      },
      {
        email: 'responder@civicshield.local',
        password: 'password123',
        name: 'Jane Responder',
        phone: '+0987654321',
        role: 'responder',
        badge: 'EMS-001',
        department: 'Emergency Medical Services',
        vehicleType: 'ambulance'
      },
      {
        email: 'dispatcher@civicshield.local',
        password: 'password123',
        name: 'Bob Dispatcher',
        phone: '+1122334455',
        role: 'dispatcher'
      }
    ]);

    console.log('✅ Demo data seeded');
    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
};

seedData();
```

Run: `node seed.js`

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login (returns JWT)
- `GET /api/auth/me` - Get current user (requires token)

### Incidents
- `POST /api/incidents` - Create incident (SOS)
- `GET /api/incidents` - List incidents
- `GET /api/incidents/:id` - Get incident details
- `PUT /api/incidents/:id` - Update incident
- `POST /api/incidents/:id/cancel` - Cancel incident

### Responders
- `GET /api/responders` - List responders
- `PUT /api/responders/location` - Update location
- `PUT /api/responders/status` - Update availability
- `GET /api/responders/available/near` - Get nearby available responders

### Assignments
- `POST /api/assignments` - Create assignment
- `GET /api/assignments` - List assignments
- `PUT /api/assignments/:id` - Update assignment status
- `GET /api/assignments/incident/:id` - Get incident assignments

### Dashboard
- `GET /api/dashboard/stats` - Platform statistics
- `GET /api/dashboard/incidents/live` - Live incidents
- `GET /api/dashboard/heatmap` - Incident heatmap data

## Real-time Events (Socket.IO)

### Client to Server
```javascript
// New incident
socket.emit('incident:create', { incidentId });

// Update responder location
socket.emit('responder:location', { userId, lat, lng, address });

// Change responder availability
socket.emit('responder:status', { userId, status });
```

### Server to Client
```javascript
// New incident alert
socket.on('incident:new', (data) => {});

// Incident updated
socket.on('incident:status:updated', (data) => {});

// Assignment created
socket.on('assignment:new', (data) => {});

// Responder location updated
socket.on('responder:location:updated', (data) => {});
```

## Environment Variables

### Backend (.env)
```
# Database
MONGODB_URI=mongodb://localhost:27017/civicshield

# JWT
JWT_SECRET=your_jwt_secret_key_change_in_production
JWT_EXPIRE=7d

# Server
PORT=5000
NODE_ENV=development
FRONTEND_URL=http://localhost:5173

# Maps API
GOOGLE_MAPS_API_KEY=your_key
MAPBOX_API_KEY=your_key
```

### Frontend (.env)
```
VITE_API_URL=http://localhost:5000/api
VITE_SOCKET_URL=http://localhost:5000
VITE_MAP_API_KEY=your_google_maps_key
```

## Authentication Flow

1. **Register**: User creates account with email, password, name, phone, role
2. **Hashing**: Password hashed with bcryptjs (10 salt rounds)
3. **JWT Token**: Generated on login, includes user ID, email, role
4. **Protected Routes**: Middleware verifies token on every protected endpoint
5. **Token Expiration**: 7 days by default

## Security Checklist

- [ ] Change `JWT_SECRET` to a strong random value
- [ ] Use HTTPS in production
- [ ] Enable CORS for trusted domains only
- [ ] Use environment variables for all secrets
- [ ] Implement rate limiting on auth endpoints
- [ ] Validate and sanitize all inputs
- [ ] Hash passwords with bcryptjs
- [ ] Use MongoDB Atlas with IP whitelist
- [ ] Enable audit logging
- [ ] Regular security updates

## Deployment

### Docker Deployment

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 5000
CMD ["node", "server.js"]
```

### Deploy to Heroku

```bash
# Install Heroku CLI
heroku login

# Create app
heroku create civicshield

# Set environment variables
heroku config:set JWT_SECRET=your_secret
heroku config:set MONGODB_URI=your_mongodb_uri

# Deploy
git push heroku main

# View logs
heroku logs --tail
```

### Deploy to AWS EC2

1. Launch EC2 instance (t2.micro, Ubuntu 20.04)
2. SSH into instance
3. Install Node.js and MongoDB
4. Clone repository
5. Configure .env
6. Install PM2: `npm install -g pm2`
7. Start with PM2: `pm2 start server.js`
8. Setup CloudFront CDN
9. Configure security groups for port 5000

### Deploy Frontend to Vercel

```bash
cd frontend
npm run build
```

Push to GitHub, connect to Vercel, auto-deploys on push

## Testing

### Test User Accounts

```
Citizen:
- Email: citizen@civicshield.local
- Password: password123

Responder:
- Email: responder@civicshield.local
- Password: password123

Dispatcher:
- Email: dispatcher@civicshield.local
- Password: password123
```

### Test API Endpoints

```bash
# Register
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@civicshield.local",
    "password": "password123",
    "name": "Test User",
    "phone": "+1234567890",
    "role": "citizen"
  }'

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@civicshield.local",
    "password": "password123"
  }'

# Create Incident
curl -X POST http://localhost:5000/api/incidents \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "title": "Medical Emergency",
    "description": "Person collapsed at mall",
    "type": "medical",
    "severity": "critical",
    "location": {
      "lat": 40.7128,
      "lng": -74.0060,
      "address": "New York, NY"
    }
  }'
```

## Troubleshooting

### Backend Won't Start
- Check MongoDB connection string
- Verify JWT_SECRET is set
- Check port 5000 isn't in use
- View logs: `npm run dev`

### Frontend Can't Connect to Backend
- Verify backend is running on port 5000
- Check CORS settings in server.js
- Verify API URL in frontend config
- Check browser console for errors

### Location Not Working
- Enable location permissions in browser
- Check HTTPS (required for geolocation in production)
- Verify GPS hardware on mobile
- Test with mock coordinates

### Database Errors
- Check MongoDB connection string
- Verify IP whitelist in MongoDB Atlas
- Check disk space
- Verify user permissions

## Monitoring

- Monitor server logs: `heroku logs --tail`
- Track incidents in real-time: Dashboard
- Monitor responder availability: Dispatcher panel
- View audit logs: Admin panel
- Set up monitoring alerts with DataDog or New Relic

## Future Enhancements

- AI incident categorization
- Predictive responder deployment
- Smart resource allocation
- Mobile native apps
- Video call integration
- Multi-language support
- Advanced analytics
- API rate limiting
- Webhook integrations
- Machine learning incident prediction
