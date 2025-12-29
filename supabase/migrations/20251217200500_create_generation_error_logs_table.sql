-- Migration: Create generation_error_logs table
-- Purpose: Track errors during AI flashcard generation for debugging and monitoring
-- Affected tables: generation_error_logs
-- Dependencies: auth.users
-- Special considerations: This is an append-only log table for error tracking

-- create the generation_error_logs table to track ai generation failures
create table public.generation_error_logs (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  model varchar not null,
  source_text_hash varchar not null,
  source_text_length integer not null check (source_text_length between 1000 and 10000),
  error_code varchar(100) not null,
  error_message text not null,
  created_at timestamptz not null default now()
);

-- create index on user_id for efficient querying of user's error logs
create index idx_generation_error_logs_user_id on public.generation_error_logs(user_id);

-- enable row level security on generation_error_logs table
alter table public.generation_error_logs enable row level security;

-- rls policy: allow authenticated users to select their own error logs
-- rationale: users should be able to view their generation errors for troubleshooting
create policy "select_own_error_logs_authenticated"
  on public.generation_error_logs
  for select
  to authenticated
  using (auth.uid() = user_id);

-- rls policy: allow anonymous users to select their own error logs
-- rationale: support for anonymous users who may encounter generation errors
create policy "select_own_error_logs_anon"
  on public.generation_error_logs
  for select
  to anon
  using (auth.uid() = user_id);

-- rls policy: allow authenticated users to insert their own error logs
-- rationale: system can log errors on behalf of authenticated users
create policy "insert_own_error_logs_authenticated"
  on public.generation_error_logs
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- rls policy: allow anonymous users to insert their own error logs
-- rationale: system can log errors on behalf of anonymous users
create policy "insert_own_error_logs_anon"
  on public.generation_error_logs
  for insert
  to anon
  with check (auth.uid() = user_id);

-- note: no update or delete policies for error logs
-- rationale: this is an append-only log table for audit purposes
-- errors should not be modified or deleted by users



