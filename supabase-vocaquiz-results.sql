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

create table if not exists public.vocaquiz_review_access (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  source text not null default 'mayar',
  mayar_transaction_id text unique,
  created_at timestamptz not null default now()
);

create table if not exists public.vocaquiz_result_answers (
  result_id uuid primary key references public.vocaquiz_results(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  answers jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.jeyasclub_course_access (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  course_key text not null,
  source text not null default 'mayar',
  mayar_transaction_id text unique,
  created_at timestamptz not null default now()
);

create table if not exists public.grammar_test_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  username text,
  test_name text not null default 'Grammar Test by Jeya''s Club',
  score integer not null,
  total_point integer not null default 40,
  category text not null,
  correct_count integer not null,
  total_questions integer not null default 40,
  accuracy integer not null,
  category_breakdown jsonb not null default '{}'::jsonb,
  answers jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.grammar_test_review_access (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  source text not null default 'mayar',
  mayar_transaction_id text unique,
  created_at timestamptz not null default now()
);

create table if not exists public.grammar_test_result_answers (
  result_id uuid primary key references public.grammar_test_results(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  answers jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.english_slang_test_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  username text,
  test_name text not null default 'English Slang Test by Jeya''s Club',
  score integer not null,
  total_point integer not null default 25,
  category text not null,
  correct_count integer not null,
  total_questions integer not null default 25,
  accuracy integer not null,
  level_breakdown jsonb not null default '{}'::jsonb,
  answers jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.english_slang_test_review_access (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  source text not null default 'mayar',
  mayar_transaction_id text unique,
  created_at timestamptz not null default now()
);

create table if not exists public.english_slang_test_result_answers (
  result_id uuid primary key references public.english_slang_test_results(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  answers jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.vocaquiz_results
add column if not exists username text;

alter table public.vocaquiz_results
add column if not exists test_name text not null default 'Vocabulary Test by Jeya''s Club';

alter table public.vocaquiz_results enable row level security;
alter table public.vocaquiz_review_access enable row level security;
alter table public.vocaquiz_result_answers enable row level security;
alter table public.jeyasclub_course_access enable row level security;
alter table public.grammar_test_results enable row level security;
alter table public.grammar_test_review_access enable row level security;
alter table public.grammar_test_result_answers enable row level security;
alter table public.english_slang_test_results enable row level security;
alter table public.english_slang_test_review_access enable row level security;
alter table public.english_slang_test_result_answers enable row level security;

revoke select on public.vocaquiz_results from authenticated;
grant insert on public.vocaquiz_results to authenticated;
grant select (
  id,
  user_id,
  email,
  username,
  full_name,
  avatar_url,
  test_name,
  score,
  total_point,
  category,
  correct_count,
  total_questions,
  accuracy,
  level_breakdown,
  created_at
) on public.vocaquiz_results to authenticated;
grant select on public.vocaquiz_review_access to authenticated;
grant select, insert on public.vocaquiz_result_answers to authenticated;
grant select on public.jeyasclub_course_access to authenticated;
grant insert on public.grammar_test_results to authenticated;
grant select (
  id,
  user_id,
  email,
  username,
  test_name,
  score,
  total_point,
  category,
  correct_count,
  total_questions,
  accuracy,
  category_breakdown,
  created_at
) on public.grammar_test_results to authenticated;
grant select on public.grammar_test_review_access to authenticated;
grant select, insert on public.grammar_test_result_answers to authenticated;
grant insert on public.english_slang_test_results to authenticated;
grant select (
  id,
  user_id,
  email,
  username,
  test_name,
  score,
  total_point,
  category,
  correct_count,
  total_questions,
  accuracy,
  level_breakdown,
  created_at
) on public.english_slang_test_results to authenticated;
grant select on public.english_slang_test_review_access to authenticated;
grant select, insert on public.english_slang_test_result_answers to authenticated;

create index if not exists vocaquiz_results_user_created_idx
on public.vocaquiz_results (user_id, created_at desc);

create index if not exists vocaquiz_review_access_user_idx
on public.vocaquiz_review_access (user_id, created_at desc);

create index if not exists vocaquiz_result_answers_user_idx
on public.vocaquiz_result_answers (user_id, created_at desc);

create index if not exists jeyasclub_course_access_user_idx
on public.jeyasclub_course_access (user_id, course_key, created_at desc);

create unique index if not exists jeyasclub_course_access_user_course_key
on public.jeyasclub_course_access (user_id, course_key);

create index if not exists grammar_test_results_user_created_idx
on public.grammar_test_results (user_id, created_at desc);

create index if not exists grammar_test_review_access_user_idx
on public.grammar_test_review_access (user_id, created_at desc);

create index if not exists grammar_test_result_answers_user_idx
on public.grammar_test_result_answers (user_id, created_at desc);

create index if not exists english_slang_test_results_user_created_idx
on public.english_slang_test_results (user_id, created_at desc);

create index if not exists english_slang_test_review_access_user_idx
on public.english_slang_test_review_access (user_id, created_at desc);

create index if not exists english_slang_test_result_answers_user_idx
on public.english_slang_test_result_answers (user_id, created_at desc);

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

drop policy if exists "Users can read their own vocaquiz review access" on public.vocaquiz_review_access;
create policy "Users can read their own vocaquiz review access"
on public.vocaquiz_review_access
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "Users can insert their own vocaquiz answer details" on public.vocaquiz_result_answers;
create policy "Users can insert their own vocaquiz answer details"
on public.vocaquiz_result_answers
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1
    from public.vocaquiz_results result
    where result.id = result_id
      and result.user_id = auth.uid()
  )
);

drop policy if exists "Paid users can read their own vocaquiz answer details" on public.vocaquiz_result_answers;
create policy "Paid users can read their own vocaquiz answer details"
on public.vocaquiz_result_answers
for select
to authenticated
using (
  user_id = auth.uid()
  and exists (
    select 1
    from public.vocaquiz_review_access access
    where access.user_id = auth.uid()
  )
);

drop policy if exists "Users can read their own course access" on public.jeyasclub_course_access;
create policy "Users can read their own course access"
on public.jeyasclub_course_access
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "Users can insert their own grammar test results" on public.grammar_test_results;
create policy "Users can insert their own grammar test results"
on public.grammar_test_results
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users can read their own grammar test results" on public.grammar_test_results;
create policy "Users can read their own grammar test results"
on public.grammar_test_results
for select
to authenticated
using (user_id = auth.uid());

create or replace function public.get_quick_english_test_taker_counts()
returns table (
  test_key text,
  taker_count bigint
)
language sql
stable
security definer
set search_path = public
as $$
  select 'vocabulary'::text as test_key, count(*)::bigint as taker_count
  from public.vocaquiz_results
  union all
  select 'grammar'::text as test_key, count(*)::bigint as taker_count
  from public.grammar_test_results
  union all
  select 'slang'::text as test_key, count(*)::bigint as taker_count
  from public.english_slang_test_results;
$$;

revoke all on function public.get_quick_english_test_taker_counts() from public;
grant execute on function public.get_quick_english_test_taker_counts() to anon, authenticated;

drop policy if exists "Users can read their own grammar test review access" on public.grammar_test_review_access;
create policy "Users can read their own grammar test review access"
on public.grammar_test_review_access
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "Users can insert their own grammar test answer details" on public.grammar_test_result_answers;
create policy "Users can insert their own grammar test answer details"
on public.grammar_test_result_answers
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1
    from public.grammar_test_results result
    where result.id = result_id
      and result.user_id = auth.uid()
  )
);

drop policy if exists "Paid users can read their own grammar test answer details" on public.grammar_test_result_answers;
create policy "Paid users can read their own grammar test answer details"
on public.grammar_test_result_answers
for select
to authenticated
using (
  user_id = auth.uid()
  and exists (
    select 1
    from public.grammar_test_review_access access
    where access.user_id = auth.uid()
  )
);

drop policy if exists "Users can insert their own english slang test results" on public.english_slang_test_results;
create policy "Users can insert their own english slang test results"
on public.english_slang_test_results
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users can read their own english slang test results" on public.english_slang_test_results;
create policy "Users can read their own english slang test results"
on public.english_slang_test_results
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "Users can read their own english slang test review access" on public.english_slang_test_review_access;
create policy "Users can read their own english slang test review access"
on public.english_slang_test_review_access
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "Users can insert their own english slang test answer details" on public.english_slang_test_result_answers;
create policy "Users can insert their own english slang test answer details"
on public.english_slang_test_result_answers
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1
    from public.english_slang_test_results result
    where result.id = result_id
      and result.user_id = auth.uid()
  )
);

drop policy if exists "Paid users can read their own english slang test answer details" on public.english_slang_test_result_answers;
create policy "Paid users can read their own english slang test answer details"
on public.english_slang_test_result_answers
for select
to authenticated
using (
  user_id = auth.uid()
  and exists (
    select 1
    from public.english_slang_test_review_access access
    where access.user_id = auth.uid()
  )
);

create or replace function public.grant_vocaquiz_review_access_by_email(
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

  select id
    into target_user_id
  from auth.users
  where lower(email) = normalized_email
  order by created_at desc
  limit 1;

  if target_user_id is null then
    return jsonb_build_object('ok', false, 'reason', 'user_not_found', 'email', normalized_email);
  end if;

  insert into public.vocaquiz_review_access (
    user_id,
    email,
    source,
    mayar_transaction_id
  )
  values (
    target_user_id,
    normalized_email,
    coalesce(nullif(trim(p_source), ''), 'mayar'),
    nullif(trim(coalesce(p_transaction_id, '')), '')
  )
  on conflict (mayar_transaction_id) do update
  set email = excluded.email
  returning id into inserted_id;

  return jsonb_build_object(
    'ok', true,
    'access_id', inserted_id,
    'user_id', target_user_id,
    'email', normalized_email
  );
end;
$$;

revoke all on function public.grant_vocaquiz_review_access_by_email(text, text, text) from public;
grant execute on function public.grant_vocaquiz_review_access_by_email(text, text, text) to service_role;

create or replace function public.grant_jeyasclub_course_access_by_email(
  p_email text,
  p_course_key text,
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
  normalized_course_key text;
  normalized_transaction_id text;
  inserted_id uuid;
begin
  normalized_email := lower(trim(coalesce(p_email, '')));
  normalized_course_key := lower(trim(coalesce(p_course_key, '')));
  normalized_transaction_id := nullif(trim(coalesce(p_transaction_id, '')), '');

  if normalized_email = '' then
    return jsonb_build_object('ok', false, 'reason', 'missing_email');
  end if;

  if normalized_course_key = '' then
    return jsonb_build_object('ok', false, 'reason', 'missing_course_key');
  end if;

  select id
    into target_user_id
  from auth.users
  where lower(email) = normalized_email
  order by created_at desc
  limit 1;

  if target_user_id is null then
    return jsonb_build_object('ok', false, 'reason', 'user_not_found', 'email', normalized_email);
  end if;

  insert into public.jeyasclub_course_access (
    user_id,
    email,
    course_key,
    source,
    mayar_transaction_id
  )
  values (
    target_user_id,
    normalized_email,
    normalized_course_key,
    coalesce(nullif(trim(p_source), ''), 'mayar'),
    normalized_transaction_id
  )
  on conflict (user_id, course_key) do update
  set
    email = excluded.email,
    source = excluded.source,
    mayar_transaction_id = coalesce(excluded.mayar_transaction_id, public.jeyasclub_course_access.mayar_transaction_id)
  returning id into inserted_id;

  return jsonb_build_object(
    'ok', true,
    'access_id', inserted_id,
    'user_id', target_user_id,
    'email', normalized_email,
    'course_key', normalized_course_key
  );
end;
$$;

revoke all on function public.grant_jeyasclub_course_access_by_email(text, text, text, text) from public;
grant execute on function public.grant_jeyasclub_course_access_by_email(text, text, text, text) to service_role;

create or replace function public.grant_grammar_test_review_access_by_email(
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

  select id
    into target_user_id
  from auth.users
  where lower(email) = normalized_email
  order by created_at desc
  limit 1;

  if target_user_id is null then
    return jsonb_build_object('ok', false, 'reason', 'user_not_found', 'email', normalized_email);
  end if;

  insert into public.grammar_test_review_access (
    user_id,
    email,
    source,
    mayar_transaction_id
  )
  values (
    target_user_id,
    normalized_email,
    coalesce(nullif(trim(p_source), ''), 'mayar'),
    nullif(trim(coalesce(p_transaction_id, '')), '')
  )
  on conflict (mayar_transaction_id) do update
  set email = excluded.email
  returning id into inserted_id;

  return jsonb_build_object(
    'ok', true,
    'access_id', inserted_id,
    'user_id', target_user_id,
    'email', normalized_email
  );
end;
$$;

revoke all on function public.grant_grammar_test_review_access_by_email(text, text, text) from public;
grant execute on function public.grant_grammar_test_review_access_by_email(text, text, text) to service_role;

create or replace function public.grant_english_slang_test_review_access_by_email(
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

  select id
    into target_user_id
  from auth.users
  where lower(email) = normalized_email
  order by created_at desc
  limit 1;

  if target_user_id is null then
    return jsonb_build_object('ok', false, 'reason', 'user_not_found', 'email', normalized_email);
  end if;

  insert into public.english_slang_test_review_access (
    user_id,
    email,
    source,
    mayar_transaction_id
  )
  values (
    target_user_id,
    normalized_email,
    coalesce(nullif(trim(p_source), ''), 'mayar'),
    nullif(trim(coalesce(p_transaction_id, '')), '')
  )
  on conflict (mayar_transaction_id) do update
  set email = excluded.email
  returning id into inserted_id;

  return jsonb_build_object(
    'ok', true,
    'access_id', inserted_id,
    'user_id', target_user_id,
    'email', normalized_email
  );
end;
$$;

revoke all on function public.grant_english_slang_test_review_access_by_email(text, text, text) from public;
grant execute on function public.grant_english_slang_test_review_access_by_email(text, text, text) to service_role;
