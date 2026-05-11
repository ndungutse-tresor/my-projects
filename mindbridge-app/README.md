# MindBridge — Student Mental Health Support

MindBridge is a React-based platform connecting university students with professional counselors through anonymous, face-hidden video sessions. Built with Vite for optimal development and production performance.

## Features

- **Anonymous Video Counseling**: Face blurring and voice pitch-shifting by default
- **Healed Stories Library**: Gated access for enrolled members only
- **Secure Messaging**: Encrypted conversations with counselors and peer supporters
- **Wellness Resources**: Breathing exercises, mood journal, crisis hotlines, self-help library
- **Application Management**: Admin review and approval workflow
- **Role-Based Access**: Student, Counselor, Peer Supporter, and Admin roles

## Setup

### Prerequisites
- Node.js 16+ and npm

### Installation

```bash
npm install
```

### Development

```bash
npm run dev
```

The app will open at `http://localhost:5173`. Hot module reloading is enabled for rapid development.

### Production Build

```bash
npm run build
```

Output is in the `dist/` directory, ready for static hosting.

## Project Structure

```
mindbridge-app/
├── src/
│   ├── components/
│   │   ├── Avatar.jsx          # User avatar component
│   │   ├── Spinner.jsx         # Loading spinner
│   │   ├── Modal.jsx           # Reusable modal dialog
│   │   ├── Sidebar.jsx         # Navigation sidebar
│   │   └── VideoRoom.jsx       # Anonymous video call interface
│   ├── pages/
│   │   ├── LandingPage.jsx     # Home, login, register, apply
│   │   ├── Dashboard.jsx       # Role-specific dashboard
│   │   ├── StoriesPage.jsx     # Healed stories library
│   │   ├── AddStoryPage.jsx    # Submit new story
│   │   ├── MessagesPage.jsx    # Secure messaging
│   │   ├── SessionsPage.jsx    # Counseling sessions
│   │   ├── EnrollmentPage.jsx  # Enrollment status
│   │   ├── ApplicationsPage.jsx# Admin: review applications
│   │   ├── UsersPage.jsx       # Admin: manage users
│   │   ├── AdminSchedulePage.jsx # Admin: schedule sessions
│   │   └── WellnessResourcesPage.jsx # Breathing, journal, hotlines, library
│   ├── data/
│   │   └── seedData.js         # Demo data (users, stories, sessions, etc.)
│   ├── App.jsx                 # Main app component with routing
│   ├── main.jsx                # Entry point
│   └── index.css               # Global styles
├── index.html                  # HTML template
├── vite.config.js              # Vite configuration
├── package.json                # Dependencies and scripts
└── .gitignore                  # Git ignore rules
```

## Demo Accounts

Log in with these credentials to explore different roles:

- **Student**: `tresor@stud.ur.ac.rw` / `student123`
- **Admin**: `admin@mindbridge.edu` / `admin123`
- **Counselor**: `amara@mindbridge.edu` / `counselor123`
- **Peer Supporter**: `hope@stud.ur.ac.rw` / `peer123`

## State Management

The app uses React hooks (`useState`) for state management. Key state includes:

- `currentUser`: Logged-in user object
- `users`: All platform users
- `applications`: Enrollment applications
- `stories`: Published healed stories
- `sessions`: Scheduled counseling sessions
- `messages`: Direct messages between users
- `page`: Current page/section

All data is stored in React state (not persisted). Refresh the page to reset to seed data.

## Styling

Global styles are in `src/index.css` with:
- CSS custom properties for theming
- Utility classes (`.btn`, `.card`, `.modal`, etc.)
- Responsive grid layouts
- Animations (fade-in, pulse, spin)

## Browser Support

- Chrome/Edge 90+
- Firefox 88+
- Safari 14+

## Deploy to Vercel

### Step 1: Push to GitHub
```bash
git add .
git commit -m "Initial MindBridge commit"
git push origin main
```

### Step 2: Create Vercel Project
1. Go to [vercel.com](https://vercel.com)
2. Click "Add New..." > "Project"
3. Import your GitHub repository
4. Vercel auto-detects Vite configuration
5. Click "Deploy"

### Step 3: Access Your App
Your app is live at `https://[project-name].vercel.app`

## Notes

- No database or API backend is currently configured. All data is demo data in `src/data/seedData.js`.
- To add a real backend, replace the in-memory state with API calls (e.g., fetch, axios).
- The video room component simulates video by requesting camera/mic permissions but displays placeholder content.
- Scheduling, messaging, and other interactions are simulated with setTimeout and mock logic.

## License

Built for educational and demonstration purposes.
