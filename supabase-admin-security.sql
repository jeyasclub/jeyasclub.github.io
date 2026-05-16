-- Run this in Supabase SQL Editor after creating the admin Auth user.
-- Admin emails must match the emails in artikel/dashboard/index.html adminUsers.

create or replace function public.is_article_admin()
returns boolean
language sql
stable
as $$
  select (auth.jwt() ->> 'email') in (
    'jeyasclub@gmail.com',
    'jihamalia@gmail.com',
    'ainworks234@gmail.com',
    'novahida@gmail.com',
    'thatonefatchicken@gmail.com',
    'nikola.tieko@gmail.com'
  );
$$;

create or replace function public.is_article_super_admin()
returns boolean
language sql
stable
as $$
  select (auth.jwt() ->> 'email') = 'jeyasclub@gmail.com';
$$;

alter table public.articles enable row level security;

alter table public.articles
add column if not exists author_email text,
add column if not exists author_name text,
add column if not exists author_avatar text;

create table if not exists public.article_admin_profiles (
  email text primary key,
  username text unique,
  display_name text not null,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.article_admin_profiles enable row level security;

drop policy if exists "Admin profiles are publicly readable" on public.article_admin_profiles;
drop policy if exists "Admins can insert their own profile" on public.article_admin_profiles;
drop policy if exists "Admins can update their own profile" on public.article_admin_profiles;

create policy "Admin profiles are publicly readable"
on public.article_admin_profiles
for select
to anon, authenticated
using (true);

create policy "Admins can insert their own profile"
on public.article_admin_profiles
for insert
to authenticated
with check (
  public.is_article_admin()
  and email = (auth.jwt() ->> 'email')
);

create policy "Admins can update their own profile"
on public.article_admin_profiles
for update
to authenticated
using (
  public.is_article_admin()
  and email = (auth.jwt() ->> 'email')
)
with check (
  public.is_article_admin()
  and email = (auth.jwt() ->> 'email')
);

drop policy if exists "Public can read published articles" on public.articles;
drop policy if exists "Public can insert articles" on public.articles;
drop policy if exists "Admin can insert articles" on public.articles;
drop policy if exists "Admin can update articles" on public.articles;
drop policy if exists "Admin can delete articles" on public.articles;

create policy "Public can read published articles"
on public.articles
for select
to anon, authenticated
using (published = true);

create policy "Admin can insert articles"
on public.articles
for insert
to authenticated
with check (
  public.is_article_admin()
  and author_email = (auth.jwt() ->> 'email')
);

create policy "Admin can update articles"
on public.articles
for update
to authenticated
using (
  public.is_article_super_admin()
  or (
    public.is_article_admin()
    and author_email = (auth.jwt() ->> 'email')
  )
)
with check (
  public.is_article_super_admin()
  or (
    public.is_article_admin()
    and author_email = (auth.jwt() ->> 'email')
  )
);

create policy "Admin can delete articles"
on public.articles
for delete
to authenticated
using (
  public.is_article_super_admin()
  or (
    public.is_article_admin()
    and author_email = (auth.jwt() ->> 'email')
  )
);

drop policy if exists "Public can read article images" on storage.objects;
drop policy if exists "Public can upload article images" on storage.objects;
drop policy if exists "Admin can upload article images" on storage.objects;
drop policy if exists "Admin can update article images" on storage.objects;
drop policy if exists "Admin can delete article images" on storage.objects;

create policy "Public can read article images"
on storage.objects
for select
to anon, authenticated
using (bucket_id = 'article-images');

create policy "Admin can upload article images"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'article-images'
  and public.is_article_admin()
);

create policy "Admin can update article images"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'article-images'
  and public.is_article_admin()
)
with check (
  bucket_id = 'article-images'
  and public.is_article_admin()
);

create policy "Admin can delete article images"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'article-images'
  and public.is_article_admin()
);
