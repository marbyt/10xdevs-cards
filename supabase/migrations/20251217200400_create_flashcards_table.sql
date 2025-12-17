-- Migration: Create flashcards table
-- Purpose: Store user flashcards with front/back content and generation metadata
-- Affected tables: flashcards
-- Dependencies: auth.users, public.generations
-- Special considerations: References generations table with ON DELETE SET NULL to preserve flashcards when generation is deleted

-- create the flashcards table to store user's flashcard content
create table public.flashcards (
  id bigserial primary key,
  front varchar(200) not null,
  back varchar(500) not null,
  source varchar not null check (source in ('ai-full', 'ai-edited', 'manual')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  generation_id bigint references public.generations(id) on delete set null,
  user_id uuid not null references auth.users(id) on delete cascade
);

-- create index on user_id for efficient querying of user's flashcards
create index idx_flashcards_user_id on public.flashcards(user_id);

-- create index on generation_id for efficient querying of flashcards by generation
create index idx_flashcards_generation_id on public.flashcards(generation_id);

-- enable row level security on flashcards table
alter table public.flashcards enable row level security;

-- rls policy: allow authenticated users to select their own flashcards
-- rationale: users should only see their own flashcards for privacy
create policy "select_own_flashcards_authenticated"
  on public.flashcards
  for select
  to authenticated
  using (auth.uid() = user_id);

-- rls policy: allow anonymous users to select their own flashcards
-- rationale: support for anonymous users who may create flashcards without account
create policy "select_own_flashcards_anon"
  on public.flashcards
  for select
  to anon
  using (auth.uid() = user_id);

-- rls policy: allow authenticated users to insert their own flashcards
-- rationale: users can create new flashcards manually or accept ai-generated ones
create policy "insert_own_flashcards_authenticated"
  on public.flashcards
  for insert
  to authenticated
  with check (auth.uid() = user_id);

-- rls policy: allow anonymous users to insert their own flashcards
-- rationale: support for anonymous users who may create flashcards without account
create policy "insert_own_flashcards_anon"
  on public.flashcards
  for insert
  to anon
  with check (auth.uid() = user_id);

-- rls policy: allow authenticated users to update their own flashcards
-- rationale: users can edit flashcard content, including ai-generated cards
create policy "update_own_flashcards_authenticated"
  on public.flashcards
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- rls policy: allow anonymous users to update their own flashcards
-- rationale: support for anonymous users who may edit their flashcards
create policy "update_own_flashcards_anon"
  on public.flashcards
  for update
  to anon
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- rls policy: allow authenticated users to delete their own flashcards
-- rationale: users can remove flashcards they no longer need
create policy "delete_own_flashcards_authenticated"
  on public.flashcards
  for delete
  to authenticated
  using (auth.uid() = user_id);

-- rls policy: allow anonymous users to delete their own flashcards
-- rationale: support for anonymous users who may want to remove flashcards
create policy "delete_own_flashcards_anon"
  on public.flashcards
  for delete
  to anon
  using (auth.uid() = user_id);

-- create trigger to automatically update updated_at on flashcards table
-- note: reuses the handle_updated_at() function created in previous migration
create trigger set_updated_at
  before update on public.flashcards
  for each row
  execute function public.handle_updated_at();

