-- ============================================================
-- Magnus Institute of Technology - Supabase Schema v2
-- Run this in Supabase SQL Editor (drop old tables first if needed)
-- ============================================================

-- Profiles
create table if not exists public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  email text,
  role text check (role in ('admin','branch')) default 'branch',
  institute_name text,
  branch_name text,
  created_at timestamptz default now()
);
alter table public.profiles enable row level security;
create policy "Users can read own profile" on public.profiles for select using (auth.uid() = id);
create policy "Admin can read all profiles" on public.profiles for select using (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);
create policy "Admin can update profiles" on public.profiles for update using (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- Institutes
create table if not exists public.institutes (
  id serial primary key,
  name text unique not null,
  color text default '#4361ee',
  created_at timestamptz default now()
);
alter table public.institutes enable row level security;
create policy "All authenticated can read institutes" on public.institutes for select using (auth.role() = 'authenticated');
create policy "Admin can manage institutes" on public.institutes for all using (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- Branches
create table if not exists public.branches (
  id serial primary key,
  institute_name text not null,
  name text not null,
  color text default '#4361ee',
  created_at timestamptz default now(),
  unique(institute_name, name)
);
alter table public.branches enable row level security;
create policy "All authenticated can read branches" on public.branches for select using (auth.role() = 'authenticated');
create policy "Admin can manage branches" on public.branches for all using (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- Departments
create table if not exists public.departments (
  id serial primary key,
  institute_name text not null,
  branch_name text not null,
  name text not null,
  color text default '#4361ee',
  created_at timestamptz default now(),
  unique(institute_name, branch_name, name)
);
alter table public.departments enable row level security;
create policy "All authenticated can read departments" on public.departments for select using (auth.role() = 'authenticated');
create policy "Admin can manage departments" on public.departments for all using (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- Fields
create table if not exists public.fields (
  id serial primary key,
  institute_name text not null,
  branch_name text not null,
  dept_name text not null,
  category text not null,
  subcategory text not null,
  sort_order integer default 0,
  created_at timestamptz default now()
);
alter table public.fields enable row level security;
create policy "All authenticated can read fields" on public.fields for select using (auth.role() = 'authenticated');
create policy "Admin can manage fields" on public.fields for all using (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- Budget data
create table if not exists public.budget_data (
  id serial primary key,
  institute_name text,
  branch_name text not null,
  dept_name text not null,
  field_key text not null,
  period text not null,
  value numeric default 0,
  updated_at timestamptz default now(),
  unique(institute_name, branch_name, dept_name, field_key, period)
);
alter table public.budget_data enable row level security;
create policy "All authenticated can read budget" on public.budget_data for select using (auth.role() = 'authenticated');
create policy "Admin can manage budget" on public.budget_data for all
  using (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'))
  with check (exists (select 1 from public.profiles where id = auth.uid() and role = 'admin'));

-- Actual data
create table if not exists public.actual_data (
  id serial primary key,
  institute_name text,
  branch_name text not null,
  dept_name text not null,
  field_key text not null,
  period text not null,
  value numeric default 0,
  updated_at timestamptz default now(),
  unique(institute_name, branch_name, dept_name, field_key, period)
);
alter table public.actual_data enable row level security;
create policy "All authenticated can read actual" on public.actual_data for select using (auth.role() = 'authenticated');
create policy "Branch can insert/update own actual" on public.actual_data for all
  using (exists (select 1 from public.profiles where id = auth.uid() and (role = 'admin' or (institute_name = actual_data.institute_name and branch_name = actual_data.branch_name))))
  with check (exists (select 1 from public.profiles where id = auth.uid() and (role = 'admin' or (institute_name = actual_data.institute_name and branch_name = actual_data.branch_name))));

-- Collection data
create table if not exists public.collection_data (
  id serial primary key,
  institute_name text,
  branch_name text not null,
  period text not null,
  source text check (source in ('SMT','CMT')) not null,
  target numeric default 0,
  actual numeric default 0,
  updated_at timestamptz default now(),
  unique(institute_name, branch_name, period, source)
);
alter table public.collection_data enable row level security;
create policy "All authenticated can read collection" on public.collection_data for select using (auth.role() = 'authenticated');
create policy "Branch can manage own collection" on public.collection_data for all
  using (exists (select 1 from public.profiles where id = auth.uid() and (role = 'admin' or (institute_name = collection_data.institute_name and branch_name = collection_data.branch_name))))
  with check (exists (select 1 from public.profiles where id = auth.uid() and (role = 'admin' or (institute_name = collection_data.institute_name and branch_name = collection_data.branch_name))));

-- ============================================================
-- SEED DATA
-- ============================================================

-- Institutes
insert into public.institutes (name, color) values
  ('Magnus Institute of Technology', '#4361ee'),
  ('Alims School of Business',       '#f77f00'),
  ('MEL Islamic School',             '#7b2d8b'),
  ('M&D Institute',                  '#2ec4b6'),
  ('Merchx',                         '#e63946'),
  ('Aider India',                    '#06d6a0')
on conflict (name) do nothing;

-- Branches
insert into public.branches (institute_name, name, color) values
  ('Magnus Institute of Technology','Manjeri','#4361ee'),
  ('Magnus Institute of Technology','Tirur','#f77f00'),
  ('Magnus Institute of Technology','Kozhicode','#7b2d8b'),
  ('Magnus Institute of Technology','Kannur','#2ec4b6'),
  ('Magnus Institute of Technology','Kasaragod','#e63946'),
  ('Magnus Institute of Technology','Palakkad','#06d6a0'),
  ('Magnus Institute of Technology','Thrissur','#118ab2'),
  ('Magnus Institute of Technology','Kollam','#ef476f'),
  ('Magnus Institute of Technology','Attingal','#f4a261'),
  ('Magnus Institute of Technology','Marthadam','#073b4c'),
  ('Magnus Institute of Technology','Allappuzha','#4361ee'),
  ('Magnus Institute of Technology','Kuttiyadi','#f77f00'),
  ('Magnus Institute of Technology','Bangalore','#7b2d8b'),
  ('Magnus Institute of Technology','Hyderabad','#2ec4b6'),
  ('Alims School of Business','Kozhikode','#f77f00'),
  ('Alims School of Business','Ernakulam','#2ec4b6'),
  ('Alims School of Business','Manjeri','#e63946'),
  ('MEL Islamic School','Manjeri','#7b2d8b'),
  ('M&D Institute','Manjeri','#2ec4b6'),
  ('M&D Institute','Ernakulam','#e63946'),
  ('Merchx','Manjeri','#e63946'),
  ('Aider India','Manjeri','#06d6a0')
on conflict (institute_name, name) do nothing;
