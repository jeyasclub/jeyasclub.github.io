-- Run this in Supabase SQL Editor before using manual journal input on /admin/finance-2/.
-- Requires supabase-class-admin.sql and supabase-vocaquiz-results.sql to be applied first.
-- Safe to run more than once.

create or replace function public.is_finance_admin()
returns boolean
language sql
stable
as $$
  select lower(coalesce(auth.jwt() ->> 'email', '')) in (
    'jihamalia@gmail.com',
    'jeyasclub@gmail.com'
  );
$$;

-- A journal entry is valid when it has at least two lines, every line posts to
-- exactly one side (debit or credit), and total debit equals total credit.
create or replace function public.finance_journal_lines_valid(p_lines jsonb)
returns boolean
language plpgsql
immutable
as $$
declare
  line jsonb;
  line_debit numeric;
  line_credit numeric;
  total_debit numeric := 0;
  total_credit numeric := 0;
begin
  if p_lines is null or jsonb_typeof(p_lines) <> 'array' then
    return false;
  end if;

  if jsonb_array_length(p_lines) < 2 then
    return false;
  end if;

  for line in select value from jsonb_array_elements(p_lines) loop
    if jsonb_typeof(line) <> 'object' then
      return false;
    end if;

    if coalesce(line ->> 'account_code', '') !~ '^[1-5][0-9]{3}$' then
      return false;
    end if;

    line_debit := coalesce((line ->> 'debit')::numeric, 0);
    line_credit := coalesce((line ->> 'credit')::numeric, 0);

    if line_debit < 0 or line_credit < 0 then
      return false;
    end if;

    if (line_debit > 0) = (line_credit > 0) then
      return false;
    end if;

    total_debit := total_debit + line_debit;
    total_credit := total_credit + line_credit;
  end loop;

  return total_debit = total_credit and total_debit > 0;
exception
  when others then
    return false;
end;
$$;

-- Chart of accounts. The first digit of the code follows the account type:
-- 1 asset, 2 liability, 3 equity, 4 revenue, 5 expense.
create table if not exists public.finance_accounts (
  code text primary key,
  name text not null,
  account_type text not null,
  is_system boolean not null default false,
  is_active boolean not null default true,
  created_by text not null default lower(coalesce(auth.jwt() ->> 'email', '')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint finance_accounts_code_format check (code ~ '^[1-5][0-9]{3}$'),
  constraint finance_accounts_name_length check (char_length(trim(name)) between 1 and 80),
  constraint finance_accounts_type_matches_code check (
    (left(code, 1) = '1' and account_type = 'asset')
    or (left(code, 1) = '2' and account_type = 'liability')
    or (left(code, 1) = '3' and account_type = 'equity')
    or (left(code, 1) = '4' and account_type = 'revenue')
    or (left(code, 1) = '5' and account_type = 'expense')
  )
);

-- General journal. Each line is {"account_code": "1101", "debit": 0, "credit": 0, "memo": ""}.
create table if not exists public.finance_journal_entries (
  id uuid primary key default gen_random_uuid(),
  entry_date date not null default current_date,
  description text not null default '',
  reference text not null default '',
  lines jsonb not null,
  created_by text not null default lower(coalesce(auth.jwt() ->> 'email', '')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint finance_journal_entries_description_length check (char_length(description) <= 500),
  constraint finance_journal_entries_reference_length check (char_length(reference) <= 120),
  constraint finance_journal_entries_lines_valid check (public.finance_journal_lines_valid(lines))
);

create index if not exists finance_journal_entries_entry_date_idx
on public.finance_journal_entries (entry_date);

-- Accounts marked is_system are the ones the automatic journal on /admin/finance-2/ posts to.
insert into public.finance_accounts (code, name, account_type, is_system)
values
  ('1101', 'Cash & Bank', 'asset', true),
  ('1102', 'Accounts Receivable', 'asset', false),
  ('2101', 'Tutor Fee Payable', 'liability', true),
  ('2102', 'Other Payables', 'liability', false),
  ('2201', 'Unearned Revenue', 'liability', true),
  ('3101', 'Owner''s Capital', 'equity', false),
  ('3201', 'Owner''s Drawings', 'equity', false),
  ('4101', 'Course Revenue', 'revenue', true),
  ('4102', 'Expired Session Revenue', 'revenue', true),
  ('4201', 'Digital Product Revenue', 'revenue', true),
  ('4901', 'Other Income', 'revenue', true),
  ('5101', 'Tutor Fee Expense', 'expense', true),
  ('5102', 'Salary Expense', 'expense', true),
  ('5201', 'Marketing Expense', 'expense', false),
  ('5202', 'Tools & Subscriptions Expense', 'expense', false),
  ('5203', 'Admin & Payment Gateway Expense', 'expense', false),
  ('5901', 'Other Expenses', 'expense', true)
on conflict (code) do nothing;

-- Earlier versions seeded Indonesian account names. Rename them to English,
-- but only where the name was never changed by hand.
update public.finance_accounts account
set name = renamed.new_name, updated_at = now()
from (
  values
    ('1101', 'Kas & Bank', 'Cash & Bank'),
    ('1102', 'Piutang Usaha', 'Accounts Receivable'),
    ('2101', 'Utang Fee Tutor', 'Tutor Fee Payable'),
    ('2102', 'Utang Lain-lain', 'Other Payables'),
    ('3101', 'Modal Pemilik', 'Owner''s Capital'),
    ('3201', 'Prive', 'Owner''s Drawings'),
    ('4102', 'Pendapatan Sesi Hangus', 'Expired Session Revenue'),
    ('4901', 'Pendapatan Lain-lain', 'Other Income'),
    ('5101', 'Beban Fee Tutor', 'Tutor Fee Expense'),
    ('5102', 'Beban Gaji', 'Salary Expense'),
    ('5201', 'Beban Marketing', 'Marketing Expense'),
    ('5202', 'Beban Tools & Langganan', 'Tools & Subscriptions Expense'),
    ('5203', 'Beban Admin & Payment Gateway', 'Admin & Payment Gateway Expense'),
    ('5901', 'Beban Lain-lain', 'Other Expenses')
) as renamed(code, old_name, new_name)
where account.code = renamed.code
  and account.name = renamed.old_name;

alter table public.finance_accounts enable row level security;
alter table public.finance_journal_entries enable row level security;

revoke all on public.finance_accounts from anon, authenticated;
revoke all on public.finance_journal_entries from anon, authenticated;

-- Code, type, and the system flag cannot be changed from the page, only the name and active status.
grant select, insert, delete on public.finance_accounts to authenticated;
grant update (name, is_active, updated_at) on public.finance_accounts to authenticated;
grant select, insert, update, delete on public.finance_journal_entries to authenticated;

drop policy if exists "Finance admins can read accounts" on public.finance_accounts;
drop policy if exists "Finance admins can insert accounts" on public.finance_accounts;
drop policy if exists "Finance admins can update accounts" on public.finance_accounts;
drop policy if exists "Finance admins can delete accounts" on public.finance_accounts;

create policy "Finance admins can read accounts"
on public.finance_accounts
for select
to authenticated
using (public.is_finance_admin());

create policy "Finance admins can insert accounts"
on public.finance_accounts
for insert
to authenticated
with check (public.is_finance_admin() and is_system = false);

create policy "Finance admins can update accounts"
on public.finance_accounts
for update
to authenticated
using (public.is_finance_admin())
with check (public.is_finance_admin());

create policy "Finance admins can delete accounts"
on public.finance_accounts
for delete
to authenticated
using (public.is_finance_admin() and is_system = false);

drop policy if exists "Finance admins can read journal entries" on public.finance_journal_entries;
drop policy if exists "Finance admins can insert journal entries" on public.finance_journal_entries;
drop policy if exists "Finance admins can update journal entries" on public.finance_journal_entries;
drop policy if exists "Finance admins can delete journal entries" on public.finance_journal_entries;

create policy "Finance admins can read journal entries"
on public.finance_journal_entries
for select
to authenticated
using (public.is_finance_admin());

create policy "Finance admins can insert journal entries"
on public.finance_journal_entries
for insert
to authenticated
with check (public.is_finance_admin());

create policy "Finance admins can update journal entries"
on public.finance_journal_entries
for update
to authenticated
using (public.is_finance_admin())
with check (public.is_finance_admin());

create policy "Finance admins can delete journal entries"
on public.finance_journal_entries
for delete
to authenticated
using (public.is_finance_admin());

-- Keep journal and account changes in the same activity history as the other admin tables.
do $$
begin
  if to_regprocedure('public.log_class_activity()') is not null then
    drop trigger if exists log_finance_journal_entries_activity on public.finance_journal_entries;
    create trigger log_finance_journal_entries_activity
    after insert or update or delete on public.finance_journal_entries
    for each row execute function public.log_class_activity();

    drop trigger if exists log_finance_accounts_activity on public.finance_accounts;
    create trigger log_finance_accounts_activity
    after insert or update or delete on public.finance_accounts
    for each row execute function public.log_class_activity();
  end if;
end;
$$;

-- Digital product sale counts split per month, so revenue can be recognized in the month of sale.
-- It reuses get_mayar_product_sale_counts, which does its own admin check.
create or replace function public.get_mayar_product_sale_counts_monthly(
  p_start_month date,
  p_end_month date
)
returns table (
  sale_month date,
  product_key text,
  product_name text,
  sale_count bigint
)
language sql
stable
set search_path = public
as $$
  select
    months.month_start::date as sale_month,
    counts.product_key,
    counts.product_name,
    counts.sale_count
  from generate_series(
    date_trunc('month', p_start_month::timestamp),
    date_trunc('month', p_end_month::timestamp),
    interval '1 month'
  ) as months(month_start)
  cross join lateral public.get_mayar_product_sale_counts(
    months.month_start::date,
    (months.month_start + interval '1 month')::date
  ) as counts
  where counts.sale_count > 0
  order by months.month_start, counts.product_key;
$$;

revoke all on function public.get_mayar_product_sale_counts_monthly(date, date) from public;
grant execute on function public.get_mayar_product_sale_counts_monthly(date, date) to authenticated;
