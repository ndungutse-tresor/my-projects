-- MindBridge — Full Database Setup
-- Run this in: Supabase Dashboard → SQL Editor → New Query → Paste → Run

-- ============================================================
-- 1. TABLES
-- ============================================================

drop table if exists messages cascade;
drop table if exists sessions cascade;
drop table if exists stories cascade;
drop table if exists applications cascade;
drop table if exists users cascade;

create table users (
  id text primary key,
  name text not null,
  email text unique not null,
  password text not null,
  role text not null,
  avatar text,
  color text,
  online boolean default false,
  enrolled boolean default false,
  "enrolledDate" text,
  "applicationStatus" text,
  created_at timestamp default now()
);

create table applications (
  id text primary key,
  "userId" text,
  name text not null,
  email text not null,
  "studentId" text not null,
  issue text not null,
  urgency text not null,
  date text not null,
  status text not null,
  created_at timestamp default now()
);

create table stories (
  id text primary key,
  title text not null,
  author text not null,
  "authorColor" text,
  tags text[],
  excerpt text,
  content text not null,
  likes integer default 0,
  views integer default 0,
  date text not null,
  category text,
  created_at timestamp default now()
);

create table sessions (
  id text primary key,
  "studentId" text,
  "counselorId" text,
  "studentName" text,
  date text not null,
  time text not null,
  status text not null,
  type text not null,
  "sessionType" text,
  anonymous boolean default true,
  notes text,
  created_at timestamp default now()
);

create table messages (
  id text primary key,
  "from" text,
  "to" text,
  text text not null,
  time text,
  date text not null,
  read boolean default false,
  created_at timestamp default now()
);

-- ============================================================
-- 2. ROW LEVEL SECURITY (open for now)
-- ============================================================

alter table users enable row level security;
alter table applications enable row level security;
alter table stories enable row level security;
alter table sessions enable row level security;
alter table messages enable row level security;

create policy "allow_all" on users for all using (true) with check (true);
create policy "allow_all" on applications for all using (true) with check (true);
create policy "allow_all" on stories for all using (true) with check (true);
create policy "allow_all" on sessions for all using (true) with check (true);
create policy "allow_all" on messages for all using (true) with check (true);

-- ============================================================
-- 3. SEED DATA
-- ============================================================

insert into users (id, name, email, password, role, avatar, color, online, enrolled, "enrolledDate", "applicationStatus") values
  ('u1', 'Dr. Amara Kamau',   'amara@mindbridge.edu',     'counselor123', 'counselor', 'AK', '#5b6cf9', true,  false, null,         null),
  ('u2', 'Admin Sarah',       'admin@mindbridge.edu',     'admin123',     'admin',     'AS', '#8b5cf6', true,  false, null,         null),
  ('u3', 'Tresor Ndungutse',  'tresor@stud.ur.ac.rw',    'student123',   'student',   'TN', '#14b8a6', true,  true,  '2025-09-01', null),
  ('u4', 'Alice Mutoni',      'alice@stud.ur.ac.rw',     'student123',   'student',   'AM', '#f59e0b', false, true,  '2025-08-15', null),
  ('u5', 'Jean Paul Uwimana', 'jp@stud.ur.ac.rw',        'student123',   'student',   'JP', '#f43f5e', false, false, null,         'pending'),
  ('u6', 'Hope Ingabire',     'hope@stud.ur.ac.rw',      'peer123',      'peer',      'HI', '#38c88c', true,  false, null,         null);

insert into applications (id, "userId", name, email, "studentId", issue, urgency, date, status) values
  ('a1', 'u5',  'Jean Paul Uwimana', 'jp@stud.ur.ac.rw',       'STU2024005', 'Severe exam anxiety and difficulty sleeping. Feeling overwhelmed by coursework.',    'high',   '2024-01-28', 'pending'),
  ('a2', null,  'Claudine Uwase',    'claudine@stud.ur.ac.rw', 'STU2024012', 'Feeling isolated and homesick. Struggling to make friends on campus.',               'medium', '2024-01-30', 'pending'),
  ('a3', null,  'Eric Habimana',     'eric@stud.ur.ac.rw',     'STU2024019', 'Grief after losing a family member. Cannot concentrate on studies.',                 'high',   '2024-01-25', 'approved');

insert into stories (id, title, author, "authorColor", tags, excerpt, content, likes, views, date, category) values
  ('s1', 'How I overcame exam anxiety and found my rhythm',   'Anonymous Student',      '#5b6cf9', ARRAY['Anxiety','Academic Stress','Mindfulness'],   'I was failing two courses and barely sleeping. I thought it was over. But through counseling sessions and breathing exercises, I found a way back...', 'I was in my second year when everything collapsed. Failing two courses, barely sleeping four hours a night, and convinced that I was the only one struggling. I remember sitting in the library bathroom crying between study sessions, hoping no one would hear me.', 124, 847,  '2024-01-10', 'Anxiety'),
  ('s2', 'Depression almost took my degree — here is what saved me', 'Anonymous Student','#8b5cf6', ARRAY['Depression','Resilience','Peer Support'],  'I stopped attending classes for three weeks. My friends did not know. My parents did not know. But inside, I was disappearing...', 'Three weeks. That is how long I stayed in my room, only leaving to use the bathroom when I was sure my roommate was asleep. I convinced myself that everyone was better off without my presence.', 203, 1204, '2024-01-05', 'Depression'),
  ('s3', 'Learning to ask for help changed my life',           'Hope I. (Peer Supporter)','#38c88c', ARRAY['Peer Support','Self-Worth','Community'],  'Growing up, asking for help felt like admitting defeat. Until the day I realized that strength and vulnerability are not opposites...', 'In my culture, you don''t talk about your problems. You endure. You are strong. Asking for help is weakness — at least, that is what I believed for 20 years.', 167, 932,  '2023-12-20', 'Self-Worth'),
  ('s4', 'Navigating grief while keeping my GPA',              'Anonymous Student',      '#f59e0b', ARRAY['Grief','Loss','Coping Strategies'],          'My mother passed away mid-semester. The university system felt cold and impossible. MindBridge became my anchor...', 'The phone call came on a Tuesday morning, one hour before my biology exam. I sat in the exam hall anyway, because I didn''t know what else to do.', 89,  614,  '2023-11-30', 'Grief & Loss');

insert into sessions (id, "studentId", "counselorId", "studentName", date, time, status, type, anonymous, notes) values
  ('sess1', 'u3', 'u1', 'Tresor Ndungutse', '2024-02-05', '10:00', 'upcoming',  'video', true, ''),
  ('sess2', 'u4', 'u1', 'Alice Mutoni',     '2024-02-05', '11:30', 'upcoming',  'video', true, ''),
  ('sess3', 'u3', 'u1', 'Tresor Ndungutse', '2024-01-29', '10:00', 'completed', 'video', true, 'Good progress on anxiety management techniques.');

insert into messages (id, "from", "to", text, time, date) values
  ('m1', 'u1', 'u3', 'Hello Tresor, how are you feeling today?',                                    '10:02 AM', '2024-01-31'),
  ('m2', 'u3', 'u1', 'A bit better than last week, thank you. The breathing exercises helped.',     '10:05 AM', '2024-01-31'),
  ('m3', 'u1', 'u3', 'That''s wonderful to hear! Keep practicing. Our session is on Monday.',       '10:07 AM', '2024-01-31'),
  ('m4', 'u3', 'u1', 'I''ll be there. I feel much more comfortable with the anonymous video option.','10:09 AM', '2024-01-31');
