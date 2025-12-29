-- Migration: Create generations table
-- Purpose: Store AI generation metadata for flashcard creation
-- Affected tables: generations
-- Dependencies: auth.users (managed by Supabase Auth)
-- Special considerations: This table must be created before flashcards due to foreign key dependency

-- create the generations table to track ai generation sessions
create table public.generations (
  id bigserial primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  model varchar not null,
  generated_count integer not null,
  accepted_unedited_count integer,
  accepted_edited_count integer,
  source_text_hash varchar not null,
  source_text_length integer not null check (source_text_length between 1000 and 10000),
  generation_duration integer not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- create index on user_id for efficient querying of user's generations
create index idx_generations_user_id on public.generations(user_id);

-- enable row level security on generations table
alter table public.generations enable row level security;

-- rls policy: allow authenticated users to select their own generation records
-- rationale: users should only see their own generation history
create policy "select_own_generations_authenticated"
  on public.generations
  for select
  to authenticated
  using (auth.uid() = user_id);

-- rls policy: allow anonymous users to select their own generation records
-- rationale: support for anonymous users who may generate flashcards without account
create policy "select_own_generations_anon"
  on public.generations
  for select
  to anon
  using (auth.uid() = user_id);

-- rls policy: allow authenticated users to insert their own generation records
-- rationale: users can create new generation records when generating flashcards
create policy "insert_own_generations_authenticated"
  on public.generations
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- rls policy: allow anonymous users to insert their own generation records
-- rationale: support for anonymous users who may generate flashcards without account
create policy "insert_own_generations_anon"
  on public.generations
  for insert
  to anon
  with check (auth.uid() = user_id);

-- rls policy: allow authenticated users to update their own generation records
-- rationale: users can update accepted counts after reviewing generated flashcards
create policy "update_own_generations_authenticated"
  on public.generations
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- rls policy: allow anonymous users to update their own generation records
-- rationale: support for anonymous users who may update generation metadata
create policy "update_own_generations_anon"
  on public.generations
  for update
  to anon
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- rls policy: allow authenticated users to delete their own generation records
-- rationale: users can remove their generation history if desired
create policy "delete_own_generations_authenticated"
  on public.generations
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- rls policy: allow anonymous users to delete their own generation records
-- rationale: support for anonymous users who may want to remove generation history
create policy "delete_own_generations_anon"
  on public.generations
  for delete
  to anon
  using (auth.uid() = user_id);

-- create function to automatically update updated_at timestamp
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- create trigger to automatically update updated_at on generations table
create trigger set_updated_at
  before update on public.generations
  for each row
  execute function public.handle_updated_at();



