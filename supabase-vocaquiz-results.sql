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

create table if not exists public.mayar_product_sales (
  id uuid primary key default gen_random_uuid(),
  product_key text not null,
  product_name text not null,
  customer_email text,
  transaction_id text unique,
  source text not null default 'mayar',
  amount numeric,
  payload jsonb not null default '{}'::jsonb,
  paid_at timestamptz not null default now(),
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
alter table public.mayar_product_sales enable row level security;
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

create index if not exists mayar_product_sales_product_paid_idx
on public.mayar_product_sales (product_key, paid_at desc);

create index if not exists mayar_product_sales_customer_idx
on public.mayar_product_sales (customer_email, paid_at desc);

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

create or replace function public.log_mayar_product_sale(
  p_product_key text,
  p_product_name text,
  p_customer_email text default null,
  p_transaction_id text default null,
  p_amount numeric default null,
  p_payload jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  normalized_product_key text;
  normalized_product_name text;
  normalized_email text;
  normalized_transaction_id text;
  sale_id uuid;
begin
  normalized_product_key := lower(trim(coalesce(p_product_key, '')));
  normalized_product_name := trim(coalesce(p_product_name, ''));
  normalized_email := nullif(lower(trim(coalesce(p_customer_email, ''))), '');
  normalized_transaction_id := nullif(trim(coalesce(p_transaction_id, '')), '');

  if normalized_product_key = '' then
    return jsonb_build_object('ok', false, 'reason', 'missing_product_key');
  end if;

  if normalized_product_name = '' then
    normalized_product_name := normalized_product_key;
  end if;

  insert into public.mayar_product_sales (
    product_key,
    product_name,
    customer_email,
    transaction_id,
    source,
    amount,
    payload
  )
  values (
    normalized_product_key,
    normalized_product_name,
    normalized_email,
    normalized_transaction_id,
    'mayar',
    p_amount,
    coalesce(p_payload, '{}'::jsonb)
  )
  on conflict (transaction_id) do update
  set
    product_key = excluded.product_key,
    product_name = excluded.product_name,
    customer_email = coalesce(excluded.customer_email, public.mayar_product_sales.customer_email),
    amount = coalesce(excluded.amount, public.mayar_product_sales.amount),
    payload = case
      when excluded.payload = '{}'::jsonb then public.mayar_product_sales.payload
      else excluded.payload
    end
  returning id into sale_id;

  return jsonb_build_object(
    'ok', true,
    'sale_id', sale_id,
    'product_key', normalized_product_key
  );
end;
$$;

revoke all on function public.log_mayar_product_sale(text, text, text, text, numeric, jsonb) from public;
grant execute on function public.log_mayar_product_sale(text, text, text, text, numeric, jsonb) to service_role;

create table if not exists public.swe_test_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  username text,
  test_name text not null default 'TOEFL ITP Structure & Written Expressions',
  score integer not null,
  total_point integer not null default 89,
  category text not null,
  correct_count integer not null,
  total_questions integer not null default 40,
  accuracy integer not null,
  category_breakdown jsonb not null default '{}'::jsonb,
  answers jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.swe_test_review_access (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  source text not null default 'mayar',
  mayar_transaction_id text unique,
  created_at timestamptz not null default now()
);

create table if not exists public.swe_test_result_answers (
  result_id uuid primary key references public.swe_test_results(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  answers jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.reading_test_results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  username text,
  test_name text not null default 'TOEFL ITP Reading Comprehension',
  score integer not null,
  total_point integer not null default 95,
  category text not null,
  correct_count integer not null,
  total_questions integer not null default 50,
  accuracy integer not null,
  category_breakdown jsonb not null default '{}'::jsonb,
  answers jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.reading_test_review_access (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  email text,
  source text not null default 'mayar',
  mayar_transaction_id text unique,
  created_at timestamptz not null default now()
);

create table if not exists public.reading_test_result_answers (
  result_id uuid primary key references public.reading_test_results(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  answers jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.swe_test_results enable row level security;
alter table public.swe_test_review_access enable row level security;
alter table public.swe_test_result_answers enable row level security;
alter table public.reading_test_results enable row level security;
alter table public.reading_test_review_access enable row level security;
alter table public.reading_test_result_answers enable row level security;

grant insert on public.swe_test_results to authenticated;
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
  answers,
  created_at
) on public.swe_test_results to authenticated;
grant select on public.swe_test_review_access to authenticated;
grant select, insert on public.swe_test_result_answers to authenticated;
grant insert on public.reading_test_results to authenticated;
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
  answers,
  created_at
) on public.reading_test_results to authenticated;
grant select on public.reading_test_review_access to authenticated;
grant select, insert on public.reading_test_result_answers to authenticated;

create index if not exists swe_test_results_user_created_idx
on public.swe_test_results (user_id, created_at desc);

create index if not exists swe_test_review_access_user_idx
on public.swe_test_review_access (user_id, created_at desc);

create index if not exists swe_test_result_answers_user_idx
on public.swe_test_result_answers (user_id, created_at desc);

create index if not exists reading_test_results_user_created_idx
on public.reading_test_results (user_id, created_at desc);

create index if not exists reading_test_review_access_user_idx
on public.reading_test_review_access (user_id, created_at desc);

create index if not exists reading_test_result_answers_user_idx
on public.reading_test_result_answers (user_id, created_at desc);

drop policy if exists "Users can insert their own swe test results" on public.swe_test_results;
create policy "Users can insert their own swe test results"
on public.swe_test_results
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users can read their own swe test results" on public.swe_test_results;
create policy "Users can read their own swe test results"
on public.swe_test_results
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "Users can read their own swe test review access" on public.swe_test_review_access;
create policy "Users can read their own swe test review access"
on public.swe_test_review_access
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "Users can insert their own swe test answer details" on public.swe_test_result_answers;
create policy "Users can insert their own swe test answer details"
on public.swe_test_result_answers
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1
    from public.swe_test_results result
    where result.id = result_id
      and result.user_id = auth.uid()
  )
);

drop policy if exists "Paid users can read their own swe test answer details" on public.swe_test_result_answers;
create policy "Paid users can read their own swe test answer details"
on public.swe_test_result_answers
for select
to authenticated
using (
  user_id = auth.uid()
  and exists (
    select 1
    from public.swe_test_review_access access
    where access.user_id = auth.uid()
  )
);

drop policy if exists "Users can insert their own reading test results" on public.reading_test_results;
create policy "Users can insert their own reading test results"
on public.reading_test_results
for insert
to authenticated
with check (user_id = auth.uid());

drop policy if exists "Users can read their own reading test results" on public.reading_test_results;
create policy "Users can read their own reading test results"
on public.reading_test_results
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "Users can read their own reading test review access" on public.reading_test_review_access;
create policy "Users can read their own reading test review access"
on public.reading_test_review_access
for select
to authenticated
using (user_id = auth.uid());

drop policy if exists "Users can insert their own reading test answer details" on public.reading_test_result_answers;
create policy "Users can insert their own reading test answer details"
on public.reading_test_result_answers
for insert
to authenticated
with check (
  user_id = auth.uid()
  and exists (
    select 1
    from public.reading_test_results result
    where result.id = result_id
      and result.user_id = auth.uid()
  )
);

drop policy if exists "Paid users can read their own reading test answer details" on public.reading_test_result_answers;
create policy "Paid users can read their own reading test answer details"
on public.reading_test_result_answers
for select
to authenticated
using (
  user_id = auth.uid()
  and exists (
    select 1
    from public.reading_test_review_access access
    where access.user_id = auth.uid()
  )
);

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
  from public.english_slang_test_results
  union all
  select 'swe'::text as test_key, count(*)::bigint as taker_count
  from public.swe_test_results
  union all
  select 'reading'::text as test_key, count(*)::bigint as taker_count
  from public.reading_test_results;
$$;

revoke all on function public.get_quick_english_test_taker_counts() from public;
grant execute on function public.get_quick_english_test_taker_counts() to anon, authenticated;

create or replace function public.grant_swe_test_review_access_by_email(
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

  insert into public.swe_test_review_access (
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

revoke all on function public.grant_swe_test_review_access_by_email(text, text, text) from public;
grant execute on function public.grant_swe_test_review_access_by_email(text, text, text) to service_role;

create or replace function public.grant_reading_test_review_access_by_email(
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

  insert into public.reading_test_review_access (
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

revoke all on function public.grant_reading_test_review_access_by_email(text, text, text) from public;
grant execute on function public.grant_reading_test_review_access_by_email(text, text, text) to service_role;

create or replace function public.get_mayar_product_sale_counts(
  p_start_date date default null,
  p_end_date date default null
)
returns table (
  product_key text,
  product_name text,
  sale_count bigint
)
language sql
stable
security definer
set search_path = public
as $$
  with admin_check as (
    select lower(coalesce(auth.jwt() ->> 'email', '')) in (
      'jihamalia@gmail.com',
      'jeyasclub@gmail.com'
    ) as allowed
  ),
  products(product_key, product_name, sort_order) as (
    values
      ('vocabulary-test', 'Vocabulary Test', 1),
      ('grammar-test', 'Grammar Test', 2),
      ('english-slang-test', 'Slang Test', 3),
      ('swe-test', 'SWE Test', 4),
      ('reading-test', 'Reading Test', 5),
      ('300-toefl-vocabulary', '300 TOEFL Vocabulary', 6),
      ('study-sheet-100-english-challenges', '1001 English Challenges', 7)
  ),
  sale_events as (
    select
      sales.product_key,
      coalesce(nullif(sales.transaction_id, ''), 'logged:' || sales.id::text) as sale_key,
      sales.paid_at as sale_at
    from public.mayar_product_sales sales
    where sales.source = 'mayar'
    union all
    select
      'vocabulary-test'::text as product_key,
      coalesce(nullif(mayar_transaction_id, ''), 'vocabulary-access:' || id::text) as sale_key,
      created_at as sale_at
    from public.vocaquiz_review_access
    where source = 'mayar'
    union all
    select
      'grammar-test'::text,
      coalesce(nullif(mayar_transaction_id, ''), 'grammar-access:' || id::text),
      created_at
    from public.grammar_test_review_access
    where source = 'mayar'
    union all
    select
      'english-slang-test'::text,
      coalesce(nullif(mayar_transaction_id, ''), 'slang-access:' || id::text),
      created_at
    from public.english_slang_test_review_access
    where source = 'mayar'
    union all
    select
      'swe-test'::text,
      coalesce(nullif(mayar_transaction_id, ''), 'swe-access:' || id::text),
      created_at
    from public.swe_test_review_access
    where source = 'mayar'
    union all
    select
      'reading-test'::text,
      coalesce(nullif(mayar_transaction_id, ''), 'reading-access:' || id::text),
      created_at
    from public.reading_test_review_access
    where source = 'mayar'
    union all
    select
      '300-toefl-vocabulary'::text,
      coalesce(nullif(mayar_transaction_id, ''), 'toefl-vocab-access:' || id::text),
      created_at
    from public.jeyasclub_course_access
    where source = 'mayar'
      and course_key = '300-toefl-vocabulary'
    union all
    select
      'study-sheet-100-english-challenges'::text,
      coalesce(nullif(mayar_transaction_id, ''), 'english-challenges-access:' || id::text),
      created_at
    from public.jeyasclub_course_access
    where source = 'mayar'
      and course_key = 'study-sheet-100-english-challenges'
  ),
  sale_counts as (
    select
      sale_events.product_key,
      count(distinct sale_events.sale_key)::bigint as sale_count
    from sale_events
    where (p_start_date is null or sale_events.sale_at >= p_start_date)
      and (p_end_date is null or sale_events.sale_at < p_end_date)
    group by sale_events.product_key
  )
  select
    products.product_key,
    products.product_name,
    coalesce(sale_counts.sale_count, 0)::bigint as sale_count
  from products
  cross join admin_check
  left join sale_counts on sale_counts.product_key = products.product_key
  where admin_check.allowed
  order by products.sort_order;
$$;

revoke all on function public.get_mayar_product_sale_counts(date, date) from public;
grant execute on function public.get_mayar_product_sale_counts(date, date) to authenticated;

create table if not exists public.tanya_jeya_questions (
  id uuid primary key default gen_random_uuid(),
  topic text not null default 'Lainnya',
  question text not null,
  status text not null default 'new',
  answered_at timestamptz,
  created_at timestamptz not null default now(),
  constraint tanya_jeya_questions_topic_length check (char_length(trim(topic)) between 1 and 80),
  constraint tanya_jeya_questions_question_length check (char_length(trim(question)) between 10 and 1200),
  constraint tanya_jeya_questions_status_check check (status in ('new', 'answered', 'archived'))
);

alter table public.tanya_jeya_questions enable row level security;

revoke all on public.tanya_jeya_questions from public;
grant insert (topic, question) on public.tanya_jeya_questions to anon;
grant insert (topic, question) on public.tanya_jeya_questions to authenticated;
grant select, update, delete on public.tanya_jeya_questions to authenticated;

create index if not exists tanya_jeya_questions_created_idx
on public.tanya_jeya_questions (created_at desc);

create index if not exists tanya_jeya_questions_status_created_idx
on public.tanya_jeya_questions (status, created_at desc);

drop policy if exists "Anyone can submit Tanya Jeya anonymously" on public.tanya_jeya_questions;
create policy "Anyone can submit Tanya Jeya anonymously"
on public.tanya_jeya_questions
for insert
to anon, authenticated
with check (
  char_length(trim(topic)) between 1 and 80
  and char_length(trim(question)) between 10 and 1200
  and status = 'new'
  and answered_at is null
);

drop policy if exists "Only Jeya can read Tanya Jeya questions" on public.tanya_jeya_questions;
create policy "Only Jeya can read Tanya Jeya questions"
on public.tanya_jeya_questions
for select
to authenticated
using (lower(coalesce(auth.jwt() ->> 'email', '')) = 'jihamalia@gmail.com');

drop policy if exists "Only Jeya can update Tanya Jeya questions" on public.tanya_jeya_questions;
create policy "Only Jeya can update Tanya Jeya questions"
on public.tanya_jeya_questions
for update
to authenticated
using (lower(coalesce(auth.jwt() ->> 'email', '')) = 'jihamalia@gmail.com')
with check (lower(coalesce(auth.jwt() ->> 'email', '')) = 'jihamalia@gmail.com');

drop policy if exists "Only Jeya can delete Tanya Jeya questions" on public.tanya_jeya_questions;
create policy "Only Jeya can delete Tanya Jeya questions"
on public.tanya_jeya_questions
for delete
to authenticated
using (lower(coalesce(auth.jwt() ->> 'email', '')) = 'jihamalia@gmail.com');
