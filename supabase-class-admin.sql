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

create or replace function public.class_tutor_email(tutor_name text)
returns text
language sql
immutable
as $$
  select lower(regexp_replace(coalesce(tutor_name, ''), '[^a-zA-Z0-9]+', '', 'g')) || '@jeyasclub.com';
$$;

create or replace function public.is_class_tutor_for(tutor_name text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.class_tutors tutor
    where tutor.is_active = true
      and lower(coalesce(tutor.email, public.class_tutor_email(tutor.name))) = lower(coalesce(auth.jwt() ->> 'email', ''))
      and (
        lower(regexp_replace(tutor.name, '[^a-zA-Z0-9]+', '', 'g')) = lower(regexp_replace(coalesce(tutor_name, ''), '[^a-zA-Z0-9]+', '', 'g'))
        or lower(coalesce(tutor.email, public.class_tutor_email(tutor.name))) = public.class_tutor_email(tutor_name)
      )
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
  email text unique,
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

alter table public.class_tutors
add column if not exists email text unique;

update public.class_tutors
set email = public.class_tutor_email(name)
where email is null or email = '';

insert into public.class_tracker (
  booking_id,
  order_date,
  student_name,
  program_name,
  tutor,
  meetings_realized,
  meetings_total,
  payments_realized,
  payments_total,
  created_by,
  created_at,
  updated_at
)
select
  booking.id,
  booking.order_date,
  booking.student_name,
  booking.program_name,
  booking.tutor,
  0,
  0,
  1,
  1,
  booking.created_by,
  booking.created_at,
  now()
from public.class_bookings booking
where not exists (
  select 1
  from public.class_tracker tracker
  where tracker.booking_id = booking.id
);

alter table public.class_tracker enable row level security;
alter table public.class_bookings enable row level security;
alter table public.class_programs enable row level security;
alter table public.class_tutors enable row level security;

drop policy if exists "Class admins can read tracker" on public.class_tracker;
drop policy if exists "Class tutors can read own tracker" on public.class_tracker;
drop policy if exists "Class admins can insert tracker" on public.class_tracker;
drop policy if exists "Class admins can update tracker" on public.class_tracker;
drop policy if exists "Class admins can delete tracker" on public.class_tracker;

create policy "Class admins can read tracker"
on public.class_tracker
for select
to authenticated
using (public.is_class_admin());

create policy "Class tutors can read own tracker"
on public.class_tracker
for select
to authenticated
using (public.is_class_tutor_for(tutor));

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
drop policy if exists "Class tutors can read own bookings" on public.class_bookings;
drop policy if exists "Class admins can insert bookings" on public.class_bookings;
drop policy if exists "Class admins can update bookings" on public.class_bookings;
drop policy if exists "Class admins can delete bookings" on public.class_bookings;

create policy "Class admins can read bookings"
on public.class_bookings
for select
to authenticated
using (public.is_class_admin());

create policy "Class tutors can read own bookings"
on public.class_bookings
for select
to authenticated
using (public.is_class_tutor_for(tutor));

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
drop policy if exists "Class tutors can read own profile" on public.class_tutors;
drop policy if exists "Class admins can insert tutors" on public.class_tutors;
drop policy if exists "Class admins can update tutors" on public.class_tutors;
drop policy if exists "Class admins can delete tutors" on public.class_tutors;

create policy "Class admins can read tutors"
on public.class_tutors
for select
to authenticated
using (public.is_class_admin());

create policy "Class tutors can read own profile"
on public.class_tutors
for select
to authenticated
using (
  is_active = true
  and lower(coalesce(email, public.class_tutor_email(name))) = lower(coalesce(auth.jwt() ->> 'email', ''))
);

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

create or replace function public.update_class_tracker_meeting_realized(
  tracker_id uuid,
  next_meetings_realized integer
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  tracker_record public.class_tracker;
begin
  if next_meetings_realized is null or next_meetings_realized < 0 then
    raise exception 'Meeting realized must be zero or greater';
  end if;

  select *
  into tracker_record
  from public.class_tracker
  where id = tracker_id;

  if not found then
    raise exception 'Tracker not found';
  end if;

  if tracker_record.meetings_total > 0 and next_meetings_realized > tracker_record.meetings_total then
    raise exception 'Meeting realized cannot exceed total meeting';
  end if;

  if not (public.is_class_admin() or public.is_class_tutor_for(tracker_record.tutor)) then
    raise exception 'Not allowed';
  end if;

  update public.class_tracker
  set
    meetings_realized = next_meetings_realized,
    updated_at = now()
  where id = tracker_id;
end;
$$;

grant execute on function public.update_class_tracker_meeting_realized(uuid, integer) to authenticated;

create or replace view public.class_tutor_login_accounts
with (security_invoker = true)
as
select
  name,
  coalesce(email, public.class_tutor_email(name)) as email,
  '123123'::text as password,
  is_active
from public.class_tutors
order by name;

grant select on public.class_tutor_login_accounts to authenticated;
