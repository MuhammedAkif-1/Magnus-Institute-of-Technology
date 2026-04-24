-- ============================================================
-- Magnus Institute of Technology - Supabase Schema
-- Run this in Supabase SQL Editor
-- ============================================================

-- Users table (extends Supabase auth.users)
create table public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  email text,
  role text check (role in ('admin','branch')) default 'branch',
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

-- Branches
create table public.branches (
  id serial primary key,
  name text unique not null,
  color text default '#4361ee',
  created_at timestamptz default now()
);
alter table public.branches enable row level security;
create policy "All authenticated can read branches" on public.branches for select using (auth.role() = 'authenticated');
create policy "Admin can manage branches" on public.branches for all using (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- Departments
create table public.departments (
  id serial primary key,
  branch_name text not null,
  name text not null,
  color text default '#4361ee',
  created_at timestamptz default now(),
  unique(branch_name, name)
);
alter table public.departments enable row level security;
create policy "All authenticated can read departments" on public.departments for select using (auth.role() = 'authenticated');
create policy "Admin can manage departments" on public.departments for all using (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- Fields (rows inside departments)
create table public.fields (
  id serial primary key,
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

-- Budget data (admin sets)
create table public.budget_data (
  id serial primary key,
  branch_name text not null,
  dept_name text not null,
  field_key text not null,
  period text not null,
  value numeric default 0,
  updated_at timestamptz default now(),
  unique(branch_name, dept_name, field_key, period)
);
alter table public.budget_data enable row level security;
create policy "All authenticated can read budget" on public.budget_data for select using (auth.role() = 'authenticated');
create policy "Admin can manage budget" on public.budget_data for all using (
  exists (select 1 from public.profiles where id = auth.uid() and role = 'admin')
);

-- Actual data (branch users fill)
create table public.actual_data (
  id serial primary key,
  branch_name text not null,
  dept_name text not null,
  field_key text not null,
  period text not null,
  value numeric default 0,
  updated_at timestamptz default now(),
  unique(branch_name, dept_name, field_key, period)
);
alter table public.actual_data enable row level security;
create policy "All authenticated can read actual" on public.actual_data for select using (auth.role() = 'authenticated');
create policy "Branch can insert/update own actual" on public.actual_data for all using (
  exists (select 1 from public.profiles where id = auth.uid() and (role = 'admin' or branch_name = actual_data.branch_name))
);

-- Collection data (SMT/CMT)
create table public.collection_data (
  id serial primary key,
  branch_name text not null,
  period text not null,
  source text check (source in ('SMT','CMT')) not null,
  target numeric default 0,
  actual numeric default 0,
  updated_at timestamptz default now(),
  unique(branch_name, period, source)
);
alter table public.collection_data enable row level security;
create policy "All authenticated can read collection" on public.collection_data for select using (auth.role() = 'authenticated');
create policy "Branch can manage own collection" on public.collection_data for all using (
  exists (select 1 from public.profiles where id = auth.uid() and (role = 'admin' or branch_name = collection_data.branch_name))
);

-- Insert default branches
insert into public.branches (name, color) values
  ('Manjeri','#4361ee'),('Tirur','#f77f00'),('Kozhicode','#7b2d8b'),
  ('Kannur','#2ec4b6'),('Kasaragod','#e63946'),('Palakkad','#06d6a0'),
  ('Thrissur','#118ab2'),('Kollam','#ef476f'),('Attingal','#f4a261'),
  ('Marthadam','#073b4c'),('Allappuzha','#4361ee'),('Kuttiyadi','#f77f00'),
  ('Bangalore','#7b2d8b'),('Hyderabad','#2ec4b6');
