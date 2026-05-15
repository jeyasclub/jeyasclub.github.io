-- Run this in Supabase SQL Editor to delete every published article.
-- This is destructive and cannot be undone unless you have a database backup.

delete from public.articles
where published = true;
