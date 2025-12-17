-- Migration: Disable all RLS policies
-- Purpose: Remove all Row Level Security policies from flashcards, generations, and generation_error_logs tables
-- Affected tables: flashcards, generations, generation_error_logs
-- Special considerations: This is a destructive operation that removes access control policies
-- WARNING: After this migration, RLS will still be enabled but no policies will exist,
--          effectively blocking all access. You may want to disable RLS entirely or create new policies.

-- ============================================================================
-- Drop all policies from generations table
-- ============================================================================

-- drop select policies for generations
drop policy if exists "select_own_generations_authenticated" on public.generations;
drop policy if exists "select_own_generations_anon" on public.generations;

-- drop insert policies for generations
drop policy if exists "insert_own_generations_authenticated" on public.generations;
drop policy if exists "insert_own_generations_anon" on public.generations;

-- drop update policies for generations
drop policy if exists "update_own_generations_authenticated" on public.generations;
drop policy if exists "update_own_generations_anon" on public.generations;

-- drop delete policies for generations
drop policy if exists "delete_own_generations_authenticated" on public.generations;
drop policy if exists "delete_own_generations_anon" on public.generations;

-- ============================================================================
-- Drop all policies from flashcards table
-- ============================================================================

-- drop select policies for flashcards
drop policy if exists "select_own_flashcards_authenticated" on public.flashcards;
drop policy if exists "select_own_flashcards_anon" on public.flashcards;

-- drop insert policies for flashcards
drop policy if exists "insert_own_flashcards_authenticated" on public.flashcards;
drop policy if exists "insert_own_flashcards_anon" on public.flashcards;

-- drop update policies for flashcards
drop policy if exists "update_own_flashcards_authenticated" on public.flashcards;
drop policy if exists "update_own_flashcards_anon" on public.flashcards;

-- drop delete policies for flashcards
drop policy if exists "delete_own_flashcards_authenticated" on public.flashcards;
drop policy if exists "delete_own_flashcards_anon" on public.flashcards;

-- ============================================================================
-- Drop all policies from generation_error_logs table
-- ============================================================================

-- drop select policies for generation_error_logs
drop policy if exists "select_own_error_logs_authenticated" on public.generation_error_logs;
drop policy if exists "select_own_error_logs_anon" on public.generation_error_logs;

-- drop insert policies for generation_error_logs
drop policy if exists "insert_own_error_logs_authenticated" on public.generation_error_logs;
drop policy if exists "insert_own_error_logs_anon" on public.generation_error_logs;

-- ============================================================================
-- Note: RLS is still ENABLED on these tables
-- ============================================================================
-- With RLS enabled but no policies, all access will be blocked by default.
-- If you want to allow unrestricted access, you would need to either:
-- 1. Disable RLS entirely with: ALTER TABLE table_name DISABLE ROW LEVEL SECURITY;
-- 2. Create permissive policies that allow access

