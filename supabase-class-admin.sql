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

create or replace function public.get_jeyasclub_member_count()
returns bigint
language plpgsql
stable
security definer
set search_path = public, auth
as $$
declare
  member_count bigint;
begin
  if not public.is_class_admin() then
    raise exception 'Not allowed';
  end if;

  select count(*)
  into member_count
  from auth.users;

  return member_count;
end;
$$;

grant execute on function public.get_jeyasclub_member_count() to authenticated;

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

create or replace function public.is_class_tutor_account()
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
  );
$$;

create table if not exists public.class_tracker (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid,
  order_date date not null,
  student_name text not null,
  student_count integer not null default 1,
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
  booking_group_id uuid not null default gen_random_uuid(),
  booking_student_order integer not null default 1,
  order_date date not null,
  valid_until date,
  certificate_issued boolean not null default false,
  testimonial_received boolean not null default false,
  student_name text not null,
  student_count integer not null default 1,
  program_name text not null,
  price numeric(12,2) not null default 0,
  tutor text not null,
  note text not null default '',
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
  zoom_link text not null default '',
  testimonial_link text not null default '',
  bank_name text not null default '',
  bank_account_number text not null default '',
  is_active boolean not null default true,
  created_by text not null default lower(coalesce(auth.jwt() ->> 'email', '')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.class_meeting_fees (
  id uuid primary key default gen_random_uuid(),
  program_name text not null,
  student_count integer not null,
  fee numeric(12,2) not null default 0,
  is_active boolean not null default true,
  created_by text not null default lower(coalesce(auth.jwt() ->> 'email', '')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (program_name, student_count)
);

create table if not exists public.class_zoom_bookings (
  id uuid primary key default gen_random_uuid(),
  booking_date date not null,
  start_time time not null,
  end_time time not null,
  tutor_name text not null,
  tutor_email text not null,
  note text not null default '',
  created_by text not null default lower(coalesce(auth.jwt() ->> 'email', '')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (start_time < end_time)
);

alter table public.class_tracker
add column if not exists booking_id uuid,
add column if not exists student_name text not null default '',
add column if not exists student_count integer not null default 1;

alter table public.class_bookings
add column if not exists booking_group_id uuid not null default gen_random_uuid(),
add column if not exists booking_student_order integer not null default 1,
add column if not exists student_name text not null default '',
add column if not exists student_count integer not null default 1,
add column if not exists valid_until date,
add column if not exists certificate_issued boolean not null default false,
add column if not exists testimonial_received boolean not null default false,
add column if not exists note text not null default '';

update public.class_bookings
set booking_group_id = id
where booking_group_id is null;

alter table public.class_tutors
add column if not exists email text unique,
add column if not exists zoom_link text not null default '',
add column if not exists testimonial_link text not null default '',
add column if not exists bank_name text not null default '',
add column if not exists bank_account_number text not null default '';

alter table public.class_meeting_fees
add column if not exists is_active boolean not null default true;

alter table public.class_zoom_bookings
drop constraint if exists class_zoom_bookings_no_overlap;

update public.class_tutors
set email = public.class_tutor_email(name)
where email is null or email = '';

update public.class_tutors tutor
set
  bank_name = bank_data.bank_name,
  bank_account_number = bank_data.bank_account_number,
  updated_at = now()
from (
  values
    ('Aya', 'MANDIRI', '1370022415984'),
    ('Dhila', 'BNI', '1254460461'),
    ('Dian', 'BCA', '0031147092'),
    ('Feby', 'BCA', '1672429310'),
    ('Fira', 'BNI', '1254691035'),
    ('Klair/Dilla', 'BCA', '7870825034'),
    ('Klair', 'BCA', '7870825034'),
    ('Dilla', 'BCA', '7870825034'),
    ('Lydia', 'BRI', '166801007389503'),
    ('Nadila', 'BNI', '1937462578'),
    ('Tista', 'BNI', '913487269'),
    ('Zahra', 'GOPAY', '0895401593441'),
    ('Zelfa', 'GOPAY', '083115310868'),
    ('Nisya', 'BCA', '5315321350'),
    ('Indi', 'MANDIRI', '1270012348361'),
    ('Ezra', 'SEABANK', '901530503283'),
    ('Lula', 'MANDIRI', '1640003022458'),
    ('Rae', '-', '-'),
    ('Nida', 'BNI', '907576031'),
    ('Vica', 'BCA', '4061315386')
) as bank_data(name, bank_name, bank_account_number)
where lower(regexp_replace(tutor.name, '[^a-zA-Z0-9]+', '', 'g')) = lower(regexp_replace(bank_data.name, '[^a-zA-Z0-9]+', '', 'g'))
  and (
    coalesce(tutor.bank_name, '') = ''
    or coalesce(tutor.bank_account_number, '') = ''
    or tutor.bank_name = '-'
    or tutor.bank_account_number = '-'
  );

insert into public.class_meeting_fees (program_name, student_count, fee, is_active)
values
  ('Basic English Course', 1, 45000, true),
  ('Basic English Course', 2, 50000, true),
  ('Basic English Course', 3, 55000, true),
  ('Basic English Course', 4, 60000, true),
  ('Private Speaking Practice', 1, 45000, true),
  ('Private Speaking Practice', 2, 50000, true),
  ('Private Speaking Practice', 3, 55000, true),
  ('Private Speaking Practice', 4, 60000, true),
  ('Private Writing Practice', 1, 45000, true),
  ('Private Writing Practice', 2, 50000, true),
  ('Private Writing Practice', 3, 55000, true),
  ('Private Writing Practice', 4, 60000, true),
  ('English Course for Kids', 1, 50000, true),
  ('English Course for Kids', 2, 55000, true),
  ('English Course for Kids', 3, 60000, true),
  ('English Course for Kids', 4, 65000, true)
on conflict (program_name, student_count)
do update set
  fee = excluded.fee,
  is_active = excluded.is_active,
  updated_at = now();

insert into public.class_tracker (
  booking_id,
  order_date,
  student_name,
  student_count,
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
  booking.student_count,
  booking.program_name,
  booking.tutor,
  0,
  0,
  0,
  0,
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
alter table public.class_meeting_fees enable row level security;
alter table public.class_zoom_bookings enable row level security;

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

drop policy if exists "Class admins can read meeting fees" on public.class_meeting_fees;
drop policy if exists "Class tutors can read active meeting fees" on public.class_meeting_fees;
drop policy if exists "Class admins can insert meeting fees" on public.class_meeting_fees;
drop policy if exists "Class admins can update meeting fees" on public.class_meeting_fees;
drop policy if exists "Class admins can delete meeting fees" on public.class_meeting_fees;

create policy "Class admins can read meeting fees"
on public.class_meeting_fees
for select
to authenticated
using (public.is_class_admin());

create policy "Class tutors can read active meeting fees"
on public.class_meeting_fees
for select
to authenticated
using (is_active = true);

create policy "Class admins can insert meeting fees"
on public.class_meeting_fees
for insert
to authenticated
with check (public.is_class_admin());

create policy "Class admins can update meeting fees"
on public.class_meeting_fees
for update
to authenticated
using (public.is_class_admin())
with check (public.is_class_admin());

create policy "Class admins can delete meeting fees"
on public.class_meeting_fees
for delete
to authenticated
using (public.is_class_admin());

drop policy if exists "Class input users can read zoom bookings" on public.class_zoom_bookings;

create policy "Class input users can read zoom bookings"
on public.class_zoom_bookings
for select
to authenticated
using (public.is_class_admin() or public.is_class_tutor_account());

create or replace function public.create_class_zoom_booking(
  p_booking_date date,
  p_start_time time,
  p_end_time time,
  p_note text default ''
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  current_email text;
  tutor_record public.class_tutors;
  zoom_booking_id uuid;
  zoom_tutor_name text;
begin
  current_email := lower(coalesce(auth.jwt() ->> 'email', ''));

  if current_email = '' then
    raise exception 'Not allowed';
  end if;

  if p_booking_date is null or p_start_time is null or p_end_time is null then
    raise exception 'Tanggal, jam mulai, dan jam selesai wajib diisi';
  end if;

  if p_start_time >= p_end_time then
    raise exception 'Jam selesai harus lebih besar dari jam mulai';
  end if;

  perform pg_advisory_xact_lock(hashtext('class_zoom_bookings:' || p_booking_date::text));

  if (
    select count(*)
    from public.class_zoom_bookings zoom
    where zoom.booking_date = p_booking_date
      and zoom.start_time < p_end_time
      and zoom.end_time > p_start_time
  ) >= 2 then
    raise exception 'Slot Zoom sudah penuh/overlap. Pilihan solusi: Hubungi admin untuk meminta link zoom baru; atau gunakan zoom pribadi (jangan lupa tetap record)';
  end if;

  if public.is_class_admin() then
    zoom_tutor_name := 'Admin';
  else
    select *
    into tutor_record
    from public.class_tutors tutor
    where tutor.is_active = true
      and lower(coalesce(tutor.email, public.class_tutor_email(tutor.name))) = current_email
    limit 1;

    if not found then
      raise exception 'Not allowed';
    end if;

    zoom_tutor_name := tutor_record.name;
  end if;

  insert into public.class_zoom_bookings (
    booking_date,
    start_time,
    end_time,
    tutor_name,
    tutor_email,
    note,
    created_by
  )
  values (
    p_booking_date,
    p_start_time,
    p_end_time,
    zoom_tutor_name,
    current_email,
    coalesce(p_note, ''),
    current_email
  )
  returning id into zoom_booking_id;

  return zoom_booking_id;
end;
$$;

grant execute on function public.create_class_zoom_booking(date, time, time, text) to authenticated;

create or replace function public.delete_class_zoom_booking(
  p_booking_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_email text;
  zoom_record public.class_zoom_bookings;
begin
  current_email := lower(coalesce(auth.jwt() ->> 'email', ''));

  select *
  into zoom_record
  from public.class_zoom_bookings
  where id = p_booking_id;

  if not found then
    raise exception 'Zoom booking not found';
  end if;

  if not (public.is_class_admin() or lower(zoom_record.tutor_email) = current_email) then
    raise exception 'Not allowed';
  end if;

  delete from public.class_zoom_bookings
  where id = p_booking_id;
end;
$$;

grant execute on function public.delete_class_zoom_booking(uuid) to authenticated;

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
