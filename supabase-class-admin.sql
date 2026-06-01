-- Run this in Supabase SQL Editor before using /admin/ and /input/.
-- Only these emails can read or write the Class Tracker and Class Booking data.

create or replace function public.is_class_admin()
returns boolean
language sql
stable
as $$
  select lower(coalesce(auth.jwt() ->> 'email', '')) in (
    'jihamalia@gmail.com',
    'jeyasclub@gmail.com'
  );
$$;

create table if not exists public.class_tracker (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid,
  order_date date not null,
  student_name text not null,
  program_name text not null,
  tutor text not null,
  meetings_realized integer not null default 0,
  meetings_total integer not null default 0,
  payments_realized integer not null default 0,
  payments_total integer not null default 0,
  created_by text not null default lower(coalesce(auth.jwt() ->> 'email', '')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.class_bookings (
  id uuid primary key default gen_random_uuid(),
  order_date date not null,
  student_name text not null,
  program_name text not null,
  price numeric(12,2) not null default 0,
  tutor text not null,
  created_by text not null default lower(coalesce(auth.jwt() ->> 'email', '')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.class_programs (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  is_active boolean not null default true,
  created_by text not null default lower(coalesce(auth.jwt() ->> 'email', '')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.class_tutors (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  is_active boolean not null default true,
  created_by text not null default lower(coalesce(auth.jwt() ->> 'email', '')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.class_tracker
add column if not exists booking_id uuid,
add column if not exists student_name text not null default '';

alter table public.class_bookings
add column if not exists student_name text not null default '';

alter table public.class_tracker enable row level security;
alter table public.class_bookings enable row level security;
alter table public.class_programs enable row level security;
alter table public.class_tutors enable row level security;

drop policy if exists "Class admins can read tracker" on public.class_tracker;
drop policy if exists "Class admins can insert tracker" on public.class_tracker;
drop policy if exists "Class admins can update tracker" on public.class_tracker;
drop policy if exists "Class admins can delete tracker" on public.class_tracker;

create policy "Class admins can read tracker"
on public.class_tracker
for select
to authenticated
using (public.is_class_admin());

create policy "Class admins can insert tracker"
on public.class_tracker
for insert
to authenticated
with check (public.is_class_admin());

create policy "Class admins can update tracker"
on public.class_tracker
for update
to authenticated
using (public.is_class_admin())
with check (public.is_class_admin());

create policy "Class admins can delete tracker"
on public.class_tracker
for delete
to authenticated
using (public.is_class_admin());

drop policy if exists "Class admins can read bookings" on public.class_bookings;
drop policy if exists "Class admins can insert bookings" on public.class_bookings;
drop policy if exists "Class admins can update bookings" on public.class_bookings;
drop policy if exists "Class admins can delete bookings" on public.class_bookings;

create policy "Class admins can read bookings"
on public.class_bookings
for select
to authenticated
using (public.is_class_admin());

create policy "Class admins can insert bookings"
on public.class_bookings
for insert
to authenticated
with check (public.is_class_admin());

create policy "Class admins can update bookings"
on public.class_bookings
for update
to authenticated
using (public.is_class_admin())
with check (public.is_class_admin());

create policy "Class admins can delete bookings"
on public.class_bookings
for delete
to authenticated
using (public.is_class_admin());

drop policy if exists "Class admins can read programs" on public.class_programs;
drop policy if exists "Class admins can insert programs" on public.class_programs;
drop policy if exists "Class admins can update programs" on public.class_programs;
drop policy if exists "Class admins can delete programs" on public.class_programs;

create policy "Class admins can read programs"
on public.class_programs
for select
to authenticated
using (public.is_class_admin());

create policy "Class admins can insert programs"
on public.class_programs
for insert
to authenticated
with check (public.is_class_admin());

create policy "Class admins can update programs"
on public.class_programs
for update
to authenticated
using (public.is_class_admin())
with check (public.is_class_admin());

create policy "Class admins can delete programs"
on public.class_programs
for delete
to authenticated
using (public.is_class_admin());

drop policy if exists "Class admins can read tutors" on public.class_tutors;
drop policy if exists "Class admins can insert tutors" on public.class_tutors;
drop policy if exists "Class admins can update tutors" on public.class_tutors;
drop policy if exists "Class admins can delete tutors" on public.class_tutors;

create policy "Class admins can read tutors"
on public.class_tutors
for select
to authenticated
using (public.is_class_admin());

create policy "Class admins can insert tutors"
on public.class_tutors
for insert
to authenticated
with check (public.is_class_admin());

create policy "Class admins can update tutors"
on public.class_tutors
for update
to authenticated
using (public.is_class_admin())
with check (public.is_class_admin());

create policy "Class admins can delete tutors"
on public.class_tutors
for delete
to authenticated
using (public.is_class_admin());
