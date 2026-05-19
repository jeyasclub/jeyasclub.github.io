create table if not exists public.vocaquiz_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  username text,
  full_name text,
  avatar_url text,
  test_name text not null default 'Vocabulary Test by Jeya''s Club',
  score integer not null,
  total_point integer not null default 340,
  category text not null,
  correct_count integer not null,
  total_questions integer not null default 50,
  accuracy integer not null,
  level_breakdown jsonb not null default '{}'::jsonb,
  answers jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.vocaquiz_results
add column if not exists username text;

alter table public.vocaquiz_results
add column if not exists test_name text not null default 'Vocabulary Test by Jeya''s Club';

alter table public.vocaquiz_results enable row level security;

grant select, insert on public.vocaquiz_results to authenticated;

create index if not exists vocaquiz_results_user_created_idx
on public.vocaquiz_results (user_id, created_at desc);

drop policy if exists "Users can insert their own vocaquiz results" on public.vocaquiz_results;
create policy "Users can insert their own vocaquiz results"
on public.vocaquiz_results
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users can read their own vocaquiz results" on public.vocaquiz_results;
create policy "Users can read their own vocaquiz results"
on public.vocaquiz_results
for select
to authenticated
using (user_id = auth.uid());
