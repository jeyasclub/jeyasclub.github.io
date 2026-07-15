create table if not exists public.accent_test_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  username text,
  test_name text not null default 'American or British Accent Test',
  category text not null,
  american_count integer not null,
  british_count integer not null,
  total_questions integer not null default 20,
  american_percent integer not null,
  british_percent integer not null,
  answers jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.accent_test_review_access (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  source text not null default 'mayar',
  mayar_transaction_id text unique,
  created_at timestamptz not null default now()
);

create table if not exists public.accent_test_result_answers (
  result_id uuid primary key references public.accent_test_results(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  answers jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.accent_test_results enable row level security;
alter table public.accent_test_review_access enable row level security;
alter table public.accent_test_result_answers enable row level security;

grant insert on public.accent_test_results to authenticated;
grant select on public.accent_test_results to authenticated;
grant select on public.accent_test_review_access to authenticated;
grant select, insert on public.accent_test_result_answers to authenticated;

create index if not exists accent_test_results_user_created_idx on public.accent_test_results (user_id, created_at desc);
create index if not exists accent_test_review_access_user_idx on public.accent_test_review_access (user_id, created_at desc);
create index if not exists accent_test_result_answers_user_idx on public.accent_test_result_answers (user_id, created_at desc);

drop policy if exists "Users can insert their own accent test results" on public.accent_test_results;
create policy "Users can insert their own accent test results" on public.accent_test_results
for insert to authenticated with check (user_id = auth.uid());

drop policy if exists "Users can read their own accent test results" on public.accent_test_results;
create policy "Users can read their own accent test results" on public.accent_test_results
for select to authenticated using (user_id = auth.uid());

drop policy if exists "Users can read their own accent test review access" on public.accent_test_review_access;
create policy "Users can read their own accent test review access" on public.accent_test_review_access
for select to authenticated using (user_id = auth.uid());

drop policy if exists "Users can insert their own accent test answer details" on public.accent_test_result_answers;
create policy "Users can insert their own accent test answer details" on public.accent_test_result_answers
for insert to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1 from public.accent_test_results result
    where result.id = result_id and result.user_id = auth.uid()
  )
);

drop policy if exists "Paid users can read their own accent test answer details" on public.accent_test_result_answers;
create policy "Paid users can read their own accent test answer details" on public.accent_test_result_answers
for select to authenticated
using (
  user_id = auth.uid()
  and exists (
    select 1 from public.accent_test_review_access access
    where access.user_id = auth.uid()
  )
);

create or replace function public.grant_accent_test_review_access_by_email(
  p_email text,
  p_transaction_id text default null,
  p_source text default 'mayar'
)
returns jsonb
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  target_user_id uuid;
  normalized_email text;
  inserted_id uuid;
begin
  normalized_email := lower(trim(coalesce(p_email, '')));
  if normalized_email = '' then
    return jsonb_build_object('ok', false, 'reason', 'missing_email');
  end if;

  select id into target_user_id
  from auth.users
  where lower(email) = normalized_email
  order by created_at desc
  limit 1;

  if target_user_id is null then
    return jsonb_build_object('ok', false, 'reason', 'user_not_found', 'email', normalized_email);
  end if;

  insert into public.accent_test_review_access (user_id, email, source, mayar_transaction_id)
  values (
    target_user_id,
    normalized_email,
    coalesce(nullif(trim(p_source), ''), 'mayar'),
    nullif(trim(coalesce(p_transaction_id, '')), '')
  )
  on conflict (mayar_transaction_id) do update set email = excluded.email
  returning id into inserted_id;

  return jsonb_build_object('ok', true, 'access_id', inserted_id, 'user_id', target_user_id, 'email', normalized_email);
end;
$$;

revoke all on function public.grant_accent_test_review_access_by_email(text, text, text) from public;
grant execute on function public.grant_accent_test_review_access_by_email(text, text, text) to service_role;
