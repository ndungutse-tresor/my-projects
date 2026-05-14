-- MindBridge — Production Database Setup
-- Run in: Supabase Dashboard → SQL Editor → New Query → Paste → Run
-- This creates clean tables and ONE admin account. All other data comes from real users.

-- ============================================================
-- 1. DROP EXISTING TABLES (clean slate)
-- ============================================================

drop table if exists messages cascade;
drop table if exists sessions cascade;
drop table if exists stories cascade;
drop table if exists applications cascade;
drop table if exists users cascade;

-- ============================================================
-- 2. CREATE TABLES
-- ============================================================

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
-- 3. ROW LEVEL SECURITY
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
-- 4. ADMIN ACCOUNT (only real account — change password after first login)
-- ============================================================

insert into users (id, name, email, password, role, avatar, color, online, enrolled)
values (
  'admin-001',
  'Tresor Ndungutse',
  'ndungutse_223003172@stud.ur.ac.rw',
  'Admin@2026',
  'admin',
  'TN',
  '#667eea',
  false,
  false
);

-- ============================================================
-- That's it. All students, counselors, stories, sessions,
-- messages, and applications will be created by real users
-- through the app.
-- ============================================================
