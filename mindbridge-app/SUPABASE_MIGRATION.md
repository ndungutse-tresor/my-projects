# MindBridge Supabase Migration Guide

## Setup Steps

### 1. Create a Supabase Project
- Go to [supabase.com](https://supabase.com)
- Click "New Project"
- Fill in project details and create database
- Wait for provisioning (usually 2-3 minutes)

### 2. Get Your Credentials
- Navigate to **Settings > API** in your Supabase dashboard
- Copy your **Project URL** and **anon public key**
- Create a `.env.local` file in your project root:
```
VITE_SUPABASE_URL=your_project_url
VITE_SUPABASE_ANON_KEY=your_anon_key
```

### 3. Create Database Tables
Run these SQL queries in the Supabase SQL Editor:

#### Users Table
```sql
create table users (
  id text primary key,
  name text not null,
  email text unique not null,
  password text not null,
  role text not null,
  avatar text,
  color text,
  online boolean default false,
  enrolled boolean,
  enrolledDate text,
  applicationStatus text,
  created_at timestamp default now()
);
```

#### Applications Table
```sql
create table applications (
  id text primary key,
  userId text references users(id),
  name text not null,
  email text not null,
  studentId text not null,
  issue text not null,
  urgency text not null,
  date text not null,
  status text not null,
  created_at timestamp default now()
);
```

#### Stories Table
```sql
create table stories (
  id text primary key,
  title text not null,
  author text not null,
  authorColor text,
  tags text[],
  excerpt text,
  content text not null,
  likes integer default 0,
  views integer default 0,
  date text not null,
  category text,
  created_at timestamp default now()
);
```

#### Sessions Table
```sql
create table sessions (
  id text primary key,
  studentId text references users(id),
  counselorId text references users(id),
  studentName text,
  date text not null,
  time text not null,
  status text not null,
  type text not null,
  anonymous boolean default true,
  notes text,
  created_at timestamp default now()
);
```

#### Messages Table
```sql
create table messages (
  id text primary key,
  from text references users(id),
  to text references users(id),
  text text not null,
  time text,
  date text not null,
  created_at timestamp default now()
);
```

---

## Page-by-Page Migration Plan

Use the `db` object from `src/lib/supabaseClient.js` (or `dbFallback` for local testing).

### Priority Order
1. **Dashboard** - Main entry point, uses users/sessions
2. **StoriesPage** - Read-heavy, good test case
3. **MessagesPage** - Real-time messaging
4. **SessionsPage** - Session management
5. **ApplicationsPage** - Application processing
6. **AdminSchedulePage** - Admin functions
7. **EnrollmentPage** - Enrollment logic
8. **AddStoryPage** - Story creation
9. **UsersPage** - User management
10. **WellnessResourcesPage** - Resources
11. **LandingPage** - Marketing/auth

### Template for Each Page

```jsx
import { db } from '../lib/supabaseClient'
import { dbFallback } from '../lib/dbFallback'

// Use dbFallback as fallback when Supabase isn't configured
const dataSource = import.meta.env.VITE_SUPABASE_URL ? db : dbFallback

export default function MyPage() {
  const [data, setData] = useState([])
  const [loading, setLoading] = useState(true)
  
  useEffect(() => {
    const fetchData = async () => {
      try {
        const result = await dataSource.getData()
        setData(result)
      } catch (error) {
        console.error('Error fetching data:', error)
      } finally {
        setLoading(false)
      }
    }
    
    fetchData()
  }, [])
  
  if (loading) return <Spinner />
  
  // Rest of component...
}
```

---

## Production Build & Deployment

### 1. Build Locally
```bash
npm run build
```

### 2. Push to GitHub
```bash
git add .
git commit -m "Integrate Supabase backend"
git push origin main
```

### 3. Deploy on Vercel
- Go to [vercel.com](https://vercel.com)
- Click "New Project"
- Import your GitHub repository
- Add environment variables:
  - `VITE_SUPABASE_URL=...`
  - `VITE_SUPABASE_ANON_KEY=...`
- Click "Deploy"

**Done!** Your app is live 🚀

---

## Testing Both Modes

- **Development**: App works with seed data OR Supabase (if configured)
- **No Breaking Changes**: Existing pages continue working with seed data
- **Gradual Migration**: Migrate one page at a time while others still use seed data

---

## Useful Supabase Commands

Check current Supabase client status:
```javascript
console.log(import.meta.env.VITE_SUPABASE_URL ? 'Supabase Ready' : 'Using Seed Data')
```

Test a database query:
```javascript
import { db } from './lib/supabaseClient'
const users = await db.getUsers()
console.log(users)
```
