# CivicShield — Emergency Response Platform

A comprehensive emergency response platform enabling real-time incident reporting, responder assignment, and coordination for faster, more effective emergency services.

## Features

### MVP (Phase 1)
- ✅ **Real-time Emergency Reporting**: SOS button with incident creation
- ✅ **Live Map Integration**: Google Maps / Mapbox with incident markers
- ✅ **Responder Dashboard**: Assign responders to incidents in real-time
- ✅ **Role-Based Access**: Citizens, Responders, Dispatchers, Admins
- ✅ **JWT Authentication**: Secure login/register with token-based auth
- ✅ **Real-time Updates**: Socket.IO for live incident status and responder location
- ✅ **Incident Tracking**: Complete incident lifecycle management
- ✅ **Admin Dashboard**: Monitor, manage, and oversee all incidents

### Future Enhancements
- AI-powered incident categorization and severity assessment
- Smart resource allocation using machine learning
- Predictive deployment based on incident patterns
- Integration with smart city IoT sensors
- Multi-language support
- Mobile native apps (React Native)

## Tech Stack

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: MongoDB
- **Real-time**: Socket.IO
- **Authentication**: JWT (JSON Web Tokens) + bcryptjs
- **Security**: Helmet, CORS, Input validation
- **Maps**: Google Maps / Mapbox APIs

### Frontend
- **Framework**: React 18
- **Build**: Vite
- **Styling**: Tailwind CSS / CSS Modules
- **Maps**: React Leaflet or Google Maps React
- **Real-time**: Socket.IO Client
- **State Management**: React Hooks + Context API

## Project Structure

```
civicshield/
├── server.js                    # Express server entry point
├── config/
│   └── database.js              # MongoDB connection
├── middleware/
│   ├── auth.js                  # JWT authentication middleware
│   └── validation.js            # Input validation middleware
├── models/
│   ├── User.js                  # User schema (Citizens, Responders, etc.)
│   ├── Incident.js              # Incident schema
│   ├── Responder.js             # Responder availability/location
│   ├── Assignment.js            # Incident-to-Responder assignments
│   └── AuditLog.js              # Activity logging
├── routes/
│   ├── auth.js                  # Authentication endpoints
│   ├── incidents.js             # Incident CRUD endpoints
│   ├── responders.js            # Responder management
│   ├── assignments.js           # Assignment endpoints
│   ├── dashboard.js             # Dashboard/analytics endpoints
│   └── admin.js                 # Admin management endpoints
├── controllers/
│   ├── authController.js        # Auth logic
│   ├── incidentController.js    # Incident logic
│   ├── responderController.js   # Responder logic
│   └── dashboardController.js   # Dashboard logic
├── services/
│   ├── notificationService.js   # SMS/Email notifications
│   ├── mapService.js            # Geolocation & distance calculations
│   ├── assignmentService.js     # Smart responder assignment
│   └── analyticsService.js      # Incident analytics
├── socket/
│   └── handlers.js              # Socket.IO event handlers
├── public/                      # Static frontend files
├── tests/                       # Test files
├── .env.example                 # Environment variables template
├── .gitignore
└── package.json
```

## Quick Start

### Prerequisites
- Node.js 16+
- MongoDB (local or Atlas)
- npm or yarn

### Installation

```bash
# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Update .env with your configuration
# - MongoDB connection string
# - JWT secret
# - API keys (Google Maps, etc.)
```

### Development

```bash
npm run dev
```

Server runs on `http://localhost:5000`

### Production

```bash
npm start
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Create new account
- `POST /api/auth/login` - Login and get JWT token
- `POST /api/auth/logout` - Logout
- `GET /api/auth/me` - Get current user profile

### Incidents
- `POST /api/incidents` - Create incident (SOS)
- `GET /api/incidents` - List incidents (filtered by role)
- `GET /api/incidents/:id` - Get incident details
- `PUT /api/incidents/:id` - Update incident status
- `DELETE /api/incidents/:id` - Delete incident (admin)

### Responders
- `GET /api/responders` - List available responders
- `PUT /api/responders/:id/location` - Update responder location
- `PUT /api/responders/:id/status` - Update responder availability
- `GET /api/responders/:id` - Get responder details

### Assignments
- `POST /api/assignments` - Create assignment
- `GET /api/assignments` - List assignments
- `PUT /api/assignments/:id` - Update assignment status
- `GET /api/assignments/incident/:id` - Get responders assigned to incident

### Dashboard
- `GET /api/dashboard/stats` - Get platform statistics
- `GET /api/dashboard/incidents/live` - Real-time incident feed
- `GET /api/dashboard/heatmap` - Incident density heatmap

## Socket.IO Events

### Client to Server
- `incident:create` - Broadcast new incident
- `responder:location` - Update responder GPS location
- `responder:status` - Change availability status
- `assignment:update` - Update assignment progress
- `incident:cancel` - Cancel incident

### Server to Client
- `incident:new` - New incident alert
- `incident:updated` - Incident status change
- `assignment:created` - New assignment notification
- `responder:nearby` - Notify nearby responders
- `incident:resolved` - Incident completion notification

## Database Models

### User
```javascript
{
  _id: ObjectId,
  email: String (unique),
  password: String (hashed),
  name: String,
  phone: String,
  role: "citizen" | "responder" | "dispatcher" | "admin",
  verified: Boolean,
  avatar: String (URL),
  address: String,
  createdAt: Date,
  updatedAt: Date
}
```

### Incident
```javascript
{
  _id: ObjectId,
  reporter: ObjectId (User),
  title: String,
  description: String,
  type: "medical" | "fire" | "security" | "accident" | "other",
  severity: "low" | "medium" | "high" | "critical",
  location: {
    lat: Number,
    lng: Number,
    address: String
  },
  status: "active" | "in-progress" | "resolved" | "cancelled",
  assignedResponders: [ObjectId],
  createdAt: Date,
  updatedAt: Date,
  resolvedAt: Date
}
```

## Authentication Flow

1. **Register**: User creates account → Password hashed with bcryptjs → User stored in DB
2. **Login**: User submits credentials → Password verified → JWT token generated → Token sent to client
3. **Protected Routes**: Client sends token in Authorization header → Middleware verifies token → Request proceeds or rejected
4. **Token Expiration**: Token expires after configured time → User must re-login

## Real-time Flow

1. **User initiates SOS**: Creates incident via REST API
2. **Server broadcasts**: Socket.IO emits `incident:new` to all connected responders
3. **Responders notified**: Mobile/web clients receive alert with incident details and map
4. **Assignment**: Dispatcher assigns responders via assignment endpoint
5. **Live Updates**: Socket.IO updates both responders and incident reporter in real-time
6. **Resolution**: Incident marked as resolved, notifications sent

## Security Considerations

- **Password Hashing**: bcryptjs with salt rounds
- **JWT Tokens**: Signed with secret, expires after 7 days
- **CORS**: Restricted to trusted domains
- **Input Validation**: Express-validator on all endpoints
- **HTTPS**: Required in production
- **Rate Limiting**: Implement to prevent abuse
- **Audit Logging**: All critical actions logged with timestamp and user

## Deployment

### Option 1: Heroku
```bash
# Create app
heroku create civicshield

# Set environment variables
heroku config:set JWT_SECRET=your_secret

# Deploy
git push heroku main
```

### Option 2: AWS EC2
- Launch EC2 instance (Node.js AMI)
- Install MongoDB
- Clone repository
- Run with PM2 for process management
- Configure CloudFront CDN

### Option 3: Docker
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 5000
CMD ["node", "server.js"]
```

## Testing

```bash
npm test
```

Test coverage includes:
- Authentication flows
- Incident creation and updates
- Responder assignment logic
- Real-time socket events
- API endpoint validation

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT License - See LICENSE file for details

## Support

For issues, feature requests, or questions:
- GitHub Issues: [CivicShield Issues]
- Email: support@civicshield.local

